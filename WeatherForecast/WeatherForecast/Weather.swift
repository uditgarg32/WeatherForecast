//
//  Weather.swift
//  WeatherForecast
//
//  Created by Udit Garg on 5/31/21.
//

import Foundation
import UIKit

// Create model to decode JSON Data

// Daily is a dictionary containing the daily forecast data
struct ForecastData: Codable {
    
    let daily: [Daily]
}

struct Daily: Codable {
    
    let dt: TimeInterval
    let temp: Temp
    let weather: [Weather]
}
 
struct Temp: Codable {
    
    let min: Double
    let max: Double
}
 
struct Weather: Codable {
    
    let description: String
    let icon: String
}


