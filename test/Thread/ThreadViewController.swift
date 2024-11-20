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

    var asyncIsTest: Bool = false
    nonisolated(unsafe) var isTest: Bool = false

    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var testLabel2: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Thread"

//        print(Date())
//        
//        let srtDate = "2022-10-01 00:00:01"
//        print(srtDate.dateWithFormat())
//
//        print("will enter task block")
//        Task {
//            print("did enter task block")
//            try? await Task.sleep(nanoseconds: 10000)
////            sleep(for: .seconds(10)) // await를 만남 -> 다음 라인의 코드 실행시키지 않고 대기
//            print("will out task block")
//        }
//        print("some another code")
    }

    nonisolated(unsafe) func test1() async -> String {
        print("test1 start ----------------------------------------")
        for i in 0..<100000 {
//            print("test1 \(i)")
            await MainActor.run {
                self.testLabel.text = "test1 \(i)"
            }

            guard await asyncIsTest else { break }
        }
        print(" ---------------- test1 end ---------------- ")
        return "test1 end"
    }

    nonisolated(unsafe) func test2() async -> String {
        print("test2 start ----------------------------------------")
        for i in 200000..<300000 {
//            print("test2 \(i)")
            await MainActor.run {
                self.testLabel2.text = "test2 \(i)"
            }
            guard await asyncIsTest else { break }
        }
        print(" ---------------- test2 end ---------------- ")
        return "test2 end"
    }
    
    nonisolated(unsafe) func test3() -> String {
        print("test3 start ----------------------------------------")
        for i in 500000..<600000 {
            DispatchQueue.main.sync {
                self.testLabel.text = "test3 \(i)"
            }
            guard isTest else { break }
        }
        print(" ---------------- test3 end ---------------- ")
        return "test3 end"
    }
    
    nonisolated(unsafe) func test4() -> String {
        print("test4 start ----------------------------------------")
        for i in 800000..<900000 {
            DispatchQueue.main.sync {
                self.testLabel2.text = "test4 \(i)"
            }
            guard isTest else { break }
        }
        print(" ---------------- test4 end ---------------- ")
        return "test4 end"
    }

    @IBAction func onAsyncAwait(_ sender: UIButton) {
        self.reset()
        print("\n ---------------- onAsyncAwait ---------------- ")
        let startTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()

        Task {
//        Task.detached {
            self.asyncIsTest = true

            async let test1 = self.test1()
            async let test2 = self.test2()
            await print("onAsyncAwait \(test1), \(test2)")
            let timeElapsed: Double = CFAbsoluteTimeGetCurrent() - startTime
            print("Time elapsed for Task: \(String(format: "%.10f", timeElapsed)) s.")
        }
//        print("---------------- onAsyncAwait end ----------------")
    }

    @IBAction func onGlobal(_ sender: UIButton) {
        self.reset()
        print("\n ---------------- onGlobal ---------------- ")
        isTest = true

        nonisolated(unsafe) var result1 = ""
        nonisolated(unsafe) var result2 = ""
        let semapore = DispatchSemaphore(value: 0)
        let startTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
        DispatchQueue.global().async {
            result1 = self.test3()

            semapore.signal()
        }
        DispatchQueue.global().async {
            result2 = self.test4()
            semapore.signal()
        }

        DispatchQueue.global().async {
            semapore.wait()
            semapore.wait()

            print("DispatchQueue.global() DispatchSemaphore \(result1), \(result2)")
            let timeElapsed: Double = CFAbsoluteTimeGetCurrent() - startTime
            print("Time elapsed for Task: \(String(format: "%.10f", timeElapsed)) s.")
        }
    }

    @IBAction func onGlobalGroup(_ sender: Any) {
        self.reset()
        print("\n ---------------- onGlobalGroup ---------------- ")
        isTest = true

        // DispatchGroup을 생성합니다.
        let group = DispatchGroup()
        let queue = DispatchQueue.global()
        nonisolated(unsafe) var result1 = ""
        nonisolated(unsafe) var result2 = ""
        let startTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
        queue.async(group: group) {
            result1 = self.test3()
        }
        queue.async(group: group) {
            result2 = self.test4()
        }

        // 그룹 내 모든 작업이 완료되면 실행
        group.notify(queue: DispatchQueue.main) {
            print("DispatchQueue.global() Group \(result1), \(result2)")
            let timeElapsed: Double = CFAbsoluteTimeGetCurrent() - startTime
            print("Time elapsed for Task: \(String(format: "%.10f", timeElapsed)) s.")
        }
    }

    @IBAction func onStop(_ sender: UIButton) {
        print(" ---------------- onStop ---------------- ")
        isTest = false
        asyncIsTest = false
    }

    func reset() {
        self.testLabel.text = "0"
        self.testLabel2.text = "0"
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
