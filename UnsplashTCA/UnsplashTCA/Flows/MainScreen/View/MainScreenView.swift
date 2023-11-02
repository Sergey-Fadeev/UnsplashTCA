//
//  ContentView.swift
//  UnsplashTCA
//
//  Created by Sergey on 02.11.2023.
//

import SwiftUI
import ComposableArchitecture

struct MainScreenView: View {
  
  let store: StoreOf<MainScreenReducer>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      NavigationView {
        VStack {
          Text("Unsplash")
            .font(.system(size: 36))
            .bold()
          
          Spacer()
          
          ScrollView(.vertical, showsIndicators: false) {
            HStack(alignment: .top, spacing: Constants.imageSpacing) {
              ForEach(viewStore.columns) { column in
                LazyVStack(spacing: Constants.imageSpacing) {
                  ForEach (column.gridItems) { gridItem in
                    NavigationLink(destination: ImageDetailView(
                      viewModel: ImageDetailViewModel(
                        networkService: NetworkService.shared,
                        gridItem: gridItem,
                        isAuthorsImageDetail: false
                      )
                    )) {
                      let cellWidth = (UIScreen.main.bounds.width - Constants.imageSpacing * 3) / 2.0
                      
                      ImageCellView(imageUrlString: gridItem.imageInfo.imageUrls.small, networkService: NetworkService.shared)
                        .frame(width: cellWidth, height: cellWidth * gridItem.ratio, alignment: .center)
                    }
                  }
                  
                  GeometryReader { geometry in
                    Color.clear.preference(key: ViewOffsetKey.self, value: geometry.frame(in: .named("scrollView")).minY)
                  }
                  .frame(height: 0)
                }
              }
            }
            .padding(.horizontal, Constants.imageHorizontalPadding)
          }
          .onAppear {
            viewStore.send(.getImages)
          }
          .coordinateSpace(name: "scrollView")
          .onPreferenceChange(ViewOffsetKey.self) { minY in
            if minY > -150 {
              viewStore.send(.getImages)
            }
          }
        }
      }
    }
  }
  
}

struct ViewOffsetKey: PreferenceKey {
  typealias Value = CGFloat
  static var defaultValue = CGFloat.zero
  static func reduce(value: inout Value, nextValue: () -> Value) {
    value += nextValue()
  }
}

//#Preview {
//  MainScreenView()
//}
