//
//  KeyboardViewController.swift
//  keyboardBenchmarkExtension
//
//  Created by Alex.Su on 2025/9/22.
//

import KeyboardKit
import SwiftUI

class KeyboardViewController: KeyboardInputViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set keyboard type to alphabetic
        state.keyboardContext.keyboardType = .alphabetic
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
