//
//  UnsplashTCAApp.swift
//  UnsplashTCA
//
//  Created by Sergey on 02.11.2023.
//

import SwiftUI
import ComposableArchitecture

@main
struct UnsplashTCAApp: App {
  var body: some Scene {
    WindowGroup {
      MainScreenView(
        store: Store(
          initialState: MainScreenReducer.State()
        ) {
          MainScreenReducer()
        }
      )
    }
  }
}
