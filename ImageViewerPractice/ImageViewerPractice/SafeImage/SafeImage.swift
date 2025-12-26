//
//  SafeImage.swift
//  ImageViewerPractice
//
//  Created by 박세웅 on 12/26/25.
//

import SwiftUI
import NukeUI

struct SafeImage: View {
  let url: String?
  
  var body: some View {
    if let url = url {
      LazyImage(url: URL(string: url)) { state in
        if let image = state.image {
          image
            .resizable()
//            .scaledToFit()
        }
      }
    }
  }
}
