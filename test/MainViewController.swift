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
                                                                       TestData(titleName: "DynamicAnimator", viewControllerType: DynamicAnimatorViewController.self),
                                                                       TestData(titleName: "DragAbleView", viewControllerType: DragAbleViewController.self)]))

        testGroupDatas.append(TestGroupData(title: "Thread", testDatas: [TestData(titleName: "Thread", viewControllerType: ThreadViewController.self)]))
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