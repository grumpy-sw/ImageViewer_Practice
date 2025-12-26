//
//  GridImageView.swift
//  ImageViewerPractice
//
//  Created by 박세웅 on 12/26/25.
//

import SwiftUI

struct GridImageView: View {
  
  @EnvironmentObject var homeData: HomeViewModel
  var index: Int
  
  var body: some View {
    Button {
      withAnimation(.easeInOut) {
        homeData.selectedImageId = homeData.allImages[index]
        homeData.showImageViewer.toggle()
      }
    } label: {
      ZStack {
        
        if index <= 3 {
          SafeImage(url: homeData.allImages[index])
            .aspectRatio(contentMode: .fill)
            .frame(width: getWidth(index: index), height: 120)
            .cornerRadius(12)

        }
        
        if homeData.allImages.count > 4 && index == 3 {
          RoundedRectangle(cornerRadius: 12)
            .fill(Color.black.opacity(0.3))
          
          let remainingImages = homeData.allImages.count - 4
          Text("+\(remainingImages)")
            .font(.title)
            .fontWeight(.heavy)
            .foregroundStyle(.white)
        }
      }
    }
    
  }
  
  // expanding Image Size
  func getWidth(index: Int) -> CGFloat {
    
    let width = getRect().width - 100
    
    if homeData.allImages.count % 2 == 0 {
      return width / 2
    }
    else {
      if index == homeData.allImages.count - 1 {
        return width
      } else {
        return width / 2
      }
    }
  }
  
}

extension View {
  func getRect() -> CGRect {
    return UIScreen.main.bounds
  }
}
