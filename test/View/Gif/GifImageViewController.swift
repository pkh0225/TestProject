//
//  GifImageViewController.swift
//  test
//
//  Created by 박길호(파트너) - 서비스개발담당App개발팀 on 2023/03/28.
//

import UIKit
import SwiftHelper

class GifImageViewController: UIViewController, RouterProtocol {
    static var storyboardName: String = "Main"

    @IBOutlet weak var testGifImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "GifImageView"

//        testGifImageView.gifImageWithName(name: "cmm_all_ani_pop_loading")
        self.testGifImageView.gifImageWithURL(gifUrl: "https://mblogthumb-phinf.pstatic.net/MjAyMDA1MjlfMTE2/MDAxNTkwNjg4MzQyOTI3.7iUf90aImVe8D1cfPu3ERBcbr-Bm285ro_gBF4r4bBYg.ctvl5JjnosAWNuKizkOWkGo8FaAZZUdqN1-YSjmV270g.GIF.zlan/%ED%8F%AC%ED%86%A0%EC%83%B5GIF%EB%A7%8C%EB%93%A4%EA%B8%B0%EB%8C%84%EC%8A%A4%EB%AA%A8%EC%85%982.gif?type=w800")
    }
}

