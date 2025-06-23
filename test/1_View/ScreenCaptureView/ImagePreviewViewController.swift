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
    private var isDraggingDownToDismiss = false
    
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
        
        // 아래로 당겨서 닫기 제스처 추가
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDismissPan(_:)))
        view.addGestureRecognizer(panGesture)
        
        // 더블탭 제스처 추가
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
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
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let zoomRect = zoomRectForScale(scale: 2.5, center: gesture.location(in: imageView))
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }

    private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width  = imageView.frame.size.width  / scale
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    @objc private func handleDismissPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)

        switch gesture.state {
        case .began:
            // 스크롤뷰가 맨 위에 있을 때만 당기기 시작
            isDraggingDownToDismiss = scrollView.contentOffset.y <= 0
        case .changed:
            // 아래로 당기는 중일 때만 뷰를 움직임
            guard isDraggingDownToDismiss, translation.y >= 0 else { return }
            
            view.transform = CGAffineTransform(translationX: 0, y: translation.y)
            view.alpha = 1.0 - (translation.y / view.frame.height)
            
        case .ended, .cancelled:
            guard isDraggingDownToDismiss else { return }

            let velocity = gesture.velocity(in: view)
            // 충분히 당겼거나 빠르게 쓸어내렸을 때 닫기
            if translation.y > view.bounds.height / 3 || velocity.y > 500 {
                dismiss(animated: true, completion: nil)
            } else {
                // 원위치로 복귀
                UIView.animate(withDuration: 0.3) {
                    self.view.transform = .identity
                    self.view.alpha = 1.0
                }
            }
            isDraggingDownToDismiss = false
        default:
            isDraggingDownToDismiss = false
            UIView.animate(withDuration: 0.3) {
                self.view.transform = .identity
                self.view.alpha = 1.0
            }
        }
    }
    
    @objc private func dismissPreview() {
        dismiss(animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
