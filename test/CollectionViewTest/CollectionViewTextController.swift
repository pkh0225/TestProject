//
//  CollectionViewTextController.swift
//  TestProduct
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 10/19/23.
//

import UIKit
import CollectionViewAdapter

class CollectionViewTestViewController: UIViewController, RouterProtocol {
    static var storyboardName: String = "Main"


    @IBOutlet weak var rightGapTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!


    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.adapterData = makeApterData()
        collectionView.reloadData()

    }

    func makeApterData() -> UICollectionViewAdapterData {
        let adapterData = UICollectionViewAdapterData()
        let sectionData = UICollectionViewAdapterData.SectionInfo()
        for _ in 0..<10 {
            let cellData = UICollectionViewAdapterData.CellInfo(contentObj: nil, cellType: TestCell.self)
            sectionData.cells.append(cellData)
        }
        adapterData.sectionList.append(sectionData)
        return adapterData
    }
}


class TestCell: UICollectionViewCell, UICollectionViewAdapterCellProtocol {
    static var SpanSize: Int = 2

    var actionClosure: CollectionViewAdapter.ActionClosure?
    

    func configure(data: Any?, subData: Any?, collectionView: UICollectionView, indexPath: IndexPath, actionClosure: CollectionViewAdapter.ActionClosure?) {
        self.backgroundColor = .green
    }

    static func getSize(data: Any?, width: CGFloat, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }

}

extension CollectionViewTestViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.collectionView.ec.trailing = textField.text?.toCGFloat() ?? 0
        return true
      }
}

extension String {
    ///   Converts String to CGFloat
    public func toCGFloat() -> CGFloat {
        if let num = NumberFormatter().number(from: self) {
            return CGFloat(num.floatValue)
        }
        else {
            return 0
        }
    }
}
