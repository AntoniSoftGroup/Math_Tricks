//
//  ContentView.swift
//  Math_Tricks
//
//  Created by Antoni Ion on 18.10.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var hidesDuoStatusBar = false

    var body: some View {
        AppRootHost(hidesStatusBar: $hidesDuoStatusBar)
            .statusBarHidden(hidesDuoStatusBar)
    }
}

private struct AppRootHost: UIViewControllerRepresentable {
    @Binding var hidesStatusBar: Bool

    func makeUIViewController(context: Context) -> AppRootViewController {
        let controller = AppRootViewController()
        controller.loadViewIfNeeded()
        let visibility = $hidesStatusBar
        (controller.view as? AppDuoContentView)?.onDuoAvailabilityChange = { available in
            // Hinge updates can arrive during layout. Update the hosting view on
            // the next main-loop turn, keeping this state local to its window.
            DispatchQueue.main.async {
                if visibility.wrappedValue != available {
                    visibility.wrappedValue = available
                }
            }
        }
        return controller
    }

    func updateUIViewController(_ controller: AppRootViewController, context: Context) {
        // SwiftUI updates must not reset the navigation stack or recreate the banner.
    }

    static func dismantleUIViewController(_ controller: AppRootViewController, coordinator: ()) {
        (controller.viewIfLoaded as? AppDuoContentView)?.onDuoAvailabilityChange = nil
    }
}

#Preview {
    ContentView()
        .ignoresSafeArea()
}
