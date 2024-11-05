//
//  DynamicffectsBallViewController.swift
//  TestProduct
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 2023/04/10.
//

import UIKit

class DynamicffectsBallViewController: UIViewController {
    var safeAreaInsets: UIEdgeInsets = .zero
    var animator: UIDynamicAnimator!
    var orangeBall: UIView!

    var paddle: UIView!
    var paddleCenterPoint: CGPoint = .zero

    var pushBehavior: UIPushBehavior?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first {
            self.safeAreaInsets = window.safeAreaInsets
        }

        self.orangeBall = UIView(frame: CGRect(x: 100, y: 100, width: 50, height: 50))
        self.orangeBall.backgroundColor = .orange
        self.orangeBall.layer.cornerRadius = 25
        self.orangeBall.layer.borderColor = UIColor.black.cgColor
        self.orangeBall.layer.borderWidth = 0
        self.view.addSubview(self.orangeBall)

        self.animator = UIDynamicAnimator(referenceView: self.view)

//        self.demoGravity()
        self.playWithBall()

    }

    func demoGravity() {
        // 중력설정
        let gravityBehavior = UIGravityBehavior(items: [self.orangeBall])
        gravityBehavior.action = {
            print(self.orangeBall.center.y)
        }
        self.animator.addBehavior(gravityBehavior)

        // 경계설정
        let collisionBehavior = UICollisionBehavior(items: [self.orangeBall])
        let tabbarFrame = self.tabBarController?.tabBar.frame ?? .zero
        let x: CGFloat = tabbarFrame.origin.x
        let y: CGFloat = tabbarFrame.origin.y - safeAreaInsets.bottom
        collisionBehavior.addBoundary(withIdentifier: "tabbar" as NSString, from: CGPoint(x: x, y: y), to: CGPoint(x: x + tabbarFrame.size.width, y: y))
        collisionBehavior.collisionDelegate = self
        collisionBehavior.collisionMode = .everything
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        self.animator.addBehavior(collisionBehavior)

        // 충돌설정
        let ballBehavior = UIDynamicItemBehavior(items: [self.orangeBall])
        ballBehavior.elasticity = 0.9
        ballBehavior.resistance = 0.0
        ballBehavior.friction = 0.0
        ballBehavior.allowsRotation = false
        self.animator.addBehavior(ballBehavior)
    }

    func playWithBall() {
        let tabbarFrame = self.tabBarController?.tabBar.frame ?? .zero
        let x: CGFloat = tabbarFrame.origin.x
        let y: CGFloat = tabbarFrame.origin.y - safeAreaInsets.bottom

        // 중력설정
        let gravityBehavior = UIGravityBehavior(items: [self.orangeBall])
        gravityBehavior.action = {
//            print(self.orangeBall.center.y)
        }
        self.animator.addBehavior(gravityBehavior)

        // 충돌설정
        let ballBehavior = UIDynamicItemBehavior(items: [self.orangeBall])
        ballBehavior.elasticity = 0.9
        ballBehavior.resistance = 0.0
        ballBehavior.friction = 0.0
        ballBehavior.allowsRotation = false
        self.animator.addBehavior(ballBehavior)


        let obstacle1 = UIView(frame: CGRect(x: 0, y: safeAreaInsets.top + 180, width: 120, height: 20))
        obstacle1.backgroundColor = .blue

        let obstacle2 = UIView(frame: CGRect(x: 250, y: safeAreaInsets.top + 400, width: 150, height: 20))
        obstacle2.backgroundColor = .cyan

        let obstacle3 = UIView(frame: CGRect(x: (self.view.frame.size.width / 2) - 75, y: safeAreaInsets.top + 520, width: 150, height: 20))
        obstacle3.backgroundColor = .black

        self.view.addSubview(obstacle1)
        self.view.addSubview(obstacle2)
        self.view.addSubview(obstacle3)

        self.paddle = UIView(frame: CGRect(x: (self.view.frame.size.width / 2) - 75, y: y - 35, width: 200, height: 30))
        self.paddle.backgroundColor = .green
        self.paddle.layer.cornerRadius = 15
        self.paddleCenterPoint = self.paddle.center
        self.view.addSubview(self.paddle)

        // 충돌설정
        let paddleBehavior = UIDynamicItemBehavior(items: [self.paddle])
        paddleBehavior.allowsRotation = false
        paddleBehavior.density = 100000.0
        self.animator.addBehavior(paddleBehavior)

        // 경계설정
        let collisionBehavior = UICollisionBehavior(items: [self.orangeBall, obstacle1, obstacle2, obstacle3, self.paddle])

        collisionBehavior.addBoundary(withIdentifier: "tabbar" as NSString, from: CGPoint(x: x, y: y), to: CGPoint(x: x + tabbarFrame.size.width, y: y))
        collisionBehavior.collisionDelegate = self
        collisionBehavior.collisionMode = .everything
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        self.animator.addBehavior(collisionBehavior)

        // 충돌설정
        let obstacles1And2Behavior = UIDynamicItemBehavior(items: [obstacle1, obstacle2])
        obstacles1And2Behavior.allowsRotation = false
        obstacles1And2Behavior.density = 100000.0
        self.animator.addBehavior(obstacles1And2Behavior)

        // 충돌설정
        let obstacle3Behavior = UIDynamicItemBehavior(items: [obstacle3])
        obstacle3Behavior.allowsRotation = true
        self.animator.addBehavior(obstacle3Behavior)

        addPanGesture(view: self.view)
        addTapGesture(view: self.orangeBall)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let pushBehavior = UIPushBehavior(items: [self.orangeBall], mode: .instantaneous)
            pushBehavior.magnitude = 0.5
            self.animator.addBehavior(pushBehavior)
        }
    }

    private func addTapGesture(view: UIView) {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(gesture)
    }


    private func addPanGesture(view: UIView) {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(gesture)
    }

    @objc private func handleTapGesture(_ gesture: UIPanGestureRecognizer) {
        if let pushBehavior = self.pushBehavior {
            self.animator.removeBehavior(pushBehavior)
        }
        self.pushBehavior = UIPushBehavior(items: [self.orangeBall], mode: .instantaneous)
        self.pushBehavior?.angle = 0;
        self.pushBehavior?.magnitude = 1;
        self.animator.addBehavior(self.pushBehavior!)
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view  else { return }
        switch gesture.state {
        case .began, .changed:
            let touchLocation = gesture.location(in: view)
            self.paddle.center = CGPoint(x: touchLocation.x, y: self.paddleCenterPoint.y)
//            self.paddle.center = touchLocation
            self.animator.updateItem(usingCurrentState: self.paddle)
           break
        case .cancelled, .ended:
            break
        case .possible:
            break
        case .failed:
            break
        default:
            break
        }
    }

}

extension DynamicffectsBallViewController: UICollisionBehaviorDelegate {
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item1: UIDynamicItem, with item2: UIDynamicItem, at p: CGPoint) {
        if item1 === self.orangeBall && item2 === self.paddle {
            if let pushBehavior = self.pushBehavior {
                self.animator.removeBehavior(pushBehavior)
            }
            self.pushBehavior = UIPushBehavior(items: [self.orangeBall], mode: .instantaneous)
            self.pushBehavior?.angle = 0.0;
            self.pushBehavior?.magnitude = 0.5;
            // 각도
            let vector1 = CGVector(dx: -0.5, dy: -0.5)
            self.pushBehavior?.pushDirection = vector1
            // 미는 중심점 변경
//            let offset = UIOffset(horizontal: 10, vertical: 20)
//            push.setTargetOffsetFromCenter(offset, for: self.pushBehavior!)
            self.animator.addBehavior(self.pushBehavior!)
            print("push")
        }
    }


    func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item1: UIDynamicItem, with item2: UIDynamicItem) {

    }


    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        self.orangeBall.backgroundColor = .brown
    }

    func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
        self.orangeBall.backgroundColor = .orange
    }
}
