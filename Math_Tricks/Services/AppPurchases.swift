import StoreKit
import UIKit

@MainActor
final class AppPurchases {
    static let shared = AppPurchases()
    static let changed = Notification.Name("AppPurchasesChanged")
    static let fullVersionID = "remove_ads_v1"
    private var purchasedFullVersion = false
    var hasFullVersion: Bool { AppConstants.simulatePro || purchasedFullVersion }
    private(set) var isReady = false
    private var fullVersionProduct: Product?
    var fullVersionPrice: String? { fullVersionProduct?.displayPrice }
    private var updates: Task<Void, Never>?
    private var busy = false
    private var entitlementRefresh: (id: UUID, task: Task<Void, Never>)?
    private var revokedTransactionIDs = Set<UInt64>()

    static func text(_ key: String) -> String { CatalogText.ui(key) }

    func start() {
        guard updates == nil else { return }
        updates = Task { [weak self] in
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result,
                      transaction.productID == Self.fullVersionID,
                      transaction.productType == .nonConsumable else { continue }
                guard let self else { return }
                log(transaction, reason: "update")
                if transaction.revocationDate != nil { revokedTransactionIDs.insert(transaction.id) }
                else { revokedTransactionIDs.remove(transaction.id) }
                await refreshEntitlements(reason: "update")
                await transaction.finish()
            }
        }
        Task {
            await refreshEntitlements(reason: "startup")
            for await result in Transaction.unfinished {
                guard case .verified(let transaction) = result,
                      transaction.productID == Self.fullVersionID else { continue }
                await transaction.finish()
            }
            _ = try? await loadFullVersionProduct()
        }
    }

    @discardableResult
    func loadFullVersionProduct() async throws -> Product? {
        let product = try await Product.products(for: [Self.fullVersionID]).first
        let available = product?.type == .nonConsumable ? product : nil
        let priceChanged = fullVersionPrice != available?.displayPrice
        fullVersionProduct = available
        if priceChanged { NotificationCenter.default.post(name: Self.changed, object: self) }
        return available
    }

    func refreshEntitlements(reason: String = "refresh") async {
        let id = UUID()
        let previous = entitlementRefresh?.task
        // Serialize checks so every caller waits for its own fresh StoreKit result.
        let task = Task {
            await previous?.value
            await self.readEntitlements(reason: reason)
        }
        entitlementRefresh = (id, task)
        await task.value
        if entitlementRefresh?.id == id { entitlementRefresh = nil }
    }

    private func readEntitlements(reason: String) async {
        var entitledTransactionIDs = Set<UInt64>()
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                guard transaction.productID == Self.fullVersionID,
                      transaction.productType == .nonConsumable else { continue }
                log(transaction, reason: reason)
                if transaction.revocationDate != nil { revokedTransactionIDs.insert(transaction.id) }
                if transaction.revocationDate == nil { entitledTransactionIDs.insert(transaction.id) }
            case .unverified(let transaction, let error):
                guard transaction.productID == Self.fullVersionID else { continue }
                #if DEBUG
                NSLog("StoreKit PRO [%@]: unverified transaction=%@ error=%@", reason, String(transaction.id), error.localizedDescription)
                #endif
            }
        }
        let purchased = !entitledTransactionIDs.subtracting(revokedTransactionIDs).isEmpty
        let changed = !isReady || purchasedFullVersion != purchased
        purchasedFullVersion = purchased
        isReady = true
        #if DEBUG
        NSLog("StoreKit PRO [%@]: purchased=%@ simulatePro=%@", reason, String(purchased), String(AppConstants.simulatePro))
        #endif
        if changed { NotificationCenter.default.post(name: Self.changed, object: self) }
    }

    private func log(_ transaction: Transaction, reason: String) {
        #if DEBUG
        let environment: String
        if #available(iOS 16.0, *) { environment = transaction.environment.rawValue }
        else { environment = transaction.environmentStringRepresentation }
        NSLog("StoreKit PRO [%@]: environment=%@ transaction=%@ purchasedAt=%@ revokedAt=%@", reason,
              environment, String(transaction.id), transaction.purchaseDate.description,
              transaction.revocationDate?.description ?? "none")
        #endif
    }

    func present(from presenter: UIViewController, data: AppDataStore) {
        guard !busy, presenter.presentedViewController == nil else { return }
        busy = true
        Task { [weak presenter] in
            defer { busy = false }
            await refreshEntitlements(reason: "dialog")
            var product: Product?
            if !hasFullVersion { product = try? await loadFullVersionProduct() }
            guard let presenter, presenter.viewIfLoaded?.window != nil, presenter.presentedViewController == nil else { return }
            var actions: [AppDialogViewController.Action] = []
            if let product, product.type == .nonConsumable, !hasFullVersion {
                actions.append(.init(title: Self.text("pro.buy") + " · " + product.displayPrice, handler: { [weak presenter] in
                    guard let presenter else { return }
                    self.purchase(product, from: presenter, data: data)
                }))
            }
            actions.append(.init(title: Self.text("pro.close"), handler: {}))
            actions.append(.init(title: Self.text("pro.restore"), handler: { [weak presenter] in
                guard let presenter else { return }
                self.restore(from: presenter, data: data)
            }, isSecondary: true))
            let message = hasFullVersion ? Self.text("pro.active") : Self.text("pro.benefits") + (product == nil ? "\n\n" + Self.text("pro.unavailable") : "")
            presenter.present(AppDialogViewController(title: Self.text("pro.title"), message: message, actions: actions, data: data), animated: false)
        }
    }

    private func purchase(_ product: Product, from presenter: UIViewController, data: AppDataStore) {
        guard !busy else { return }
        busy = true
        Task {
            defer { busy = false }
            do {
                switch try await product.purchase() {
                case .success(let result):
                    guard case .verified(let transaction) = result,
                          transaction.productID == Self.fullVersionID,
                          transaction.productType == .nonConsumable else {
                        show("pro.verification_error", from: presenter, data: data)
                        return
                    }
                    await refreshEntitlements(reason: "purchase")
                    await transaction.finish()
                    show(hasFullVersion ? "pro.active" : "pro.verification_error", from: presenter, data: data)
                case .pending: show("pro.pending", from: presenter, data: data)
                case .userCancelled: break
                @unknown default: show("pro.error", from: presenter, data: data)
                }
            } catch { show("pro.error", from: presenter, data: data) }
        }
    }

    private func restore(from presenter: UIViewController, data: AppDataStore) {
        guard !busy else { return }
        busy = true
        Task {
            defer { busy = false }
            do {
                #if DEBUG
                NSLog("StoreKit PRO [restore]: sync started")
                #endif
                try await AppStore.sync()
                await refreshEntitlements(reason: "restore")
                show(hasFullVersion ? "pro.active" : "pro.not_found", from: presenter, data: data)
            } catch {
                #if DEBUG
                NSLog("StoreKit PRO [restore]: sync failed: %@", error.localizedDescription)
                #endif
                show("pro.error", from: presenter, data: data)
            }
        }
    }

    private func show(_ key: String, from presenter: UIViewController, data: AppDataStore) {
        guard presenter.viewIfLoaded?.window != nil, presenter.presentedViewController == nil else { return }
        presenter.present(AppDialogViewController(title: Self.text("pro.title"), message: Self.text(key),
            actions: [.init(title: MainText.text("ok"), handler: {})], data: data), animated: false)
    }
}
