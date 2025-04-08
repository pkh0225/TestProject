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

    @IBAction func onButton1(_ sender: Any) {
        view1.addSubview(targetView)

        print("onButton1 isMainThread : \(Thread.isMainThread)")
        Task.detached {
            print("onButton1 isMainThread : \(Thread.isMainThread)")
            let index = await TaskTestClas.showAlertWithMultipleActions(vc: self)
//            let index = await self.showAlertWithMultipleActions(vc: self)
            print("onButton1 isMainThread : \(Thread.isMainThread)")
        }
    }

    @IBAction func onButton2(_ sender: Any) {
        view2.addSubview(targetView)
    }

    func showAlertWithMultipleActions(vc: UIViewController) async -> Int {
        print("showAlertWithMultipleActions 1 isMainThread : \(Thread.isMainThread)")
//        MainActor.assertIsolated()
        return await withCheckedContinuation { continuation in
            print("showAlertWithMultipleActions 2 isMainThread : \(Thread.isMainThread)")
            let alertController = UIAlertController(
                title: "선택",
                message: "어떤 작업을 수행하시겠습니까?",
                preferredStyle: .alert
            )

            // 다양한 액션 추가
            let confirmAction = UIAlertAction(
                title: "확인",
                style: .default) { _ in
                    print("확인 작업 수행")
                    continuation.resume(returning: 1)
                }

            let cancelAction = UIAlertAction(
                title: "취소",
                style: .cancel) { _ in
                    print("취소되었습니다.")
                    continuation.resume(returning: 2)
                }

            let destructiveAction = UIAlertAction(
                title: "삭제",
                style: .destructive) { _ in
                    print("위험한 작업 수행")
                    continuation.resume(returning: 3)
                }

            // 액션들을 알림 컨트롤러에 추가
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            alertController.addAction(destructiveAction)

            vc.present(alertController, animated: true, completion: nil)
        }
    }

}

class TaskTestClas {
    static func showAlertWithMultipleActions(vc: UIViewController) async -> Int {
        print("showAlertWithMultipleActions 1 isMainThread : \(Thread.isMainThread)")
//        MainActor.assertIsolated()
        return await withCheckedContinuation { continuation in
            Task {
                print("showAlertWithMultipleActions 2 isMainThread : \(Thread.isMainThread)")
                let alertController = UIAlertController(
                    title: "선택",
                    message: "어떤 작업을 수행하시겠습니까?",
                    preferredStyle: .alert
                )

                // 다양한 액션 추가
                let confirmAction = UIAlertAction(
                    title: "확인",
                    style: .default) { _ in
                        print("확인 작업 수행")
                        continuation.resume(returning: 1)
                    }

                let cancelAction = UIAlertAction(
                    title: "취소",
                    style: .cancel) { _ in
                        print("취소되었습니다.")
                        continuation.resume(returning: 2)
                    }

                let destructiveAction = UIAlertAction(
                    title: "삭제",
                    style: .destructive) { _ in
                        print("위험한 작업 수행")
                        continuation.resume(returning: 3)
                    }

                // 액션들을 알림 컨트롤러에 추가
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
                alertController.addAction(destructiveAction)

                vc.present(alertController, animated: true, completion: nil)

            }
        }
    }
}
