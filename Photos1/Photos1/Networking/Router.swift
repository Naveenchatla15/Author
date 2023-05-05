//
//  CatsRouter.swift
//  PrefetchExample
//
//  Created by Karim Ebrahem on 4/3/20.
//  Copyright © 2020 Karim Ebrahem. All rights reserved.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    
    static let baseURLString = "https://picsum.photos/v2/list?"
    
    case images(Int)
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .images:
            return .get
        }
    }
    
    
    var url: URL {
        switch self {
        case .images(let page):
            let url = try! Self.baseURLString.asURL()
            let queryItems = [
                URLQueryItem(name: "limit", value: "20"),
                URLQueryItem(name: "page", value: "\(page)")
            ]
            var urlComps = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            urlComps.queryItems = queryItems
            return urlComps.url!
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        return urlRequest
    }
}
