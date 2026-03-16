//
//  Constants.swift
//  WeatherTest
//
//  Created by Maxim Pakhotin on 14.03.2026.
//

import Foundation
enum Constants {
    static let apiKey = "fa8b3df74d4042b9aa7135114252304"
    static let baseURL = "https://api.weatherapi.com/v1"
    static let forecastURL = "\(baseURL)/forecast.json?key=\(apiKey)&q=%f,%f&days=3"
}
