//
//  Column.swift
//  UnsplashTCA
//
//  Created by Sergey on 02.11.2023.
//

import Foundation

struct Column: Identifiable, Equatable {
  let id = UUID()
  var gridItems = [GridItem]()
}
