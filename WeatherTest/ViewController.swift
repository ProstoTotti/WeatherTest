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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
        activityIndicator.hidesWhenStopped = true
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
    
    
    func getCitiesToTable() {
            let path = Bundle.main.url(forResource: "cities", withExtension: "json")!
            let data = try! Data(contentsOf: path)
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            let jsonArray = json as! [[String: Any]]
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
        activityIndicator.startAnimating()
        let currentCity = cities[indexPath.row].name!
        newApi.currentWeatherByCity(name: currentCity) { (result) in
            if let result = result {
                let weather = Weather(data: result)
                try! self.realm.write {
                    if let weatherCity = self.realm.objects(WeatherData.self).filter("city = '\(currentCity)'").first {
                        weatherCity.setValue("\(weather.temperature)", forKey: "currentTemp")
                        weatherCity.setValue("\(weather.condition)", forKey: "weatherDescription")
                    } else {
                        let weatherCity = WeatherData()
                        weatherCity.city = currentCity
                        weatherCity.currentTemp = String(weather.temperature)
                        weatherCity.weatherDescription = weather.condition
                        self.realm.add(weatherCity)
                    }
                }
            }
            self.activityIndicator.stopAnimating()
            let data = self.realm.objects(WeatherData.self).filter("city = '\(currentCity)'")
            if let temp = data.first?.currentTemp {
                self.tempLabel.text = temp + "°"
                self.weatherLabel.text = data.first?.weatherDescription
                self.cityLabel.text = data.first?.city
                self.descriptionCityLabel.text = self.cities[indexPath.row].description
            } else {
                let alert = UIAlertController(title: "Error", message: "Maybe WeatherAPI is down or you don't have an internet connection.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}

