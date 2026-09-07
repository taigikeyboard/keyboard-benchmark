//
//  KeyboardViewController.swift
//  keyboardBenchmarkExtension
//
//  Created by Alex.Su on 2025/9/22.
//

import KeyboardKit
import OSLog
import SwiftUI
import UIKit

/// The autocapitalization configuration under test, applied on every launch.
///
/// `isAutocapitalizationEnabled` is `@AppStorage`-backed, so a value written once stays in
/// `UserDefaults` forever. Every variant therefore writes both the setting and the override
/// explicitly — removing an assignment does not restore a default, and a stale store would
/// silently invalidate a test run.
///
/// Retests KeyboardKit issues #1057 and #967, which the author closed as fixed in 10.8.1.
enum AutocapitalizationTestVariant {

    /// Baseline: autocapitalization on, field preference untouched.
    case settingOnOverrideNone

    /// Issue #1057: the user turns autocapitalization off.
    case settingOffOverrideNone

    /// Override only, to tell a broken setting apart from a broken override.
    case settingOnOverrideExplicitNone

    /// The combination the #967 reporter used and still saw capitalization with.
    case settingOffOverrideExplicitNone

    var isAutocapitalizationEnabled: Bool {
        switch self {
        case .settingOnOverrideNone, .settingOnOverrideExplicitNone: return true
        case .settingOffOverrideNone, .settingOffOverrideExplicitNone: return false
        }
    }

    var autocapitalizationTypeOverride: Keyboard.AutocapitalizationType? {
        switch self {
        case .settingOnOverrideNone, .settingOffOverrideNone: return nil
        case .settingOnOverrideExplicitNone, .settingOffOverrideExplicitNone: return Keyboard.AutocapitalizationType.none
        }
    }
}

/// A stock KeyboardKit keyboard, kept free of customizations so it can serve as
/// a baseline when comparing behavior against the Taigi keyboard.
class KeyboardViewController: KeyboardInputViewController {

    /// Change this line and reinstall the extension to run a different variant.
    private let testVariant: AutocapitalizationTestVariant = .settingOffOverrideNone

    /// Applies the variant in the setup completion's success branch, matching the official demo
    /// at `Demo/Keyboard/KeyboardViewController.swift`. `setupKeyboardKit(for:)` completes
    /// asynchronously, so writing state right after the call can be overwritten by the rest of
    /// setup — that would read as a KeyboardKit failure when it is a test-bed failure.
    override func viewWillSetupKeyboardKit() {
        setupKeyboardKit(for: .benchmark) { [weak self] result in
            switch result {
            case .success:
                self?.applyTestVariant(event: "keyboard.setup.complete")
            case .failure(let error):
                Self.logger.error("keyboard.setup.failed error=\(String(describing: error), privacy: .public)")
            }
        }
    }

    private func applyTestVariant(event: String) {
        state.keyboardContext.settings.isAutocapitalizationEnabled = testVariant.isAutocapitalizationEnabled
        state.keyboardContext.autocapitalizationTypeOverride = testVariant.autocapitalizationTypeOverride
        logCaseState(event: event)
    }

    /// Reapplies the variant immediately before KeyboardKit computes the initial case.
    ///
    /// The setup completion runs asynchronously, so on 10.9.3 the assignment there can land after
    /// this hook — too late to affect the first keyboard presentation, which is the exact symptom
    /// issue #1057 describes. Writing here removes that timing question: if the first character
    /// still comes out uppercased, KeyboardKit's initial-case logic is ignoring the setting rather
    /// than reading it before we set it.
    override func viewWillSetupInitialKeyboardCase() {
        logCaseState(event: "keyboard.initialCase.beforeApply")
        applyTestVariant(event: "keyboard.initialCase.applied")
        super.viewWillSetupInitialKeyboardCase()
        logCaseState(event: "keyboard.initialCase.didSetup")
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

    /// Uses unified logging so the tester can read the trace in Console.app without attaching
    /// Xcode to the extension process before it launches.
    private func logCaseState(event: String) {
        let context = state.keyboardContext
        Self.logger.notice("""
            \(event, privacy: .public) \
            variant=\(String(describing: self.testVariant), privacy: .public) \
            isAutocapitalizationEnabled=\(context.settings.isAutocapitalizationEnabled, privacy: .public) \
            autocapitalizationTypeOverride=\(String(describing: context.autocapitalizationTypeOverride), privacy: .public) \
            keyboardCase=\(context.keyboardCase.rawValue, privacy: .public) \
            storeKeyPrefix=\(KeyboardSettings.storeKeyPrefix, privacy: .public) \
            proxyAutocapitalizationType=\(String(describing: self.textDocumentProxy.autocapitalizationType?.rawValue), privacy: .public)
            """)
    }

    private static let logger = Logger(subsystem: "com.keyboardBenchmark.extension", category: "autocapitalization")
}
