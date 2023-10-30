//
//  MainViewController.swift
//  test
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 2023/04/09.
//

import UIKit

var MAinNavigationController: UINavigationController?

class MainViewwController: UITableViewController {
    var testGroupDatas = [TestGroupData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        MAinNavigationController = self.navigationController

        testGroupDatas.append(TestGroupData(title: "View", testDatas: [TestData(titleName: "Gif", viewControllerType: GifImageViewController.self),
                                                                       TestData(titleName: "Gradient", viewControllerType: GradientViewController.self),
                                                                       TestData(titleName: "AddViewTest", viewControllerType: AddViewTestViewController.self),
                                                                       TestData(titleName: "WebLoadTest", viewControllerType: WebLoadImageTestViewController.self),
                                                                       TestData(titleName: "CollectionViewTest", viewControllerType: CollectionViewTestViewController.self)
                                                                      ]))

        testGroupDatas.append(TestGroupData(title: "Animation", testDatas: [TestData(titleName: "DynamicAnimator Sample", viewControllerType: DynamicAnimatorViewController.self),
                                                                            TestData(titleName: "DragAbleView", viewControllerType: DragAbleViewController.self),
                                                                            TestData(titleName: "Dynamic Effects Test", viewControllerType: DynamicffectsTabViewController.self),
                                                                            TestData(titleName: "UIFieldBehavior", viewControllerType: Field​BehaviorViewController.self)
                                                                           ]))



        testGroupDatas.append(TestGroupData(title: "Thread", testDatas: [TestData(titleName: "Thread", viewControllerType: ThreadViewController.self)]))

        testGroupDatas.append(TestGroupData(title: "Push", testDatas: [TestData(titleName: "Xib ViewController", viewControllerType: PushViewController.self)]))

        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return testGroupDatas.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testGroupDatas[section].testDatas.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return testGroupDatas[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath)
        let data = testGroupDatas[indexPath.section].testDatas[indexPath.row]
        cell.textLabel?.text = data.titleName
        cell.detailTextLabel?.text = String(describing: data.viewControllerType)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        testGroupDatas[indexPath.section].testDatas[indexPath.row].viewControllerType.pushViewController()
//        self.navigationController?.pushViewController(AAAViewController(), animated: true)
    }
}

struct TestGroupData {
    var title: String
    var testDatas: [TestData]
}

struct TestData {
    var titleName: String
    var viewControllerType: RouterProtocol.Type
}

protocol RouterProtocol: UIViewController {
    static var storyboardName: String { get }
}

extension RouterProtocol where Self: UIViewController {
    // MARK:- assembleModule
    private static func assembleModule() -> Self {
        if !self.storyboardName.isEmpty {
            let storyboard = UIStoryboard(name: self.storyboardName, bundle: Bundle.main)
            if let vc = storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? Self {
                return vc
            }
        }
        return self.init()
    }

    // MARK:- getViewController
    static func getViewController() -> Self {
        return assembleModule()
    }

    static func pushViewController() {
        MAinNavigationController?.pushViewController(getViewController(), animated: true)
    }
}

func randomColor() -> UIColor {
    let r: CGFloat = CGFloat(arc4random() % 11) / 10.0
    let g: CGFloat = CGFloat(arc4random() % 11) / 10.0
    let b: CGFloat = CGFloat(arc4random() % 11) / 10.0
    return UIColor(red: r, green: g, blue: b, alpha: 1.0)
}
