//
//  Untitled.swift
//  TestProduct
//
//  Created by 박길호(팀원) - 서비스개발담당App개발팀 on 6/20/25.
//

import UIKit
import SwiftHelper

class ScreenCaptureViewController: UIViewController, RouterProtocol {
    
    private let screenCaptureManager = ViewSpacingCaptureManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        
        // 플로팅 버튼 표시
        FloatingCaptureButton.shared.showFloatingButton()
    }
    
    private func setupLayout() {
        // --- 최상위 뷰들 ---
        let topBanner = createView(color: .systemIndigo, text: "Top Banner (A)")
        let middleScrollView = UIScrollView()
        let bottomButton = createButton(title: "Capture Screen")
        
        middleScrollView.backgroundColor = .systemGray5
        
        view.addSubview(topBanner)
        view.addSubview(middleScrollView)
        view.addSubview(bottomButton)
        
        // --- middleScrollView 내부 뷰들 ---
        let innerContainer = createView(color: .systemTeal, text: "Container (B)")
        middleScrollView.addSubview(innerContainer)
        
        let redBox = createView(color: .systemRed, text: "Red")
        let greenBox = createView(color: .systemGreen, text: "Green")
        innerContainer.addSubview(redBox)
        innerContainer.addSubview(greenBox)
        
        // --- redBox 내부 뷰 ---
        let deepBlueBox = createView(color: .blue, text: "Deep (C)")
        redBox.addSubview(deepBlueBox)
        
        // --- 오토레이아웃 설정 ---
        topBanner.translatesAutoresizingMaskIntoConstraints = false
        middleScrollView.translatesAutoresizingMaskIntoConstraints = false
        bottomButton.translatesAutoresizingMaskIntoConstraints = false
        innerContainer.translatesAutoresizingMaskIntoConstraints = false
        redBox.translatesAutoresizingMaskIntoConstraints = false
        greenBox.translatesAutoresizingMaskIntoConstraints = false
        deepBlueBox.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            // 최상위 뷰
            topBanner.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            topBanner.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            topBanner.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            topBanner.heightAnchor.constraint(equalToConstant: 100),
            
            middleScrollView.topAnchor.constraint(equalTo: topBanner.bottomAnchor, constant: 15),
            middleScrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 30),
            middleScrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -30),
            
            bottomButton.topAnchor.constraint(equalTo: middleScrollView.bottomAnchor, constant: 25),
            bottomButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20),
            bottomButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            bottomButton.widthAnchor.constraint(equalToConstant: 200),
            bottomButton.heightAnchor.constraint(equalToConstant: 50),
            
            // ScrollView 내부 뷰
            innerContainer.topAnchor.constraint(equalTo: middleScrollView.contentLayoutGuide.topAnchor, constant: 10),
            innerContainer.leadingAnchor.constraint(equalTo: middleScrollView.contentLayoutGuide.leadingAnchor, constant: 10),
            innerContainer.trailingAnchor.constraint(equalTo: middleScrollView.contentLayoutGuide.trailingAnchor, constant: -10),
            innerContainer.bottomAnchor.constraint(equalTo: middleScrollView.contentLayoutGuide.bottomAnchor, constant: -10),
            innerContainer.widthAnchor.constraint(equalTo: middleScrollView.frameLayoutGuide.widthAnchor, constant: -20), // 중요
            
            // Container 내부 뷰
            redBox.topAnchor.constraint(equalTo: innerContainer.topAnchor, constant: 20),
            redBox.leadingAnchor.constraint(equalTo: innerContainer.leadingAnchor, constant: 20),
            redBox.trailingAnchor.constraint(equalTo: innerContainer.trailingAnchor, constant: -20),
            redBox.heightAnchor.constraint(equalToConstant: 80),
            
            greenBox.topAnchor.constraint(equalTo: redBox.bottomAnchor, constant: 10),
            greenBox.leadingAnchor.constraint(equalTo: innerContainer.leadingAnchor, constant: 40),
            greenBox.trailingAnchor.constraint(equalTo: innerContainer.trailingAnchor, constant: -40),
            greenBox.heightAnchor.constraint(equalToConstant: 60),
            greenBox.bottomAnchor.constraint(equalTo: innerContainer.bottomAnchor, constant: -20),
            
            // RedBox 내부 뷰
            deepBlueBox.topAnchor.constraint(equalTo: redBox.topAnchor, constant: 10),
            deepBlueBox.leadingAnchor.constraint(equalTo: redBox.leadingAnchor, constant: 15),
            deepBlueBox.bottomAnchor.constraint(equalTo: redBox.bottomAnchor, constant: -10),
            deepBlueBox.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        bottomButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
    }
    
    // --- 헬퍼 함수 ---
    private func createView(color: UIColor, text: String) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    private func createButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        return button
    }
    
    @objc private func captureButtonTapped() {
        screenCaptureManager.captureViewControllerWithBounds(self) { success in
            print("Screen capture completed: \(success)")
        }
    }
}
