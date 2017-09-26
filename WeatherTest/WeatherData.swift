//
//  WeatherData.swift
//  WeatherTest
//
//  Created by Игорь Лисицкий on 26.09.17.
//  Copyright © 2017 Igor Lisitzki. All rights reserved.
//

import Foundation
import RealmSwift
class WeatherData : Object {
    @objc dynamic var currentTemp = ""
    @objc dynamic var weatherDescription = ""
    @objc dynamic var city = ""
}
