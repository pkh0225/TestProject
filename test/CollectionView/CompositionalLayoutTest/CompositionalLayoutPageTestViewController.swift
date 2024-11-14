//
//  Untitled.swift
//  TestProduct
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 10/29/24.
//

import UIKit
import CollectionViewAdapter
import SwiftHelper
import EasyConstraints

@available(iOS 13.0, *)
class CompositionalLayoutPageTestViewController: UIViewController, RouterProtocol {

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.getLayout())
        collectionView.backgroundColor = #colorLiteral(red: 0.9355872273, green: 0.9355872273, blue: 0.9355872273, alpha: 1)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isPagingEnabled = true
        self.view.addSubViewSafeArea(subView: collectionView, safeBottom: false)
        return collectionView
    }()

    private lazy var dataSource: [SectionItem] = {
        var data = [SectionItem]()
        for i in 0..<5 {
            var subItems = [SubItem]()
            for j in 0..<2 {
                subItems.append(SubItem(text: "item \(i) : \(j)"))
            }
            data.append(SectionItem(text: "header \(i)", subItems: subItems))
        }
        return data
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "CompositionalLayout"
        self.view.backgroundColor = .white

        self.collectionView.adapterData = makeAdapterData()
        self.collectionView.reloadData()
    }

    private func makeAdapterData() -> CVAData {
        let testData = CVAData()
        for (s, sectionItem) in dataSource.enumerated() {
            let sectionInfo = CVASectionInfo()
            testData.sectionList.append(sectionInfo)
//            sectionInfo.header = CVACellInfo(cellType: TestCollectionReusableView.self)
//                .setContentObj("\(sectionItem.text) \(s)")
//                .setActionClosure({ [weak self] (name, object) in
//                    guard let self else { return }
//                    guard let object = object else { return }
//
//                    alert(vc: self, title: "", message: "\(object) : \(name)")
//                })

            for (i, subItem) in sectionItem.subItems.enumerated() {
                if i == 0 {
                    let cellInfo = CVACellInfo(cellType: PageTestSubPageCell.self)
                        .setContentObj(subItem)
                        .setActionClosure({ [weak self] (name, object) in
                            guard let self else { return }
                            guard let object = object else { return }
                            alert(vc: self, title: name, message: "\(object)")
                            self.collectionView.scrollToItem(at: IndexPath(item: i, section: s), at: .centeredHorizontally, animated: true)
                        })

                    sectionInfo.cells.append(cellInfo)
                }
                else {
                    let cellInfo = CVACellInfo(cellType: PageTestCell.self)
                        .setContentObj(subItem.text)
                        .setActionClosure({ [weak self] (name, object) in
                            guard let self else { return }
                            guard let object = object else { return }
                            alert(vc: self, title: name, message: "\(object)")
                            self.collectionView.scrollToItem(at: IndexPath(item: i, section: s), at: .centeredHorizontally, animated: true)
                        })

                    sectionInfo.cells.append(cellInfo)
                }
            }
        }

        return testData
    }

    private func getLayout() -> UICollectionViewCompositionalLayout {
        return pageSectoin()
    }


    private func pageSectoin() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { sectionIndex, env -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(400)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let itemSize2 = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(800)
            )
            let item2 = NSCollectionLayoutItem(layoutSize: itemSize2)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(500)
            )
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item, item2]
            )
            group.interItemSpacing = NSCollectionLayoutSpacing.fixed(10)

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)
            // Decoration Item 추가
            let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "BackgroundDecorationView")
            section.decorationItems = [decorationItem]

            return section
        }

        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: configuration)
        layout.register(BackgroundDecorationView.self, forDecorationViewOfKind: "BackgroundDecorationView")
        return layout
    }

}

private struct SectionItem {
    let text: String
    let subItems: [SubItem]
}

private struct SubItem {
    let text: String
}

class PageTestCell: UICollectionViewCell, CVACellProtocol {
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
        self.contentView.backgroundColor = randomColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func getSize(data: Any?, width: CGFloat, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize {
        return CGSize(width: width, height: 100)
    }

    func configure(data: Any?, subData: Any?, collectionView: UICollectionView, indexPath: IndexPath) {
        guard let data = data as? String else { return }

        self.label.text = data
    }
}

class PageTestSubPageCell: UICollectionViewCell, CVACellProtocol {
    static var SpanSize: Int = 0
    var actionClosure: ((String, Any?) -> Void)?

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.getLayout())
        collectionView.backgroundColor = #colorLiteral(red: 0.9355872273, green: 0.9355872273, blue: 0.9355872273, alpha: 1)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isPagingEnabled = true
        collectionView.tag = 100
        collectionView.bounces = false
        self.contentView.addSubViewAutoLayout(collectionView)
        return collectionView
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 0.5214445153)
        label.textColor = .black
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Sub Page CollectionView"
        self.contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
        ])
        return label
    }()

    private lazy var dataSource: [SubItem] = {
        var subItems = [SubItem]()
        for i in 0..<3 {
            subItems.append(SubItem(text: "subItem \(i)"))
        }
        return subItems
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        self.collectionView.isHidden = false
        self.label.isHidden = false

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func getSize(data: Any?, width: CGFloat, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize {
        return CGSize(width: width, height: 100)
    }

    func configure(data: Any?, subData: Any?, collectionView: UICollectionView, indexPath: IndexPath) {

        self.collectionView.adapterData = self.makeAdapterData()
        self.collectionView.reloadData()
    }

    func willDisplay(collectionView: UICollectionView, indexPath: IndexPath) {
        self.collectionView.scrollViewDelegate = self
//        self.parentCollectionView?.scrollViewDelegate = self
    }

    private func getLayout() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { sectionIndex, env -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 30, bottom: 30, trailing: 30)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)

            return section
        }

        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: configuration)
        return layout
    }

    private func makeAdapterData() -> CVAData {
        let testData = CVAData()
        let sectionInfo = CVASectionInfo()
        testData.sectionList.append(sectionInfo)
        for (_, subItem) in dataSource.enumerated() {
            let cellInfo = CVACellInfo(cellType: PageTestCell.self)
                .setContentObj(subItem.text)
            sectionInfo.cells.append(cellInfo)
        }

        return testData
    }
}


extension PageTestSubPageCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("\(scrollView.tag) offset = \(scrollView.contentOffset)")
//        // BscrollView의 스크롤이 끝에 도달했을 때
//        if scrollView == self.collectionView {
//            let contentOffsetX = scrollView.contentOffset.x
//            let maxOffsetX = scrollView.contentSize.width - scrollView.bounds.width
//
//            // 스크롤이 콘텐츠의 끝에 도달했을 때 AscrollView에 스크롤 이벤트 전달
//            if contentOffsetX <= 0 || contentOffsetX >= maxOffsetX {
//                scrollView.isScrollEnabled = true
//            } else {
//                scrollView.isScrollEnabled = false
//            }
//            print("self.scrollView?.isScrollEnabled: \(scrollView.isScrollEnabled)")
//        }
    }

//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        if scrollView == self.collectionView {
//            if (scrollView.contentOffset.x <= 0)
//                || (scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.frame.size.width) {
//                scrollView.isScrollEnabled = false
//            }
//        }
//    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == self.collectionView {
            scrollView.isScrollEnabled = true
        }
    }

}
