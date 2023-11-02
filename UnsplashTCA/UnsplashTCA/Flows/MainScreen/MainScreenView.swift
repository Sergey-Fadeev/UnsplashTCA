//
//  ContentView.swift
//  UnsplashTCA
//
//  Created by Sergey on 02.11.2023.
//

import SwiftUI
import ComposableArchitecture

struct CounterFeature: Reducer {
  struct State: Equatable {
    var isLoadingImages = false
    var pageCount = 1
    
    var columns: [Column] = [Column(), Column()]
    var leftHeight: Double = 0
    var rightHeight: Double = 0
  }
  
  enum Action: Equatable {
    case getImages
    case imagesResponse([DomainImageResponse])
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .getImages:
        guard !state.isLoadingImages else {
          return .none
        }
        
        state.isLoadingImages = true
        
        return .run { [page = state.pageCount] send in
          let apiTarget = DefaulAPITarget.loadImages(
            LoadPageRequest(page: page, username: nil)
          )
          
          let url = URL(string: apiTarget.fullUrlString)!
          let (data, _) = try await URLSession.shared.data(from: url)
          
          do {
            let decoder = JSONDecoder()
            let imagesResponse = try decoder.decode([APIImageResponse].self, from: data).map { $0.asDomain }
            
            await send(.imagesResponse(imagesResponse))
            
          } catch {
            print("Ошибка при декодировании данных: \(error)")
          }
        }
        
      case let .imagesResponse(imagesArray):
        print("images.count - \(imagesArray.count)")
        
        state.pageCount += 1
        state.isLoadingImages = false
        
        let gridItems: [GridItem] = imagesArray.compactMap { response in
          let ratio = Double(response.height) / Double(response.width)
          
          return GridItem(
            ratio: ratio,
            imageInfo: response
          )
        }
        
        var columns: [Column] = [Column(), Column()]
        var columnsHeights = [state.leftHeight, state.rightHeight]
        
        for gridItem in gridItems {
          if columnsHeights[0] > columnsHeights[1] {
            columns[1].gridItems.append(gridItem)
            columnsHeights[1] += gridItem.ratio
          } else {
            columns[0].gridItems.append(gridItem)
            columnsHeights[0] += gridItem.ratio
          }
        }
        
        state.columns[0].gridItems += columns[0].gridItems
        state.columns[1].gridItems += columns[1].gridItems
        state.leftHeight = columnsHeights[0]
        state.rightHeight = columnsHeights[1]
        
        return .none
      }
    }
  }
}

struct MainScreenView: View {
  
  let store: StoreOf<CounterFeature>
  
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

struct GridItem: Identifiable, Equatable {
  let id = UUID()
  let ratio: Double
  let imageInfo: DomainImageResponse
//  let imageCellViewModel: ImageCellViewModel
}

struct Column: Identifiable, Equatable {
  let id = UUID()
  var gridItems = [GridItem]()
}

//#Preview {
//  MainScreenView()
//}
