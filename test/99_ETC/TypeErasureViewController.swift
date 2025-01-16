//
//  Untitled.swift
//  TestProduct
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 12/20/24.
//

import UIKit
import SwiftHelper
import EasyConstraints

class TypeErasureViewController: UIViewController, RouterProtocol {

    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
//        flowLayout.itemSize = CGSize(width: self.view.width, height: 80)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.backgroundColor = .lightGray
//        cv.register(TestAdapterCell.self, forCellWithReuseIdentifier: "TestAdapterCell")
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    lazy var dataSource: AnyDataSectionItem = {
        var data = AnyDataSectionItem()
        data.cellss = [
            TestAnyDataClass(TestAdapterCell1.self, value: "123"),
            TestAnyDataClass(TestAdapterCell2.self, value: 123),
            TestAnyDataClass(TestAdapterCell3.self, value: StructABC()),
            TestAnyDataClass(TestAdapterCell4.self, value: ClssXYZ())
        ]
        data.cellss.forEach {
            collectionView.register(
                $0.cellType as! UICollectionViewCell.Type,
                forCellWithReuseIdentifier: String(describing: type(of: $0.cellType))
            )
        }
        return data
    }()

    let menu: [any MenuItem] = [
        Coffee(type: .latte),
        Coffee(type: .mocha),
        Food(type: .croissant),
        Food(type: .muffin),
    ]


    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "TypeErasure"
        self.view.backgroundColor = .white

//        UIView.enableBorderLayerSwizzling()

        self.view.addSubViewSafeArea(subView: collectionView, safeBottom: false)
        collectionView.reloadData()

        for item in menu {
            print("Prices for \(item.description)")
            for pricelist in getPriceList(for: item) {
                print("- \(pricelist.size): $\(pricelist.price)")
            }
        }

        func getPriceList<T: MenuItem>(for item: T) -> [(size: T.ItemSize, price: Float)] {
            var prices: [(T.ItemSize, Float)] = []
            for size in item.sizes {
                prices.append((size: size, price: item.price(for: size)))
            }
            return prices
        }
    }

    

}

extension TypeErasureViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.cellss.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = dataSource.cellss[indexPath.row]
//        let cell = collectionView.dequeueReusableCell(data.cellType as! UICollectionViewCell.Type, for: indexPath) as! TestCellProtocol
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: type(of: data.cellType)),
            for: indexPath) as! TestCellProtocol

        cell.configure(data: data)
        return cell as! UICollectionViewCell
    }
}

extension TypeErasureViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return BaseTestCell.getSize(data: dataSource.cellss[indexPath.item], collectionView: collectionView)
    }
}


protocol AnyDataProtocal {
    associatedtype DataType
    var storedValue: DataType { get set }
    var cellType: TestCellProtocol.Type { get set}

    var description: String { get }
}

extension AnyDataProtocal {
    func toAnyDataClass() -> TestAnyDataClass<DataType> {
        TestAnyDataClass(cellType, value: storedValue)
    }
//    func toAnyDataClass<T>() -> TestAnyDataClass<T> where T == DataType {
//        return TestAnyDataClass(cellType, value: storedValue)
//    }
//
//    func toWrapper() -> AnyDataProtocalWrapper {
//        AnyDataProtocalWrapper(self)
//    }
}

protocol TestCellProtocol: UICollectionReusableView {
    func configure(data: (any AnyDataProtocal)?)
    static func getSize(data: (any AnyDataProtocal)?, collectionView: UICollectionView) -> CGSize
}

extension TestCellProtocol {
    static func getSize(data: (any AnyDataProtocal)?, collectionView: UICollectionView) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 100)
    }
}

class TestAnyDataClass<DataType>: AnyDataProtocal {
    var storedValue: DataType
    var cellType: TestCellProtocol.Type


    init(_ type: TestCellProtocol.Type, value: DataType) {
        self.cellType = type
        self.storedValue = value
    }

    var description: String {
        "CellType: \(cellType) \nStored Type: \(type(of: storedValue)) \nValue: \(storedValue)"
    }

    class var className: String {
        return String(describing: self)
    }
}


class AnyDataSectionItem {
    var header: (any AnyDataProtocal)?
    var cellss = [any AnyDataProtocal]()

}

struct StructABC {
    let a = "1"
    let b = "2"
    let c = "3"
}

class ClssXYZ {
    let x = "4"
    let y = "5"
    let z = "6"
}


class BaseTestCell: UICollectionViewCell, TestCellProtocol {
    lazy var label1: UILabel = {
        let l = UILabel()
        l.textColor = .black
        l.textAlignment = .center
        l.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
        l.numberOfLines = 0
        return l
    }()
    lazy var label2: UILabel = {
        let l = UILabel()
        l.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        l.textAlignment = .center
        l.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        l.numberOfLines = 0
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubViewAutoLayout(containerView, edgeInsets: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
            .ec.priority()
            .bottom(.fittingSizeLevel)
        containerView.addSubViewAutoLayout(subviews: [label1, label2], addType: .vertical, equally: false, itemSpacing: 5)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(data: (any AnyDataProtocal)?) {
        guard let data else { return }
        self.contentView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        label1.text = "\(type(of: self)) Configure"
        label2.text = "\(data.description)"
    }
}

class TestAdapterCell1: BaseTestCell {
    override func configure(data: (any AnyDataProtocal)?) {
        super.configure(data: data)
        self.contentView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
    }
}

class TestAdapterCell2: BaseTestCell {
    override func configure(data: (any AnyDataProtocal)?) {
        super.configure(data: data)
        self.contentView.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
    }
}

class TestAdapterCell3: BaseTestCell {
    override func configure(data: (any AnyDataProtocal)?) {
        super.configure(data: data)
        self.contentView.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
    }
}

class TestAdapterCell4: BaseTestCell {
    override func configure(data: (any AnyDataProtocal)?) {
        super.configure(data: data)
        self.contentView.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
    }
}

struct Coffee {
    enum CoffeeType: String {
        case latte
        case cappuccino
        case mocha
    }

    let type: CoffeeType
}

struct Food {
    enum FoodType: String {
        case croissant
        case muffin
        case sandwich
    }

    let type: FoodType
}

protocol MenuItem {
    associatedtype ItemSize: CaseIterable
    func price(for size: ItemSize) -> Float
    var description: String { get } // 메뉴 설명
}

extension MenuItem {
    var sizes: [ItemSize] {
        ItemSize.allCases as! [Self.ItemSize]
    }
}
extension Coffee: MenuItem {
    enum ItemSize: CaseIterable {
        case small
        case medium
        case large
    }

    func price(for size: ItemSize) -> Float {
        return prices[type]?[size] ?? 0
    }

    var prices: [CoffeeType: [ItemSize: Float]] {
        return [
            .latte: [
                .small: 4.5,
                .medium: 5.5,
                .large: 6.0
            ],
            .cappuccino: [
                .small: 4.5,
                .medium: 5.5,
                .large: 6.0
            ],
            .mocha: [
                .small: 4.5,
                .medium: 5.5,
                .large: 6.0
            ]
        ]
    }

//    var sizes: [ItemSize] {
//        ItemSize.allCases
//    }

    var description: String {
        return type.rawValue
    }
}

extension Food: MenuItem {
    enum ItemSize: CaseIterable {
        case small
        case regular
    }

    func price(for size: ItemSize) -> Float {
        prices[type]?[size] ?? 0
    }

    private var prices: [FoodType: [ItemSize: Float]] {
        return [
            .croissant: [
                .small: 8,
                .regular: 12,
            ],
            .muffin: [
                .small: 6.5,
                .regular: 8,
            ],
            .sandwich: [
                .regular: 8.5
            ]
        ]
    }

//    var sizes: [ItemSize] {
//        ItemSize.allCases
//    }

    var description: String {
        return type.rawValue
    }
}
