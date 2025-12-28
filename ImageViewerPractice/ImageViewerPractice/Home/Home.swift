//
//  Home.swift
//  ImageViewerPractice
//
//  Created by 박세웅 on 12/26/25.
//

import SwiftUI
import ImageViewerRemote

struct Home: View {
  
  @StateObject var homeData = HomeViewModel()
  
  init() {
    UIScrollView.appearance().bounces = false
  }
  
  var body: some View {
    ZStack {
      Color.white.edgesIgnoringSafeArea(.all)
      
      ScrollView {
        
        HStack(alignment: .top, spacing: 15) {
          Image("profile1")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 60, height: 60)
            .clipShape(Circle())
          
          VStack(alignment: .leading, spacing: 10) {
            (
              Text("Se Woong Park  ")
                .foregroundColor(.black)
                .fontWeight(.bold)
              +
              Text("@ios")
                .foregroundColor(.gray)
            )
            Text("#ios #swiftui")
              .foregroundStyle(.blue)
            
            Text("iJustine New Photos :))))")
              .foregroundColor(.black)

            // Our Custom Grid of Items
            
            // We have only TWO columns in a row
            // and max is FOUR grid boxes...
            let columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 2)
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
              ForEach(homeData.allImages.indices, id: \.self) { index in
                GridImageView(index: index)
              }
            }
            .padding(.top)
          }
          
          
          
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        
      }
    }
//    .overlay {
//      // Image Viewer
//      if homeData.showImageViewer {
//        Color.black
//          .opacity(homeData.backgroundOpacity)
//          .ignoresSafeArea()
//        ImageView()
//      }
//      
//    }
    .overlay {
      
      ImageViewerRemote(imageURL: $homeData.selectedImageId, viewerShown: $homeData.showImageViewer)

      
      
//      .overlay(ImageViewer(image: self.$image, viewerShown: self.$showImageViewer))
    }
    
    
    
    .environmentObject(homeData)
  }
}
