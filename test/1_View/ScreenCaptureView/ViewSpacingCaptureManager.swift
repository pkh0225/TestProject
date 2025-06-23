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
            
            // 측정값 그리기 (빨간색)
            cgContext.setStrokeColor(UIColor.red.cgColor)
            cgContext.setLineWidth(1.0)
            cgContext.setLineDash(phase: 0, lengths: [5, 3]) // 점선
            
            // 인셋과 간격 측정 및 표시
            drawMeasurements(viewInfos: viewInfos, rootView: rootView, in: cgContext)
        }
    }
    
    // MARK: - 뷰 정보 수집 (보이는 뷰만)
    private func collectViewInfos(rootView: UIView) -> [ViewInfo] {
        var allViewInfos: [ViewInfo] = []
        // 1. 먼저 모든 뷰의 정보를 재귀적으로 수집합니다 (hidden, alpha 제외).
        collectAllViewInfosRecursively(view: rootView, rootView: rootView, viewInfos: &allViewInfos)
        
        // 2. 다른 뷰에 의해 완전히 가려지는 뷰를 필터링합니다.
        let visibleViewInfos = allViewInfos.filter { viewInfo in
            let view = viewInfo.view
            
            // 최상위 뷰(rootView)는 항상 보인다고 가정합니다.
            if view === rootView {
                return true
            }

            // UITableViewCell이나 UICollectionViewCell의 자손 뷰는 항상 포함시킵니다.
            // 셀이 화면에 보이면 그 내용물도 측정 대상에 포함하기 위함입니다.
            if isViewInsideCell(view) {
                return true
            }

            // 그 외의 뷰들은 hitTest로 보이는지 확인합니다.
            if viewInfo.frame.isEmpty {
                return false
            }
            let centerPoint = CGPoint(x: viewInfo.frame.midX, y: viewInfo.frame.midY)
            
            // hitTest를 사용하여 해당 지점의 최상단 뷰를 찾습니다.
            guard let topView = rootView.hitTest(centerPoint, with: nil) else {
                // 뷰의 중심이 화면 밖에 있으면 보이지 않는 것으로 간주합니다.
                return false
            }
            
            // 최상단 뷰가 자기 자신이거나 자신의 자식 뷰이면 보이는 것입니다.
            // 즉, 뷰의 중심부를 다른 뷰가 가리지 않았다는 의미입니다.
            return topView === view || topView.isDescendant(of: view)
        }
        
        return visibleViewInfos
    }

    private func collectAllViewInfosRecursively(view: UIView, rootView: UIView, viewInfos: inout [ViewInfo]) {
        // 히든 상태이거나 투명한 뷰는 수집하지 않습니다.
        if view.isHidden || view.alpha == 0 {
            return
        }
        
        let frameInRootView = view.convert(view.bounds, to: rootView)
        let viewInfo = ViewInfo(
            view: view,
            frame: frameInRootView,
            originalFrame: view.frame
        )
        viewInfos.append(viewInfo)

        for subview in view.subviews {
            collectAllViewInfosRecursively(view: subview, rootView: rootView, viewInfos: &viewInfos)
        }
    }
    
    // MARK: - 뷰 타입별 색상으로 경계 및 크기 그리기
    private func drawViewBoundsByType(viewInfos: [ViewInfo], in context: CGContext) {
        for viewInfo in viewInfos {
            let view = viewInfo.view
            let frame = viewInfo.frame
            
            // 내용이 없는 라벨과 버튼은 그리기 대상에서 제외
            if let label = view as? UILabel, (label.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) {
                continue
            }
            if let button = view as? UIButton {
                let hasTitle = !(button.currentTitle?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
                let hasImage = button.currentImage != nil
                if !hasTitle && !hasImage {
                    continue
                }
            }

            let color = getColorForViewType(view)

            // 1. 모든 뷰의 경계선 그리기
            context.saveGState()
            
            let isThickerLineView: Bool
            if type(of: view) == UIView.self {
                isThickerLineView = true
            } else {
                isThickerLineView = view is UITableViewCell ||
                                    view is UICollectionViewCell ||
                                    view is WKWebView ||
                                    view is UITextField ||
                                    view is UIScrollView ||
                                    view is UIStackView ||
                                    view is UITextView
            }
            let lineWidth = isThickerLineView ? 1.5 : 1.0
            
            context.setLineWidth(lineWidth)
            context.setLineDash(phase: 0, lengths: []) // 실선
            context.setStrokeColor(color.cgColor)
            context.stroke(frame)
            context.restoreGState()

            // 2. 특정 타입의 뷰이며 내용이 있는 경우에만 크기 정보 표시
            let isExcludedFromSizeLabel = type(of: view) == UIView.self || view is UITableViewCell || view is UICollectionViewCell
            
            if !isExcludedFromSizeLabel && frame.width > 20 && frame.height > 10 {
                context.saveGState()
                
                // 2.1. 크기 표시를 위한 점선 그리기 (경계선 색상 사용)
                context.setStrokeColor(color.cgColor)
                context.setLineWidth(0.5)
                context.setLineDash(phase: 0, lengths: [2, 2]) // 짧은 점선

                // 수직선
                context.move(to: CGPoint(x: frame.midX, y: frame.minY))
                context.addLine(to: CGPoint(x: frame.midX, y: frame.maxY))
                context.strokePath()

                // 수평선
                context.move(to: CGPoint(x: frame.minX, y: frame.midY))
                context.addLine(to: CGPoint(x: frame.maxX, y: frame.midY))
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
        // 요청된 색상 변경
        case is UILabel:
            return UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0).withAlphaComponent(alpha) // 어두운 녹색
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
            
        // 기타 기존 색상
        case is UIScrollView:
            return .systemPurple.withAlphaComponent(alpha)
        case is UIStackView:
            return .systemOrange.withAlphaComponent(alpha)
        case is UITextView:
            if #available(iOS 15.0, *) {
                return .systemCyan.withAlphaComponent(alpha)
            } else {
                return .cyan.withAlphaComponent(alpha)
            }
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
        
        // UIView 및 기타 모든 뷰
        default:
            return UIColor(red: 0.9, green: 0.7, blue: 0.0, alpha: 1.0).withAlphaComponent(alpha)
        }
    }
    
    // MARK: - 계층적 측정값 그리기 (중복 및 겹침 방지 포함)
    private func drawMeasurements(viewInfos: [ViewInfo], rootView: UIView, in context: CGContext) {
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
            } else {
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
            } else {
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
            } else {
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
            } else {
                drawParentInset(from: parentFrame, to: childFrame, edge: .right, siblings: siblings, in: context)
            }
        }
    }

    // MARK: - 그리기 헬퍼
    private enum MeasurementEdge { case top, bottom, left, right }

    private func drawParentInset(from parentFrame: CGRect, to childFrame: CGRect, edge: MeasurementEdge, siblings: [ViewInfo], in context: CGContext) {
        switch edge {
        case .top:
            let inset = childFrame.minY - parentFrame.minY
            if inset > 0.5 {
                drawVerticalMeasurement(from: CGPoint(x: childFrame.midX, y: parentFrame.minY), to: CGPoint(x: childFrame.midX, y: childFrame.minY), value: Int(round(inset)), textPosition: CGPoint(x: childFrame.midX, y: (parentFrame.minY + childFrame.minY) / 2), in: context)
            }
        case .bottom:
            let inset = parentFrame.maxY - childFrame.maxY
            if inset > 0.5 {
                drawVerticalMeasurement(from: CGPoint(x: childFrame.midX, y: childFrame.maxY), to: CGPoint(x: childFrame.midX, y: parentFrame.maxY), value: Int(round(inset)), textPosition: CGPoint(x: childFrame.midX, y: (childFrame.maxY + parentFrame.maxY) / 2), in: context)
            }
        case .left:
            let inset = childFrame.minX - parentFrame.minX
            if inset > 0.5 {
                drawHorizontalMeasurement(from: CGPoint(x: parentFrame.minX, y: childFrame.midY), to: CGPoint(x: childFrame.minX, y: childFrame.midY), value: Int(round(inset)), textPosition: CGPoint(x: (parentFrame.minX + childFrame.minX) / 2, y: childFrame.midY), in: context)
            }
        case .right:
            let inset = parentFrame.maxX - childFrame.maxX
            if inset > 0.5 {
                drawHorizontalMeasurement(from: CGPoint(x: childFrame.maxX, y: childFrame.midY), to: CGPoint(x: parentFrame.maxX, y: childFrame.midY), value: Int(round(inset)), textPosition: CGPoint(x: (childFrame.maxX + parentFrame.maxX) / 2, y: childFrame.midY), in: context)
            }
        }
    }

    private func drawSiblingSpacing(from: CGRect, to: CGRect, edge: MeasurementEdge, in context: CGContext) {
        switch edge {
        case .top, .bottom:
            let spacing = to.minY - from.maxY
            if spacing > 0.5 {
                let lineX = (max(from.minX, to.minX) + min(from.maxX, to.maxX)) / 2
                drawVerticalMeasurement(from: CGPoint(x: lineX, y: from.maxY), to: CGPoint(x: lineX, y: to.minY), value: Int(round(spacing)), textPosition: CGPoint(x: lineX, y: (from.maxY + to.minY) / 2), in: context)
            }
        case .left, .right:
            let spacing = to.minX - from.maxX
            if spacing > 0.5 {
                let lineY = (max(from.minY, to.minY) + min(from.maxY, to.maxY)) / 2
                drawHorizontalMeasurement(from: CGPoint(x: from.maxX, y: lineY), to: CGPoint(x: to.minX, y: lineY), value: Int(round(spacing)), textPosition: CGPoint(x: (from.maxX + to.minX) / 2, y: lineY), in: context)
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
    private func drawVerticalMeasurement(from startPoint: CGPoint, to endPoint: CGPoint, value: Int, textPosition: CGPoint, in context: CGContext) {
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
        
        let lineLength = abs(endPoint.y - startPoint.y)
        drawMeasurementText("\(value)", at: textPosition, lineLength: lineLength, in: context)
    }
    
    // MARK: - 수평 측정선 그리기 (텍스트 위치 별도 지정)
    private func drawHorizontalMeasurement(from startPoint: CGPoint, to endPoint: CGPoint, value: Int, textPosition: CGPoint, in context: CGContext) {
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
        
        let lineLength = abs(endPoint.x - startPoint.x)
        drawMeasurementText("\(value)", at: textPosition, lineLength: lineLength, in: context)
    }
    
    // MARK: - 측정값 텍스트 그리기 (동적 폰트 크기 조절)
    private func drawMeasurementText(_ text: String, at point: CGPoint, lineLength: CGFloat, in context: CGContext) {
        let defaultFontSize: CGFloat = 5.0
        let reducedFontSize: CGFloat = 3.0
        let minFontSize: CGFloat = 2.0 // 더 작은 폰트 크기 추가
        let reduceThreshold: CGFloat = 12.0 // 이 길이보다 짧으면 폰트 크기를 줄임
        let minThreshold: CGFloat = 8.0 // 이 길이보다 짧으면 폰트를 더 줄임

        // 선의 길이에 따라 폰트 크기를 동적으로 결정
        var fontSize = defaultFontSize
        if lineLength < reduceThreshold {
            fontSize = reducedFontSize
        }
        if lineLength < minThreshold {
            fontSize = minFontSize
        }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .medium),
            .foregroundColor: UIColor.red,
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
        
        context.setFillColor(UIColor.white.withAlphaComponent(0.9).cgColor)
        context.fill(backgroundRect)
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(0.5)
        context.stroke(backgroundRect)
        
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
        let minFontSize: CGFloat = 2.0
        let reduceThreshold: CGFloat = 50.0
        let minThreshold: CGFloat = 30.0
        
        let smallestSide = min(viewFrame.width, viewFrame.height)
        var fontSize = defaultFontSize
        if smallestSide < reduceThreshold {
            fontSize = reducedFontSize
        }
        if smallestSide < minThreshold {
            fontSize = minFontSize
        }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .bold),
            .foregroundColor: color, // 뷰의 경계선 색상과 동일하게 설정
            .backgroundColor: UIColor.white.withAlphaComponent(0.8)
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.size()
        
        // 텍스트를 담을 배경 사각형
        let backgroundRect = CGRect(
            x: point.x - textSize.width / 2 - 2,
            y: point.y - textSize.height / 2 - 1,
            width: textSize.width + 4,
            height: textSize.height + 2
        )
        
        // 텍스트를 그리기 전에 현재 그래픽 상태를 저장합니다.
        context.saveGState()
        
        // 배경색 채우기
        context.setFillColor(UIColor.white.withAlphaComponent(0.8).cgColor)
        context.fill(backgroundRect)
        
        // 테두리 그리기
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(0.5)
        context.stroke(backgroundRect)

        // 텍스트 그리기
        let textRect = CGRect(
            x: point.x - textSize.width / 2,
            y: point.y - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        attributedString.draw(in: textRect)
        
        // 이전 그래픽 상태로 복원합니다.
        context.restoreGState()
    }
    
    // MARK: - 헬퍼 메서드들
    private func findParentViewInfo(for viewInfo: ViewInfo, in viewInfos: [ViewInfo]) -> ViewInfo? {
        guard let superview = viewInfo.view.superview else { return nil }
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
