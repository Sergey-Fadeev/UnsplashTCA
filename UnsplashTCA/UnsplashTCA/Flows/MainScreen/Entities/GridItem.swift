//
//  GridItem.swift
//  UnsplashTCA
//
//  Created by Sergey on 02.11.2023.
//

import Foundation

struct GridItem: Identifiable, Equatable {
  let id = UUID()
  let ratio: Double
  let imageInfo: DomainImageResponse
//  let imageCellViewModel: ImageCellViewModel
}
