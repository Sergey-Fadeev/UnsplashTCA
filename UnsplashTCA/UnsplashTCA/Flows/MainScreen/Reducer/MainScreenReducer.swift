//
//  MainScreenReducer.swift
//  UnsplashTCA
//
//  Created by Sergey on 02.11.2023.
//

import Foundation
import ComposableArchitecture

struct MainScreenReducer: Reducer {
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
