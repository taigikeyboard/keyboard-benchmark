//
//  KeyboardViewController.swift
//  keyboardBenchmarkExtension
//
//  Created by Alex.Su on 2025/9/22.
//

import KeyboardKit
import SwiftUI
import UIKit

extension KeyboardApp {

    static var benchmark: KeyboardApp {
        .init(name: "Keyboard Benchmark")
    }
}

/// A stock KeyboardKit keyboard, kept free of customizations so it can serve as
/// a baseline when comparing behavior against the Taigi keyboard.
class KeyboardViewController: KeyboardInputViewController {

    override func viewWillSetupKeyboardKit() {
        setupKeyboardKit(for: .benchmark)
    }

    override func viewWillSetupKeyboardView() {
        setupKeyboardView { controller in
            KeyboardView(
                services: controller.services,
                buttonContent: { $0.view },
                buttonView: { $0.view },
                collapsedView: { $0.view },
                emojiKeyboard: { $0.view },
                toolbar: { $0.view }
            )
        }
    }
}
