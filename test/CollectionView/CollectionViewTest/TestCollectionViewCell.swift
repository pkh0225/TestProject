//
//  TestCollectionViewCell.swift
//  TestProduct
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 11/29/24.
//

import UIKit
import CollectionViewAdapter

class TestCollectionViewCell: UICollectionViewCell, CollectionViewAdapterCellProtocol {
    static var SpanSize: Int = 0
    var actionClosure: ((String, Any?) -> Void)?

    lazy var testLabel: UILabel = {
        let l = UILabel()
        self.contentView.addSubview(l)

        return l
    }()

    lazy var reloadButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "arrow.circlepath"), for: .normal)
        btn.addTarget(self, action: #selector(self.onReloadButton), for: .touchUpInside)
        btn.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.contentView.addSubview(btn)
        return btn
    }()

    lazy var addButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        btn.addTarget(self, action: #selector(self.onAddButton), for: .touchUpInside)
        btn.frame = CGRect(x: self.frame.size.width - 60, y: 0, width: 50, height: 50)
        btn.layer.borderColor = UIColor.red.cgColor
        btn.layer.borderWidth = 1
        self.contentView.addSubview(btn)
        return btn
    }()

    lazy var addSectionButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        btn.addTarget(self, action: #selector(self.onAddSectionButton), for: .touchUpInside)
        btn.frame = CGRect(x: self.frame.size.width - 120, y: 0, width: 50, height: 50)
        btn.layer.borderColor = UIColor.red.cgColor
        btn.layer.borderWidth = 1
        btn.tag = 1
        self.contentView.addSubview(btn)
        return btn
    }()

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
            let cellData = CVACellInfo(cellType: Self.self)

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
                let cellData = CVACellInfo(cellType: Self.self)
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
                    .setDataType("new")
                    .setCells([CVACellInfo(cellType: Self.self).setContentObj("new")])

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
                        if newSectoinIndex < self.indexPath.section {
//                            sectionIndex = self.indexPath.section - 1
//
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

        self.testLabel.text = "\(indexPath.section) / \(indexPath.row)"
        self.testLabel.sizeToFit()
        self.testLabel.centerInSuperView()

        self.reloadButton.tag = indexPath.section
        self.addButton.tag_value = data
        self.addSectionButton.tag_value = data
    }

    static func getSize(data: Any?, width: CGFloat, collectionView: UICollectionView, indexPath: IndexPath) -> CGSize {
        print("getSize : \(indexPath.section) / \(indexPath.row)")
        return CGSize(width: width, height: 50)
    }

}
