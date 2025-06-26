//
//  ViewSpacingCaptureManager.swift
//
//  Created by 박길호(팀원) - 서비스개발담당App개발팀 on 6/20/25.
//  Copyright © 2025 emart. All rights reserved.
//

import UIKit
import WebKit

// MARK: - 뷰 간격 캡처 관리자
class ViewSpacingCaptureManager {
    func captureViewControllerWithBounds(_ viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        let targetView = viewController.view!

        // 뷰 캡처
        guard let screenshot = captureView(targetView) else {
            completion(false)
            return
        }

        // 뷰 경계와 측정값을 그린 이미지 생성
        let imageWithBounds = drawViewBoundsWithMeasurements(on: screenshot, rootView: targetView)

        // 결과 이미지를 바로 미리보기로 표시
        showImagePreview(imageWithBounds, from: viewController)
        completion(true)
    }

    // MARK: - 뷰 캡처 메서드
    private func captureView(_ view: UIView) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        return renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }

    // MARK: - 뷰 경계와 측정값 그리기 메서드
    private func drawViewBoundsWithMeasurements(on image: UIImage, rootView: UIView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)

        return renderer.image { context in
            // 원본 이미지 그리기
            image.draw(at: .zero)

            let cgContext = context.cgContext

            // 모든 뷰들의 정보 수집
            let viewInfos = collectViewInfos(rootView: rootView)

            // 뷰 타입별로 다른 색상으로 경계 및 크기 그리기
            drawViewBoundsByType(viewInfos: viewInfos, in: cgContext)

            // 인셋과 간격 측정 및 표시
            drawMeasurements(viewInfos: viewInfos, rootView: rootView, in: cgContext)
        }
    }

    // MARK: - 뷰 정보 수집 (보이는 뷰만)
    private func collectViewInfos(rootView: UIView) -> [ViewInfo] {
        var allViewInfos: [ViewInfo] = []
        // 모든 뷰의 정보를 재귀적으로 수집합니다
        collectAllViewInfosRecursively(view: rootView, rootView: rootView, viewInfos: &allViewInfos)

        return allViewInfos
    }


    private func collectAllViewInfosRecursively(view: UIView, rootView: UIView, viewInfos: inout [ViewInfo]) {
        // 히든 상태이거나 투명한 뷰는 수집하지 않습니다.
        if view.isHidden || view.alpha == 0 {
            return
        }
        // 뷰의 크기가 1x1 미만이면 무시합니다.
        if view.width < 1 || view.height < 1 {
            return
        }
        // 화면에서 벗어났는지 검사
        if !UIScreen.main.bounds.intersects(view.convert(view.bounds, to: nil)) {
            return
        }
        // 내용이 없는 라벨과 버튼은 수집하지 않습니다.
        if let label = view as? UILabel {
            if label.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
                return
            }
            if label.attributedText == nil {
                return
            }
        }
        if let button = view as? UIButton, let superView = button.superview?.superview {
            if button.title(for: .normal)?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true &&
                button.attributedTitle(for: .normal) == nil &&
                button.image(for: .normal) == nil &&
                button.backgroundImage(for: .normal) == nil {
                if let view = superView as? UITableViewCell, view.contentView.bounds == button.frame {
                    return
                }
                if let view = superView as? UITableViewHeaderFooterView, view.bounds == button.frame {
                    return
                }
                if let view = superView as? UICollectionReusableView, view.bounds == button.frame {
                    return
                }
                if let view = superView as? UICollectionViewCell, view.contentView.bounds == button.frame {
                    return
                }
            }
        }

        let frameInRootView = view.convert(view.bounds, to: rootView)
        let viewInfo = ViewInfo(
            view: view,
            frame: frameInRootView,
            originalFrame: view.frame
        )
        viewInfos.append(viewInfo)

        if !(view is UIButton) {
            for subview in view.subviews {
                collectAllViewInfosRecursively(view: subview, rootView: rootView, viewInfos: &viewInfos)
            }
        }
    }

    // MARK: - 뷰 타입별 색상으로 경계 및 크기 그리기
    private func drawViewBoundsByType(viewInfos: [ViewInfo], in context: CGContext) {
        for viewInfo in viewInfos {
            let view = viewInfo.view
            let frame = viewInfo.frame
            let color = getColorForViewType(view)

            // 1. 모든 뷰의 경계선 그리기
            context.saveGState()
            context.setLineWidth(0.5)
            context.setLineDash(phase: 0, lengths: [])
            context.setStrokeColor(color.cgColor)
            context.stroke(frame)
            context.restoreGState()

            // 2. 특정 타입의 뷰이거나, 자식 뷰가 없는 UIView인 경우 크기 정보 표시
            let isIncludedFromSizeLabel = view is UILabel || view is UIImageView || view is UIButton || view is WKWebView || view is UITextField || view is UITextView || view is UISwitch || view is UISlider || view is UISegmentedControl || view is UIStepper || view is UIProgressView || view is UIActivityIndicatorView || view is UINavigationBar || view is UITabBar || view is UIToolbar || view is UIDatePicker || view is UIPickerView

            // 순수 UIView 타입이면서 자식 뷰가 없는 경우를 확인하는 조건 추가
            let isLeafUIView = (type(of: view) == UIView.self && view.subviews.isEmpty)

            if isIncludedFromSizeLabel || isLeafUIView {
                context.saveGState()

                // 2.1. 크기 표시를 위한 X자 점선 그리기 (경계선 색상 사용)
                context.setStrokeColor(color.cgColor)
                context.setLineWidth(0.5)
                context.setLineDash(phase: 0, lengths: [1, 2]) // 점선으로 변경

                // 첫 번째 대각선 (좌상단 -> 우하단)
                context.move(to: CGPoint(x: frame.minX, y: frame.minY))
                context.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY))
                context.strokePath()

                // 두 번째 대각선 (좌하단 -> 우상단)
                context.move(to: CGPoint(x: frame.minX, y: frame.maxY))
                context.addLine(to: CGPoint(x: frame.maxX, y: frame.minY))
                context.strokePath()

                context.restoreGState()

                // 2.2. 크기 텍스트 그리기 (경계선 색상 사용)
                let sizeString = "\(Int(round(frame.width)))x\(Int(round(frame.height)))"
                let center = CGPoint(x: frame.midX, y: frame.midY)
                drawSizeLabel(text: sizeString, at: center, color: color, viewFrame: frame, in: context)
            }
        }
    }

    // MARK: - 뷰 타입별 색상 반환
    private func getColorForViewType(_ view: UIView) -> UIColor {
        let alpha: CGFloat = 0.7
        switch view {
        case is UILabel:
//            return UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0).withAlphaComponent(alpha) // 어두운 녹색
            return .green.withAlphaComponent(0.8)
        case is UIImageView:
            return .red.withAlphaComponent(alpha)
        case is UIButton:
            return .blue.withAlphaComponent(alpha)
        case is UITableViewCell, is UICollectionViewCell:
            return .purple.withAlphaComponent(alpha)
        case is WKWebView:
            return .red.withAlphaComponent(alpha)
        case is UITextField:
            return .darkGray.withAlphaComponent(alpha)
        case is UIScrollView:
            return .systemPurple.withAlphaComponent(alpha)
        case is UIStackView:
            return .systemOrange.withAlphaComponent(alpha)
        case is UITextView:
            return .cyan.withAlphaComponent(alpha)
        case is UISwitch:
            return .systemPink.withAlphaComponent(alpha)
        case is UISlider:
            return .systemYellow.withAlphaComponent(alpha)
        case is UISegmentedControl:
            return .systemIndigo.withAlphaComponent(alpha)
        case is UIStepper:
            return .systemBrown.withAlphaComponent(alpha)
        case is UIProgressView:
            return .systemGray.withAlphaComponent(alpha)
        case is UIActivityIndicatorView:
            return .systemGray2.withAlphaComponent(alpha)
        case is UINavigationBar:
            return .systemRed.withAlphaComponent(alpha)
        case is UITabBar:
            return .systemOrange.withAlphaComponent(alpha)
        case is UIToolbar:
            return .systemYellow.withAlphaComponent(alpha)
        case is UIDatePicker:
            return .systemBlue.withAlphaComponent(alpha)
        case is UIPickerView:
            return .systemGreen.withAlphaComponent(alpha)
        default:
            return UIColor(red: 299 / 255, green: 229 / 255, blue: 0.0, alpha: 1.0)
        }
    }

    // MARK: - 계층적 측정값 그리기 (중복 및 겹침 방지 포함)
    private func drawMeasurements(viewInfos: [ViewInfo], rootView: UIView, in context: CGContext) {
//        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(0.5)
        context.setLineDash(phase: 0, lengths: [4, 2]) // 점선

        var drawnVerticalSiblingPairs: Set<Set<ObjectIdentifier>> = []
        var drawnHorizontalSiblingPairs: Set<Set<ObjectIdentifier>> = []

        for currentViewInfo in viewInfos where currentViewInfo.view !== rootView {
            guard let parentInfo = findParentViewInfo(for: currentViewInfo, in: viewInfos) else { continue }

            let childFrame = currentViewInfo.frame
            let parentFrame = parentInfo.frame
            let siblings = viewInfos.filter { $0.view.superview === parentInfo.view && $0.view !== currentViewInfo.view }

            // 상단
            let potentialAbove = siblings.filter { $0.frame.maxY <= childFrame.minY && framesOverlapHorizontally(childFrame, $0.frame) }
            if let closestAbove = potentialAbove.max(by: { $0.frame.maxY < $1.frame.maxY }) {
                let pair: Set<ObjectIdentifier> = [ObjectIdentifier(currentViewInfo.view), ObjectIdentifier(closestAbove.view)]
                if !drawnVerticalSiblingPairs.contains(pair) {
                    drawSiblingSpacing(from: closestAbove.frame, to: childFrame, edge: .top, in: context)
                    drawnVerticalSiblingPairs.insert(pair)
                }
            }
            else {
                drawParentInset(from: parentFrame, to: childFrame, edge: .top, siblings: siblings, in: context)
            }

            // 하단
            let potentialBelow = siblings.filter { $0.frame.minY >= childFrame.maxY && framesOverlapHorizontally(childFrame, $0.frame) }
            if let closestBelow = potentialBelow.min(by: { $0.frame.minY < $1.frame.minY }) {
                let pair: Set<ObjectIdentifier> = [ObjectIdentifier(currentViewInfo.view), ObjectIdentifier(closestBelow.view)]
                if !drawnVerticalSiblingPairs.contains(pair) {
                    drawSiblingSpacing(from: childFrame, to: closestBelow.frame, edge: .bottom, in: context)
                    drawnVerticalSiblingPairs.insert(pair)
                }
            }
            else {
                drawParentInset(from: parentFrame, to: childFrame, edge: .bottom, siblings: siblings, in: context)
            }

            // 좌측
            let potentialLeft = siblings.filter { $0.frame.maxX <= childFrame.minX && framesOverlapVertically(childFrame, $0.frame) }
            if let closestLeft = potentialLeft.max(by: { $0.frame.maxX < $1.frame.maxX }) {
                let pair: Set<ObjectIdentifier> = [ObjectIdentifier(currentViewInfo.view), ObjectIdentifier(closestLeft.view)]
                if !drawnHorizontalSiblingPairs.contains(pair) {
                    drawSiblingSpacing(from: closestLeft.frame, to: childFrame, edge: .left, in: context)
                    drawnHorizontalSiblingPairs.insert(pair)
                }
            }
            else {
                drawParentInset(from: parentFrame, to: childFrame, edge: .left, siblings: siblings, in: context)
            }

            // 우측
            let potentialRight = siblings.filter { $0.frame.minX >= childFrame.maxX && framesOverlapVertically(childFrame, $0.frame) }
            if let closestRight = potentialRight.min(by: { $0.frame.minX < $1.frame.minX }) {
                let pair: Set<ObjectIdentifier> = [ObjectIdentifier(currentViewInfo.view), ObjectIdentifier(closestRight.view)]
                if !drawnHorizontalSiblingPairs.contains(pair) {
                    drawSiblingSpacing(from: childFrame, to: closestRight.frame, edge: .right, in: context)
                    drawnHorizontalSiblingPairs.insert(pair)
                }
            }
            else {
                drawParentInset(from: parentFrame, to: childFrame, edge: .right, siblings: siblings, in: context)
            }
        }
    }

    // MARK: - 그리기 헬퍼
    private enum MeasurementEdge { case top, bottom, left, right }

    private func drawParentInset(from parentFrame: CGRect, to childFrame: CGRect, edge: MeasurementEdge, siblings: [ViewInfo], in context: CGContext) {
        let color = UIColor.red
        switch edge {
        case .top:
            let inset = childFrame.minY - parentFrame.minY
            if inset > 0.5 {
                let lineX = childFrame.midX
                let startY = parentFrame.minY
                let endY = childFrame.minY

                let isObstructed = siblings.contains { siblingInfo -> Bool in
                    let siblingFrame = siblingInfo.frame
                    let measurementLine = CGRect(x: lineX - 0.5, y: startY, width: 1, height: endY - startY)
                    return measurementLine.intersects(siblingFrame)
                }
                guard !isObstructed else { return }

                drawVerticalMeasurement(from: CGPoint(x: lineX, y: startY), to: CGPoint(x: lineX, y: endY), value: Int(round(inset)), textPosition: CGPoint(x: lineX, y: (startY + endY) / 2), color: color, in: context)
            }
        case .bottom:
            let inset = parentFrame.maxY - childFrame.maxY
            if inset > 0.5 {
                let lineX = childFrame.midX
                let startY = childFrame.maxY
                let endY = parentFrame.maxY

                let isObstructed = siblings.contains { siblingInfo -> Bool in
                    let siblingFrame = siblingInfo.frame
                    let measurementLine = CGRect(x: lineX - 0.5, y: startY, width: 1, height: endY - startY)
                    return measurementLine.intersects(siblingFrame)
                }
                guard !isObstructed else { return }

                drawVerticalMeasurement(from: CGPoint(x: lineX, y: startY), to: CGPoint(x: lineX, y: endY), value: Int(round(inset)), textPosition: CGPoint(x: lineX, y: (startY + endY) / 2), color: color, in: context)
            }
        case .left:
            let inset = childFrame.minX - parentFrame.minX
            if inset > 0.5 {
                let lineY = childFrame.midY
                let startX = parentFrame.minX
                let endX = childFrame.minX

                let isObstructed = siblings.contains { siblingInfo -> Bool in
                    let siblingFrame = siblingInfo.frame
                    let measurementLine = CGRect(x: startX, y: lineY - 0.5, width: endX - startX, height: 1)
                    return measurementLine.intersects(siblingFrame)
                }
                guard !isObstructed else { return }

                drawHorizontalMeasurement(from: CGPoint(x: startX, y: lineY), to: CGPoint(x: endX, y: lineY), value: Int(round(inset)), textPosition: CGPoint(x: (startX + endX) / 2, y: lineY), color: color, in: context)
            }
        case .right:
            let inset = parentFrame.maxX - childFrame.maxX
            if inset > 0.5 {
                let lineY = childFrame.midY
                let startX = childFrame.maxX
                let endX = parentFrame.maxX

                let isObstructed = siblings.contains { siblingInfo -> Bool in
                    let siblingFrame = siblingInfo.frame
                    let measurementLine = CGRect(x: startX, y: lineY - 0.5, width: endX - startX, height: 1)
                    return measurementLine.intersects(siblingFrame)
                }
                guard !isObstructed else { return }

                drawHorizontalMeasurement(from: CGPoint(x: startX, y: lineY), to: CGPoint(x: endX, y: lineY), value: Int(round(inset)), textPosition: CGPoint(x: (startX + endX) / 2, y: lineY), color: color, in: context)
            }
        }
    }

    private func drawSiblingSpacing(from: CGRect, to: CGRect, edge: MeasurementEdge, in context: CGContext) {
        let color = UIColor.magenta
        switch edge {
        case .top, .bottom:
            let spacing = to.minY - from.maxY
            if spacing > 0.5 {
                let lineX = (max(from.minX, to.minX) + min(from.maxX, to.maxX)) / 2
                drawVerticalMeasurement(from: CGPoint(x: lineX, y: from.maxY), to: CGPoint(x: lineX, y: to.minY), value: Int(round(spacing)), textPosition: CGPoint(x: lineX, y: (from.maxY + to.minY) / 2), color: color, in: context)
            }
        case .left, .right:
            let spacing = to.minX - from.maxX
            if spacing > 0.5 {
                let lineY = (max(from.minY, to.minY) + min(from.maxY, to.maxY)) / 2
                drawHorizontalMeasurement(from: CGPoint(x: from.maxX, y: lineY), to: CGPoint(x: to.minX, y: lineY), value: Int(round(spacing)), textPosition: CGPoint(x: (from.maxX + to.minX) / 2, y: lineY), color: color, in: context)
            }
        }
    }

    // MARK: - 뷰 프레임 겹침 확인 헬퍼 메서드
    private func framesOverlapHorizontally(_ rect1: CGRect, _ rect2: CGRect) -> Bool {
        return max(rect1.minX, rect2.minX) < min(rect1.maxX, rect2.maxX)
    }

    private func framesOverlapVertically(_ rect1: CGRect, _ rect2: CGRect) -> Bool {
        return max(rect1.minY, rect2.minY) < min(rect1.maxY, rect2.maxY)
    }

    // MARK: - 수직 측정선 그리기 (텍스트 위치 별도 지정)
    private func drawVerticalMeasurement(from startPoint: CGPoint, to endPoint: CGPoint, value: Int, textPosition: CGPoint, color: UIColor, in context: CGContext) {
        context.saveGState()
        context.setStrokeColor(color.cgColor)

        context.move(to: startPoint)
        context.addLine(to: endPoint)
        context.strokePath()

        let tickLength: CGFloat = 5
        context.move(to: CGPoint(x: startPoint.x - tickLength, y: startPoint.y))
        context.addLine(to: CGPoint(x: startPoint.x + tickLength, y: startPoint.y))
        context.strokePath()

        context.move(to: CGPoint(x: endPoint.x - tickLength, y: endPoint.y))
        context.addLine(to: CGPoint(x: endPoint.x + tickLength, y: endPoint.y))
        context.strokePath()

        context.restoreGState()

        let lineLength = abs(endPoint.y - startPoint.y)
        drawMeasurementText("\(value)", at: textPosition, lineLength: lineLength, color: color, in: context)
    }

    // MARK: - 수평 측정선 그리기 (텍스트 위치 별도 지정)
    private func drawHorizontalMeasurement(from startPoint: CGPoint, to endPoint: CGPoint, value: Int, textPosition: CGPoint, color: UIColor, in context: CGContext) {
        context.saveGState()
        context.setStrokeColor(color.cgColor)

        context.move(to: startPoint)
        context.addLine(to: endPoint)
        context.strokePath()

        let tickLength: CGFloat = 5
        context.move(to: CGPoint(x: startPoint.x, y: startPoint.y - tickLength))
        context.addLine(to: CGPoint(x: startPoint.x, y: startPoint.y + tickLength))
        context.strokePath()

        context.move(to: CGPoint(x: endPoint.x, y: endPoint.y - tickLength))
        context.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y + tickLength))
        context.strokePath()

        context.restoreGState()

        let lineLength = abs(endPoint.x - startPoint.x)
        drawMeasurementText("\(value)", at: textPosition, lineLength: lineLength, color: color, in: context)
    }

    // MARK: - 측정값 텍스트 그리기 (동적 폰트 크기 조절)
    private func drawMeasurementText(_ text: String, at point: CGPoint, lineLength: CGFloat, color: UIColor, in context: CGContext) {
        let defaultFontSize: CGFloat = 5.0
        let reducedFontSize: CGFloat = 3.0
        let minFontSize: CGFloat = 3.0
        let reduceThreshold: CGFloat = 12.0
        let minThreshold: CGFloat = 8.0

        var fontWeight: UIFont.Weight = .medium
        var fontSize = defaultFontSize
        if lineLength < reduceThreshold {
            fontSize = reducedFontSize
            fontWeight = .regular
        }
        if lineLength < minThreshold {
            fontSize = minFontSize
            fontWeight = .light
        }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: fontWeight),
            .foregroundColor: color.withAlphaComponent(1.0),
            .backgroundColor: UIColor.white.withAlphaComponent(0.8)
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.size()

        // 수치 표시될 영역 박스 표시
//        let backgroundRect = CGRect(
//            x: point.x - textSize.width / 2 - 2,
//            y: point.y - textSize.height / 2 - 1,
//            width: textSize.width + 4,
//            height: textSize.height + 2
//        )

//        context.setFillColor(UIColor.white.withAlphaComponent(0.9).cgColor)
//        context.fill(backgroundRect)
//        context.setStrokeColor(color.cgColor)
//        context.setLineWidth(0.5)
//        context.stroke(backgroundRect)

        let textRect = CGRect(
            x: point.x - textSize.width / 2,
            y: point.y - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )

        attributedString.draw(in: textRect)
    }

    // MARK: - 뷰 크기 레이블 그리기 (동적 폰트 크기 조절)
    private func drawSizeLabel(text: String, at point: CGPoint, color: UIColor, viewFrame: CGRect, in context: CGContext) {
        let defaultFontSize: CGFloat = 6.0
        let reducedFontSize: CGFloat = 4.0
        let minFontSize: CGFloat = 3.0
        let reduceThreshold: CGFloat = 50.0
        let minThreshold: CGFloat = 30.0

        var fontWeight: UIFont.Weight = .bold
        let smallestSide = min(viewFrame.width, viewFrame.height)
        var fontSize = defaultFontSize
        if smallestSide < reduceThreshold {
            fontSize = reducedFontSize
            fontWeight = .regular
        }
        if smallestSide < minThreshold {
            fontSize = minFontSize
            fontWeight = .light
        }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: fontWeight),
            .foregroundColor: color.withAlphaComponent(1.0),
            .backgroundColor: UIColor.white.withAlphaComponent(0.8)
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.size()

        let backgroundRect = CGRect(
            x: point.x - textSize.width / 2 - 2,
            y: point.y - textSize.height / 2 - 1,
            width: textSize.width + 4,
            height: textSize.height + 2
        )

        context.saveGState()

        context.setFillColor(UIColor.white.withAlphaComponent(0.8).cgColor)
        context.fill(backgroundRect)

        context.setStrokeColor(color.cgColor)
        context.setLineWidth(0.5)
        context.stroke(backgroundRect)

        let textRect = CGRect(
            x: point.x - textSize.width / 2,
            y: point.y - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )

        attributedString.draw(in: textRect)

        context.restoreGState()
    }

    // MARK: - 헬퍼 메서드들
    private func findParentViewInfo(for viewInfo: ViewInfo, in viewInfos: [ViewInfo]) -> ViewInfo? {
        guard let superview = viewInfo.view.superview else {
            return nil
        }
        return viewInfos.first { $0.view === superview }
    }

    private func isViewInsideCell(_ view: UIView) -> Bool {
        var parent = view.superview
        while parent != nil {
            if parent is UITableViewCell || parent is UICollectionViewCell {
                return true
            }
            parent = parent?.superview
        }
        return false
    }

    // MARK: - 결과 표시
    private func showImagePreview(_ image: UIImage, from viewController: UIViewController) {
         let previewVC = ImagePreviewViewController()
         previewVC.image = image
         previewVC.modalPresentationStyle = .fullScreen
         viewController.present(previewVC, animated: true)
    }
}

// MARK: - 뷰 정보 구조체
struct ViewInfo {
    let view: UIView
    let frame: CGRect
    let originalFrame: CGRect
}
