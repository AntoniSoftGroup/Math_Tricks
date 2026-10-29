import UIKit
import UniformTypeIdentifiers

extension CloudViewController: UIDocumentPickerDelegate {
    func buildFileSection(in column: UIStackView) {
        column.addArrangedSubview(label(CloudText.text("filesTitle"),role:.settingsTitle))
        let native = button(CloudText.text("fileNative"),icon:.exportFile) { [weak self] in self?.exportFile(android:false) }
        let save = button(CloudText.text("fileSave"),icon:.exportFile) { [weak self] in self?.exportFile(android:true) }
        let restore = button(CloudText.text("fileRestore"),icon:.importFile) { [weak self] in self?.chooseFile() }
        native.accessibilityIdentifier = "progress.fileSaveIOS"
        save.accessibilityIdentifier = "progress.fileSave"
        restore.accessibilityIdentifier = "progress.fileRestore"
        for item in [native,save,restore] {
            item.label.role = .detail; item.label.numberOfLines = 0
            item.setContentInsets(UIEdgeInsets(top:4,left:12,bottom:4,right:8),minimumHeight:44)
        }
        let row = UIStackView(arrangedSubviews:[native,save]); row.axis = .horizontal; row.distribution = .fillEqually; row.spacing = 8
        column.addArrangedSubview(row)
        column.addArrangedSubview(restore)
        column.addArrangedSubview(label(CloudText.text("fileSummary"),role:.caption))
        fileStatus.numberOfLines = 0; fileStatus.isHidden = true
        themedLabels.append(fileStatus); column.addArrangedSubview(fileStatus)
    }

    private func finishFileOperation(_ statusKey: String? = nil) {
        importingPicker = nil; pendingArchive = nil; choosingRevision = nil; pendingFileIsNative = false
        fileStatus.text = statusKey.map(CloudText.text); fileStatus.isHidden = statusKey == nil
        CloudSync.shared.endFileOperation()
    }

    private func exportFile(android: Bool) {
        guard CloudSync.shared.beginFileOperation() else { return }
        fileStatus.text = CloudText.text("fileWorking"); fileStatus.isHidden = false
        Task { [weak self] in
            guard let self else { CloudSync.shared.endFileOperation(); return }
            do {
                let bytes = try await data.exportProgressArchive(android:android)
                let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString,isDirectory:true)
                try FileManager.default.createDirectory(at:directory,withIntermediateDirectories:true)
                let file = directory.appendingPathComponent(android ? "Math-Tricks.mathtricks.gz" : "MathTricks-iOS.mathtricks.json")
                try bytes.write(to:file,options:.atomic)
                guard viewIfLoaded?.window != nil else { finishFileOperation(); return }
                let picker = UIDocumentPickerViewController(forExporting:[file],asCopy:true)
                picker.delegate = self; present(picker,animated:false)
            } catch { showError(error); finishFileOperation("fileSaveError") }
        }
    }

    private func chooseFile() {
        guard let revision = data.snapshot?.revision, CloudSync.shared.beginFileOperation() else { return }
        choosingRevision = revision
        let picker = UIDocumentPickerViewController(forOpeningContentTypes:[.json,.gzip,.data],asCopy:true)
        picker.delegate = self; picker.allowsMultipleSelection = false; importingPicker = picker
        present(picker,animated:false)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated:false) { [weak self] in self?.finishFileOperation() }
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard controller === importingPicker else {
            controller.dismiss(animated:false) { [weak self] in self?.finishFileOperation("fileSaved") }
            return
        }
        guard let url = urls.first else { finishFileOperation(); return }
        importingPicker = nil
        controller.dismiss(animated:false)
        fileStatus.text = CloudText.text("fileWorking"); fileStatus.isHidden = false
        Task { [weak self] in
            guard let self else { CloudSync.shared.endFileOperation(); return }
            do {
                let bytes = try await Task.detached(priority:.userInitiated) {
                    let access = url.startAccessingSecurityScopedResource()
                    defer { if access { url.stopAccessingSecurityScopedResource() } }
                    let values = try url.resourceValues(forKeys:[.fileSizeKey,.isRegularFileKey])
                    guard values.isRegularFile == true, (values.fileSize ?? Int.max) <= ProgressArchive.maximumBytes else { throw ProgressError.invalidArchive }
                    return try Data(contentsOf:url,options:.mappedIfSafe)
                }.value
                let archive = try await data.previewProgressArchive(bytes)
                guard viewIfLoaded?.window != nil else { finishFileOperation(); return }
                pendingArchive = archive; pendingFileIsNative = !bytes.starts(with:[0x1f,0x8b]); offerFileImport(archive)
            } catch { showError(error,reading:true); finishFileOperation("fileRestoreError") }
        }
    }

    private func offerFileImport(_ archive: ProgressArchive) {
        let formatter = DateFormatter(); formatter.dateStyle = .medium; formatter.timeStyle = .short
        let message = pendingFileIsNative ? CatalogText.ui("archive_replace_warning") : CloudText.text("fileRestoreConfirm")
        let details = message + "\n\n" + formatter.string(from:archive.exportedAt)
            + "\n" + CloudText.text("coins") + ": \(archive.state.coins)\n" + CloudText.text("solved") + ": \(archive.state.totalSolved)"
        present(AppDialogViewController(title:CloudText.text("fileRestore"),message:details,actions:[
            .init(title:CatalogText.ui("cancel"),handler:{ [weak self] in self?.finishFileOperation() }),
            .init(title:CloudText.text("fileRestore"),handler:{ [weak self] in self?.confirmFileImport() })
        ],data:data),animated:false)
    }

    private func confirmFileImport() {
        present(AppDialogViewController(title:CloudText.text("fileRestore"),message:CatalogText.ui("archive_final_confirm"),actions:[
            .init(title:CatalogText.ui("cancel"),handler:{ [weak self] in self?.finishFileOperation() }),
            .init(title:CloudText.text("fileRestore"),handler:{ [weak self] in self?.restoreFile() })
        ],data:data),animated:false)
    }

    private func restoreFile() {
        guard let archive = pendingArchive, let revision = choosingRevision else { finishFileOperation(); return }
        Task { [weak self] in
            guard let self else { CloudSync.shared.endFileOperation(); return }
            do {
                try await data.importProgressArchive(archive,expectedRevision:revision)
                do { try await DailyNotificationService.shared.schedule(data.snapshot) }
                catch { NSLog("File restore reminder scheduling: %@",error.localizedDescription) }
                finishFileOperation("fileRestored")
            } catch { showError(error); finishFileOperation("fileRestoreError") }
        }
    }
}
