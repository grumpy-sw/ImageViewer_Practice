//
//  SafeAspectImage.swift
//  Kozipsa
//
//  Created by 박세웅 on 11/25/25.
//

import SwiftUI
import NukeUI

struct SafeAspectImage: View {
  let url: String?
  let width: CGFloat?
  let height: CGFloat?
  
  init(url: String?, width: CGFloat? = nil, height: CGFloat? = nil) {
    self.url = url
    self.width = width
    self.height = height
  }
  
  var body: some View {
    if let url = url {
      LazyImage(url: URL(string: url)) { state in
        if let image = state.image {
          image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: height)
        }
      }
    }
  }
}


#Preview {
  
  SafeAspectImage(url: "https://cdn.pixabay.com/photo/2016/09/08/18/45/cube-1655118_640.jpg", width: 200)
}

#Preview {
  SafeAspectImage(url: "https://cdn.pixabay.com/photo/2016/09/08/18/45/cube-1655118_640.jpg", height: 150)
}
