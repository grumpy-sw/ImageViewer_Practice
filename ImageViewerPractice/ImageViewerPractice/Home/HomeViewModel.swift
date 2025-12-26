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
  
  // Background Opacity
  @Published var backgroundOpacity: Double = 1.0
  
  // Scaling
  @Published var imageScale: CGFloat = 1
  var baseScale: CGFloat = 1  // Scale at gesture start

  // Image pan offset when zoomed
  @Published var imageOffset: CGSize = .zero
  
  func onChange(value: CGSize) {
    DispatchQueue.main.async { [weak self] in
      self?.imageViewerOffset = value
    }
    // Change opacity
    let halgHeight = UIScreen.main.bounds.height / 2
    
    let progress = imageViewerOffset.height / halgHeight
    
    withAnimation(.default) {
      DispatchQueue.main.async { [weak self] in
        self?.backgroundOpacity = Double(1 - (progress < 0 ? -progress : progress))
      }
    }
  }
  
  func onEnd(value: DragGesture.Value) {
    withAnimation(.easeInOut(duration: 0.25)) {
      var translation = value.translation.height

      if translation < 0 {
        translation = -translation
      }

      if translation < 250 {
        imageViewerOffset = .zero
        backgroundOpacity = 1
      } else {
        showImageViewer.toggle()
        imageViewerOffset = .zero
        backgroundOpacity = 1
      }
    }
  }

  func onPanChange(value: CGSize) {
    imageOffset = value
  }

  func onPanEnd(value: DragGesture.Value) {
    // Accumulate the offset instead of replacing
    imageOffset.width += value.translation.width
    imageOffset.height += value.translation.height
  }

  func resetImageState() {
    imageScale = 1
    baseScale = 1
    imageOffset = .zero
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
      if newScale < 1.2 {
        imageScale = 1
        baseScale = 1
      } else {
        imageScale = min(newScale, 4.0)  // Max scale 4
        baseScale = imageScale
      }
    }
  }
}
