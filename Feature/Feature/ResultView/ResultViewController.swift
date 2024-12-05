//
//  ResultViewController.swift
//  Feature
//
//  Created by 디해 on 12/5/24.
//

import AVFoundation
import Combine
import UIKit

public final class ResultViewController: UIViewController {
    private let videoView = VideoPlayerView()
    
    private let viewModel: ResultViewModel
    var cancellables = Set<AnyCancellable>()
    
    public init(viewModel: ResultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
