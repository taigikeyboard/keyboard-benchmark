//
//  keyboardBenchmarkApp.swift
//  keyboardBenchmark
//
//  Created by Alex.Su on 2025/9/22.
//

import KeyboardKit
import SwiftUI

@main
struct keyboardBenchmarkApp: App {

    /// `KeyboardAppView` sets up the KeyboardKit settings store before any `@AppStorage` access,
    /// as the official demo does in `Demo/Demo/DemoApp.swift`.
    var body: some Scene {
        WindowGroup {
            KeyboardAppView(for: .benchmark) {
                ContentView()
            }
        }
    }
}
