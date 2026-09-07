//
//  ContentView.swift
//  keyboardBenchmark
//
//  Created by Alex.Su on 2025/9/22.
//

import SwiftUI

/// A text field whose autocapitalization preference is declared explicitly, plus the text the
/// tester should get out of it. The keyboard extension must honor the declared preference, so
/// each row is one assertion in the dogfood matrix.
///
/// An explicit `.none` override makes every field lowercase, so that column is shared: it is the
/// discriminator that tells a broken setting apart from a broken override.
private struct AutocapitalizationTestField: Identifiable {

    let id = UUID()
    let title: String
    let capitalization: TextInputAutocapitalization
    let expectedSettingOnOverrideNil: String
    let expectedSettingOffOverrideNil: String

    static let expectedWithExplicitNoneOverride = "ab cd. ef"

    static let all: [AutocapitalizationTestField] = [
        .init(
            title: ".sentences",
            capitalization: .sentences,
            expectedSettingOnOverrideNil: "Ab cd. Ef",
            expectedSettingOffOverrideNil: "ab cd. ef"
        ),
        .init(
            title: ".never",
            capitalization: .never,
            expectedSettingOnOverrideNil: "ab cd. ef",
            expectedSettingOffOverrideNil: "ab cd. ef"
        ),
        .init(
            title: ".words",
            capitalization: .words,
            expectedSettingOnOverrideNil: "Ab Cd. Ef",
            expectedSettingOffOverrideNil: "ab cd. ef"
        ),
        .init(
            title: ".characters",
            capitalization: .characters,
            expectedSettingOnOverrideNil: "AB CD. EF",
            expectedSettingOffOverrideNil: "ab cd. ef"
        )
    ]
}

/// Dogfood harness for KeyboardKit issues #1057 and #967: type the same key sequence into each
/// field and compare the result against the expected text for the extension's current variant.
struct ContentView: View {

    @State private var enteredText: [UUID: String] = [:]
    @FocusState private var focusedField: UUID?

    var body: some View {
        NavigationStack {
            Form {
                Section("Instructions") {
                    Text("Type: a, b, space, c, d, period, space, e, f — never touch Shift.")
                    Text("Check the Shift key state on the very first frame after the keyboard opens, before typing.")
                    Text("Each initial-case assertion needs a freshly opened keyboard on an empty field. Reset first — switching fields with the keyboard still up does not retest the first presentation.")
                }
                ForEach(AutocapitalizationTestField.all) { field in
                    Section(field.title) {
                        TextField(field.title, text: binding(for: field))
                            .textInputAutocapitalization(field.capitalization)
                            .autocorrectionDisabled()
                            .keyboardType(.default)
                            .focused($focusedField, equals: field.id)
                        LabeledContent("Setting on, override nil", value: field.expectedSettingOnOverrideNil)
                        LabeledContent("Setting off, override nil", value: field.expectedSettingOffOverrideNil)
                        LabeledContent(
                            "Override .none, either setting",
                            value: AutocapitalizationTestField.expectedWithExplicitNoneOverride
                        )
                    }
                }
                Section {
                    Button("Reset: clear text and dismiss keyboard") {
                        enteredText.removeAll()
                        focusedField = nil
                    }
                }
            }
            .navigationTitle("Autocapitalization")
        }
    }

    private func binding(for field: AutocapitalizationTestField) -> Binding<String> {
        .init(
            get: { enteredText[field.id] ?? "" },
            set: { enteredText[field.id] = $0 }
        )
    }
}

#Preview {
    ContentView()
}
