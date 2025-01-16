//
//  CompositionalTestCell.swift
//  CollectionViewAdapter
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 10/30/24.
//  Copyright © 2024 pkh. All rights reserved.
//

import UIKit
import CollectionViewAdapter
import SwiftHelper
import EasyConstraints

class CompositionalTestCell: UICollectionViewCell, CVACellProtocol {
    static var SpanSize: Int = 0
    var actionClosure: ((String, Any?) -> Void)?

    lazy var label: UILabel = {
        UILabel(frame: frame).apply {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.numberOfLines = 1
            $0.textAlignment = .center
        }
    }()

    lazy var button: UIButton = {
        UIButton(frame: frame).apply {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.addTarget(self, action: #selector(self.onBtnAction), for: .touchUpInside)
        }
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentView.apply {
            $0.addSubViewAutoLayout(label, edgeInsets: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
            $0.addSubViewAutoLayout(button)
        }
        UIColor.random.apply {
            self.contentView.backgroundColor = $0
            self.label.textColor = $0.getComplementaryForColorUsingHSB()
        }
    }

    
    static func getSize(data: Any?, width: CGFloat, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize {
        return CGSize(width: width, height: self.fromXibSize().height)
    }

    func configure(data: Any?, subData: Any?, collectionView: UICollectionView, indexPath: IndexPath) {
        guard let data = data as? String else { return }
        self.label.text = data


    }

    @objc func onBtnAction(btn: UIButton) {
        self.actionClosure?("", self.label.text)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.layer.apply {
            if indexPath.section == 0 || indexPath.section == 1 {
                $0.cornerRadius = self.frame.size.height / 2.0
                $0.borderWidth = 1
                $0.borderColor = UIColor.gray.cgColor
            }
            else {
                $0.cornerRadius = 10
                $0.borderWidth = 0
                $0.borderColor = UIColor.clear.cgColor
            }
        }
    }
}

class BackgroundDecorationView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 10 // 모서리 둥글기 설정

        self.backgroundColor = .random
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
