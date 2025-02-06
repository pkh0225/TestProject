//
//  AddViewTestViewController.swift
//  TestProduct
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 2023/04/28.
//

import UIKit
import SwiftHelper

class AddViewTestViewController: UIViewController, RouterProtocol {
    static var storyboardName: String = "Main"

    
    @IBOutlet weak var targetView: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view1: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "AddViewTest"
    }

    @IBAction func onButton2(_ sender: Any) {
        view2.addSubview(targetView)
    }

    @IBAction func onButton1(_ sender: Any) {
        view1.addSubview(targetView)
    }

//    func closure(_ value: @escaping (Int) -> String) -> Self {
//        self.closure = value
//        return self
//    }
}
