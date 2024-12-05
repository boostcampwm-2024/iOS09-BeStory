//
//  VideolayerView.swift
//  Feature
//
//  Created by Yune gim on 11/26/24.
//

import AVFoundation
import Combine
import SnapKit
import UIKit

final class VideoPlayerView: UIView {
	// MARK: - Properties
    private var player: AVPlayer
    private var playerLayer: AVPlayerLayer
	private var isHide: Bool = false
	private var cancellables = Set<AnyCancellable>()
	var isHiddenSliderBar: Bool = false {
		didSet { seekingSlider.isHidden = isHiddenSliderBar }
	}

	// MARK: - UI Components
    private let playPauseButton = UIButton()
    private let seekingSlider = HeightResizableSlider(trackHeight: 6)
    
    // MARK: - Initializer
    init(playerItem: AVPlayerItem?) {
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        super.init(frame: .zero)
        setupViewAttributes()
        setupViewHierarchies()
        setupViewBinding()
        setupViewConstraints()
    }
    
    convenience init() {
        self.init(playerItem: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

// MARK: - Internal Methods
extension VideoPlayerView {
    func replaceVideo(video: AVAsset) {
        let videoItem = AVPlayerItem(asset: video)
        replaceVideo(playerItem: videoItem)
    }

    func replaceVideo(url: URL) {
        let videoItem = AVPlayerItem(url: url)
        replaceVideo(playerItem: videoItem)
    }

    func replaceVideo(playerItem: AVPlayerItem) {
        player.pause()
        player.replaceCurrentItem(with: playerItem)
    }

    func updateVideoTime(with value: Double) {
        let time = CMTime(seconds: value, preferredTimescale: 600)
        guard let playerDuration = self.player.currentItem?.duration else { return }
        let currentTime = CMTimeGetSeconds(time)
        let duration = CMTimeGetSeconds(playerDuration)
        let progress = Float(currentTime / duration)
        self.seekingSlider.value = progress * 100
        self.updateVideoTime(to: self.seekingSlider.value)
    }
}

// MARK: - UI Methods
private extension VideoPlayerView {
    func setupViewAttributes() {
        self.backgroundColor = .systemGray6
        setupPlayTappableView()
        setupPlayPauseButton()
        setupSeekingSlider()
        setupTimeObserver()
    }
    
    func setupViewHierarchies() {
        layer.addSublayer(playerLayer)
        addSubview(playPauseButton)
        addSubview(seekingSlider)
    }
    
    func setupViewConstraints() {
        playerLayer.frame = bounds
        
        playPauseButton.snp.makeConstraints {
            $0.width.equalTo(30)
            $0.height.equalTo(30)
            $0.center.equalToSuperview()
        }
        
        seekingSlider.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(4)
            $0.leading.equalToSuperview().offset(18)
            $0.trailing.equalToSuperview().inset(18)
        }
    }
    
    func setupPlayTappableView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    func setupPlayPauseButton() {
        var buttonConfigurarion = UIButton.Configuration.plain()
        buttonConfigurarion.image = UIImage(systemName: "play.circle.fill")
        buttonConfigurarion.preferredSymbolConfigurationForImage =  UIImage.SymbolConfiguration(pointSize: 30)
        buttonConfigurarion.baseForegroundColor = .white
        playPauseButton.configuration = buttonConfigurarion
    }
    
    func setupSeekingSlider() {
        seekingSlider.tintColor = .black
        seekingSlider.minimumValue = 0
        seekingSlider.maximumValue = 100
        seekingSlider.value = 0
    }
}

// MARK: - Binding
private extension VideoPlayerView {
	func setupViewBinding() {
        NotificationCenter.default
            .publisher(for: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            .sink(with: self) { owner, _ in
                owner.handleVideoCompletion()
            }
            .store(in: &cancellables)
        
		// Thanks to LURKS02
		playPauseButton.publisher(for: .touchUpInside)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				self?.updatePlaying()
			}
			.store(in: &cancellables)
		
		seekingSlider.publisher(for: .valueChanged)
			.compactMap { $0 as? UISlider }
			.sink { [weak self] slider in
				self?.updateVideoTime(to: slider.value)
			}
			.store(in: &cancellables)
	}
}

// MARK: - Action
@objc private extension VideoPlayerView {
	private func handleTap() {
		isHide.toggle()
		UIView.animate(withDuration: 0.25) { [weak self] in
			guard let self else { return }
			self.playPauseButton.alpha = self.isHide ? 0 : 1
			
			self.seekingSlider.alpha = (self.isHide) ? 0 : 1
		}
	}
}

// MARK: - Private Methods
private extension VideoPlayerView {
	func setupTimeObserver() {
		// Thanks to LURKS02
		let interval = CMTime(seconds: 1, preferredTimescale: 1)
		player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
			guard let self,
				  let playerDuration = self.player.currentItem?.duration else { return }
			let currentTime = CMTimeGetSeconds(time)
			let duration = CMTimeGetSeconds(playerDuration)
			let progress = Float(currentTime / duration)
			self.seekingSlider.value = progress * 100
		}
	}
	
	func updatePlaying() {
		switch player.timeControlStatus {
		case .paused:
			if let playerDuration = player.currentItem?.duration,
			   playerDuration == player.currentTime() {
				updateVideoTime(to: .zero)
			}
			let image = UIImage(systemName: "pause.circle")
			playPauseButton.setImage(image, for: .normal)
			self.player.play()
		case .playing:
			let image = UIImage(systemName: "play.circle.fill")
			playPauseButton.setImage(image, for: .normal)
			player.pause()
		default:
			break
		}
	}
	
	func updateVideoTime(to value: Float) {
		// Thanks to LURKS02
		guard let playerDuration = player.currentItem?.duration else { return }
		let duration = CMTimeGetSeconds(playerDuration)
		let newTime = Double(value / 100) * duration
		let seekTime = CMTime(seconds: newTime, preferredTimescale: 1)
		player.seek(to: seekTime)
	}
    
    func handleVideoCompletion() {
            seekingSlider.value = 100

            let image = UIImage(systemName: "play.circle.fill")
            playPauseButton.setImage(image, for: .normal)

            player.seek(to: .zero)
        }
}
