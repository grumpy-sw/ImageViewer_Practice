//
//  ImageView.swift
//  ImageViewerPractice
//
//  Created by 박세웅 on 12/26/25.
//

import SwiftUI

struct ImageView: View {

  @EnvironmentObject var homeData: HomeViewModel
  @GestureState var draggingOffset: CGSize = .zero
  @GestureState var panOffset: CGSize = .zero
  @GestureState var magnifying: Bool = false

  var body: some View {
    
    ZStack {
      // Tab View has a problem in ignoring edges..
      ScrollView(.init()) {
        TabView(selection: $homeData.selectedImageId) {
          ForEach(homeData.allImages, id: \.self) { image in
            let isSelected = homeData.selectedImageId == image
            let isZoomed = homeData.imageScale > 1.2

            SafeImage(url: image)
              .aspectRatio(contentMode: .fit)
              .tag(image)
              .scaleEffect(isSelected ? homeData.imageScale : 1)
              // Always apply pan offset, but only when selected
              .offset(
                x: isSelected ? homeData.imageOffset.width + panOffset.width : 0,
                y: isSelected ? homeData.imageOffset.height + panOffset.height : 0
              )
              // Always apply gesture, but only respond when zoomed
              .simultaneousGesture(
                DragGesture(minimumDistance: isZoomed && isSelected ? 0 : .infinity)
                  .updating($panOffset) { value, state, _ in
                    if isZoomed && isSelected {
                      state = value.translation
                    }
                  }
                  .onEnded { value in
                    if isZoomed && isSelected {
                      homeData.onPanEnd(value: value)
                    }
                  },
                including: isZoomed && isSelected ? .all : .subviews
              )
              .simultaneousGesture(
                TapGesture(count: 2)
                  .onEnded { _ in
                    withAnimation {
                      if homeData.imageScale > 1 {
                        homeData.imageScale = 1
                        homeData.imageOffset = .zero
                      } else {
                        homeData.imageScale = 4
                      }
                    }
                  }
              )
              .gesture(
                MagnificationGesture()
                  .updating($magnifying) { _, state, _ in
                    if !state {
                      homeData.onMagnificationStart()
                    }
                    state = true
                  }
                  .onChanged { value in
                    print("[SWTEST] value: \(value)")
                    homeData.onMagnificationChange(value: value)
                  }
                  .onEnded { value in
                    homeData.onMagnificationEnd(value: value)
                  }
              )
          }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        // Apply dismiss offset to entire TabView
        .offset(y: homeData.imageViewerOffset.height)
        .onChange(of: homeData.selectedImageId) { id in
          homeData.resetImageState()
        }
        .overlay (
          Button(action: {
            withAnimation(.default) {
              homeData.showImageViewer.toggle()
            }
          }, label: {
            Image(systemName: "xmark")
              .foregroundStyle(.white)
              .padding()
              .background(.white.opacity(0.35))
              .clipShape(Circle())
          })
          .padding(10)
          .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
          .opacity(homeData.backgroundOpacity)
          
          , alignment: .topTrailing
        )
      }
      .ignoresSafeArea()
    }
    .gesture(
      DragGesture()
        .updating($draggingOffset) { value, state, _ in
          // Only allow dismiss gesture when not zoomed
          if homeData.imageScale <= 1 {
            state = value.translation
            homeData.onChange(value: state)
          }
        }
        .onEnded { value in
          // Only dismiss when not zoomed
          if homeData.imageScale <= 1 {
            homeData.onEnd(value: value)
          }
        }
    )
    .transition(.move(edge: .bottom))

  }
}
