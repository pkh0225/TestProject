//
//  FloatingCaptureButton.swift
//  TestProduct
//
//  Created by 박길호(팀원) - 서비스개발담당App개발팀 on 6/20/25.
//

import UIKit

// MARK: - 플로팅 캡처 버튼 관리자
class FloatingCaptureButton {
    static let shared = FloatingCaptureButton()
    
    private var floatingButton: DraggableButton?
    private var targetViewController: UIViewController?
    
    private init() {}
    
    func showFloatingButton() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        
        // 기존 버튼이 있으면 제거
        hideFloatingButton()
        
        // 드래그 가능한 버튼 생성
        floatingButton = DraggableButton(type: .system)
        guard let button = floatingButton else { return }
        
        button.setTitle("📷", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        button.layer.cornerRadius = 30
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // 버튼 액션 설정
        button.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        
        // 윈도우에 추가
        window.addSubview(button)
        
        // 초기 위치 설정 (우측 상단)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 60),
            button.heightAnchor.constraint(equalToConstant: 60),
            button.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -20),
            button.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 100)
        ])
        
        // 애니메이션으로 나타나기
        button.alpha = 0
        button.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            button.alpha = 1
            button.transform = .identity
        }
    }
    
    func hideFloatingButton() {
        floatingButton?.removeFromSuperview()
        floatingButton = nil
    }
    
    @objc private func captureButtonTapped() {
        // 현재 표시중인 뷰컨트롤러 찾기
        guard let currentVC = getCurrentViewController() else {
            print("현재 뷰컨트롤러를 찾을 수 없습니다.")
            return
        }
        
        // 네비게이션의 마지막 뷰컨트롤러 또는 현재 뷰컨트롤러 캡처
        let targetVC = getTargetViewController(from: currentVC)
        captureViewControllerWithBounds(targetVC)
    }
    
    private func getCurrentViewController() -> UIViewController? {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              let rootVC = window.rootViewController else {
            return nil
        }
        
        return findTopViewController(from: rootVC)
    }
    
    private func findTopViewController(from viewController: UIViewController) -> UIViewController {
        if let presentedVC = viewController.presentedViewController {
            return findTopViewController(from: presentedVC)
        }
        
        if let navigationVC = viewController as? UINavigationController {
            return navigationVC.topViewController ?? navigationVC
        }
        
        if let tabBarVC = viewController as? UITabBarController {
            return findTopViewController(from: tabBarVC.selectedViewController ?? tabBarVC)
        }
        
        return viewController
    }
    
    private func getTargetViewController(from currentVC: UIViewController) -> UIViewController {
        // 네비게이션 컨트롤러가 있는 경우 마지막 뷰컨트롤러 반환
        if let navigationController = currentVC.navigationController {
            return navigationController.topViewController ?? currentVC
        }
        
        return currentVC
    }
    
    private func captureViewControllerWithBounds(_ viewController: UIViewController) {
        // 플로팅 버튼 임시 숨기기
        let wasButtonHidden = floatingButton?.isHidden ?? true
        floatingButton?.isHidden = true
        
        // 잠시 후 캡처 실행 (UI 업데이트 대기)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let viewSpacingCapture = ViewSpacingCaptureManager()
            viewSpacingCapture.captureViewControllerWithBounds(viewController) { [weak self] success in
                // 캡처 완료 후 버튼 다시 표시
                self?.floatingButton?.isHidden = wasButtonHidden
                
                if success {
                    // 햅틱 피드백
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                }
            }
        }
    }
}

// MARK: - 드래그 가능한 버튼
class DraggableButton: UIButton {
    private var initialTouchPoint: CGPoint = .zero
    private var initialCenter: CGPoint = .zero
    private var isDragging: Bool = false
    private let dragThreshold: CGFloat = 10.0 // 드래그로 인식할 최소 이동 거리
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        initialTouchPoint = touch.location(in: superview)
        initialCenter = center
        isDragging = false
        
        // 터치 시작 시 약간 작아지는 애니메이션
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
        
        // super 호출을 나중에 하여 기본 버튼 동작을 제어
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let superview = superview else { return }
        
        let currentTouchPoint = touch.location(in: superview)
        let deltaX = currentTouchPoint.x - initialTouchPoint.x
        let deltaY = currentTouchPoint.y - initialTouchPoint.y
        let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
        
        // 드래그 임계값을 넘었는지 확인
        if distance > dragThreshold {
            isDragging = true
            
            // 드래그 중일 때는 버튼의 기본 터치 이벤트 취소
            if !isDragging {
                super.touchesCancelled(touches, with: event)
            }
            
            let newCenter = CGPoint(
                x: initialCenter.x + deltaX,
                y: initialCenter.y + deltaY
            )
            
            // 화면 경계 체크
            let safeArea = superview.safeAreaInsets
            let minX = bounds.width / 2
            let maxX = superview.bounds.width - bounds.width / 2
            let minY = safeArea.top + bounds.height / 2
            let maxY = superview.bounds.height - safeArea.bottom - bounds.height / 2
            
            center = CGPoint(
                x: max(minX, min(maxX, newCenter.x)),
                y: max(minY, min(maxY, newCenter.y))
            )
        }
        
        // 드래그 중이 아니면 기본 버튼 동작 유지
        if !isDragging {
            super.touchesMoved(touches, with: event)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 터치 종료 시 원래 크기로 복원
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3) {
            self.transform = .identity
        }
        
        if isDragging {
            // 드래그였다면 가장자리로 이동만 하고 버튼 액션은 실행하지 않음
            snapToEdge()
            isDragging = false
        } else {
            // 클릭이었다면 기본 버튼 동작 실행
            super.touchesEnded(touches, with: event)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 터치 취소 시 원래 크기로 복원
        UIView.animate(withDuration: 0.2) {
            self.transform = .identity
        }
        
        if isDragging {
            snapToEdge()
            isDragging = false
        } else {
            super.touchesCancelled(touches, with: event)
        }
    }
    
    private func snapToEdge() {
        guard let superview = superview else { return }
        
        let centerX = center.x
        let screenWidth = superview.bounds.width
        let margin: CGFloat = 20
        
        // 좌측 또는 우측 가장자리로 이동
        let targetX = centerX < screenWidth / 2 ? margin + bounds.width / 2 : screenWidth - margin - bounds.width / 2
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.center.x = targetX
        }
    }
}
