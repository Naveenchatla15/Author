//
//  PhotosResponseModel.swift
//  Photos1
//
//  Created by Mac on 05/05/23.
//

import Foundation


// MARK: - PhotosResponseModelElement
struct PhotosResponseModel: Codable {
    let id, author: String?
    let width, height: Int?
    let url, downloadURL: String?
    var isChecked : Bool?

    enum CodingKeys: String, CodingKey {
        case id, author, width, height, url, isChecked
        case downloadURL = "download_url"
    }
}


