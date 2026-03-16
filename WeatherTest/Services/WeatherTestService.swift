//
//  WeatherTestService.swift
//  WeatherTest
//
//  Created by Maxim Pakhotin on 13.03.2026.
//

import Foundation

enum WTWeatherError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkError(String)

    var message: String {
        switch self {
            case .invalidURL:
                return String(localized: "Error.Weather.invalidURL")
            case .noData:
                return String(localized: "Error.Weather.noData")
            case .decodingError:
                return String(localized: "Error.Weather.decoding")
            case .networkError(let description):
                return String(localized: "Error.Weather.network \(description)")
        }
    }
}

final class WTWeatherService {

    private let session = URLSession.shared

    // MARK: - Прогноз на 3 дня и текущая
    func fetchForecast(coordinates: WTCoordinates) async throws -> WTForecastResponse {
        let urlString = String(format: Constants.forecastURL, coordinates.lat, coordinates.lon)
        return try await performRequest(urlString: urlString)
    }

    // MARK: - Общий метод для запросов
    private func performRequest<T: Decodable>(urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw WTWeatherError.invalidURL
        }

        do {
            let (data, _) = try await session.data(from: url)

            let decoder = JSONDecoder()
            do {
                let result = try decoder.decode(T.self, from: data)
                return result
            } catch {
                throw WTWeatherError.decodingError
            }
        } catch {
            throw WTWeatherError.networkError(error.localizedDescription)
        }
    }

    // MARK: - Метод для города по умолчанию (Москва)
    func fetchMoscowWeather() async throws -> WTForecastResponse {
        let coordinatesMoscow = Constants.coordinatesMoscow
        let urlString = String(format: Constants.forecastURL, coordinatesMoscow.lat, coordinatesMoscow.lon)
        return try await performRequest(urlString: urlString)
    }
}
