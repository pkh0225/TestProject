//
//  GradientViewController.swift
//  test
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 2023/04/09.
//

import UIKit

class GradientViewController: UIViewController , RouterProtocol {
    static var storyboardName: String = "Main"

    @IBOutlet weak var testView: UIView!


    override func viewDidLoad() {
        super.viewDidLoad()

        testGraadientView()

    }

    func testGraadientView() {
        testView.clipsToBounds = true

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = testView.bounds // Set the bounds of the gradient layer
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.blue.cgColor] // Set the colors of the gradient
        gradientLayer.startPoint = CGPoint(x: 0, y: 0) // Set the starting point of the gradient to the top-left corner
        gradientLayer.endPoint = CGPoint(x: 1, y: 1) // Set the ending point of the gradient to the bottom-right corner
//        let radians = atan2(testView.frame.height, testView.frame.width) // Calculate the angle of the gradient in radians
//        let degrees = radians * 180 / .pi // Convert the angle to degrees
//        gradientLayer.transform = CATransform3DMakeRotation(radians, 0, 0, 1) // Rotate the gradient layer by the calculated angle

        testView.layer.addSublayer(gradientLayer) // Add the gradient layer to your view's layer
    }
}
