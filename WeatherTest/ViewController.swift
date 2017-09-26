//
//  ViewController.swift
//  WeatherTest
//
//  Created by Игорь Лисицкий on 26.09.17.
//  Copyright © 2017 Igor Lisitzki. All rights reserved.
//

import UIKit
import RealmSwift
import OpenWeatherSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var weatherStackView: UIStackView!
    @IBOutlet weak var startStackView: UIStackView!
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var descriptionCityLabel: UILabel!
    
    var newApi = OpenWeatherSwift(apiKey: "eba47effea88b18d5b67eae531209447", temperatureFormat: .Celsius)
    let realm = try! Realm()

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    var cities = [City]()
    var isTapped = false
    @IBOutlet weak var viewForText: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getCitiesToTable()
        startStackView.isHidden = false
        weatherStackView.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func animatedView(_ sender: UITapGestureRecognizer) {
        if !isTapped {
            UIView.animate(withDuration: 0.5, delay: 0, options: .allowAnimatedContent, animations: {
                let heightOfSuperview = self.view.bounds.height
                self.heightConstraint.constant = heightOfSuperview * 0.3
                self.isTapped = true
                self.viewForText.superview?.layoutIfNeeded()
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, options: .allowAnimatedContent, animations: {
                self.heightConstraint.constant = 0
                self.isTapped = false
                self.viewForText.superview?.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func getWeatherCity(city name: String){
        newApi.currentWeatherByCity(name: name) { (result) in
            let weather = Weather(data: result)
            try! self.realm.write {
                if let weatherCity = self.realm.objects(WeatherData.self).filter("city = '\(name)'").first {
                    weatherCity.setValue("\(weather.temperature)", forKey: "currentTemp")
                    weatherCity.setValue("\(weather.condition)", forKey: "weatherDescription")
                } else {
                    let weatherCity = WeatherData()
                    weatherCity.city = name
                    weatherCity.currentTemp = String(weather.temperature)
                    weatherCity.weatherDescription = weather.condition
                    self.realm.add(weatherCity)
                }
            }
        }
    }
    
    func getCitiesToTable() {
            let path = Bundle.main.url(forResource: "cities", withExtension: "json")!
            let data = try! Data(contentsOf: path)
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            guard  let jsonArray = json as? [[String: Any]] else {
                print("Didn't get array of gists object as JSON from API")
                return
            }
            self.cities = jsonArray.flatMap{ City(json: $0)}
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let city = cities[indexPath.row]
        cell.textLabel?.text = city.name
        cell.detailTextLabel?.text = city.code
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !startStackView.isHidden {
            startStackView.isHidden = true
            weatherStackView.isHidden = false
        }
        let currentCity = cities[indexPath.row].name!
        getWeatherCity(city: currentCity)
        let data = realm.objects(WeatherData.self).filter("city = '\(currentCity)'")
        tempLabel.text = "\(data.first!.currentTemp)°"
        weatherLabel.text = data.first?.weatherDescription
        cityLabel.text = data.first?.city
        descriptionCityLabel.text = cities[indexPath.row].description
        
    }
    
}

