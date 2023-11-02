//
//  ImageCellView.swift
//  UnsplashPetProject
//
//  Created by Sergey on 31.10.2023.
//

import SwiftUI
import Combine

struct ImageCellView: View {
  
  @State var image: UIImage?
  
  
  private var imageUrlString: String
  private var networkService: NetworkService
  @State private var cancellables = Set<AnyCancellable>()
  
  init(imageUrlString: String, networkService: NetworkService) {
    self.imageUrlString = imageUrlString
    self.networkService = networkService
  }
  
  var body: some View {
    if let image = image {
      Image(uiImage: image)
        .resizable()
        .scaledToFill()
        .cornerRadius(12)
    } else {
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.gray)
        .opacity(0.5)
        .overlay {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
        }
        .onAppear {
          loadImage()
        }
    }
  }
  
  func loadImage() {
    if let cachedImage = ImageCache.shared.getImage(for: imageUrlString) {
      image = cachedImage
    } else {
      networkService.loadImage(urlString: imageUrlString)
        .flatMap { imageData -> AnyPublisher<UIImage, Never> in
          guard let loadedImage = UIImage(data: imageData) else {
            return Empty(completeImmediately: false).eraseToAnyPublisher()
          }
          
          ImageCache.shared.setImage(loadedImage, for: self.imageUrlString)
          
          return Just(loadedImage)
            .eraseToAnyPublisher()
        }
        .receive(on: DispatchQueue.main)
        .sink(
          receiveCompletion: { error in
            print("\(error)")
          },
          receiveValue: { loadedImage in
            self.image = loadedImage
          }
        )
        .store(in: &cancellables)
    }
  }
  
}

//#Preview {
//    ImageCellView()
//}
