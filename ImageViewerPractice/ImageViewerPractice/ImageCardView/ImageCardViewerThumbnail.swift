//
//  ImageCardViewerThumbnail.swift
//  Kozipsa
//
//  Created by 박세웅 on 11/3/25.
//

import SwiftUI

struct ImageCardViewerThumbnail: View {
  
  var imageURL: String?
  var onTapped: (() -> Void)?
  let width: CGFloat
  let height: CGFloat
  let trailingPadding: CGFloat
  let bottomPadding: CGFloat
  
  var body: some View {
    Button {
      onTapped?()
    } label: {
      ZStack(alignment: .bottomTrailing) {
        GeometryReader { proxy in
          RoundedRectangle(cornerRadius: 6)
            .foregroundStyle(.clear)
            .frame(width: width, height: height)
            .overlay {
              if let imageURL {
                SafeFillImage(url: imageURL)
                  .frame(width: width, height: height)
              } else {
                Image("ic_album_large")
                  .resizable()
                  .frame(width: width / 2, height: height / 2)
              }
            }
            .clipShape(RoundedRectangle(cornerRadius: 6))
          
        }
        if imageURL != nil {
          Image("ic-magnification")
            .assetIconImage(width: 14.5, height: 14.5)
            .padding(.bottom, bottomPadding)
            .padding(.trailing, trailingPadding)
        }
      }
      .frame(width: width, height: height)

    }
    .disabled(imageURL == nil)
  }
}
