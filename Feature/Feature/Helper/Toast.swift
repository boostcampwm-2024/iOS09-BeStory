//
//  Toast.swift
//  Feature
//
//  Created by 디해 on 12/5/24.
//

import UIKit

extension UIView {
    private static let toastTag = 9999
    
    func showToast(message: String, duration: TimeInterval? = nil) {
        if let existingToast = self.viewWithTag(UIView.toastTag) {
            existingToast.removeFromSuperview()
        }
        
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 15)
        toastLabel.numberOfLines = 0
        toastLabel.tag = UIView.toastTag
        
        let maxSize = CGSize(width: self.bounds.width - 40, height: self.bounds.height)
        let textSize = toastLabel.sizeThatFits(maxSize)
        toastLabel.frame = CGRect(
            x: (self.bounds.width - textSize.width - 20) / 2,
            y: self.bounds.height / 2 - textSize.height / 2,
            width: textSize.width + 40,
            height: textSize.height + 40
        )
        toastLabel.layer.cornerRadius = 20
        toastLabel.layer.masksToBounds = true
        
        self.addSubview(toastLabel)
        
        if let duration = duration {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
                self?.hideToast()
            }
        }
    }
    
    func hideToast() {
        if let toastLabel = self.viewWithTag(UIView.toastTag) {
            UIView.animate(withDuration: 0.5, animations: {
                toastLabel.alpha = 0.0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}
