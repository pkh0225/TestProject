//
//  OcclusionCheckViewController.swift
//  TestProduct
//
//  Created by 박길호(팀원) - 서비스개발담당App개발팀 on 6/25/25.
//

import UIKit
import SwiftHelper

class OcclusionCheckViewController: UIViewController, RouterProtocol {

    // MARK: - UI Components

    // A, B, C 뷰를 감싸는 부모 뷰입니다.
    private var containerView: UIView!

    private var viewA: UIView!
    private var viewB: UIView!
    private var viewC: UIView!

    private var labelA: UILabel!
    private var labelB: UILabel!
    private var labelC: UILabel!

    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "A 뷰를 움직여 상태를 확인해보세요."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()

    private lazy var checkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("A 뷰 상태 확인", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemIndigo
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        button.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupViews()
    }

    // MARK: - UI Setup

    private func setupViews() {
        let screenWidth = view.bounds.width

        // --- 부모 뷰(컨테이너) 생성 ---
        containerView = UIView(frame: CGRect(x: 20, y: 100, width: screenWidth - 40, height: screenWidth - 40))
        containerView.backgroundColor = .systemGray4
        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.systemGray2.cgColor
        containerView.clipsToBounds = true // 자식 뷰들이 경계를 넘어가도 잘리지 않게 보이도록 함
        view.addSubview(containerView)

        // --- 자식 뷰 생성 (Frame은 containerView 기준) ---
        // 뷰 C (300x300)
        viewC = UIView(frame: CGRect(x: 20, y: 20, width: 200, height: 200))
        viewC.backgroundColor = .systemTeal.withAlphaComponent(0.8)
        viewC.layer.cornerRadius = 12
        labelC = createLabel(withText: "C")
        viewC.addSubview(labelC)

        // 뷰 B (200x200)
        viewB = UIView(frame: CGRect(x: 70, y: 70, width: 200, height: 200))
        viewB.backgroundColor = .systemGreen.withAlphaComponent(0.8)
        viewB.layer.cornerRadius = 12
        labelB = createLabel(withText: "B")
        viewB.addSubview(labelB)

        // 뷰 A (100x100)
        viewA = UIView(frame: CGRect(x: 120, y: 120, width: 100, height: 100))
        viewA.backgroundColor = .systemRed.withAlphaComponent(0.8)
        viewA.layer.cornerRadius = 12
        labelA = createLabel(withText: "A")
        viewA.addSubview(labelA)

        // --- 뷰 계층 설정 (containerView에 추가) ---
        containerView.addSubview(viewC)
        containerView.addSubview(viewB)
        containerView.addSubview(viewA)

        centerLabel(labelA, in: viewA)
        centerLabel(labelB, in: viewB)
        centerLabel(labelC, in: viewC)

        addPanGesture(to: viewA)
        addPanGesture(to: viewB)
        addPanGesture(to: viewC)

        // --- 하단 UI 컴포넌트 추가 ---
        view.addSubview(resultLabel)
        view.addSubview(checkButton)

        let screenHeight = view.bounds.height
        checkButton.sizeToFit()
        checkButton.center = CGPoint(x: screenWidth / 2, y: screenHeight - 60)
        resultLabel.frame = CGRect(x: 20, y: checkButton.frame.minY - 70, width: screenWidth - 40, height: 60)
    }

    // MARK: - Helper Methods

    private func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textAlignment = .center
        return label
    }

    private func centerLabel(_ label: UILabel, in parentView: UIView) {
        label.sizeToFit()
        label.center = CGPoint(x: parentView.bounds.midX, y: parentView.bounds.midY)
    }

    private func addPanGesture(to view: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }

    // MARK: - Actions

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let targetView = gesture.view, let container = targetView.superview else {
            return
        }

        // 드래그하는 뷰를 컨테이너의 최상단으로 올림
        container.bringSubviewToFront(targetView)

        let translation = gesture.translation(in: container)
        targetView.center = CGPoint(x: targetView.center.x + translation.x, y: targetView.center.y + translation.y)
        gesture.setTranslation(.zero, in: container)
    }

    @objc private func checkButtonTapped() {
        // 1. 가려짐 여부 확인
        let isObscured = isViewCompletelyObscured(viewA, by: [viewB, viewC])

        // 2. 경계 이탈 여부 확인
        let isOut = isViewOutOfBounds(viewA, in: containerView)

        // 3. 결과 텍스트 조합
        let obscuredText = isObscured ? "A뷰 ✅ 완전히 가려짐" : "❌ 일부 보임"
        let boundsText = isOut ? "A뷰 ✅ 영역 이탈" : "❌ 영역 내부"

        resultLabel.text = "[가려짐 상태]: \(obscuredText)\n[경계 상태]: \(boundsText)"

        // 경계 이탈 시 텍스트 색상 변경
        if isOut {
            resultLabel.textColor = .systemOrange
        } else {
            resultLabel.textColor = isObscured ? .systemGreen : .systemRed
        }
    }

    // MARK: - Core Logic

    /// 특정 뷰가 부모 뷰의 경계를 벗어났는지 확인하는 함수
    /// - Parameters:
    ///   - viewToCheck: 확인할 뷰
    ///   - boundsView: 경계의 기준이 되는 부모 뷰
    /// - Returns: 뷰가 경계를 완전히 벗어나거나 일부라도 걸쳐있으면 true, 완전히 안에 있으면 false
    func isViewOutOfBounds(_ viewToCheck: UIView, in boundsView: UIView) -> Bool {
        // CGRect.contains(CGRect)는 한 사각형이 다른 사각형을 완전히 포함하는지 검사합니다.
        // 따라서 포함되지 않는다면 경계를 벗어난 것입니다.
        return !boundsView.bounds.contains(viewToCheck.frame)
    }

    /// 특정 뷰가 다른 뷰들에 의해 완전히 가려졌는지 확인하는 함수 (5px 간격 동적 샘플링)
    func isViewCompletelyObscured(_ viewToTest: UIView, by obscuringViews: [UIView]) -> Bool {
        guard let container = viewToTest.superview else {
            return false
        }
        guard let viewToTestIndex = container.subviews.firstIndex(of: viewToTest) else {
            return false
        }

        let effectiveObscuringViews = obscuringViews.filter {
            guard let obscuringViewIndex = container.subviews.firstIndex(of: $0) else {
                return false
            }
            return obscuringViewIndex > viewToTestIndex && !$0.isHidden && $0.alpha > 0.01
        }

        if effectiveObscuringViews.isEmpty {
            return false
        }

        let frameToTest = viewToTest.frame
        // 5픽셀 간격으로 검사할 점을 생성합니다.
        let step: CGFloat = 5.0

        // y 좌표를 0부터 시작하여 뷰의 높이를 넘지 않을 때까지 5씩 증가시키며 반복합니다.
        var y: CGFloat = 0
        while true {
            // x 좌표를 0부터 시작하여 뷰의 너비를 넘지 않을 때까지 5씩 증가시키며 반복합니다.
            var x: CGFloat = 0
            while true {
                let testPoint = CGPoint(x: frameToTest.minX + x, y: frameToTest.minY + y)

                var isPointCovered = false
                for obscuringView in effectiveObscuringViews {
                    // 점이 가리는 뷰 중 하나에라도 포함되면, 이 점은 가려진 것으로 판단합니다.
                    if obscuringView.frame.contains(testPoint) {
                        isPointCovered = true
                        break
                    }
                }

                // 만약 격자 위의 한 점이라도 가려지지 않았다면, 전체 뷰는 완전히 가려진 것이 아닙니다.
                if !isPointCovered {
                    return false
                }

                // 마지막 x 좌표를 확인했으면 내부 루프를 탈출합니다.
                if x == frameToTest.width {
                    break
                }
                // 다음 x 좌표를 계산하되, 뷰의 너비를 넘지 않도록 합니다.
                x = min(x + step, frameToTest.width)
            }

            // 마지막 y 좌표를 확인했으면 외부 루프를 탈출합니다.
            if y == frameToTest.height {
                break
            }
            // 다음 y 좌표를 계산하되, 뷰의 높이를 넘지 않도록 합니다.
            y = min(y + step, frameToTest.height)
        }

        // 모든 격자점이 가려졌다면, 뷰가 완전히 가려진 것으로 간주합니다.
        return true
    }
}
