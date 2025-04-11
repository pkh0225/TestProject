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

//        checkedContinuation()
        
//        print("will enter task block")
//        Task {
//            print("did enter task block")
//            let startTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
//            try? await Task.sleep(nanoseconds: 1_000_000_000)
//            print("Time elapsed for Task: \(String(format: "%.10f", CFAbsoluteTimeGetCurrent() - startTime)) s.")
//            print("will out task block")
//        }
//        print("some another code")
    }

    func reset() {
        self.testLabel.text = "0"
        self.testLabel2.text = "0"
    }

    nonisolated func test1() async -> String {
        print("test1 start ----------------------------------------")
        print("Thread.isMainThread 0 : \(Thread.isMainThread)")
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

    nonisolated func test2() async -> String {
        print("test2 start ----------------------------------------")
        print("Thread.isMainThread 0 : \(Thread.isMainThread)")
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
    
    nonisolated func test3() -> String {
        print("test3 start ----------------------------------------")
        print("Thread.isMainThread 0 : \(Thread.isMainThread)")
        for i in 500000..<600000 {
            DispatchQueue.main.sync {
                self.testLabel.text = "test3 \(i)"
            }
            guard isTest else { break }
        }
        print(" ---------------- test3 end ---------------- ")
        return "test3 end"
    }
    
    nonisolated func test4() -> String {
        print("test4 start ----------------------------------------")
        print("Thread.isMainThread 0 : \(Thread.isMainThread)")
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
        print("Thread.isMainThread 0 : \(Thread.isMainThread)")
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
        print("Thread.isMainThread 0 : \(Thread.isMainThread)")
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
        print("Thread.isMainThread 0 : \(Thread.isMainThread)")
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

    @IBAction func onTaskTest(_ sender: UIButton) {
        print("\n ---------------- onTaskTest ---------------- ")
        processData()
    }

    @IBAction func onTaskMainActorTest(_ sender: UIButton) {
        print("\n ---------------- onTaskMainActorTest ---------------- ")
        print("Thread.isMainThread 0 : \(Thread.isMainThread)")
        Task.detached {
            print("Thread.isMainThread 1 : \(Thread.isMainThread)")
            for i in 0..<99999 {
                print("label 1 = \(i)")
                await MainActor.run {
                    self.testLabel.text = "\(i)"
                }

            }
        }

        Task.detached {
            print("Thread.isMainThread 2 : \(Thread.isMainThread)")
            for i in 0..<99999 {
                print("label 2 = \(i)")
                await MainActor.run {
                    self.testLabel2.text = "\(i)"
                }
            }
        }
    }

    func processData() {
        print("Thread.isMainThread 0 : \(Thread.isMainThread)")
        self.testLabel.text = "No data"
        Task { @DatabaseActor in
            print("Thread.isMainThread 1 : \(Thread.isMainThread)")
            self.actorTest = "No data" // @DatabaseActor 변수 이기에 @DatabaseActor in 채택해줘야 함
            await saveDataToDatabase("Sample Data")

            let data = actorTest
            Task { @MainActor in
                print("Thread.isMainThread 2 : \(Thread.isMainThread)")
                updateUI(data)
            }
        }
    }

    @DatabaseActor 
    var actorTest = "No data"

    @DatabaseActor
    func saveDataToDatabase(_ data: String) async {
        print("Saving data 5초 대기")
        print("Thread.isMainThread 0 : \(Thread.isMainThread)")
        for i in stride(from:5, through: 0, by: -1) {
            print("대기 ... \(i)")
            await MainActor.run {
                self.testLabel2.text = "대기 ... \(i)"
            }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
        print("Saving data: \(data)")
        self.actorTest = data
    }

    func updateUI(_ data: String) {
        MainActor.assertIsolated() // MainActor 검사
//        MainActor.assumeIsolated { // MainActor 무시하고 실행 개발자가 직접 검증
            print("Updating UI = \(data)")
        self.testLabel.text = data
        self.testLabel2.text = "완료"
//        }
    }

    func checkedContinuation() {
        print("\n \(#function) ----------------------")


        func getNum(completion: @escaping (Int) -> Void) {
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                completion(1)
            }
        }

        func printResultWithUnsafeContinuation() async -> Int {
            return await withUnsafeContinuation { continuation in
                getNum { result in
                    continuation.resume(returning: result)
                }
            }
        }

        func printResultWithCheckedContinuation() async -> Int {
            return await withCheckedContinuation { continuation in
                getNum { result in
                    continuation.resume(returning: result)
                }
            }
        }

        Task {
            let startTime = CFAbsoluteTimeGetCurrent()

            let num1 = await printResultWithCheckedContinuation()
            print("Checked num1 : \(num1)")
            let num2 = await printResultWithCheckedContinuation()
            print("Checked num2 : \(num2)")

            let durationTime = CFAbsoluteTimeGetCurrent() - startTime
            print("Checked 경과 시간: \(durationTime)")
        }

        Task {
            let startTime = CFAbsoluteTimeGetCurrent()

            let num1 = await printResultWithUnsafeContinuation()
            print("Unsafe num1 : \(num1)")
            let num2 = await printResultWithUnsafeContinuation()
            print("Unsafe num2 : \(num2)")

            let durationTime = CFAbsoluteTimeGetCurrent() - startTime
            print("Unsafe 경과 시간: \(durationTime)")
        }
    }

    @IBAction func onMutilTask(_ sender: Any) {
        Task {
            await testSafety()
        }
    }

    nonisolated
    func testSafety() async {
        let unsafe = UnsafeCounter()
        let safe = SafeCounter()

        // UnsafeCounter: 경합 발생 가능
        await withTaskGroup(of: Void.self) { group in
            for _ in 1...1000 {
                group.addTask { unsafe.increment() }
            }
        }
        print("Unsafe count: \(unsafe.count)") // 1000 미만일 가능성 있음

        // SafeCounter: 안전하게 증가
        await withTaskGroup(of: Void.self) { group in
            for _ in 1...1000 {
                group.addTask { await safe.increment() }
            }
        }
        let safeCount = await safe.getCount()
        print("Safe count: \(safeCount)") // 항상 1000

        // Atomic
        await withTaskGroup(of: Void.self) { group in
            for _ in 1...1000 {
                group.addTask {
                    await unsafe.add()
//                    unsafe.stringList.append("123123")
                }
            }
        }
        print("Atomic count: \(unsafe.stringList.count)")
    }

}


@globalActor
actor DatabaseActor {
    static let shared = DatabaseActor()
}

extension Task where Failure == Error {
    @discardableResult
    static public func delayed(
        byTimeInterval delayInterval: TimeInterval,
        priority: TaskPriority? = nil,
        @_implicitSelfCapture operation: @escaping @Sendable () async throws -> Success
    ) -> Task {
        Task(priority: priority) {
            let delay = UInt64(delayInterval * 1_000_000_000)
            try await Task<Never, Never>.sleep(nanoseconds: delay)
            return try await operation()
        }
    }
}

class UnsafeCounter {
    var count: Int = 0
    func increment() { count += 1 }

    @Atomic var stringList = [String]()

    @DatabaseActor
    func add() {
        stringList.append("123123")
    }

}

actor SafeCounter {
    var count: Int = 0
    func increment() { count += 1 }
    func getCount() -> Int { count }
}

