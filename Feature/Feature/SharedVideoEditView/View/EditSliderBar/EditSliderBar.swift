//
//  EditSliderBar.swift
//  Feature
//
//  Created by jung on 11/30/24.
//

import Core
import UIKit
import SnapKit

protocol EditSliderBarDelegate: AnyObject {
	func lowerValueDidChanged(_ sliderBar: EditSliderBar, value: Double)
	func upperValueDidChanged(_ sliderBar: EditSliderBar, value: Double)
	func playerValueDidChanged(_ sliderBar: EditSliderBar, value: Double)
}

final class EditSliderBar: UIControl {
	enum Constants {
		// TODO: - 이거 네이밍 수정
		static let thumbWidth: CGFloat = 16
		static let imageFramePadding: CGFloat = 5
		static let seekThumbWidth: CGFloat = 10
	}
	
	// MARK: - UI Components
	private let imageFrameView = ImageFrameView()
	private let lowerThumb = SliderThumb(tintColor: .systemYellow)
	private let upperThumb = SliderThumb(tintColor: .systemYellow)
	private let seekThumb = SliderThumb(trackTintColor: .white, hightlightedTintColor: .systemGray4)
	weak var currentHighlightedThumb: SliderThumb?
	
	// MARK: - Properties
	weak var delegate: EditSliderBarDelegate?
	
	private var previousLocation: CGPoint = .zero
	private var minimumValue: Double = 0
	private var maximumValue: Double = 100
	
	private var totalLength: Double {
		let total = bounds.width - Constants.thumbWidth
		return total < 0 ? 0 : total
	}
	
	private var seekThumbAvailableLength: Double {
		let total = totalLength - Constants.thumbWidth
		
		return total < 0 ? 0 : total
	}
	
	/// 현재 slider의 최솟값
	private(set) var lowerValue: Double = 10.0 {
		didSet {
			updateThumbFrame(lowerThumb)
			delegate?.lowerValueDidChanged(self, value: lowerValue)
		}
	}
	
	/// 현재 slider의 최댓값
	private(set) var upperValue: Double = 100 {
		didSet {
			updateThumbFrame(upperThumb)
			delegate?.upperValueDidChanged(self, value: upperValue)
		}
	}
	
	private(set) var seekValue: Double = 0 {
		didSet {
			updateSeekThumbFrame()
			delegate?.playerValueDidChanged(self, value: seekValue)
		}
	}
	
	var gapBetweenThumbs: Double {
		let proportion = (maximumValue - minimumValue) / totalLength
		return Constants.thumbWidth * proportion * 2
	}
	
	// MARK: - Initializers
	init() {
		super.init(frame: .zero)
		setupUI()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - UIControl
	override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		let location = touch.location(in: self)
		defer { previousLocation = location }
		
		if seekThumb.contain(point: location) {
			seekThumb.isHightlighted = true
			currentHighlightedThumb = seekThumb
		} else if lowerThumb.contain(point: location) {
			lowerThumb.isHightlighted = true
			currentHighlightedThumb = lowerThumb
		} else if upperThumb.contain(point: location) {
			upperThumb.isHightlighted = true
			currentHighlightedThumb = upperThumb
		}
		
		return lowerThumb.isHightlighted || upperThumb.isHightlighted || seekThumb.isHightlighted
	}
	
	override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		let location = touch.location(in: self)
		defer { previousLocation = location }
		
		guard let slider = currentHighlightedThumb else { return false }
		
		// point -> 초로 환산
		let sliderDeltaValue = deltaValue(from: previousLocation, to: location)
		let seekDeltaValue = deltaValue(from: previousLocation, to: location)
		
		if slider === seekThumb {
			self.seekValue = updatedSeekValue(moved: seekDeltaValue)
		} else if slider === lowerThumb {
			self.lowerValue = updatedLowerValue(moved: sliderDeltaValue)
			self.seekValue = lowerValue
		} else if slider === upperThumb {
			self.upperValue = updatedUpperValue(moved: sliderDeltaValue)
			self.seekValue = upperValue
		}
		sendActions(for: .valueChanged)
		return true
	}
	
	override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
		lowerThumb.isHightlighted = false
		upperThumb.isHightlighted = false
		seekThumb.isHightlighted = false
		currentHighlightedThumb = nil
	}
	
	// MARK: - LayoutSubviews
	override func layoutSubviews() {
		super.layoutSubviews()
		updateThumbsFrame()
	}
	
	// MARK: - Draw
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		guard let context = UIGraphicsGetCurrentContext() else { return }
		
		let maskedRect = selectedRangeAtSlidarBar()
		let selectedRect = selectedRangeAtImageFrame()
		
		self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
		context.setFillColor(UIColor.systemYellow.cgColor)
		context.fill(maskedRect)
		
		imageFrameView.selectedRect = selectedRect
	}
}

// MARK: - UI Methods
private extension EditSliderBar {
	func setupUI() {
		setupViewHierarchies()
		setupViewConstraints()
		setupLowerThumb()
		setupUpperThumb()
		setupSeekThumb()
		
		updateThumbsFrame()
	}
	
	func setupViewHierarchies() {
		addSubviews(
			imageFrameView,
			lowerThumb,
			upperThumb,
			seekThumb
		)
	}
	
	func setupViewConstraints() {
		imageFrameView.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview().inset(Constants.thumbWidth)
			$0.top.bottom.equalToSuperview().inset(Constants.imageFramePadding)
		}
	}
	
	func setupLowerThumb() {
		let boldConfig = UIImage.SymbolConfiguration(weight: .heavy)
		let image = UIImage(systemName: "chevron.left")?
			.color(.systemGray)
			.withConfiguration(boldConfig)
		
		lowerThumb.setImage(image)
		lowerThumb.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
	}
	
	func setupUpperThumb() {
		let boldConfig = UIImage.SymbolConfiguration(weight: .heavy)
		let image = UIImage(systemName: "chevron.right")?
			.color(.systemGray)
			.withConfiguration(boldConfig)
		
		upperThumb.setImage(image)
		upperThumb.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
	}
	
	func setupSeekThumb() {
		seekThumb.layer.borderColor = UIColor.systemGray.cgColor
		seekThumb.layer.borderWidth = 1.0
	}
}

// MARK: - Private Methotds
private extension EditSliderBar {
	func updateThumbsFrame() {
		updateThumbFrame(lowerThumb)
		updateThumbFrame(upperThumb)
		updateSeekThumbFrame()
	}
	
	func updateThumbFrame(_ thumb: SliderThumb) {
		let width = Constants.thumbWidth
		
		let leading = thumb === lowerThumb ? leading(of: lowerValue) : leading(of: upperValue)
		
		thumb.frame = CGRect(
			x: leading,
			y: 0,
			width: width,
			height: bounds.height
		)
		setNeedsDisplay()
	}
	
	func updateSeekThumbFrame() {
		let width = Constants.seekThumbWidth
		let leading = leadingForSeek(of: seekValue)
		let xPosition = leading + lowerThumb.frame.maxX
		
		seekThumb.frame = CGRect(
			x: xPosition,
			y: 0,
			width: width,
			height: bounds.height
		)
	}
	
	func updatedLowerValue(moved delta: Double) -> Double {
		return (lowerValue + delta).bound(lower: minimumValue, upper: upperValue - gapBetweenThumbs)
	}
	
	func updatedUpperValue(moved delta: Double) -> Double {
		return (upperValue + delta).bound(lower: lowerValue + gapBetweenThumbs, upper: maximumValue)
	}
	
	func updatedSeekValue(moved delta: Double) -> Double {
		return (seekValue + delta).bound(lower: lowerValue, upper: upperValue)
	}
	
	func selectedRangeAtSlidarBar() -> CGRect {
		let startPoint = lowerThumb.frame.maxX
		let width = upperThumb.frame.minX - lowerThumb.frame.maxX
		
		return CGRect(
			x: startPoint,
			y: 0,
			width: width,
			height: bounds.height
		)
	}
	
	func selectedRangeAtImageFrame() -> CGRect {
		let startPoint = lowerThumb.frame.maxX - Constants.thumbWidth
		let width = upperThumb.frame.minX - lowerThumb.frame.maxX
		
		return CGRect(
			x: startPoint,
			y: 0,
			width: width,
			height: bounds.height
		)
	}
	
	func deltaValue(from previous: CGPoint, to current: CGPoint) -> Double {
		let deltaLocation = Double(current.x - previous.x)
		
		return (maximumValue - minimumValue) * deltaLocation / Double(totalLength)
	}
	
	func leading(of value: Double) -> Double {
		return totalLength * value / maximumValue
	}
	
	func leadingForSeek(of value: Double) -> Double {
		let range = upperValue - lowerValue
		guard range > 0 else { return 0 }
		
		let proportion = (value - lowerValue) / range
		return Double(upperThumb.frame.minX - lowerThumb.frame.maxX) * proportion
	}
}
