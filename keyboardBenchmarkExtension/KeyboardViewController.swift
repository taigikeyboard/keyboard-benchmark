//
//  KeyboardViewController.swift
//  keyboardBenchmarkExtension
//
//  Created by Alex.Su on 2025/9/22.
//

import KeyboardKit
import SwiftUI
import UIKit

// MARK: - Apple Autocomplete Service

class AppleAutocompleteService: AutocompleteService {

    private let checker = UITextChecker()
    private let language: String

    init(language: String = "en_US") {
        self.language = language
    }

    // MARK: - AutocompleteService Protocol

    var locale: Locale = .current

    var canIgnoreWords: Bool { false }
    var canLearnWords: Bool { false }

    var ignoredWords: [String] = []
    var learnedWords: [String] = []

    func autocomplete(_ text: String) async throws -> Autocomplete.Result {
        let suggestions = getSuggestions(for: text)
        return Autocomplete.Result(
            inputText: text,
            suggestions: suggestions
        )
    }

    func hasIgnoredWord(_ word: String) -> Bool { ignoredWords.contains(word) }
    func hasLearnedWord(_ word: String) -> Bool { learnedWords.contains(word) }

    func ignoreWord(_ word: String) { }
    func learnWord(_ word: String) { }
    func removeIgnoredWord(_ word: String) { }
    func unlearnWord(_ word: String) { }

    // MARK: - Private Helpers

    private func getSuggestions(for text: String) -> [Autocomplete.Suggestion] {
        let currentWord = extractCurrentWord(from: text)
        guard !currentWord.isEmpty else { return [] }

        var suggestions: [Autocomplete.Suggestion] = []

        // Get completions for the current word
        let range = NSRange(0..<currentWord.utf16.count)
        if let completions = checker.completions(
            forPartialWordRange: range,
            in: currentWord,
            language: language
        ) {
            suggestions = completions.prefix(3).map { completion in
                Autocomplete.Suggestion(text: completion)
            }
        }

        // If no completions, try spell checking for corrections
        if suggestions.isEmpty {
            let misspelledRange = checker.rangeOfMisspelledWord(
                in: currentWord,
                range: range,
                startingAt: 0,
                wrap: false,
                language: language
            )

            if misspelledRange.location != NSNotFound {
                if let guesses = checker.guesses(
                    forWordRange: misspelledRange,
                    in: currentWord,
                    language: language
                ) {
                    suggestions = guesses.prefix(3).map { guess in
                        Autocomplete.Suggestion(text: guess)
                    }
                }
            }
        }

        return suggestions
    }

    private func extractCurrentWord(from text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return "" }

        // Find the last word (after the last space)
        if let lastSpaceIndex = trimmed.lastIndex(of: " ") {
            let wordStartIndex = trimmed.index(after: lastSpaceIndex)
            return String(trimmed[wordStartIndex...])
        }

        return trimmed
    }
}

// MARK: - Keyboard View Controller

class KeyboardViewController: KeyboardInputViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set keyboard type to alphabetic
        state.keyboardContext.keyboardType = .alphabetic

        // Setup autocomplete service
        services.autocompleteService = AppleAutocompleteService(language: "en_US")
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
