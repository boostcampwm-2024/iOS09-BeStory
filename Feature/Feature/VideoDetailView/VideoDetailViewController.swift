//
//  VideoDetailViewController.swift
//  Feature
//
//  Created by 디해 on 11/11/24.
//

import UIKit
import Combine

public final class VideoDetailViewController: UIViewController {
    // MARK: - Initializers
    init(video: VideoListPresentationModel) {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Controller Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViewAttributes()
    }
}

// MARK: - Setting
extension VideoDetailViewController {
    func setupViewAttributes() {
        view.backgroundColor = .black
    }
}
