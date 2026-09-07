//
//  KeyboardApp+Benchmark.swift
//

import KeyboardKit

extension KeyboardApp {

    /// The app value shared by the host app and the keyboard extension.
    ///
    /// Both targets must pass the same value — the host app to `KeyboardAppView(for:)`, the
    /// extension to `setupKeyboardKit(for:)` — so KeyboardKit resolves one settings store with
    /// one key prefix. The project uses file-system-synchronized groups, where a file belongs to
    /// exactly one target, so this declaration is duplicated in `keyboardBenchmark` and
    /// `keyboardBenchmarkExtension`. Change one, change the other.
    ///
    /// `appGroupId` stays nil, matching the official demo's default: it ships without a working
    /// App Group, so settings do not sync between app and keyboard. The benchmark's variant is
    /// hardcoded in the extension and needs no sync.
    static var benchmark: KeyboardApp {
        .init(name: "Keyboard Benchmark")
    }
}
