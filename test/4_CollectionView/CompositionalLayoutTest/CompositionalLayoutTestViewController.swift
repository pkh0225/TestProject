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
class CompositionalLayoutTestViewController: UIViewController, RouterProtocol {

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.getLayout())
        collectionView.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.scrollViewDelegate = self
        collectionView.contentInset = .init(top: 10, left: 0, bottom: 10, right: 0)
        collectionView.automaticallyAdjustsScrollIndicatorInsets = false
        collectionView.contentInsetAdjustmentBehavior = .never
        self.view.addSubViewSafeArea(subView: collectionView, safeBottom: false)

//        collectionView.dataSource = self
//        collectionView.registerHeader(TestCollectionReusableView.self)
//        collectionView.register(CompositionalTestCell.self)

        return collectionView
    }()

    private var dataSource: [SectionItem]!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "CompositionalLayout"
        self.view.backgroundColor = .white
        self.setData()
//        for _ in 0..<10 {
//            self.dataSource.append(.init(text: "header",
//                                         layoutType: .horizontalList2,
//                                         subItems: [.init(text: "사과"),
//                                                    .init(text: "사과"),
//                                                    .init(text: "사과"),
//                                                    .init(text: "사과"),
//                                                    .init(text: "사과"),
//                                                    .init(text: "사과"),
//                                                    .init(text: "사과"),
//                                                    .init(text: "사과"),
//                                                    .init(text: "사과"),
//                                                    .init(text: "사과"),
//                                                    .init(text: "사과"),
//                                                    .init(text: "사과")]))
//        }

        self.collectionView.adapterData = makeAdapterData()
        self.collectionView.reloadData()
    }

    func setData() {
        dataSource = [
            .init(text: "header",
                  layoutType: .horizontalListAutoSize,
                  subItems: [.init(text: "사과"),
                             .init(text: "사과ㄴㅁㅇㅎ"),
                             .init(text: "사과ㅁㄴㅇㅎㅁㄴㅇㅎㅎ"),
                             .init(text: "사과"),
                             .init(text: "사과ㅁㄴㅇㅎㅁㄴㅇㅎ"),
                             .init(text: "사과ㅁㅇㅎ"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과ㅁㄴㅇㅎㅇㄴㅁ"),
                             .init(text: "사과"),
                             .init(text: "사과ㅁㄴㅇㅎ"),
                             .init(text: "사과")]),
            .init(text: "header",
                  layoutType: .gridAutoSize,
                  subItems: [.init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과ㅁㄴㅇㅎ"),
                             .init(text: "사과"),
                             .init(text: "사과ㅁㅇㅇ"),
                             .init(text: "사과"),
                             .init(text: "사과ㅇㅇㅇ"),
                             .init(text: "사과ㅁㅇㅇ"),
                             .init(text: "사과"),
                             .init(text: "사과ㅇㅇㅇ"),
                             .init(text: "사과ㅁㅇㅇ"),
                             .init(text: "사과"),
                             .init(text: "사과ㅇㅇㅇ"),
                             .init(text: "사과ㅇㅇㅇ"),
                             .init(text: "사과")]),
            .init(text: "header",
                  layoutType: .horizontalList1,
                  subItems: [.init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과")]),
            .init(text: "header",
                  layoutType: .horizontalList2,
                  subItems: [.init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과")]),
            .init(text: "header",
                  layoutType: .groups,
                  subItems: [.init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과"),
                             .init(text: "사과")]),

        ]
    }

    var indexPath: IndexPath?

    private func makeAdapterData() -> CVAData {
        let testData = CVAData()
        for (s, sectionItem) in dataSource.enumerated() {
            let sectionInfo = CVASectionInfo()
            testData.sectionList.append(sectionInfo)
            sectionInfo.header = CVACellInfo(TestCollectionReusableView.self)
                .contentObj("\(sectionItem.text) \(s)")
                .actionClosure({ (name, object) in
                    alert(title: name, message: "\(String(describing: object))")
                })

            for (i, subItem) in sectionItem.subItems.enumerated() {
                let cellInfo = CVACellInfo(CompositionalTestCell.self)
                    .contentObj("\(subItem.text) \(i)")
                    .actionClosure({ [weak self] (name, object) in
                        guard let self else { return }
//                        guard let object = object else { return }
//                        alert(title: name, message: "\(object)")
                        self.indexPath = IndexPath(item:i, section: s)
                        self.collectionView.scrollToItem(at: IndexPath(item:i, section: s), at: .centeredHorizontally, animated: true)
//                        self.collectionView.contentOffset = CGPoint(x: 0, y: 100)
//                        self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
                    })

                sectionInfo.cells.append(cellInfo)
            }
        }

        return testData
    }

    private func getLayout() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 20
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { sectionIndex, env -> NSCollectionLayoutSection? in
            switch self.dataSource[sectionIndex].layoutType {
            case .horizontalListAutoSize:
                return self.getListSectionAutoSize()
            case .gridAutoSize:
                return self.getGridSection()
            case .horizontalList1:
                return self.getListSection(height: 0.3, env: env)
            case .horizontalList2:
                return self.getListSection(height: 0.13, env: env)
            case .groups:
                return self.getGroupsSection()
            }
        }
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: configuration)
        layout.register(BackgroundDecorationView.self, forDecorationViewOfKind: "BackgroundDecorationView")
        return layout
        
    }


    var offset: CGPoint = .zero
    var isSave = true

    private func getListSectionAutoSize() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(30),
            heightDimension: .estimated(30)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .estimated(30),
            heightDimension: .estimated(30)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)
        section.interGroupSpacing = 8
        section.visibleItemsInvalidationHandler = { [weak self] (visibleItems, offset, env) in
            //            print("sub scrollView \(offset)")
            guard let self = self else { return }
            if isSave {
                print("offset : \(offset)")
                self.offset = offset
            }

//            let normalizedOffsetX = offset.x
//            let centerPoint = CGPoint(x: normalizedOffsetX + ss.collectionView.bounds.width / 2, y: 20)
//            visibleItems.forEach({ item in
//                guard let cell = ss.collectionView.cellForItem(at: item.indexPath) else { return }
//                UIView.animate(withDuration: 0.3) {
//                    cell.transform = item.frame.contains(centerPoint) ? .identity : CGAffineTransform(scaleX: 0.9, y: 0.9)
//                }
//            })
        }

        // sectionHeader 사이즈 설정
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
//            ,absoluteOffset: CGPoint(x: 0, y: -50)
        )
//        sectionHeader.pinToVisibleBounds = true
//        sectionHeader.extendsBoundary = true

        // section에 헤더 추가
        section.boundarySupplementaryItems = [sectionHeader]

        // Decoration Item 추가
        let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "BackgroundDecorationView")
        section.decorationItems = [decorationItem]
        return section
    }

    private func getGridSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(50),
            heightDimension: .estimated(30)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
//        item.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: NSCollectionLayoutSpacing.fixed(0),
//                                                         top: NSCollectionLayoutSpacing.fixed(0),
//                                                         trailing: NSCollectionLayoutSpacing.fixed(8),
//                                                         bottom: NSCollectionLayoutSpacing.fixed(0))
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(30)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(8)
//        group.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)
        section.interGroupSpacing = 8

        // sectionHeader 사이즈 설정
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        // section에 헤더 추가
        section.boundarySupplementaryItems = [sectionHeader]

        // Decoration Item 추가
        let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "BackgroundDecorationView")
        section.decorationItems = [decorationItem]
        return section
    }

    private func getListSection(height: CGFloat, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.35),
            heightDimension: .fractionalHeight(height)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        //        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(8)
        //        let group = NSCollectionLayoutGroup.horizontal(
        //            layoutSize: groupSize,
        //            subitem: item,
        //            count: 4
        //        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)
        section.interGroupSpacing = 8
        //        section.visibleItemsInvalidationHandler = { [weak self] (visibleItems, offset, env) in
        //            //            print("sub scrollView \(offset)")
        //            guard let ss = self else { return }
        //            let normalizedOffsetX = offset.x
        //            let centerPoint = CGPoint(x: normalizedOffsetX + ss.collectionView.bounds.width / 2, y: 20)
        //            visibleItems.forEach({ item in
        //                guard let cell = ss.collectionView.cellForItem(at: item.indexPath) else { return }
        //                UIView.animate(withDuration: 0.3) {
        //                    cell.transform = item.frame.contains(centerPoint) ? .identity : CGAffineTransform(scaleX: 0.9, y: 0.9)
        //                }
        //            })
        //        }

        // sectionHeader 사이즈 설정
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .absolute(env.container.effectiveContentSize.width - 30),
            heightDimension: .absolute(50)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        // section에 헤더 추가
        section.boundarySupplementaryItems = [sectionHeader]

        // Decoration Item 추가
        let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "BackgroundDecorationView")
        section.decorationItems = [decorationItem]

        return section
    }

    func getGroupsSection() -> NSCollectionLayoutSection {
        let leadingItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let leadingItem = NSCollectionLayoutItem(layoutSize: leadingItemSize)
        leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 8)
        let leadingGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.7),
            heightDimension: .fractionalHeight(1)
        )
        let leadingGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: leadingGroupSize,
            subitem: leadingItem,
            count: 1
        )

        let trailingItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let trailingItem = NSCollectionLayoutItem(layoutSize: trailingItemSize)
        trailingItem.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 16)
        let trailingGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.3),
            heightDimension: .fractionalHeight(1)
        )
        let trailingGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: trailingGroupSize,
            subitem: trailingItem,
            count: 2
        )

        let containerGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(250)
        )
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: containerGroupSize,
            subitems: [leadingGroup, trailingGroup]
        )

        let section = NSCollectionLayoutSection(group: containerGroup)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)

        // Decoration Item 추가
        let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "BackgroundDecorationView")
        section.decorationItems = [decorationItem]

        return section
    }

}

extension CompositionalLayoutTestViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll : \(scrollView.contentOffset)")
    }
}


private struct SectionItem {
    enum layoutType {
        case gridAutoSize
        case horizontalList1
        case horizontalList2
        case horizontalListAutoSize
        case groups
    }

    struct SubItem {
        let text: String
    }

    let text: String
    let layoutType: layoutType
    let subItems: [SubItem]
}


extension CompositionalLayoutTestViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource[section].subItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(CompositionalTestCell.self, for: indexPath)

        let data = dataSource[indexPath.section].subItems[indexPath.item].text
        cell.configure(data: data, subData: nil, collectionView: collectionView, indexPath: indexPath)
        cell.actionClosure = { [weak self] (_, _) in
            guard let self else { return }
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if kind == UICollectionView.elementKindSectionHeader {
            let view = collectionView.dequeueReusableHeader(TestCollectionReusableView.self, for: indexPath)
            let data = "\(dataSource[indexPath.section].text) \(indexPath.section)"
            view.configure(data: data, subData: nil, collectionView: collectionView, indexPath: indexPath)
            view.actionClosure = { [weak self] (_, _) in
                guard let self else { return }
                self.setData()
                self.collectionView.reloadData()
            }
            return view
        } else {
            return UICollectionReusableView()
        }
    }



}
