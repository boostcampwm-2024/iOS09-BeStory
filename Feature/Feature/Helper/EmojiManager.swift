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

    func getRandomEmoji(id: String) -> String? {
        let randomEmoji = emojis.randomElement()
        userEmojis[id] = randomEmoji
        return randomEmoji
    }

    func getUserEmoji(id: String) -> String? {
        return userEmojis[id]
    }

    func removeUserEmoji(id: String) {
        userEmojis.removeValue(forKey: id)
    }
}
