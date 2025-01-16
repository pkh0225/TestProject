//
//  ViewController.swift
//  TestProduct
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 12/16/24.
//

import UIKit
import SwiftHelper

class ViewLayoutControler: UIViewController, RouterProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()


    }


    @IBAction func onOn(_ sender: UIButton) {
        UIView.enableBorderLayerSwizzling()
    }
    
    @IBAction func onOff(_ sender: UIButton) {
        UIView.disableBorderLayerSwizzling()
    }
}

class LayoutTextView: UIView {

    override func layoutSubviews() {
        print("LayoutTextView layoutSubviews 1")
        super.layoutSubviews()

        print("LayoutTextView layoutSubviews 2")
    }
}
