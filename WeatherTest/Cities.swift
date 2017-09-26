//
//  Cities.swift
//  WeatherTest
//
//  Created by Игорь Лисицкий on 26.09.17.
//  Copyright © 2017 Igor Lisitzki. All rights reserved.
//

import Foundation

class City {
    var name: String?
    var code: String?
    var description: String?
    
    required init?(json: [String: Any]) {
        guard let name = json["city"] as? String,
            let code = json["code"] as? String,
            let description = json["description"] as? String else {return nil}
        
        self.name = name
        self.code = code
        self.description = description
}

}
