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
            title: "句首大寫(.sentences)",
            capitalization: .sentences,
            expectedSettingOnOverrideNil: "Ab cd. Ef",
            expectedSettingOffOverrideNil: "ab cd. ef"
        ),
        .init(
            title: "永不大寫(.never)",
            capitalization: .never,
            expectedSettingOnOverrideNil: "ab cd. ef",
            expectedSettingOffOverrideNil: "ab cd. ef"
        ),
        .init(
            title: "每個字大寫(.words)",
            capitalization: .words,
            expectedSettingOnOverrideNil: "Ab Cd. Ef",
            expectedSettingOffOverrideNil: "ab cd. ef"
        ),
        .init(
            title: "全部大寫(.characters)",
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
                Section("測試步驟") {
                    Text("四個欄位敲的鍵完全一樣,只有該出現的字不同。")
                    Text("每個欄位都敲這九個鍵:a、b、空白、c、d、句點、空白、e、f")
                    Text("全程不要碰 Shift。")
                    Text("鍵盤跳出來的第一幀就要看 Shift 鍵狀態,打字之前先看。")
                    Text("每次判定首字大小寫都要在空欄位重新開一次鍵盤。先按重設 — 鍵盤還開著就直接切欄位,測不到首次呈現。")
                }
                ForEach(AutocapitalizationTestField.all) { field in
                    Section(field.title) {
                        TextField("敲 a b 空白 c d 句點 空白 e f", text: binding(for: field))
                            .textInputAutocapitalization(field.capitalization)
                            .autocorrectionDisabled()
                            .keyboardType(.default)
                            .focused($focusedField, equals: field.id)
                        LabeledContent("設定開、override nil", value: field.expectedSettingOnOverrideNil)
                        LabeledContent("設定關、override nil", value: field.expectedSettingOffOverrideNil)
                        LabeledContent(
                            "override .none,設定開關皆同",
                            value: AutocapitalizationTestField.expectedWithExplicitNoneOverride
                        )
                    }
                }
                Section {
                    Button("重設:清空文字並收起鍵盤") {
                        enteredText.removeAll()
                        focusedField = nil
                    }
                }
            }
            .navigationTitle("自動大寫測試")
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
