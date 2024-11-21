//
//  EmojiManager.swift
//  Feature
//
//  Created by 이숲 on 11/21/24.
//

final class EmojiManager {
    // MARK: - Properties

    static let shared = EmojiManager()

    private var userEmojis: [String: String] = [:]
    private let emojis = ["😀", "😊", "🤪", "🤓", "😡", "🥶", "🤯", "🤖", "👻", "👾"]

    // MARK: - Initializer

    private init() {}

    // MARK: - Methods

    func getEmoji(id: String) -> String? {
        guard let userEmoji = userEmojis[id] else {
            let randomEmoji = emojis.randomElement()
            userEmojis[id] = randomEmoji
            return randomEmoji
        }
        return userEmoji
    }

    func removeUserEmoji(id: String) {
        userEmojis.removeValue(forKey: id)
    }
}
