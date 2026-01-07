//
//  UIDevice+.swift
//  ImageViewerPractice
//
//  Created by 박세웅 on 1/7/26.
//

import SwiftUI

extension UIDevice {
  static var hasHomeIndicator: Bool {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else { return false }
    
    return window.safeAreaInsets.bottom > 0
  }
}
