//
//  CombineViewController.swift
//  TestProduct
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 1/16/25.
//

import UIKit
import SwiftHelper
import Combine

class CombineViewController: UIViewController, RouterProtocol {

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "Combine"

        sink()
        assign()
        sinkReceiveValue()
        eraseToAnyPublisher()
        combinelatest()
        compactMap()
        subscriber()
        passthroughSubject()
        currentValueSubject()
    }

    func sink() {
        print("\n😀 \(#function) ----------------------")
        let publisher = [1, 2, 3, 4, 5, 6, 7, 8 ,9].publisher
        publisher.sink(receiveCompletion: {_ in
            print("데이터 전달이 끝났습니다.")
        }, receiveValue: {data in
            print(data)
        })
        .store(in: &cancellables)
    }

    func assign() {
        print("\n😀 \(#function) ----------------------")
        let dumper = Dumper()
        let publisher = [1, 2, 3, 4].publisher
        publisher
            .assign(to: \.value, on: dumper)
            .store(in: &cancellables)
    }

    func sinkReceiveValue() {
        print("\n😀 \(#function) ----------------------")
        let model = SomeModel()
        let publisher = model.$name
        publisher.sink(receiveValue: { value in
            print("name is \(value)")
        })
        .store(in: &cancellables)


        model.name = "changed"
    }

    func eraseToAnyPublisher() {
        print("\n😀 \(#function) ----------------------")
        // In another module:
        let nonErased = TypeWithSubject()
        if let _ = nonErased.publisher as? PassthroughSubject<Int, Never> {
            print("Successfully cast nonErased.publisher.")
        }

        let erased = TypeWithErasedSubject()
        if let _ = erased.publisher as? PassthroughSubject<Int, Never> {
            print("Successfully cast erased.publisher.")
        }
    }

    func combinelatest() {
        print("\n😀 \(#function) ----------------------")
        let pub1 = PassthroughSubject<Int, Never>()
        let pub2 = PassthroughSubject<Int, Never>()

        pub1.combineLatest(pub2)
            .sink { print("Result: \($0).") }
            .store(in: &cancellables)

        pub1.send(1)
        pub1.send(2)
        pub2.send(2)
        pub1.send(3)
        pub1.send(45)
        pub2.send(22)


        print()
        let login = LoginViewModel()
        login.id = "123"
        login.password = "xyz"
        login.validInfo
            .sink { print("login.validInfo: \($0)"  ) }
            .store(in: &cancellables)

        login.id = "123"
        login.password = "123"
    }

    func compactMap() {
        print("\n😀 \(#function) ----------------------")

        let numbers = (0...5)
        let romanNumeralDict: [Int : String] = [1: "I", 2: "II", 3: "III", 5: "V", 6: "VI", 7: " VII", 8: " VIII", 9: "IX", 10: "X"]

        numbers.publisher
            .compactMap { romanNumeralDict[$0] }
            .sink { print("\($0)", terminator: " ") }
            .store(in: &cancellables)

        print()
    }

    func subscriber() {
        print("\n😀 \(#function) ----------------------")
        let publisher = ["A","B","C","D","E","F","G"].publisher

        let subscriber = CustomSubscrbier()

        publisher.subscribe(subscriber)
    }

    func passthroughSubject() {
        print("\n😀 \(#function) ----------------------")
        let subject = PassthroughSubject<String, Never>()

        subject.sink(receiveCompletion: { completion in
            //에러가 발생한경우도 receiveCompletion 블록이 호출됩니다.
            switch completion {
            case .failure:
                print("Error가 발생하였습니다.")
            case .finished:
                print("데이터의 발행이 끝났습니다.")
            }
        }, receiveValue: { value in
            print(value)
        })
        .store(in: &cancellables)

        //데이터를 외부에서 발행할 수 있습니다.
        subject.send("A")
        subject.send("B")
        //데이터의 발행을 종료합니다.
        subject.send(completion: .finished)
    }

    func currentValueSubject() {
        print("\n😀 \(#function) ----------------------")
        //맨처음 초기값을 지정합니다.
        let currentStatus = CurrentValueSubject<Bool, Error>(true)

        currentStatus.sink(receiveCompletion: { completion in
            switch completion {
            case .failure:
                print("Error가 발생하였습니다.")
            case .finished:
                print("데이터의 발행이 끝났습니다.")
            }
        }, receiveValue: { value in
            print(value)
        })
        .store(in: &cancellables)

        //데이터를 외부에서 발행할 수 있습니다.
        print("초기값은 \(currentStatus.value)입니다.")
        currentStatus.send(false) //false 값을 주입합니다.

        //value값을 변경해도 값이 발행됩니다.
        currentStatus.value = true
    }
}

class Dumper {
    var value = 0 {
        didSet {
            print("value was updated to \(value)")
        }
    }
}

class SomeModel {
    @Published var name = "Test"
}


public class TypeWithSubject {
    public let publisher: some Publisher = PassthroughSubject<Int,Never>()
}
public class TypeWithErasedSubject {
    public let publisher: some Publisher = PassthroughSubject<Int,Never>()
        .eraseToAnyPublisher()
}

class LoginViewModel: ObservableObject {
    @Published var id: String = ""
    @Published var password: String = ""

    var validInfo: AnyPublisher<Bool, Never> {
        return self.$password.combineLatest(self.$id) {
            return $0 == $1
        }.eraseToAnyPublisher()
    }
}

class CustomSubscrbier: Subscriber {
    typealias Input = String //성공타입
    typealias Failure = Never //실패타입

    func receive(completion: Subscribers.Completion<Never>) {
        print("모든 데이터의 발행이 완료되었습니다.")
    }

    func receive(subscription: Subscription) {
        print("데이터의 구독을 시작합니다.")
        //구독할 데이터의 개수를 제한하지않습니다.
        subscription.request(.unlimited)
    }

    func receive(_ input: String) -> Subscribers.Demand {
        print("데이터를 받았습니다.", input)
        return .none
    }
}
