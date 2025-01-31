//
//  CollectionViewTextController.swift
//  TestProduct
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 10/19/23.
//

import UIKit
import SwiftHelper
import CollectionViewAdapter
import EasyConstraints

class CollectionViewTestViewController: UIViewController, RouterProtocol {
    static var storyboardName: String = "Main"


    @IBOutlet weak var collectionView: UICollectionView!


    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView
            .adapterData(makeApterData())
            .reloadData()
    }

    func makeApterData() -> CVAData {
        let adapterData = CVAData()

        for _ in 0..<10 {
            let sectionData = CVASectionInfo()
            for _ in 0..<4 {
                let cellData = CVACellInfo(TestCollectionViewCell.self)
                sectionData.addCell(cellData)
            }
            adapterData.addSection(sectionData)
        }

        return adapterData
    }
}
