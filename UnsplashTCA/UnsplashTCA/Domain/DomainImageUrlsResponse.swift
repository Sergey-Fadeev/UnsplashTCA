//
//  DomainImageUrlsResponse.swift
//  UnsplashPetProject
//
//  Created by Sergey on 27.10.2023.
//

struct DomainImageUrlsResponse: Equatable {
  
  let raw, full, regular, small: String
  let thumb, smallS3: String
  
}
