//
//  GradientViewController.swift
//  test
//
//  Created by 박길호 on 2023/04/09.
//

import UIKit
import SwiftHelper
import EasyConstraints

class CAGradientLayerTestViewController: UIViewController , RouterProtocol {

    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var frameWTextField: UITextField!
    @IBOutlet weak var frameHTextField: UITextField!
    @IBOutlet weak var startPointXTextField: UITextField!
    @IBOutlet weak var startPointYTextField: UITextField!
    @IBOutlet weak var endPointXTextField: UITextField!
    @IBOutlet weak var endPointYTextField: UITextField!
    @IBOutlet weak var colorsTextField: UITextField!
    @IBOutlet weak var locationsTextField: UITextField!
    @IBOutlet weak var axialButton: UIButton!
    @IBOutlet weak var radialButton: UIButton!
    @IBOutlet weak var conicButton: UIButton!
    
    private var gradientLayer: CAGradientLayer = CAGradientLayer()

    private var animationView: AnimatedGradientView!
    private var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Gradient"
        self.hideKeyboardWhenTappedAroundAndCancelsTouchesInView()

        self.frameWTextField.text = self.gradientView.ec.width.toString
        self.frameHTextField.text = self.gradientView.ec.height.toString

        self.makeAnimationView()

        self.setGradient()
    }

    private func makeAnimationView() {
        containerView = UIView(frame: CGRect(x: 10, y: 100, width: 100, height: 100))
        containerView.backgroundColor = .lightGray
        containerView.addSuperView(self.view)
            .ec.make()
            .leading(self.view.leadingAnchor, 10)
            .top(self.view.topAnchor, 600)
            .width(100)
            .height(100)


        animationView = AnimatedGradientView(frame: CGRect(x: 10, y: 100, width: 100, height: 100))
        animationView.cornerRadius(50)
        animationView.addSuperView(containerView)
            .ec.make()
            .leading(containerView.leadingAnchor)
            .trailing(containerView.trailingAnchor)
            .top(containerView.topAnchor)
            .bottom(containerView.bottomAnchor)



        let btn = UIButton(frame: self.animationView.bounds)
        self.animationView.addSubViewAutoLayout(btn)
        btn.addAction(for: .touchUpInside) { btn in
            let duration = 0.25

            CATransaction.begin()
            CATransaction.setAnimationDuration(duration)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))

            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
                if self.containerView.ec.width == 100 {
                    self.containerView.ec
                        .leading(10)
                        .width(300)
                        .height(300)
                }
                else {
                    self.containerView.ec
                        .leading(100)
                        .width(100)
                        .height(100)
                }

//                if self.animationView.ec.width == 100 {
//                    self.animationView.ec
//                        .width(300)
//                        .height(300)
//
//                }
//                else {
//                    self.animationView.ec
//                        .width(100)
//                        .height(100)
//                }
                self.view.layoutIfNeeded()
            }

//            self.animationView.gradientLayer.removeAllAnimations()
//            // frame 변경을 위한 애니메이션
//
//            CATransaction.begin()
//            CATransaction.setAnimationDuration(0.25)
//            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
//
//            let frameAnimation = CAKeyframeAnimation(keyPath: "frame")
////            frameAnimation.duration = 2.0
//            frameAnimation.fillMode = .forwards
//            frameAnimation.isRemovedOnCompletion = false
//
//            if self.animationView.gradientLayer.frame.width == 100 {
//                frameAnimation.values = [NSValue(cgRect: CGRect(x: 0, y: 0, width: 100, height: 100)) ,
//                NSValue(cgRect: CGRect(x: 0, y: 0, width: 300, height: 300))]
////                frameAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
//                self.animationView.gradientLayer.add(frameAnimation, forKey: "frameAnimation")
//                // 애니메이션 후 실제 frame 값을 업데이트 (중요)
//                self.animationView.gradientLayer.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
//            }
//            else {
//                frameAnimation.values = [NSValue(cgRect: CGRect(x: 0, y: 0, width: 300, height: 300)),
//                NSValue(cgRect: CGRect(x: 0, y: 0, width: 100, height: 100))]
////                frameAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
//                self.animationView.gradientLayer.add(frameAnimation, forKey: "frameAnimation")
//                // 애니메이션 후 실제 frame 값을 업데이트 (중요)
//                self.animationView.gradientLayer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//            }
//
//
//
            CATransaction.commit()




        }
    }

    @IBAction func onApply(_ sender: UIButton) {
        self.setGradient()
    }

    @IBAction func onAxial(_ sender: UIButton) {
        self.axialButton.isSelected = true
        self.radialButton.isSelected = false
        self.conicButton.isSelected = false
        self.setGradient()
        self.dismissKeyboard()
    }

    @IBAction func onRadial(_ sender: UIButton) {
        self.axialButton.isSelected = false
        self.radialButton.isSelected = true
        self.conicButton.isSelected = false
        self.setGradient()
        self.dismissKeyboard()
    }

    @IBAction func onConic(_ sender: UIButton) {
        self.axialButton.isSelected = false
        self.radialButton.isSelected = false
        self.conicButton.isSelected = true
        self.setGradient()
        self.dismissKeyboard()
    }

    func setGradient() {
        self.dismissKeyboard()
        self.gradientView.layer.sublayers?.removeAll()

        self.gradientView.ec.width = self.frameWTextField.text?.toCGFloat() ?? 0
        self.gradientView.ec.height = self.frameHTextField.text?.toCGFloat() ?? 0

        self.gradientLayer.frame = CGRect(x: 0, y: 0, width: self.gradientView.ec.width, height: self.gradientView.ec.height)
        if let colorStrings = self.colorsTextField.text?.split(",") {
            var colors = [CGColor]()
            for c in colorStrings {
                colors.append(UIColor.hexString(c).cgColor)
            }
            self.gradientLayer.colors = colors
        }

        if let locationStrings = self.locationsTextField.text?.split(",") {
            var loactions = [NSNumber]()
            for c in locationStrings {
                loactions.append(NSNumber(value: c.toDouble()))
            }
            self.gradientLayer.locations = loactions
        }

        if self.axialButton.isSelected {
            self.gradientLayer.type = .axial
        }
        else if self.radialButton.isSelected {
            self.gradientLayer.type = .radial
        }
        else if self.conicButton.isSelected {
            self.gradientLayer.type = .conic
        }
        self.gradientLayer.startPoint = CGPoint(x: self.startPointXTextField.text?.toCGFloat() ?? 0, y: self.startPointYTextField.text?.toCGFloat() ?? 0)
        self.gradientLayer.endPoint = CGPoint(x: self.endPointXTextField.text?.toCGFloat() ?? 0, y: self.endPointYTextField.text?.toCGFloat() ?? 0)
        self.gradientView.layer.addSublayer(gradientLayer)

        self.animationView.gradientLayer.locations = self.gradientLayer.locations
        self.animationView.gradientLayer.colors = self.gradientLayer.colors
        self.animationView.gradientLayer.type = self.gradientLayer.type
        self.animationView.gradientLayer.startPoint = self.gradientLayer.startPoint
        self.animationView.gradientLayer.endPoint = self.gradientLayer.endPoint

        self.view.layoutIfNeeded()


    }
}

extension CAGradientLayerTestViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        return true
    }
}


// 커스텀 그라데이션 뷰
class AnimatedGradientView: UIView {

    let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = bounds.height / 2
    }

    private func setupGradient() {
        gradientLayer.colors = [UIColor.purple.cgColor, UIColor.orange.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
    }

    func cornerRadius(_ value: CGFloat) {
        gradientLayer.cornerRadius = value
    }

}
