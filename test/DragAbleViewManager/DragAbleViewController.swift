//
//  DragAbleViewController.swift
//  test
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 2023/04/09.
//

import UIKit

class DragAbleViewController: UIViewController, RouterProtocol {
    static var storyboardName: String = ""

    var dragAbleViewManager: DragAbleViewManager?
    var blueBoxView: DragAbleView!
    var itemViews = [UIView]()

    var addButton: UIButton!
    var removeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return }
        let top = window.safeAreaInsets.top
        //            let bottom = window.safeAreaInsets.bottom

        //            let frameRect = CGRect(x: 10, y: top, width: 80, height: 80)
        //            self.blueBoxView = DragAbleView(frame: frameRect)
        //            self.blueBoxView.backgroundColor = UIColor.blue
        //            window.addSubview(self.blueBoxView)
        //            self.blueBoxView.setContainerView(containerView: window, setBoundsIntoBoundary: UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0))


        addButton = UIButton(frame: CGRect(x: 50, y: top + 50, width: 50, height: 50))
        addButton?.setTitle("add", for: .normal)
        addButton?.addTarget(self, action: #selector(self.onButtonAdd), for: .touchUpInside)
        addButton?.backgroundColor = .blue
        self.view.addSubview(addButton)

        removeButton = UIButton(frame: CGRect(x: 150, y: top + 50, width: 80, height: 50))
        removeButton?.setTitle("remove", for: .normal)
        removeButton?.addTarget(self, action: #selector(self.onButtonRemove), for: .touchUpInside)
        removeButton?.backgroundColor = .red
        self.view.addSubview(removeButton)
    }

//    deinit {
//        for view in itemViews {
//            view.removeFromSuperview()
//        }
//    }

    @objc func onButtonAdd() {
        guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return }
        let top = window.safeAreaInsets.top
        let bottom = window.safeAreaInsets.bottom
        let v = TestView(frame: CGRect(x: 100, y: top + 100, width: 100, height: 100))
        v.backgroundColor = randomColor()
//        window.addSubview(v)
        self.view.addSubview(v)

        itemViews.append(v)
        if dragAbleViewManager == nil {
            dragAbleViewManager = DragAbleViewManager(containerView: window, setBoundsIntoBoundary: UIEdgeInsets(top: top, left: 0, bottom: bottom, right: 0), itemViews: [v])
        }
        else {
            dragAbleViewManager?.addView(view: v)
        }
    }

    @objc func onButtonRemove() {
        if let v = itemViews.last {
            dragAbleViewManager?.removeView(view: v)
            v.removeFromSuperview()
            itemViews.removeLast()
        }
    }
}

public class DragAbleViewManager {
    weak var containerView: UIView?
    var itemViews = [UIView: UIPanGestureRecognizer]()
    // 다이나믹스 애니메이터 인스턴스 변수 선언
    var animator:UIDynamicAnimator?
    // 탄성 설정
    var viewBehavior: UIDynamicItemBehavior?
    // 항목이 붙어있는 것을 구현할 수 있는 클래스
    var attachment: UIAttachmentBehavior?
    // 충돌 설정
    var collision: UICollisionBehavior?
    // 앵커 포인트 현재 위치 저장할 변수
    var currentLocation: CGPoint = .zero

    // View가 먼저 Add 된 후 호출 해야 함
    public init(containerView: UIView, setBoundsIntoBoundary: UIEdgeInsets, itemViews: [UIView]) {
        self.containerView = containerView
        animator = UIDynamicAnimator(referenceView: containerView)

        viewBehavior = UIDynamicItemBehavior(items: itemViews)
        viewBehavior?.allowsRotation = false
        viewBehavior?.resistance = 5
        viewBehavior?.density = 0.02
        animator?.addBehavior(viewBehavior!)


        collision = UICollisionBehavior(items: itemViews)
        collision?.translatesReferenceBoundsIntoBoundary = true
        collision?.setTranslatesReferenceBoundsIntoBoundary(with: setBoundsIntoBoundary)
        animator?.addBehavior(collision!)

        addPanGesture(itemViews: itemViews)
    }

    deinit {
        print("deinit DragAbleViewManager")
    }

    public func addView(view: UIView) {
        viewBehavior?.addItem(view)
        collision?.addItem(view)
        addPanGesture(itemViews: [view])
    }

    public func removeView(view: UIView) {
        viewBehavior?.removeItem(view)
        collision?.removeItem(view)
        if let g = self.itemViews[view] {
            view.removeGestureRecognizer(g)
        }
        self.itemViews.removeValue(forKey: view)
    }

    private func addPanGesture(itemViews: [UIView]) {
        for v in itemViews {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
            v.addGestureRecognizer(panGesture)
            self.itemViews[v] = panGesture
        }
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view  else { return }
        guard let containerView = self.containerView else { return }
        switch gesture.state {
        case .began:
            containerView.bringSubviewToFront(view)
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


public class DragAbleView: UIView {
    weak var containerView: UIView?
    // 다이나믹스 애니메이터 인스턴스 변수 선언
    public var animator: UIDynamicAnimator?
    // 탄성 설정
    public var viewBehavior: UIDynamicItemBehavior?
    // 항목이 붙어있는 것을 구현할 수 있는 클래스
    public var attachment: UIAttachmentBehavior?
    // 충돌 설정
    public var collision: UICollisionBehavior?
    // 앵커 포인트 현재 위치 저장할 변수
    var currentLocation: CGPoint = .zero

    deinit {
        print("deinit DragAbleView")
    }

    /// View가 먼저 Add 된 후 호출 해야 함
    /// - Parameters:
    ///   - containerView: 경계가 되는 부모 뷰
    ///   - setBoundsIntoBoundary: insets
    public func setContainerView(containerView: UIView, setBoundsIntoBoundary: UIEdgeInsets) {
        self.containerView = containerView
        animator = UIDynamicAnimator(referenceView: containerView)

        viewBehavior = UIDynamicItemBehavior(items: [self])
        viewBehavior?.allowsRotation = false
        viewBehavior?.resistance = 5
        viewBehavior?.density = 0.02
        animator?.addBehavior(viewBehavior!)

        collision = UICollisionBehavior(items: [self])
        collision?.translatesReferenceBoundsIntoBoundary = true
        collision?.setTranslatesReferenceBoundsIntoBoundary(with: setBoundsIntoBoundary)
        animator?.addBehavior(collision!)

        addPanGesture()
    }

    /// 저항 조절
    /// - Parameter value: 커질수록 속도가 빨리 줄어듬
    public func setResistance(_ value: CGFloat) {
        viewBehavior?.resistance = value
    }

    private func addPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.addGestureRecognizer(panGesture)
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let containerView = self.containerView else { return }
        switch gesture.state {
        case .began:
            containerView.bringSubviewToFront(self)
            currentLocation = gesture.location(in: containerView)
            attachment = UIAttachmentBehavior(item: self, attachedToAnchor: currentLocation)
            animator?.addBehavior(attachment!)
        case .changed:
            currentLocation = gesture.location(in: containerView)
            attachment?.anchorPoint = currentLocation
        case .cancelled, .ended:
            let velocity = gesture.velocity(in: containerView)
            viewBehavior?.addLinearVelocity(velocity, for: self)
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





class TestView: UIView {

    deinit {
        print("\(#function) TestView")
    }
}
