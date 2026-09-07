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

/// Renders the trace as a scrollable strip where the keyboard's autocomplete toolbar would be,
/// with a button that types the whole trace into the focused field so it can be copied out.
struct AutocapitalizationTraceToolbar: View {

    @ObservedObject var trace: AutocapitalizationTrace

    /// Types the joined trace into the document, for a tester who cannot select text on the
    /// keyboard itself. Run it only after reading the case result — it changes the field's text.
    let onDump: (String) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(trace.lines.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.system(size: 10, design: .monospaced))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            Button("輸出") {
                onDump(trace.lines.joined(separator: "\n"))
            }
            .font(.system(size: 11))
            .buttonStyle(.bordered)
        }
        .padding(.horizontal, 6)
        .frame(height: 72)
    }
}
