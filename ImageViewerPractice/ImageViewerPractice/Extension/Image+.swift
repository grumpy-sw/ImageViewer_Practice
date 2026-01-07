//
//  Image+.swift
//  ImageViewerPractice
//
//  Created by 박세웅 on 1/7/26.
//

import SwiftUI

extension Image {
  func assetIconImage(width: CGFloat, height: CGFloat) -> some View {
    self.resizable()
      .scaledToFit()
      .frame(width: width, height: height)
  }
  
  func assetIconImage(width: CGFloat, height: CGFloat, color: Color) -> some View {
    self.renderingMode(.template)
      .resizable()
      .scaledToFit()
      .frame(width: width, height: height)
      .foregroundStyle(color)
  }
}
