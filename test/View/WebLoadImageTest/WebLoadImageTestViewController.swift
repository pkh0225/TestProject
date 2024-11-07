//
//  NukeTestViewController.swift
//  TestProduct
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 2023/06/02.
//

import UIKit
import SDWebImage
import SDWebImageWebPCoder
import SwiftHelper

class WebLoadImageTestViewController: UIViewController, RouterProtocol {
    static var storyboardName: String = "Main"

    @IBOutlet weak var gifImageView: UIImageView!

    @IBOutlet weak var webpImageView: UIImageView!
    @IBOutlet weak var webpImageView2: UIImageView!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "WebP Image"
        let WebPCoder = SDImageWebPCoder.shared
        SDImageCodersManager.shared.addCoder(WebPCoder)

    }

    
    @IBAction func onLoadButton(_ sender: UIButton) {

        do {
            let url = URL(string: "https://media.tenor.com/pS1K3X8FTrYAAAAC/test.gif")!
            gifImageView.sd_setImage(with: url) { img,_,_,_ in
                print("imageLoopCount: \(img?.sd_imageLoopCount)")
            }
        }

        do {
            let url = URL(string: "https://mathiasbynens.be/demo/animated-webp-supported.webp")!
            webpImageView.sd_setImage(with: url) { img,_,_,_ in
                print("imageLoopCount: \(img?.sd_imageLoopCount)")
                img?.sd_imageLoopCount = 3
                self.webpImageView.image?.sd_imageLoopCount = 3
            }
        }
        do {
            let url = URL(string: "https://sui.ssgcdn.com/cmpt/banner/202304/2023040710394543500068152106_62.gif")!
            webpImageView2.sd_setImage(with: url) { img,_,_,_ in
                print("imageLoopCount: \(img?.sd_imageLoopCount)")
                img?.sd_imageLoopCount = 3
            }
        }

    }
    @IBAction func onStopButton(_ sender: UIButton) {
        self.gifImageView.stopAnimating()
        self.webpImageView.stopAnimating()
        self.webpImageView2.stopAnimating()
    }
    @IBAction func onStartButton(_ sender: UIButton) {
        self.gifImageView.startAnimating()
        self.webpImageView.startAnimating()
        self.webpImageView2.startAnimating()
    }
}
