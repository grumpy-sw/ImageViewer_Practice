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
  @Published var selectedCard: ImageCard? = nil
  @Published var selectedImageIndex: Int = 0

  func createImageCard(startingAt index: Int) -> ImageCard {
    selectedImageIndex = index
    return ImageCard(images: allImages, description: nil)
  }
}
