//
//  GradientViewController.swift
//  test
//
//  Created by 박길호 on 2023/04/09.
//

import UIKit
import SwiftHelper

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
    
    var gradientLayer: CAGradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Gradient"
        self.hideKeyboardWhenTappedAroundAndCancelsTouchesInView()

        self.gradientLayer.frame = CGRect(x: 0, y: 0, width: self.gradientView.ec.width, height: self.gradientView.ec.height)
        self.gradientView.layer.addSublayer(gradientLayer)

        self.frameWTextField.text = self.gradientView.ec.width.toString
        self.frameHTextField.text = self.gradientView.ec.height.toString

        self.setGradient()
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
        self.view.layoutIfNeeded()
    }
}

extension CAGradientLayerTestViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        return true
    }
}
