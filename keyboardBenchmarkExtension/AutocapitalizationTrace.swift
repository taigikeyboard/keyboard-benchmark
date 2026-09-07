//
//  AutocapitalizationTrace.swift
//  keyboardBenchmarkExtension
//

import SwiftUI

/// Case-state trace rendered in the keyboard's own toolbar.
///
/// A keyboard extension is a separate process, so its log lands neither in the host app's Xcode
/// console nor in a debugger attached after launch — and the lines that matter are the ones from
/// before the keyboard is visible. Showing them on the keyboard makes every cold launch readable
/// without Console.app.
@MainActor
final class AutocapitalizationTrace: ObservableObject {

    /// Trace lines in the order they were recorded, oldest first.
    @Published private(set) var lines: [String] = []

    private static let maximumLineCount = 12

    func record(_ line: String) {
        lines.append(line)
        if lines.count > Self.maximumLineCount {
            lines.removeFirst(lines.count - Self.maximumLineCount)
        }
    }
}

/// Renders the trace as a scrollable strip where the keyboard's autocomplete toolbar would be.
struct AutocapitalizationTraceToolbar: View {

    @ObservedObject var trace: AutocapitalizationTrace

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(Array(trace.lines.enumerated()), id: \.offset) { _, line in
                    Text(line)
                        .font(.system(size: 9, design: .monospaced))
                        .textSelection(.enabled)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 6)
        }
        .frame(height: 64)
    }
}
