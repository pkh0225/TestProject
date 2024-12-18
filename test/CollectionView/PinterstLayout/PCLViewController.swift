//
//  PinterestCompostionalLayoutViewController.swift
//  TestProduct
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 11/27/24.
//

import UIKit
import CollectionViewAdapter
import SwiftHelper
import EasyConstraints

@available(iOS 14.0, *)
class PCLViewController: UIViewController, RouterProtocol {

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.getLayout())
        collectionView.backgroundColor = #colorLiteral(red: 0.9355872273, green: 0.9355872273, blue: 0.9355872273, alpha: 1)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubViewSafeArea(subView: collectionView, safeBottom: false)
        return collectionView
    }()

    private lazy var datas: [PCLItem] = {
        var datas: [PCLItem] = []
        for i in 0..<100 {
            datas.append(PCLItem(text: "\(i)"))
        }
        return datas
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "PinterestCompostionalLayout"
        self.view.backgroundColor = .white

        self.collectionView.adapterData = makeAdapterData()
        self.collectionView.reloadData()
    }

    private func makeAdapterData() -> CVAData {
        let testData = CVAData()
        let sectionInfo = CVASectionInfo()
        testData.sectionList.append(sectionInfo)
        for item in datas {
            let cellInfo = CVACellInfo(PCLTestCell.self)
                .contentObj(item)
                .actionClosure({ (name, object) in
                    guard let object = object else { return }
                    alert(title: name, message: "\(object)")
                })

            sectionInfo.cells.append(cellInfo)
        }

        return testData
    }

    private func createPinterstLayout(env: NSCollectionLayoutEnvironment,
                                      models: [PCLItem]) -> NSCollectionLayoutSection {

        let layout = PinterestCompostionalLayout.makeLayoutSection(
            config: .init(numberOfColumns: 2, // 몇줄?
                          interItemSpacing: 8, // 간격은?
                          contentInsets: .init(top: 10, leading: 10, bottom: 10, trailing: 10),
                          contentInsetsReference: UIContentInsetsReference.automatic, // 알아서
                          itemHeightProvider: { index, _ in
                              return models[index].height
                          },
                          itemCountProfider: {
                              return models.count
                          }),
            environment: env,
            sectionIndex: 0
        )

        return layout

    }

    private func getLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] section, env in
            guard let self else { return nil }
            return createPinterstLayout(env: env, models: datas)
        }

        return layout
    }

}

class PCLTestCell: UICollectionViewCell, CVACellProtocol {
    static var SpanSize: Int = 0
    var actionClosure: ((String, Any?) -> Void)?

    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 30)
        label.textAlignment = .center
        self.contentView.addSubViewAutoLayout(label)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor.random

        let btn = UIButton().apply { btn in
            btn.addAction(for: .touchUpInside) { [weak self] btn in
                self?.actionClosure?("", self?.label.text)
            }
        }

        self.contentView.addSubViewAutoLayout(btn)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func getSize(data: Any?, width: CGFloat, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize {
        return CGSize(width: width, height: 100)
    }

    func configure(data: Any?, subData: Any?, collectionView: UICollectionView, indexPath: IndexPath) {
        guard let data = data as? PCLItem else { return }

        self.label.text = data.text
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.cornerRadius = 10
    }
}

struct PCLItem {
    static let heights: [CGFloat] = [150, 250, 300]
    let text: String
    let height: CGFloat

    init(text: String) {
        self.text = text
        self.height = Self.heights.randomElement() ?? 0
    }
}
