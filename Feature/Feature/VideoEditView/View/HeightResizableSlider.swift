//
//  HeghtResizableSlider.swift
//  Feature
//
//  Created by Yune gim on 11/27/24.
//

import UIKit

final class HeightResizableSlider: UISlider {
    private let trackHeight: CGFloat
    
    let thumbImage = {
        let thumbView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        thumbView.backgroundColor = .white
        thumbView.layer.cornerRadius = 8
        thumbView.layer.borderColor = UIColor.black.cgColor
        thumbView.layer.borderWidth = 1
        return thumbView.toImage()
    }()
    
    init(trackHeight: CGFloat) {
        self.trackHeight = trackHeight
        super.init(frame: .zero)
        setThumbImage(thumbImage, for: .normal)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let track = super.trackRect(forBounds: bounds)
        let resizedRect = CGRect(
            x: track.origin.x,
            y: track.origin.y,
            width: track.width,
            height: trackHeight)
        return resizedRect
    }
}
