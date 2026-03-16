//
//  WeatherTestModels.swift
//  WeatherTest
//
//  Created by Maxim Pakhotin on 13.03.2026.
//

import Foundation

// MARK: - Текущая погода (current.json)
struct WTResponse: Codable {
    let location: WTLocation
    let current: WTCurrent
}

// MARK: - Прогноз (forecast.json?days=3)
struct WTForecastResponse: Codable {
    let location: WTLocation
    let current: WTCurrent
    let forecast: WTForecast
}

// MARK: - Location (общая структура)
struct WTLocation: Codable {
    let name: String
    let region: String
    let country: String
    let localtime: String // Нам понадобится для определения текущего часа
}

// MARK: - Current (общая структура)
struct WTCurrent: Codable {
    let tempC: Double
    let condition: WTCondition
    let feelslikeC: Double
    let humidity: Int

    enum CodingKeys: String, CodingKey {
        case tempC = "temp_c"
        case condition
        case feelslikeC = "feelslike_c"
        case humidity
    }
}

// MARK: - Condition (общая структура)
struct WTCondition: Codable {
    let text: String
    let icon: String // Приходит в виде "//cdn.weatherapi.com/weather/64x64/day/116.png"

    // Метод для получения полного URL иконки
    func iconUrl() -> URL? {
        let baseUrl = "https:\(icon)"
        return URL(string: baseUrl)
    }
}

// MARK: - Forecast (обертка для прогноза)
struct WTForecast: Codable {
    let forecastday: [WTForecastDay]
}

// MARK: - ForecastDay (прогноз на один день)
struct WTForecastDay: Codable {
    let date: String
    let day: WTDay
    let hour: [WTHour] // 24 часа
}

// MARK: - Day (дневной прогноз)
struct WTDay: Codable {
    let maxtempC: Double
    let mintempC: Double
    let condition: WTCondition

    enum CodingKeys: String, CodingKey {
        case maxtempC = "maxtemp_c"
        case mintempC = "mintemp_c"
        case condition
    }
}

// MARK: - Hour (почасовой прогноз)
struct WTHour: Codable {
    let time: String // Формат: "2024-01-01 00:00"
    let tempC: Double
    let condition: WTCondition

    enum CodingKeys: String, CodingKey {
        case time
        case tempC = "temp_c"
        case condition
    }

    // Получаем час из строки времени (например "2024-01-01 14:00" -> "14:00")
    func hourString() -> String? {
        let components = time.split(separator: " ")
        guard components.count == 2 else { return nil }
        return String(components[1])
    }
}

struct WTHourDisplay {
    let time: String
    let tempDisplay: String
    let temp: Double
    let iconURL: URL?
}

struct WTDayDisplay {
    let day: String
    let maxTemp: String
    let minTemp: String
    let iconURL: URL?
}
