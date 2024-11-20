//
//  VideoDetailViewController.swift
//  Feature
//
//  Created by 디해 on 11/11/24.
//

import AVFoundation
import Combine
import UIKit

public final class VideoDetailViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    
    private var player: AVPlayer
    private var playerLayer: AVPlayerLayer
    
    // MARK: - UI Components
    private let videoView = UIView()
    private let playPauseButton = UIButton()
    private let slider = UISlider()
    
    private var isPlaying: Bool = false
    
    // MARK: - Initializers
    init(video: VideoListItem) {
        player = AVPlayer(url: video.videoURL)
        playerLayer = AVPlayerLayer(player: player)
        
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
        setupViewHierarchies()
        setupViewConstraints()
        setupViewBinding()
        setupPlayPauseButton()
        setupSlider()
        setupTimeObserver()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoView.bounds
    }
}

// MARK: - Setting
private extension VideoDetailViewController {
    func setupViewAttributes() {
        view.backgroundColor = .black
    }
    
    func setupViewHierarchies() {
        view.addSubview(videoView)
        view.addSubview(playPauseButton)
        view.addSubview(slider)
        videoView.layer.addSublayer(playerLayer)
    }
    
    func setupViewConstraints() {
        videoView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(600)
        }
        
        slider.snp.makeConstraints { make in
            make.top.equalTo(videoView.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        playPauseButton.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.top.equalTo(slider.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
    }
    
    func setupViewBinding() {
        playPauseButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updatePlaying()
            }
            .store(in: &cancellables)
        
        slider.publisher(for: .valueChanged)
            .compactMap { $0 as? UISlider }
            .sink { [weak self] slider in
                self?.updateVideoTime(to: slider.value)
            }
            .store(in: &cancellables)
    }
    
    func setupVideoPlayer(url: URL) {
        playerLayer.videoGravity = .resizeAspect
    }
    
    func setupPlayPauseButton() {
        let image = UIImage(systemName: "play.fill")
        playPauseButton.setImage(image, for: .normal)
        playPauseButton.tintColor = .white
        playPauseButton.imageView?.contentMode = .scaleAspectFit
    }
    
    func setupSlider() {
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 0
    }
    
    func setupTimeObserver() {
        let interval = CMTime(seconds: 1, preferredTimescale: 1)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self,
                  let playerDuration = self.player.currentItem?.duration else { return }
            let currentTime = CMTimeGetSeconds(time)
            let duration = CMTimeGetSeconds(playerDuration)
            let progress = Float(currentTime / duration)
            self.slider.value = progress * 100
        }
    }
}

extension VideoDetailViewController {
    func updatePlaying() {
        if isPlaying {
            self.player.pause()
            let image = UIImage(systemName: "play.fill")
            playPauseButton.setImage(image, for: .normal)
        } else {
            self.player.play()
            let image = UIImage(systemName: "pause.fill")
            playPauseButton.setImage(image, for: .normal)
        }
        isPlaying.toggle()
    }
    
    func updateVideoTime(to value: Float) {
        guard let playerDuration = player.currentItem?.duration else { return }
        let duration = CMTimeGetSeconds(playerDuration)
        let newTime = Double(value / 100) * duration
        let seekTime = CMTime(seconds: newTime, preferredTimescale: 1)
        player.seek(to: seekTime)
    }
}
