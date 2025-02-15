//
//  TestCollectionReusableView.swift
//  CollectionViewAdapter
//
//  Created by pkh on 16/07/2019.
//  Copyright © 2019 pkh. All rights reserved.
//

import UIKit
import CollectionViewAdapter

class TestCollectionReusableView: UICollectionReusableView, CVACellProtocol {
    static var SpanSize: Int = 0
    var actionClosure: ((String, Any?) -> Void)?

    @IBOutlet weak var label: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        MainActor.assertIsolated()
        MainActor.assumeIsolated {
            self.label.text = "awakeFromNib"
        }
    }

    static func getSize(data: Any?, width: CGFloat, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize {
        return CGSize(width: width, height: self.fromXibSize().height)
    }

    func configure(data: Any?, subData: Any?, collectionView: UICollectionView, indexPath: IndexPath) {
        guard let data = data as? String else { return }
        label.text = data
    }

    @IBAction func onButton(_ sender: UIButton) {
        self.actionClosure?("ReusableView Button", self.label.text)
    }
    // UICollectionViewAdapterCellProtocol Function
    func willDisplay(collectionView: UICollectionView, indexPath: IndexPath) {
//        print("footer willDisplay : \(indexPath)")

    }
    // UICollectionViewAdapterCellProtocol Function
    func didEndDisplaying(collectionView: UICollectionView, indexPath: IndexPath) {
//        print("footer didEndDisplaying : \(indexPath)")
    }

//    static func getSize(data: Any?, width: CGFloat, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize {
//        return CGSize(width: width, height: self.fromXibSize().height)
//    }
}
