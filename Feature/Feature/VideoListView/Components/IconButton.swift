//
//  IconButton.swift
//  Feature
//
//  Created by 디해 on 11/7/24.
//

import Combine
import UIKit

final class IconButton: UIButton {
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        setupViewAttributes()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with image: UIImage?, title: String) {
        setTitle(title, for: .normal)
        setImage(image, for: .normal)
    }
}

// MARK: - Setting
private extension IconButton {
    func setupViewAttributes() {
        backgroundColor = .white
        tintColor = .black
        setTitleColor(.black, for: .normal)
        layer.cornerRadius = 10
        
        setupButtonConfiguration()
    }
    
    func setupButtonConfiguration() {
        var configuration = UIButton.Configuration.plain()
        configuration.imagePlacement = .leading
        configuration.imagePadding = 10
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 13, leading: 7, bottom: 13, trailing: 7)
        self.configuration = configuration
    }
}
