//
//  TableViewTestViewController.swift
//  TestProduct
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 11/5/24.
//

import UIKit
import SwiftHelper
import TableViewAdapter
import EasyConstraints

class TableViewTestViewController: UIViewController, RouterProtocol {

    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = #colorLiteral(red: 0.9459366202, green: 0.9459366202, blue: 0.9459366202, alpha: 1)
        tv.sectionHeaderHeight = 0
        tv.sectionFooterHeight = 0
        self.view.addSubViewSafeArea(subView: tv, safeBottom: false)
        return tv
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "TableViewTest"
        self.view.backgroundColor = .white


        let tableData = TVAData()
        for i in 0..<5 {
            let tableSection = TVASectionInfo()
            tableData.sectionList.append(tableSection)
            for j in 0..<5 {
                let tableCell = TVACellInfo(TableTestCell.self)
                    .contentObj("section(\(i)) row(\(j)) - class")
                    .actionClosure { _, _ in
                    }
                tableSection.cells.append(tableCell)
            }
            for j in 0..<5 {
                let tableCell = TVACellInfo(TableTestCell2.self)
                    .contentObj("section(\(i)) row(\(j)) - xib")
                    .actionClosure { _, _ in
                    }
                tableSection.cells.append(tableCell)
            }
        }

        self.tableView.adapterData = tableData
        self.tableView.reloadData()
    }
}

class TableTestCell: UITableViewCell, TVACellProtocol {
    var actionClosure: ((String, Any?) -> Void)?

    // UI 요소 선언
    let customLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()

    let customImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // 초기화 메서드 설정
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // UI 요소 추가
        contentView.addSubview(customLabel)
        contentView.addSubview(customImageView)

        // 레이아웃 설정
        NSLayoutConstraint.activate([
            customImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            customImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            customImageView.widthAnchor.constraint(equalToConstant: 40),
            customImageView.heightAnchor.constraint(equalToConstant: 40),

            customLabel.leadingAnchor.constraint(equalTo: customImageView.trailingAnchor, constant: 10),
            customLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            customLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])

        self.contentView.backgroundColor = #colorLiteral(red: 1, green: 0.7122581601, blue: 0.6296025515, alpha: 1)
    }

    // required initializer (필수)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func getSize(data: Any?, width: CGFloat, tableView: UITableView, indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func configure(data: Any?, subData: Any?, tableView: UITableView, indexPath: IndexPath) {
        guard let data = data as? String else { return }
        self.customLabel.text = data
        self.customImageView.image = #imageLiteral(resourceName: "E_i_tab_food_p_t")
    }


}
