//
//  Untitled.swift
//  CollectionViewAdapter
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 10/30/24.
//  Copyright © 2024 pkh. All rights reserved.
//

import UIKit
import SwiftHelper
import CollectionViewAdapter

class Section: Hashable, @unchecked Sendable {
    let id = UUID()
    var cellItems = [Item]()

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Section, rhs: Section) -> Bool {
        lhs.id == rhs.id
    }
}

class Item: Hashable, @unchecked Sendable {
    let id = UUID()
    var title: String = ""

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }

    init(title: String) {
        self.title = title
    }
}

@available(iOS 13.0, *)
class DiffableDataSourceViewController: UIViewController, RouterProtocol {
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.getLayout())
        collectionView.backgroundColor = .systemGray5
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.register(CompositionalTestCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.alwaysBounceHorizontal = false
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.968627451, blue: 0.9019607843, alpha: 1)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(onTextFieldDidChange(textField:)), for: .editingChanged)
        return textField
    }()

    private lazy var btn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitleColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), for: .normal)
        btn.setTitle("vertical", for: .normal)
        btn.setTitle("horizontal", for: .selected)
        btn.layer.cornerRadius = 10
        btn.layer.masksToBounds = true
        btn.layer.borderWidth = 1
        btn.layer.borderColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1).cgColor
        btn.addAction(for: .touchUpInside) { [weak self] _ in
            guard let self else { return }
            self.collectionView.isPagingEnabled = self.btn.isSelected
            self.btn.isSelected.toggle()
            self.collectionView.collectionViewLayout = self.getLayout()
            self.collectionView.contentOffset = .zero
        }
        return btn
    }()

    private var dataSource: DataSource!
    @Atomic private var testItems = [Section]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "Diffable Data Source"

        self.MakeAutoLayout()

        self.testItems = makeData()
//        self.collectionView.dataSource = self

        dataSource = DataSource(collectionView: collectionView) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let self else { return nil }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CompositionalTestCell
            cell.actionClosure = { [weak self] _, _ in
                guard let self else { return }
                print("select indexPath section: \(indexPath.section), item: \(indexPath.item)")
                if indexPath.item == 0 {
                    self.updateItem(item: item, indexPath: indexPath)
                }
                else if cell.label.text == "new item" {
                    self.deleteItem(item: item, indexPath: indexPath)
                }
                else {
                    self.addNewItem(item: item, indexPath: indexPath)
                }
            }
            cell.configure(data: item.title, subData: nil, collectionView: collectionView, indexPath: indexPath)
            return cell
        }

        var snapshot = Snapshot()
        snapshot.appendSections(testItems)
        testItems.forEach { snapshot.appendItems($0.cellItems, toSection: $0) }
        dataSource.apply(snapshot, animatingDifferences: true)

    }

    private func MakeAutoLayout() {
        self.view.addSubviews([textField, btn, collectionView])
        textField.ec.make()
            .leading(self.view.safeAreaLayoutGuide.leadingAnchor, 15)
            .top(self.view.safeAreaLayoutGuide.topAnchor, 0)
            .bottom(collectionView.topAnchor, -10)
            .height(50)

        btn.ec.make()
            .leading(textField.trailingAnchor, 10)
            .trailing(self.view.safeAreaLayoutGuide.trailingAnchor, -10)
            .centerY(textField.centerYAnchor, 0)
            .width(100)
            .height(50)

        collectionView.ec.make()
            .leading(self.view.safeAreaLayoutGuide.leadingAnchor, 0)
            .trailing(self.view.safeAreaLayoutGuide.trailingAnchor, 0)
            .bottom(self.view.bottomAnchor, 0)

    }

    private func addNewItem(item: Item, indexPath: IndexPath) {
        let newItem = Item(title: "new item")
        self.testItems[indexPath.section].cellItems.insert(newItem, at: indexPath.item + 1)

        var snapshot = dataSource.snapshot()
        snapshot.insertItems([newItem], afterItem: item)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func deleteItem(item: Item, indexPath: IndexPath) {
        self.testItems[indexPath.section].cellItems.remove(at: indexPath.item)

        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([item])
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func updateItem(item: Item, indexPath: IndexPath) {
//        self.testItems[indexPath.section].subItems[indexPath.item].title = "update item"
        item.title = "updated item"
        var snapshot = dataSource.snapshot()
        if #available(iOS 15.0, *) {
            snapshot.reconfigureItems([item])
        }
        else {
            snapshot.reloadItems([item])
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func getLayout() -> UICollectionViewLayout {
        if self.btn.isSelected {
            return getGridSection()
        }
        else {
            return getListSection()
        }
    }

    private func getGridSection() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 10
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { sectionIndex, env -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.8),
                heightDimension: .absolute(50)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .absolute(170)
            )
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )
            group.interItemSpacing = NSCollectionLayoutSpacing.fixed(10)

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            section.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 20, trailing: 15)
            section.interGroupSpacing = 8


            // Decoration Item 추가
            let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "BackgroundDecorationView")
            section.decorationItems = [decorationItem]

            return section
        }

        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: configuration)
        layout.register(BackgroundDecorationView.self, forDecorationViewOfKind: "BackgroundDecorationView")
        return layout
    }

    private func getListSection() -> UICollectionViewCompositionalLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { sectionIndex, env -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .absolute(50)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: 1
            )

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0)
            section.interGroupSpacing = 10

            // Decoration Item 추가
            let decorationItem = NSCollectionLayoutDecorationItem.background(elementKind: "BackgroundDecorationView")
            section.decorationItems = [decorationItem]

            return section
        }

        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: configuration)
        layout.register(BackgroundDecorationView.self, forDecorationViewOfKind: "BackgroundDecorationView")
        return layout
    }

    @objc private func onTextFieldDidChange(textField: UITextField) {
        if let text = textField.text {
            print(text)
            var snapshot = Snapshot()
            if text.isEmpty {
                snapshot.appendSections(testItems)
                testItems.forEach { snapshot.appendItems($0.cellItems, toSection: $0) }
            }
            else {
                let filtered = testItems.flatMap { section in
                    section.cellItems.filter { item in
                        item.title.contains(text)
                    }
                }

                snapshot.appendSections([Section()])
                snapshot.appendItems(filtered)
            }
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }

    private func makeData() -> [Section] {
        var testData = [Section]()
        for i in 0...5 {
            let section = Section()
            for j in 0...30 {
                let item = Item(title: "cell (\(i) : \(j))")
                section.cellItems.append(item)
            }
            testData.append(section)
        }

        return testData
    }
}

@available(iOS 13.0, *)
extension DiffableDataSourceViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        guard let cell = cell as? CompositionalTestCell else { return }
//        print("will display cell at section: \(indexPath.section), item: \(indexPath.item)")
    }
}

extension DiffableDataSourceViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("scrollViewDidScroll : \(scrollView.contentOffset)")
    }
}


//@available(iOS 13.0, *)
//extension DiffableDataSourceViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        return UICollectionViewCell()
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 100
//    }
//}
