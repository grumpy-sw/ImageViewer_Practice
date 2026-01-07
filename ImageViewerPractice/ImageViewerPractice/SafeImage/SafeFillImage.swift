//
//  SafeFillImage.swift
//  Kozipsa
//
//  Created by 박세웅 on 7/8/25.
//

import SwiftUI
import NukeUI

struct SafeFillImage: View {
  let url: String?
  
  var body: some View {
    if let url = url {
      LazyImage(url: URL(string: url)) { state in
        if let image = state.image {
          image
            .resizable()
            .scaledToFill()
        }
      }
    }
  }
}
