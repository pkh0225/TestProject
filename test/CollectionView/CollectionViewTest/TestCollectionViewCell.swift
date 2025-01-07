//
//  TestCollectionViewCell.swift
//  TestProduct
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 11/29/24.
//

import UIKit
import CollectionViewAdapter
import EasyConstraints

class TestCollectionViewCell: UICollectionViewCell, CollectionViewAdapterCellProtocol {
    static var SpanSize: Int = 0
    var actionClosure: ((String, Any?) -> Void)?

    lazy var titleLable: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    lazy var reloadButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "arrow.circlepath"), for: .normal)
        btn.addTarget(self, action: #selector(self.onReloadButton), for: .touchUpInside)
        btn.layer.borderColor = UIColor.red.cgColor
        btn.layer.borderWidth = 0.5
        btn.ec.make()
            .width(50)
            .height(50)

        return btn
    }()

    lazy var addButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        btn.addTarget(self, action: #selector(self.onAddButton), for: .touchUpInside)
        btn.layer.borderColor = UIColor.red.cgColor
        btn.layer.borderWidth = 0.5
        btn.ec.make()
            .width(50)
            .height(50)
        return btn
    }()

    lazy var addSectionButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        btn.addTarget(self, action: #selector(self.onAddSectionButton), for: .touchUpInside)
        btn.layer.borderColor = UIColor.red.cgColor
        btn.layer.borderWidth = 0.5
        btn.tag = 1
        btn.ec.make()
            .width(50)
            .height(50)
        return btn
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)

        let stv = UIStackView(arrangedSubviews: [reloadButton, titleLable, addSectionButton, addButton]).apply {
            $0.axis = .horizontal
            $0.spacing = 10
            $0.alignment = .center
            $0.distribution = .fill
            $0.isLayoutMarginsRelativeArrangement = true
            $0.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }
        self.contentView.addSubViewAutoLayout(stv)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onReloadButton(btn: UIButton) {
        if self.indexPath.row == 0 {
            print("reloadSections: \(self.indexPath.section)")
            self.parentCollectionView?.cacheRemoveAfterReloadSections(IndexSet(integer: self.indexPath.section))
        }
        else {
            print("reloadItems: \(self.indexPath)")
            self.parentCollectionView?.cacheRemoveAfterReloadItems(at: [self.indexPath])
        }
    }

    @objc func onAddButton(btn: UIButton) {
        print("onAddButton: \(self.indexPath)")

        if let adapterData = self.parentCollectionView?.adapterData {
            let sectionData = adapterData.sectionList[self.indexPath.section]
            let cellData = CVACellInfo(Self.self)

//            UIView.animate(withDuration: 0.1) {
//                sectionData.cells.insert(cellData, at: self.indexPath.row + 1)
//                self.parentCollectionView?.insertItems(at: [ IndexPath(row: self.indexPath.row + 1, section: self.indexPath.section) ])
//            } completion: { _ in
//                self.parentCollectionView?.reloadData()
//            }
            parentCollectionView?.performBatchUpdates({
                sectionData.cells.insert(cellData, at: self.indexPath.row + 1)
                self.parentCollectionView?.insertItems(at: [ IndexPath(row: self.indexPath.row + 1, section: self.indexPath.section) ])
            }, completion: { _ in
                self.parentCollectionView?.reloadData()
            })
        }
    }

    @objc func onAddSectionButton(btn: UIButton) {
        print("onAddSectionButton: \(self.indexPath)")

        if btn.tag == 0 {
            if let adapterData = self.parentCollectionView?.adapterData {
                let sectionData = CVASectionInfo()
                let cellData = CVACellInfo(Self.self)
                sectionData.cells.append(cellData)

                parentCollectionView?.performBatchUpdates({
                    adapterData.sectionList.insert(sectionData, at: self.indexPath.section + 1)
                    self.parentCollectionView?.insertSections(IndexSet(integer: self.indexPath.section + 1))
                }, completion: { _ in
                    self.parentCollectionView?.reloadData()
                })
            }
        }
        else {
            if let adapterData = self.parentCollectionView?.adapterData {
                let sectionList1 = CVASectionInfo()
                let sectionList2 = CVASectionInfo()

                for (idx,cell) in adapterData.sectionList[self.indexPath.section].cells.enumerated() {
                    if idx <= self.indexPath.row {
                        sectionList1.cells.append(cell)
                    }
                    else {
                        sectionList2.cells.append(cell)
                    }
                }

                let sectionInsert = CVASectionInfo()
                    .dataType("new")
                    .cells([CVACellInfo(Self.self).contentObj("new")])

                parentCollectionView?.performBatchUpdates({
                    var newSectoinIndex = -1
                    for (idx, data) in adapterData.sectionList.enumerated() {
                        if data.dataType == "new" {
                            newSectoinIndex = idx
                            break
                        }
                    }
                    if newSectoinIndex > -1 {
                        adapterData.sectionList.remove(at: newSectoinIndex)
                        self.parentCollectionView?.deleteSections(IndexSet(integer: newSectoinIndex))

                        let sectionIndex: Int
                        if newSectoinIndex <= self.indexPath.section {
//                            sectionIndex = self.indexPath.section

//                            adapterData.sectionList.remove(at: sectionIndex )
//                            self.parentCollectionView?.deleteSections(IndexSet(integer: sectionIndex ))

//                            if sectionList1.cells.count > 0 {
//                                adapterData.sectionList.insert(sectionList1, at: sectionIndex)
//                                self.parentCollectionView?.insertSections(IndexSet(integer: sectionIndex))
//                            }
//
//                            adapterData.sectionList.insert(sectionInsert, at: sectionIndex + 1)
//                            self.parentCollectionView?.insertSections(IndexSet(integer: sectionIndex + 1))
//
//                            if sectionList2.cells.count > 0 {
//                                adapterData.sectionList.insert(sectionList2, at: sectionIndex + 2)
//                                self.parentCollectionView?.insertSections(IndexSet(integer: sectionIndex + 2))
//                            }
                        }
                        else {
                            sectionIndex = self.indexPath.section

                            adapterData.sectionList.remove(at: sectionIndex)
                            self.parentCollectionView?.deleteSections(IndexSet(integer: sectionIndex))

                            if sectionList1.cells.count > 0 {
                                adapterData.sectionList.insert(sectionList1, at: sectionIndex)
                                self.parentCollectionView?.insertSections(IndexSet(integer: sectionIndex))
                            }

                            adapterData.sectionList.insert(sectionInsert, at: sectionIndex + 1)
                            self.parentCollectionView?.insertSections(IndexSet(integer: sectionIndex + 1))

                            if sectionList2.cells.count > 0 {
                                adapterData.sectionList.insert(sectionList2, at: sectionIndex + 2)
                                self.parentCollectionView?.insertSections(IndexSet(integer: sectionIndex + 2))
                            }
                        }
                    }
                    else {
                        adapterData.sectionList.remove(at: self.indexPath.section)
                        self.parentCollectionView?.deleteSections(IndexSet(integer: self.indexPath.section))

                        if sectionList1.cells.count > 0 {
                            adapterData.sectionList.insert(sectionList1, at: self.indexPath.section)
                            self.parentCollectionView?.insertSections(IndexSet(integer: self.indexPath.section))
                        }
                        adapterData.sectionList.insert(sectionInsert, at: self.indexPath.section + 1)
                        self.parentCollectionView?.insertSections(IndexSet(integer: self.indexPath.section + 1))

                        if sectionList2.cells.count > 0 {
                            adapterData.sectionList.insert(sectionList2, at: self.indexPath.section + 2)
                            self.parentCollectionView?.insertSections(IndexSet(integer: self.indexPath.section + 2))
                        }
                    }

                }, completion: { _ in
                    self.parentCollectionView?.reloadData()
                })

            }
        }
    }


    func configure(data: Any?, subData: Any?, collectionView: UICollectionView, indexPath: IndexPath) {
        print("configure: \(indexPath.section) / \(indexPath.row)")
        let data = data as? String ?? ""
        self.backgroundColor = data == "new" ? .blue : .green

        self.titleLable.text = "\(indexPath.section) / \(indexPath.row)"
//        self.titleLable.sizeToFit()
//        self.titleLable.centerInSuperView()

        self.reloadButton.tag = indexPath.section
        self.addButton.tag_value = data
        self.addSectionButton.tag_value = data
    }

    static func getSize(data: Any?, width: CGFloat, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize {
        print("getSize : \(indexPath.section) / \(indexPath.row)")
        return CGSize(width: width, height: 50)
    }

}
