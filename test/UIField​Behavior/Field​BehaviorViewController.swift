//
//  Field​BehaviorViewController.swift
//  TestProduct
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 2023/04/10.
//

import UIKit

class Field​BehaviorViewController: UIViewController, RouterProtocol {
    static var storyboardName: String = "Main"

    @IBOutlet var containerView: UIView!

    // 다이나믹스 애니메이터 인스턴스 변수 선언
    var animator:UIDynamicAnimator?
    // 탄성 설정
    var viewBehavior: UIDynamicItemBehavior?
    // 충돌 설정
    var collision: UICollisionBehavior?

    // 항목이 붙어있는 것을 구현할 수 있는 클래스
    public var attachment: UIAttachmentBehavior?
    // 앵커 포인트 현재 위치 저장할 변수
    var currentLocation: CGPoint = .zero


    var targetView: UIView!



    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
//            guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return }
//            let top = window.safeAreaInsets.top
//            let bottom = window.safeAreaInsets.bottom

            self.targetView = UIView(frame: CGRect(x: 100, y: 100, width: 70, height: 70))
            self.targetView.backgroundColor = .blue
            self.containerView.addSubview(self.targetView)

            self.animator = UIDynamicAnimator(referenceView: self.containerView)
            self.animator?.setValue(true, forKey: "debugEnabled")

            // 감속지역 설정
            let drag = UIFieldBehavior.dragField()
            drag.position = self.targetView.center
            drag.region = UIRegion(size: self.targetView.bounds.size)
            self.animator?.addBehavior(drag)

            var y: CGFloat = 0
            let size = CGSize(width: self.containerView.frame.width / 1.5, height: self.containerView.frame.height / 4)

            self.addSpringField(center: CGPoint(x: self.containerView.frame.width / 2, y: self.containerView.frame.height / 2), size: size)

            for i in 0..<5 {
                y = (CGFloat(i) * (size.height))

                if i == 0 || i == 4 {
                    let center1 = CGPoint(x: 0, y: y)
                    self.addSpringField(center: center1, size: size)

                    let center2 = CGPoint(x: self.containerView.frame.width / 2, y: y)
                    self.addSpringField(center: center2, size: CGSize(width: self.containerView.frame.width - (self.containerView.frame.width / 1.5), height: self.containerView.frame.height / 4))

                    let center3 = CGPoint(x: self.containerView.frame.width, y: y)
                    self.addSpringField(center: center3, size: size)
                }
                else {
                    let size = CGSize(width: (self.targetView.frame.width * 2) + 60, height: self.containerView.frame.height / 4)
                    let center1 = CGPoint(x: 0, y: y)
                    self.addSpringField(center: center1, size: size)

                    let center3 = CGPoint(x: self.containerView.frame.width, y: y)
                    self.addSpringField(center: center3, size: size)
                }

            }

            // 충돌설정
            self.viewBehavior = UIDynamicItemBehavior(items: [self.targetView])
            self.viewBehavior?.allowsRotation = false
            self.viewBehavior?.resistance = 8
            self.viewBehavior?.density = 0.02
            self.animator?.addBehavior(self.viewBehavior!)


            // 경계설정
            self.collision = UICollisionBehavior(items: [self.targetView])
            self.collision?.translatesReferenceBoundsIntoBoundary = true
            self.collision?.setTranslatesReferenceBoundsIntoBoundary(with: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
            self.animator?.addBehavior(self.collision!)


            self.addPanGesture(view: self.targetView)
        }

    }


    /// 자석 지역설정
    /// - Parameters:
    ///   - center: 위치
    ///   - size:   크기
    func addSpringField(center: CGPoint, size: CGSize) {
//        let scale = CGAffineTransform(scaleX: 0.5, y: 0.5)
//        let size = self.containerView.bounds.size.applying(scale)
        let springField = UIFieldBehavior.springField()
        springField.position = center
        springField.region = UIRegion(size: size)
        springField.addItem(targetView)
        animator?.addBehavior(springField)

//        let checkView = UIView(frame: .zero)
//        checkView.center = center
//        checkView.bounds.size = size
//        checkView.backgroundColor = randomColor()
//        checkView.alpha = 0.3
//
//        let centerPointView = UIView(frame: .zero)
//        centerPointView.backgroundColor = .red
//        centerPointView.layer.cornerRadius = 5
//        centerPointView.center = CGPoint(x: checkView.frame.width / 2, y: checkView.frame.height / 2)
//        centerPointView.frame.size = CGSize(width: 10, height: 10)
//        checkView.addSubview(centerPointView)
//        self.containerView.addSubview(checkView)
//        self.containerView.sendSubviewToBack(checkView)
    }

    private func addPanGesture(view: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let containerView = self.containerView else { return }
        guard let view = gesture.view else { return }
        switch gesture.state {
        case .began:
            self.view.bringSubviewToFront(view)
            currentLocation = gesture.location(in: containerView)
            attachment = UIAttachmentBehavior(item: view, attachedToAnchor: currentLocation)
            animator?.addBehavior(attachment!)
        case .changed:
            currentLocation = gesture.location(in: containerView)
            attachment?.anchorPoint = currentLocation
        case .cancelled, .ended:
            let velocity = gesture.velocity(in: containerView)
            viewBehavior?.addLinearVelocity(velocity, for: view)
            if let attachment = attachment {
                animator?.removeBehavior(attachment)
            }
            attachment = nil
        case .failed:
            if let attachment = attachment {
                animator?.removeBehavior(attachment)
            }
            attachment = nil
        case .possible:
            break
        @unknown default:
            break
        }
    }
}
