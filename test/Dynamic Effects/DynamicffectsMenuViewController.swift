//
//  DynamicffectsMenuViewController.swift
//  TestProduct
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 2023/04/10.
//

import UIKit

private let MENU_WIDTH: CGFloat = 150

class DynamicffectsMenuViewController: UIViewController {
    var safeAreaInsets: UIEdgeInsets = .zero

    var menuView: UIView!
    var backgroundView: UIView!
    var animator: UIDynamicAnimator!

    @IBOutlet weak var centerLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first {
            self.safeAreaInsets = window.safeAreaInsets
        }

        self.animator = UIDynamicAnimator(referenceView: self.view)
        
        self.backgroundView = UIView(frame: self.view.bounds)
        self.backgroundView.backgroundColor = .lightGray
        self.backgroundView.alpha = 0
        self.view.addSubview(self.backgroundView)

        self.setupMenuView()

        let showMenuGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        showMenuGesture.direction = .right
        self.view.addGestureRecognizer(showMenuGesture)

        let hideMenuGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        hideMenuGesture.direction = .left
        self.backgroundView.addGestureRecognizer(hideMenuGesture)
    }

    func setupMenuView() {
        self.menuView = UIView(frame: CGRect(x: -MENU_WIDTH, y: safeAreaInsets.top, width: MENU_WIDTH, height: self.view.frame.size.height - safeAreaInsets.top - safeAreaInsets.bottom))
        self.menuView.backgroundColor = .cyan
        self.view.addSubview(self.menuView)
    }

    func toggleMenu(isOpne: Bool) {
        self.animator.removeAllBehaviors()

        let gravityDirectionX = isOpne ? 1.0 : -1.0
        let pushMagnitude = isOpne ? 20.0 : -20.0
        let boundaryPointX = isOpne ? MENU_WIDTH : -MENU_WIDTH

        let gravityBehavior = UIGravityBehavior(items: [self.menuView])
        gravityBehavior.gravityDirection = CGVector(dx: gravityDirectionX, dy: 0.0)
        self.animator.addBehavior(gravityBehavior)

        let collisionBehavior = UICollisionBehavior(items: [self.menuView])
        collisionBehavior.addBoundary(withIdentifier: "menuBoundary" as NSString, from: CGPoint(x: boundaryPointX, y: safeAreaInsets.top), to: CGPoint(x: boundaryPointX, y: self.view.frame.size.height - safeAreaInsets.top - safeAreaInsets.bottom))
        self.animator.addBehavior(collisionBehavior)

        let pushBehavior = UIPushBehavior(items: [self.menuView], mode: .instantaneous)
        pushBehavior.magnitude = pushMagnitude
        self.animator.addBehavior(pushBehavior)

        let menuViewBehavior = UIDynamicItemBehavior(items: [self.menuView])
        menuViewBehavior.elasticity = 0.4
        self.animator.addBehavior(menuViewBehavior)

        UIView.animate(withDuration: 0.3) {
            self.backgroundView.alpha = isOpne ? 0.5 : 0
        }

        self.centerLabel.text = isOpne ? "<<< 왼쪽으로 스와이프 하세요 " : ">>> 오른쪽으로 스와이프 하세요 "
    }

    @objc private func handleTapGesture(_ gesture: UISwipeGestureRecognizer) {
        self.toggleMenu(isOpne: gesture.direction == .right)
    }
}
