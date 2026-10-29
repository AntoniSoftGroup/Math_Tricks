//
//  Math_TricksApp.swift
//  Math_Tricks
//
//  Created by Antoni Ion on 18.10.2026.
//

import SwiftUI
import GoogleSignIn

@main
struct Math_TricksApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL {
                    AppAnalytics.shared.configure()
                    GIDSignIn.sharedInstance.handle($0)
                }
                .ignoresSafeArea()
                .statusBarHidden(false)
        }
    }
}
