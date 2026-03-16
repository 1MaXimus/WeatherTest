//
//  WeatherTestViewModel.swift
//  WeatherTest
//
//  Created by Maxim Pakhotin on 13.03.2026.
//

import Foundation
import Combine

// MARK: - Состояния экрана
enum WTScreenState {
    case loading
    case error(String)
    case success
}

// MARK: - Данные для отображения на экране
struct WTDisplayData {
    // Текущая погода
    var cityName: String = ""
    var currentTempString: String = ""
    var currentTemp: Double = 0
    var currentCondition: String = ""
    var currentIconURL: URL?
    var feelsLike: String = ""
    var humidity: String = ""

    // Почасовой прогноз
    var hourlyForecast: [WTHourDisplay] = []

    // Прогноз на 3 дня
    var dailyForecast: [WTDayDisplay] = []
}

// MARK: - ViewModel
@MainActor
final class WTWeatherViewModel {

    // MARK: - Published Properties
    @Published private(set) var state: WTScreenState = .loading
    @Published private(set) var displayData = WTDisplayData()

    // MARK: - Private Properties
    private let weatherService = WTWeatherService()
    private let locationManager = WTLocationManager()

    private var forecastResponse: WTForecastResponse?

    // MARK: - Public Methods
    func loadData() async {
        state = .loading

        do {
            // Получаем локацию (только координаты)
            let location = try await locationManager.requestLocation()

            // Запрашиваем прогноз - город придет в ответе от API
            let response = try await weatherService.fetchForecast(
                coordinates: location
            )

            self.forecastResponse = response
            processData(response)
            state = .success

        } catch let error as WTWeatherError {
            state = .error(error.message)
        } catch _ as WTLocationError {
            // При ошибке геолокации используем Москву
            await loadMoscowWeather()
        } catch {
            state = .error(String(localized: "Unknown error"))
        }
    }

    // MARK: - Private Methods
    private func loadMoscowWeather() async {
        do {
            let response = try await weatherService.fetchMoscowWeather()
            self.forecastResponse = response
            processData(response)
            state = .success
        } catch let error as WTWeatherError {
            state = .error(error.message)
        } catch {
            state = .error(String(localized: "Notload"))
        }
    }

    private func processData(_ response: WTForecastResponse) {
        var data = WTDisplayData()

        // Город
        data.cityName = response.location.name

        // Текущая погода
        let current = response.current
        data.currentTempString = "\(Int(current.tempC))°"
        data.currentTemp = current.tempC
        data.currentCondition = current.condition.text
        data.currentIconURL = current.condition.iconUrl()
        data.feelsLike = String(localized: "Fillslike \(Int(current.feelslikeC))")
        data.humidity = String(localized: "Humidity \(current.humidity)")

        // Почасовой прогноз
        data.hourlyForecast = processHourlyForecast(forecast: response.forecast)

        // Прогноз на 3 дня
        data.dailyForecast = processDailyForecast(forecast: response.forecast)

        self.displayData = data
    }

    private func processHourlyForecast(forecast: WTForecast) -> [WTHourDisplay] {
        var hours: [WTHourDisplay] = []

        guard forecast.forecastday.count >= 2 else { return [] }

        // Получаем текущий час
        let currentHour = getCurrentHour()

        // Сегодняшние часы (начиная с текущего)
        let todayHours = forecast.forecastday[0].hour
        let remainingTodayHours = todayHours.filter { hour in
            guard let hourStr = hour.hourString(),
                  let hourInt = Int(hourStr.split(separator: ":").first ?? "0") else {
                return false
            }
            return hourInt >= currentHour
        }

        // Завтрашние часы (все)
        let tomorrowHours = forecast.forecastday[1].hour

        // Объединяем и конвертируем
        let allHours = remainingTodayHours + tomorrowHours

        for hour in allHours.prefix(24) {
            let display = WTHourDisplay(
                time: hour.hourString() ?? "",
                tempDisplay: "\(Int(hour.tempC))°",
                temp: hour.tempC,
                iconURL: hour.condition.iconUrl()
            )
            hours.append(display)
        }

        return hours
    }

    private func processDailyForecast(forecast: WTForecast) -> [WTDayDisplay] {
        return forecast.forecastday.map { day in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            let displayDate: String
            if let date = dateFormatter.date(from: day.date) {
                dateFormatter.dateFormat = "E"
                displayDate = dateFormatter.string(from: date)
            } else {
                displayDate = ""
            }

            return WTDayDisplay(
                day: displayDate,
                maxTemp: "\(Int(day.day.maxtempC))°",
                minTemp: "\(Int(day.day.mintempC))°",
                iconURL: day.day.condition.iconUrl()
            )
        }
    }

    private func getCurrentHour() -> Int {
        if let localtime = forecastResponse?.location.localtime {
            let components = localtime.split(separator: " ")
            if components.count == 2 {
                let timeComponent = components[1]
                let hourMin = timeComponent.split(separator: ":")
                if let hour = Int(hourMin.first ?? "0") {
                    return hour
                }
            }
        }
        return Calendar.current.component(.hour, from: Date())
    }
}
