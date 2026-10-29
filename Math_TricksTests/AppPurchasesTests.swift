import XCTest
import StoreKitTest
import UIKit
@testable import Math_Tricks

@MainActor
final class AppPurchasesTests: XCTestCase {
    func testProButtonIconsCanBeRestored() {
        let button = AppButton(title: "PRO", icon: .noAds, trailingIcon: .pro, kind: .compact, action: {})
        let originalWidth = button.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width
        button.setIconsHidden(true)
        XCTAssertLessThan(button.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width, originalWidth)
        button.setIconsHidden(false)
        XCTAssertEqual(button.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width, originalWidth, accuracy: 0.5)
    }

    func testFullVersionEntitlementAndRefund() async throws {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "FullVersion", withExtension: "storekit"))
        let session = try SKTestSession(contentsOf: url)
        session.disableDialogs = true
        session.clearTransactions()
        defer { session.clearTransactions() }
        let purchases = AppPurchases()
        let loadedProduct = try await purchases.loadFullVersionProduct()
        let product = try XCTUnwrap(loadedProduct)
        XCTAssertEqual(purchases.fullVersionPrice, product.displayPrice)
        await purchases.refreshEntitlements()
        XCTAssertTrue(purchases.isReady)
        XCTAssertFalse(purchases.hasFullVersion)

        try session.buyProduct(productIdentifier: AppPurchases.fullVersionID)
        await purchases.refreshEntitlements()
        XCTAssertTrue(purchases.hasFullVersion)

        // A new manager restores access from StoreKit without a local paid flag.
        let restored = AppPurchases()
        await restored.refreshEntitlements()
        XCTAssertTrue(restored.hasFullVersion)

        let transaction = try XCTUnwrap(session.allTransactions().first)
        try session.refundTransaction(identifier: transaction.identifier)
        await restored.refreshEntitlements()
        XCTAssertFalse(restored.hasFullVersion)
    }
}
