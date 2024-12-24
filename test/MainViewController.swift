//
//  MainViewController.swift
//  test
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 2023/04/09.
//

import UIKit
import SwiftHelper

class MainViewwController: UITableViewController {
    var testGroupDatas: [TestGroupData]!

    override func viewDidLoad() {
        super.viewDidLoad()

        testGroupDatas = [
            TestGroupData(
                title: "View",
                testDatas: [
                    TestGroupData.TestData(
                        titleName: "ViewLayout Show",
                        viewControllerType: ViewLayoutControler.self
                    ),
                    TestGroupData.TestData(
                        titleName: "Gif",
                        viewControllerType: GifImageViewController.self
                    ),
                    TestGroupData.TestData(
                        titleName: "Gradient",
                        viewControllerType: CAGradientLayerTestViewController.self
                    ),
                    TestGroupData.TestData(
                        titleName: "AddViewTest",
                        viewControllerType: AddViewTestViewController.self
                    ),
                    TestGroupData.TestData(
                        titleName: "WebLoadTest",
                        viewControllerType: WebLoadImageTestViewController.self
                    )
                ]
            ),

            TestGroupData(
                title: "GridView",
                testDatas: [
                    TestGroupData.TestData(
                        titleName: "GridViewTest",
                        viewControllerType: GridViewTestController.self
                    ),
                ]
            ),

            TestGroupData(
                title: "TableView",
                testDatas: [
                    TestGroupData.TestData(
                        titleName: "TableViewTest",
                        viewControllerType: TableViewTestViewController.self
                    ),
                ]
            ),

            TestGroupData(
                title: "CollectionView",
                testDatas: [
                    TestGroupData.TestData(
                        titleName: "CollectionViewTest",
                        viewControllerType: CollectionViewTestViewController.self
                    ),
                    TestGroupData.TestData(
                        titleName: "CompositionalLayout",
                        viewControllerType: CompositionalLayoutTestViewController.self
                    ),
                    TestGroupData.TestData(
                        titleName: "CompositionalLayout Page",
                        viewControllerType: CompositionalLayoutPageTestViewController.self
                    ),
                    TestGroupData.TestData(
                        titleName: "DiffableDataSource",
                        viewControllerType: DiffableDataSourceViewController.self
                    ),
                ]
            ),

            TestGroupData(
                title: "Animation",
                testDatas: [
                    TestGroupData.TestData(
                        titleName: "DynamicAnimator Sample",
                        viewControllerType: DynamicAnimatorViewController.self
                    ),
                    TestGroupData.TestData(
                        titleName: "DragAbleView",
                        viewControllerType: DragAbleViewController.self
                    ),
                    TestGroupData.TestData(
                        titleName: "Dynamic Effects Test",
                        viewControllerType: DynamicffectsTabViewController.self
                    ),
                    TestGroupData.TestData(
                        titleName: "UIFieldBehavior",
                        viewControllerType: Field​BehaviorViewController.self
                    )
                ]
            ),

            TestGroupData(
                title: "ETC",
                testDatas: [
                    TestGroupData.TestData(
                        titleName: "Thread",
                        viewControllerType: ThreadViewController.self
                    ),
                    TestGroupData.TestData(
                        titleName: "Type erasure",
                        viewControllerType: TypeErasureViewController.self
                    )
                ]
            )
        ]

        if #available(iOS 14.0, *) {
            for gd in testGroupDatas {
                if gd.title == "CollectionView" {
                    gd.testDatas.append(
                        TestGroupData.TestData(
                            titleName: "PinterestCompostionalLayout",
                            viewControllerType: PCLViewController.self
                        )
                    )
                }
            }
        }
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
        testGroupDatas[indexPath.section]
            .testDatas[indexPath.row]
            .viewControllerType.pushViewController()
    }
}

class TestGroupData {
    struct TestData {
        var titleName: String
        var viewControllerType: RouterProtocol.Type
    }

    var title: String = ""
    var testDatas = [TestData]()

    init(title: String, testDatas: [TestData] = [TestData]()) {
        self.title = title
        self.testDatas = testDatas
    }
}

