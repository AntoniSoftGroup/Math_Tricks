//
//  ContentView.swift
//  Math_Tricks
//
//  Created by Antoni Ion on 18.10.2026.
//

import SwiftUI

struct ContentView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> AppRootViewController {
        AppRootViewController()
    }

    func updateUIViewController(_ controller: AppRootViewController, context: Context) {
        // SwiftUI updates must not reset the navigation stack or recreate the banner.
    }
}

#Preview {
    ContentView()
        .ignoresSafeArea()
}
