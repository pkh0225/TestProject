//
//  ViewController.swift
//  Test
//
//  Created by pkh on 2018. 8. 14..
//  Copyright © 2018년 pkh. All rights reserved.
//

import UIKit
import PkhGridView
import SwiftHelper

class GridViewTestController: UIViewController, RouterProtocol {
    static var storyboardName: String = "Main"


    @IBOutlet weak var gridView: PkhGridView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "GridView"


        let texts = ["테스트1","테스트2","테스트3","테스트4","테스트5","테스트6","테스트7","테스트8","테스트9"]

        let gridListData = GridViewListData()
        // 그리드뷰에 셋팅된 뷰를 사용하기에 CellType을 따호 하지 않는다.
        for item in texts {
            let gridViewData = GridViewData()
                .setContentObj(item)
                .setSubData(nil)
                .setActionClosure( { (name, object) in
                    alert(title: "\(name)", message: String(describing: object))
                })
            gridListData.itemList.append(gridViewData)
        }

        // 그리드뷰에 셋팅된 뷰를 사용하지 않고 커스트 다른 셀을 추가 한다.
        let gridViewData = GridViewData()
            .setContentObj("CustomView")
            .setSubData(nil)
            .setCellType(TestCellCollectionViewCell2.self)
            .setActionClosure( { (name, object) in
                alert(title: "\(name)", message: String(describing: object))
            })

        gridListData.itemList.append(gridViewData)

        self.gridView.data = gridListData
//        self.gridView.showLineCount = 1
//        self.gridView.allItemHeightSame = true
//        self.gridView.isVertical = true
        self.gridView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

