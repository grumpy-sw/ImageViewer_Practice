//
//  HomeViewModel.swift
//  ImageViewerPractice
//
//  Created by 박세웅 on 12/26/25.
//

import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
   
  @Published var allImages: [String] = [
    "https://picsum.photos/id/24/200/300",
    "https://picsum.photos/id/25/200/300",
    "https://picsum.photos/id/26/200/300",
    "https://picsum.photos/id/27/200/300",
    "https://picsum.photos/id/28/200/300",
    "https://picsum.photos/id/29/200/300",
  ]
  
  @Published var showImageViewer: Bool = false
  @Published var selectedImageId: String = ""
  @Published var imageViewerOffset: CGSize = .zero
  
  @Published var backgroundOpacity: Double = 1.0
  
  @Published var imageScale: CGFloat = 1
  var baseScale: CGFloat = 1  // Scale at gesture start

  @Published var imageOffset: CGSize = .zero
  
  private let minZoomedScale = 1.2
  private let maxScale = 3.0
  
  func onChange(value: CGSize) {
    
    let halfHeight = UIScreen.main.bounds.height / 2
    let progress = value.height / halfHeight

    // Only update vertical offset for dismiss gesture


    DispatchQueue.main.async { [weak self] in
      self?.imageViewerOffset = CGSize(width: 0, height: value.height)
      self?.backgroundOpacity = Double(1 - (progress < 0 ? -progress : progress))
    }

  }
  
  func onEnd(value: DragGesture.Value) {
    withAnimation(.easeInOut(duration: 0.25)) {
      imageViewerOffset = .zero
      var translation = value.translation.height

      if translation < 0 {
        translation = -translation
      }

      if translation < 250 {
//        imageViewerOffset = .zero
        backgroundOpacity = 1
      } else {
        // close
        showImageViewer.toggle()
//        imageViewerOffset = .zero
        backgroundOpacity = 1
        // Reset image state when closing viewer
        resetImageState()
      }
    }
  }

  func onPanChange(value: CGSize) {
    imageOffset = value
  }

  func onPanEnd(value: DragGesture.Value, in viewSize: CGSize) {
    imageOffset.width += value.translation.width
    imageOffset.height += value.translation.height

    // Apply boundary constraints with animation
    withAnimation(.interpolatingSpring(stiffness: 300, damping: 30)) {
      boundOffset(in: viewSize)
    }
  }

  func boundOffset(in viewSize: CGSize) {
    // Calculate the scaled image size
    let scaledWidth = viewSize.width * imageScale
    let scaledHeight = viewSize.height * imageScale

    // Limit offset to keep image within bounds
    if scaledWidth > viewSize.width {
      let maxOffsetX = (scaledWidth - viewSize.width) / 2
      imageOffset.width = max(-maxOffsetX, min(maxOffsetX, imageOffset.width))
    } else {
      imageOffset.width = 0
    }

    if scaledHeight > viewSize.height {
      let maxOffsetY = (scaledHeight - viewSize.height) / 2
      imageOffset.height = max(-maxOffsetY, min(maxOffsetY, imageOffset.height))
    } else {
      imageOffset.height = 0
    }
  }

  func resetImageState() {
    imageScale = 1
    baseScale = 1
    imageOffset = .zero
    imageViewerOffset = .zero
  }

  func onMagnificationStart() {
    baseScale = imageScale
  }

  func onMagnificationChange(value: CGFloat) {
    imageScale = baseScale * value
  }

  func onMagnificationEnd(value: CGFloat) {
    let newScale = baseScale * value

    withAnimation {
      if newScale < minZoomedScale {
        imageScale = 1
        baseScale = 1
        imageOffset = .zero
      } else {
        let clampedScale = min(newScale, maxScale)
        imageScale = clampedScale
        baseScale = clampedScale
      }
    }
  }

  func toggleZoom(at location: CGPoint, in size: CGSize) {
    withAnimation {
      if imageScale > 1 {
        imageScale = 1
        imageOffset = .zero
      } else {
        let targetScale: CGFloat = maxScale
        let centerX = size.width / 2
        let centerY = size.height / 2
        let tapOffsetX = location.x - centerX
        let tapOffsetY = location.y - centerY

        imageOffset = CGSize(
          width: -tapOffsetX * targetScale,
          height: -tapOffsetY * targetScale
        )
        imageScale = targetScale

        // Apply boundary constraints
        boundOffset(in: size)
      }
    }
  }
}
