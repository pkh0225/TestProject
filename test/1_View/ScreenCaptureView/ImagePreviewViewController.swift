//
//  ImagePreviewViewController.swift
//  TestProduct
//
//  Created by 박길호(팀원) - 서비스개발담당App개발팀 on 6/20/25.
//

import UIKit

class ImagePreviewViewController: UIViewController, UIScrollViewDelegate {
    var image: UIImage?
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        // 스크롤뷰 설정
        scrollView.frame = view.bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        view.addSubview(scrollView)
        
        // 이미지뷰 설정
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.frame = scrollView.bounds
        scrollView.addSubview(imageView)
        
        // 닫기 버튼 추가
        addCloseButton()
    }
    
    private func addCloseButton() {
        let closeButton = UIButton(type: .system)
        
        // 배경색 및 모양 설정
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        closeButton.layer.cornerRadius = 22 // 원형 버튼
        closeButton.layer.masksToBounds = true
        
        // 아이콘/텍스트 및 색상 설정
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
            let xmarkImage = UIImage(systemName: "xmark", withConfiguration: config)
            closeButton.setImage(xmarkImage, for: .normal)
        } else {
            closeButton.setTitle("X", for: .normal)
            closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        }
        closeButton.tintColor = .white // 아이콘 색상
        
        closeButton.addTarget(self, action: #selector(dismissPreview), for: .touchUpInside)
        
        view.addSubview(closeButton)
        
        // Auto Layout 설정
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func dismissPreview() {
        dismiss(animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
