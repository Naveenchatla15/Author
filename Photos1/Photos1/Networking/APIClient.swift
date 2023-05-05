//
//  APIClient.swift
//  PrefetchExample
//
//  Created by Karim Ebrahem on 4/3/20.
//  Copyright © 2020 Karim Ebrahem. All rights reserved.
//

import Foundation
import Alamofire

class APIClient {
    
    static func fetchImages2(atPage page: Int, completion: @escaping (Array<PhotosResponseModel>?, AFError?) -> Void) {
        AF.request(Router.images(page)).responseDecodable { (response: AFDataResponse<[PhotosResponseModel]>) in
            
            switch response.result {
            case .success(let value):
                completion(value, nil)
                print(value)
            case .failure(let error):
                completion(nil, error)
                print(error)
            }
        }
        
        
        
    }
}
