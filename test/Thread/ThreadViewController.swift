//
//  ThreadViewController.swift
//  test
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 2022/08/16.
//

import UIKit
import SwiftHelper

class ThreadViewController: UIViewController, RouterProtocol {
    static var storyboardName: String = "Main"

    var isTest: Bool = false
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Date())
        
        let srtDate = "2022-10-01 00:00:01"
        print(srtDate.dateWithFormat())

        print("will enter task block")
        Task {
            print("did enter task block")
            try? await Task.sleep(nanoseconds: 10000)
//            sleep(for: .seconds(10)) // await를 만남 -> 다음 라인의 코드 실행시키지 않고 대기
            print("will out task block")
        }
        print("some another code")
    }

    @objc func aaaaaaaa(_ sender: Any) {
        
        if let btn = sender as? UIButton {
            btn.setTitle("1111", for: .normal)
        }
        
    }

    func test1() async -> String {
        print("test1 start ----------------------------------------")
        for i in 0..<100000 {
//            sleep(1)
            print(i)
            guard isTest else { break }
        }
        print(" ---------------- test1 end ---------------- ")
        return "test1 end"
    }

    func test2() async -> String {
        print("test2 start ----------------------------------------")
        for i in 200000..<300000 {
//            sleep(1)
            print(i)
            guard isTest else { break }
        }
        print(" ---------------- test2 end ---------------- ")
        return "test2 end"
    }
    
    func test3() -> String {
        for i in 5000000..<6000000 {
//            sleep(1)
            print(i)
            guard isTest else { break }
        }
        print(" ---------------- test3 end ---------------- ")
        return "test3 end"
    }
    
    func test4() -> String {
        for i in 600..<700 {
            print(i)
        }
        print(" ---------------- test4 end ---------------- ")
        return "test4 end"
    }

    @IBAction func onAsyncAwait(_ sender: UIButton) {
        print(" ---------------- onAsyncAwait ---------------- ")
        isTest = true
//        Task {
//            await self.process()
//        }
        Task {
            async let test1 = self.test1()
            async let test2 = self.test2()
            await print("\(test1), \(test2)")
        }
    }
    @IBAction func onGlobal(_ sender: UIButton) {
        print(" ---------------- onGlobal ---------------- ")
        isTest = true
        
        DispatchQueue.global().async {
            self.test3()
        }
        
    }
    @IBAction func onStop(_ sender: UIButton) {
        print(" ---------------- onStop ---------------- ")
        isTest = false
        
        
        let btn = UIButton()
        btn.setTitle("타이틀", for: .normal)
        btn.setTitle("타이틀22222", for: .highlighted)
        btn.setTitle("타이틀333333", for: .selected)
        
        btn.isSelected = true
        
        
        
    }
}

extension String {
    public func dateWithFormat() -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        if let dateString = formatter.date(from: self) {
            return dateString
        }
        else {
            return Date()
        }
    }
}


