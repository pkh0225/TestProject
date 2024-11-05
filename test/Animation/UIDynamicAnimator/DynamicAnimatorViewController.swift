//
//  DynamicAnimatorViewController.swift
//  test
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 2023/04/09.
//

import UIKit
import SwiftHelper

class DynamicAnimatorViewController: UIViewController , RouterProtocol {
    static var storyboardName: String = "Main"
    
    @IBOutlet weak var containerView: UIView!
    var blueBoxView: UIView?
    var redBoxView: UIView?
    var purpleBoxView: UIView?

    // 다이나믹스 애니메이터 인스턴스 변수 선언
    var animator: UIDynamicAnimator?
    // 앵커 포인트 현재 위치 저장할 변수
    var currentLocation: CGPoint = .zero
    // 항목이 붙어있는 것을 구현할 수 있는 클래스
    var attachment: UIAttachmentBehavior?

    override func viewDidLoad() {
        super.viewDidLoad()

        var frameRect = CGRect(x: 10, y: 20, width: 80, height: 80)
        blueBoxView = UIView(frame: frameRect)
        blueBoxView?.backgroundColor = UIColor.blue
        addPanGesture(view: blueBoxView!)

        frameRect = CGRect(x: 160, y: 20, width: 60, height: 60)
        redBoxView = UIView(frame: frameRect)
        redBoxView?.backgroundColor = UIColor.red
        addPanGesture(view: redBoxView!)

        frameRect = CGRect(x: 290, y: 20, width: 40, height: 40)
        purpleBoxView = UIView(frame: frameRect)
        purpleBoxView?.backgroundColor = UIColor.purple
        addPanGesture(view: purpleBoxView!)

        self.containerView.addSubview(blueBoxView!)
        self.containerView.addSubview(redBoxView!)
        self.containerView.addSubview(purpleBoxView!)

        // 다이나믹스 인스턴스 생성 초기화
        animator = UIDynamicAnimator(referenceView: self.containerView)


        // 두 뷰에 대한 중력 설정
        let gravity = UIGravityBehavior(items: [blueBoxView!, redBoxView!, purpleBoxView!])
        // y축 방향으로 1.0 UIkit Newton의 중력 설정. 음수 값으로 설정하면 중력의 반대 방향으로 간다.
        let vector = CGVector(dx: 0.0, dy: 1.0)
        gravity.gravityDirection = vector

        animator?.addBehavior(gravity)



        // 충돌 설정
        let collision = UICollisionBehavior(items: [blueBoxView!, redBoxView!, purpleBoxView!])
        // 설정된 경계와 충돌을 한다.
        collision.translatesReferenceBoundsIntoBoundary = true
        animator?.addBehavior(collision)

        let behavior = UIDynamicItemBehavior(items: [blueBoxView!])
        // 탄성 설정 값이 높을수록 높게 튀어오름
//        behavior.allowsRotation = false
        behavior.elasticity = 0.5
        animator?.addBehavior(behavior)
/*
 UIDynamicItemBehavor 클래스
 let behavior1 = UIDynamicItemBehavior(items: [purpleBoxView!])
 // 회전을 허용할 것인지
 behavior1.allowsRotation = true
 // 회전에 저항하는 강도 값이 높을수록 빨리 멈춘다
 behavior1.angularResistance = 1.0
 // 항목의 질량
 behavior1.density = 1.0
 // 충돌시 탄성 정도 값이 클수록 많이 튕긴다
 behavior1.elasticity = 1.0
 // 항목이 미끄러질 때 저항
 behavior1.friction = 1.0
 // 항목의 전체적인 저항 값이 크면 빨리 멈춘다
 behavior1.resistance = 1.0
 // 각속도를 증가,감소 시킨다
 behavior1.addAngularVelocity(1.0, for: purpleBoxView!)
 // 선속도를 증가,감소 시킨다
 behavior1.addLinearVelocity(point, for: purpleBoxView!)

 동작 결합하기(커스텀 동작)
 let customBehavior = UIDynamicBehavior()
 customBehavior.addChildBehavior(behavior)
 customBehavior.addChildBehavior(snap)
 customBehavior.addChildBehavior(gravity)
 customBehavior.addChildBehavior(boxAttachment)
 
 animator?.addBehavior(customBehavior)
 */
        

        // 스프링 연결
        let boxAttachment = UIAttachmentBehavior(item: blueBoxView!, attachedTo: redBoxView!)
        // 스프링 효과 빈도 값
        boxAttachment.frequency = 4.0
        // 감쇠 값
        boxAttachment.damping = 0.0

        animator?.addBehavior(boxAttachment)

        // 스프링 연결
        let boxAttachment2 = UIAttachmentBehavior(item: redBoxView!, attachedTo: purpleBoxView!)
        // 스프링 효과 빈도 값
        boxAttachment2.frequency = 4.0
        // 감쇠 값
        boxAttachment2.damping = 0.0

        boxAttachment2.length = 200

        animator?.addBehavior(boxAttachment2)



        // 스냅
//        let point = CGPoint(x: 100, y: 100)
//        let snap = UISnapBehavior(item: blueBoxView!, snapTo: point)
//        // 감쇠 기본값 0.5 숫자가 작을수록 땡기는 힘이 강하다. (최대값 1.0)
//        // snap.damping = 0.5
//        animator?.addBehavior(snap)



        // 푸시 mode: .continuous - 지속적으로 밀어서 점점 빨라짐 .instantaneous - 한번 밀어서 점점 느려짐
//        let push = UIPushBehavior(items: [purpleBoxView!], mode: .instantaneous)
//        let vector1 = CGVector(dx: 0.2, dy: 0.2)
//        push.pushDirection = vector1
//        // 미는 중심점 변경
//        let offset = UIOffset(horizontal: 10, vertical: 20)
//        push.setTargetOffsetFromCenter(offset, for: purpleBoxView!)
//
//        animator?.addBehavior(push)


    }

    private func addPanGesture(view: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }


    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view  else { return }
        guard let containerView = self.containerView else { return }
        switch gesture.state {
        case .began:
            currentLocation = gesture.location(in: containerView)
//            let offset = UIOffset(horizontal: 20, vertical: 20)
            // 오프셋 인자를 제거하면 아이템의 중심에 연결된다.
            attachment = UIAttachmentBehavior(item: view/*, offsetFromCenter: offset*/, attachedToAnchor: currentLocation)
            animator?.addBehavior(attachment!)
        case .changed:
            currentLocation = gesture.location(in: containerView)
            attachment?.anchorPoint = currentLocation
        case .cancelled, .ended:
            if let attachment = attachment {
                animator?.removeBehavior(attachment)
            }
            attachment = nil
        case .possible:
            break
        case .failed:
            if let attachment = attachment {
                animator?.removeBehavior(attachment)
            }
            attachment = nil
        @unknown default:
            break
        }
    }
}
