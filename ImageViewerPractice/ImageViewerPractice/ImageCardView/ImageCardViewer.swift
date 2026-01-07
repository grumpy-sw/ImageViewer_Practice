//
//  ImageCardViewer.swift
//  Kozipsa
//
//  Created by 박세웅 on 10/29/25.
//

import SwiftUI

struct ImageCard: Identifiable {
  var id: String = UUID().uuidString
  var images: [String]
  var description: String?
}

struct ImageCardViewer: View {
  @Binding var card: ImageCard?
  @Binding var isPresented: Bool
  var namespace: Namespace.ID
  var initialIndex: Int = 0
  var resetZoomOnPageChange: Bool = false

  @State private var index: Int = 0
  @State private var scrollProgress: CGFloat = 0.0
  
  var body: some View {
    ZStack(alignment: .bottom) {
      Color.black.opacity(0.8)
        .ignoresSafeArea()
      
      VStack(spacing: 0) {
        // Header
        HStack {
          Spacer()
          if let card, card.images.count > 1 {
            Text("\(index + 1)/\(card.images.count)")
              .foregroundColor(.white)
              .font(.system(size: 16, weight: .medium))
          }
          Spacer()
          Button {
            dismiss()
          } label: {
            Image("close")
              .assetIconImage(width: 24, height: 24, color: .white)
          }
        }
        .frame(height: 44)
        .padding(.horizontal, 26)
        
        Spacer()
        
        if let card {
          // Content
          if card.images.count > 1 {
            PagingTabView(
              currentIndex: $index,
              scrollProgress: $scrollProgress,
              pages: card.images.enumerated().map { index, url in
                imageViewContent(index, url)
              }
            )
          } else {
            imageViewContent(0, card.images.first)
          }
        }
      }
    }
    .onAppear {
      index = initialIndex
    }
  }
  
  private func dismiss() {
    DispatchQueue.main.async {
      isPresented = false
    }
    //    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
    //      isPresented = false
    //    }
  }
  
  @ViewBuilder
  private func imageViewContent(_ imageIndex: Int = 0, _ url: String?) -> some View {
    VStack(spacing: 17) {
      ZoomableImageView(
        url: url,
        imageIndex: imageIndex,
        namespace: namespace,
        currentPageIndex: $index,
        resetZoomOnPageChange: resetZoomOnPageChange
      )
    }
  }
}

// MARK: - ZoomableImageView
struct ZoomableImageView: View {
  let url: String?
  let imageIndex: Int
  let namespace: Namespace.ID
  @Binding var currentPageIndex: Int
  var resetZoomOnPageChange: Bool

  @State private var scale: CGFloat = 1.0
  @State private var offset: CGSize = .zero
  @State private var viewSize: CGSize = .zero

  private let minScale: CGFloat = 1.0 // 목표 최소 스케일 (원본 크기)
  private let allowedMinScale: CGFloat = 0.5 // 축소 허용 최소 스케일
  private let maxScale: CGFloat = 4.0

  var body: some View {
    GeometryReader { geometry in
      SafeImage(url: url)
        .matchedGeometryEffect(id: "image-\(imageIndex)", in: namespace)
        .frame(width: geometry.size.width, height: geometry.size.height)
        .scaleEffect(scale, anchor: .center)
        .offset(offset)
        .clipped()
        .overlay(
          GestureOverlay(
            scale: $scale,
            offset: $offset,
            viewSize: geometry.size,
            minScale: minScale,
            allowedMinScale: allowedMinScale,
            maxScale: maxScale
          )
        )
        .onAppear {
          viewSize = geometry.size
        }
        .onChange(of: currentPageIndex) { newValue in
          // 다른 페이지로 이동했을 때 현재 페이지의 줌 리셋
          if resetZoomOnPageChange && newValue != imageIndex {
            scale = minScale
            offset = .zero
          }
        }
    }
  }
}

// MARK: - GestureOverlay
struct GestureOverlay: UIViewRepresentable {
  @Binding var scale: CGFloat
  @Binding var offset: CGSize
  let viewSize: CGSize
  let minScale: CGFloat
  let allowedMinScale: CGFloat
  let maxScale: CGFloat

  func makeUIView(context: Context) -> UIView {
    let view = UIView()
    view.backgroundColor = .clear

    let pinchGesture = UIPinchGestureRecognizer(
      target: context.coordinator,
      action: #selector(Coordinator.handlePinch(_:))
    )
    let panGesture = UIPanGestureRecognizer(
      target: context.coordinator,
      action: #selector(Coordinator.handlePan(_:))
    )
    let tapGesture = UITapGestureRecognizer(
      target: context.coordinator,
      action: #selector(Coordinator.handleDoubleTap(_:))
    )
    tapGesture.numberOfTapsRequired = 2

    pinchGesture.delegate = context.coordinator
    panGesture.delegate = context.coordinator

    view.addGestureRecognizer(pinchGesture)
    view.addGestureRecognizer(panGesture)
    view.addGestureRecognizer(tapGesture)

    return view
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    context.coordinator.viewSize = viewSize
    context.coordinator.minScale = minScale
    context.coordinator.allowedMinScale = allowedMinScale
    context.coordinator.maxScale = maxScale
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(scale: $scale, offset: $offset, viewSize: viewSize, minScale: minScale, allowedMinScale: allowedMinScale, maxScale: maxScale)
  }

  class Coordinator: NSObject, UIGestureRecognizerDelegate {
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    var viewSize: CGSize
    var minScale: CGFloat
    var allowedMinScale: CGFloat
    var maxScale: CGFloat

    private var initialScale: CGFloat = 1.0
    private var initialOffset: CGSize = .zero
    private var pinchCenter: CGPoint = .zero

    init(scale: Binding<CGFloat>, offset: Binding<CGSize>, viewSize: CGSize, minScale: CGFloat, allowedMinScale: CGFloat, maxScale: CGFloat) {
      _scale = scale
      _offset = offset
      self.viewSize = viewSize
      self.minScale = minScale
      self.allowedMinScale = allowedMinScale
      self.maxScale = maxScale
    }

    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
      guard let view = gesture.view else { return }

      switch gesture.state {
      case .began:
        initialScale = scale
        initialOffset = offset
        pinchCenter = gesture.location(in: view)

      case .changed:
        // 축소는 allowedMinScale까지, 확대는 maxScale까지 허용
        let newScale = min(max(initialScale * gesture.scale, allowedMinScale), maxScale)

        // 1.0 미만으로 축소 시에는 offset을 0으로 유지 (중앙 기준 축소)
        if newScale < minScale {
          scale = newScale
          offset = .zero
        } else {
          // 1.0 이상일 때는 핀치 중심점을 기준으로 offset 계산
          let scaleDelta = newScale / scale
          let centerOffset = CGSize(
            width: pinchCenter.x - viewSize.width / 2,
            height: pinchCenter.y - viewSize.height / 2
          )

          let newOffset = CGSize(
            width: offset.width * scaleDelta - centerOffset.width * (scaleDelta - 1),
            height: offset.height * scaleDelta - centerOffset.height * (scaleDelta - 1)
          )

          scale = newScale
          offset = limitOffset(newOffset)

          // 줌이 원본 크기가 되면 offset 초기화
          if scale == minScale {
            offset = .zero
          }
        }

      case .ended, .cancelled:
        // 원본 크기보다 작으면 원본으로 복구
        if scale < minScale {
          withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            scale = minScale
            offset = .zero
          }
        }

      default:
        break
      }
    }

    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
      guard scale > minScale else { return }
      guard let view = gesture.view else { return }

      switch gesture.state {
      case .began:
        initialOffset = offset

      case .changed:
        let translation = gesture.translation(in: view)
        let newOffset = CGSize(
          width: initialOffset.width + translation.x,
          height: initialOffset.height + translation.y
        )
        offset = limitOffset(newOffset)

      default:
        break
      }
    }

    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
      if scale > minScale {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
          resetZoom()
        }
      }
    }

    private func limitOffset(_ offset: CGSize) -> CGSize {
      let maxOffsetX = (viewSize.width * (scale - 1)) / 2
      let maxOffsetY = (viewSize.height * (scale - 1)) / 2

      return CGSize(
        width: min(max(offset.width, -maxOffsetX), maxOffsetX),
        height: min(max(offset.height, -maxOffsetY), maxOffsetY)
      )
    }

    private func resetZoom() {
      scale = minScale
      offset = .zero
    }

    // 제스처 시작 조건 설정
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
      // Pan 제스처는 줌이 되어있을 때만 시작
      if let pan = gestureRecognizer as? UIPanGestureRecognizer {
        guard scale > minScale else { return false }

        let velocity = pan.velocity(in: pan.view)

        // 경계 계산
        let maxOffsetX = (viewSize.width * (scale - 1)) / 2
        let isAtLeftBoundary = offset.width >= maxOffsetX - 5
        let isAtRightBoundary = offset.width <= -maxOffsetX + 5

        // 왼쪽 경계에서 오른쪽으로 스와이프 (이전 페이지로)
        if isAtLeftBoundary && velocity.x > 0 {
          return false  // Pan 비활성화 → 페이징 허용
        }

        // 오른쪽 경계에서 왼쪽으로 스와이프 (다음 페이지로)
        if isAtRightBoundary && velocity.x < 0 {
          return false  // Pan 비활성화 → 페이징 허용
        }

        return true
      }
      return true
    }

    // 동시 제스처 설정
    func gestureRecognizer(
      _ gestureRecognizer: UIGestureRecognizer,
      shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
      // Pan이나 Pinch 제스처는 다른 제스처와 동시 인식 안 함 (줌 중/줌 상태일 때 스와이프 막기)
      if gestureRecognizer is UIPanGestureRecognizer || gestureRecognizer is UIPinchGestureRecognizer {
        return false
      }
      return true
    }
  }
}
