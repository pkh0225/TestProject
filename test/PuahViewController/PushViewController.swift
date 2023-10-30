//
//  AAAViewController.swift
//  TestProduct
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 10/30/23.
//

import UIKit

/// 스토리보드가 아닌 xib로 Push
class PushViewController: UIViewController, RouterProtocol {
    static var storyboardName: String = ""


    override func viewDidLoad() {
        super.viewDidLoad()


        let myView = Bundle.loadView(fromNib: "VVVView", withType: VVVView.self)
        self.view.addSubview(myView)
        myView.center = self.view.center

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Bundle {

    static func loadView<T>(fromNib name: String, withType type: T.Type) -> T {
        if let view = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? T {
            return view
        }

        fatalError("Could not load view with type " + String(describing: type))
    }
}
