//
//  FiveHundredPx.swift
//  Concentration
//
//  Created by Shaun Rowe on 10/08/2017.
//  Copyright © 2017 Shaun Rowe. All rights reserved.
//

import Foundation
import Moya

enum FiveHundredPx {
    case search(term: String)
}

private var consumerKey: String {
    if let fileUrl = Bundle.main.url(forResource: "FiveHundredPx", withExtension: "plist"),
        let data = try? Data(contentsOf: fileUrl) {
            if let result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] {
                return result?["Key"] as! String
            }
    }
    
    return ""
}

extension FiveHundredPx: TargetType {
    var baseURL: URL { return URL(string: "https://api.500px.com/v1")! }
    var path: String {
        switch self {
        case .search:
            return "/photos/search"
        }
    }
    var method: Moya.Method {
        switch self {
        case .search:
            return .get
        }
    }
    var parameters: [String: Any]? {
        switch self {
        case .search(let term):
            return ["term": term, "consumer_key": consumerKey]
        }
    }
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .search:
            return URLEncoding.default
        }
    }
    var task: Task {
        switch self {
        case .search:
            return .request
        }
    }
    var sampleData: Data {
        return Data()
    }
}
