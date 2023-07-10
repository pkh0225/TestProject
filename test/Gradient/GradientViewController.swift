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

        self.view.backgroundColor = UIColor.hexString("f5f5f5")
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = testView.bounds // Set the bounds of the gradient layer
//        gradientLayer.backgroundColor = UIColor.clear
        gradientLayer.colors = [UIColor.hexString("ff0000").cgColor, UIColor.hexString("00ff00").cgColor] // Set the colors of the gradient
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5) // Set the starting point of the gradient to the top-left corner
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5) // Set the ending point of the gradient to the bottom-right corner
        gradientLayer.locations = [0, 1]
//        let radians = atan2(testView.frame.height, testView.frame.width) // Calculate the angle of the gradient in radians
//        let degrees = radians * 180 / .pi // Convert the angle to degrees
//        gradientLayer.transform = CATransform3DMakeRotation(radians, 0, 0, 1) // Rotate the gradient layer by the calculated angle

        testView.layer.addSublayer(gradientLayer) // Add the gradient layer to your view's layer
    }
}




extension UIColor {
    public class func hexString(_ hexString: String, alpha: CGFloat = 1.0, defaultColor: UIColor = .darkGray) -> UIColor {
        var alpha = alpha
        var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count) != 6 {
            if cString.count == 8 {
                // alpha 코드 포함
                let endIdx: String.Index = cString.index(cString.startIndex, offsetBy: 1)
                let startIdx: String.Index = cString.index(cString.startIndex, offsetBy: 2)

                let alphaCode = String(cString[...endIdx])
                cString = String(cString[startIdx...])

                let alphaDeci = Int(alphaCode, radix: 16)! // hex to decimal
                let alphaVal = round(Double(alphaDeci) / 255.0 * 100) / 100 // decimal 수치로 변환 후 소숫점 두자리까지 표현
                alpha = CGFloat( alphaVal )
            }
            else {
                return defaultColor
            }
        }

        let key = "\(hexString)_\(alpha)"

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        let color: UIColor = UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: alpha)

        return color
    }


}
