//
//  PageIndicator.swift
//  ImageViewerPractice
//
//  Created by 박세웅 on 1/7/26.
//

import SwiftUI

struct PageIndicator: View {
  let count: Int
  var currentIndex: Int
  
  var spacer: CGFloat = 8
  var selectedColor: Color = .grey1000
  var unselectedColor: Color = .grey400
  
  var body: some View {
    HStack(spacing: spacer) {
      ForEach(0..<count, id: \.self) { index in
        Circle()
          .fill(index == currentIndex ? selectedColor : unselectedColor)
          .frame(width: 8, height: 8)
          .animation(.easeInOut(duration: 0.2), value: currentIndex)
      }
    }
  }
}
