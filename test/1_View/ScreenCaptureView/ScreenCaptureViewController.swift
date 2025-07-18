//
//  Untitled.swift
//  TestProduct
//
//  Created by 박길호(팀원) - 서비스개발담당App개발팀 on 6/20/25.
//

import UIKit
import SwiftHelper
import ViewSpacingCapture

class ScreenCaptureViewController: UIViewController, RouterProtocol {
    static var storyboardName: String = "ScreenCaptureView"

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        collectionView.reloadData()

        // 플로팅 버튼 표시
        FloatingCaptureButton.shared.showFloatingButton()
    }
}

extension ScreenCaptureViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "ScreenCaptureCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 105)
        
    }
    
}


class ScreenCaptureCell: UICollectionViewCell {

}
