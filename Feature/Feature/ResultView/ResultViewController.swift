//
//  ResultViewController.swift
//  Feature
//
//  Created by 디해 on 12/6/24.
//

import UIKit

public final class ResultViewController: UIViewController {
    private let mainLabel = UILabel()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViewAttributes()
        setupViewHierarchies()
        setupViewConstraints()
        setupMainLabel()
    }
}

// MARK: - Setting
private extension ResultViewController {
    func setupViewAttributes() {
        view.backgroundColor = UIColor.black
    }
    
    func setupViewHierarchies() {
        view.addSubview(mainLabel)
    }
    
    func setupViewConstraints() {
        mainLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func setupMainLabel() {
        mainLabel.text = "성공적으로\n동영상을 저장했어요! 🥳"
        mainLabel.font = UIFont.boldSystemFont(ofSize: 20)
        mainLabel.textColor = .white
        mainLabel.numberOfLines = 0
        mainLabel.textAlignment = .center
    }
}
