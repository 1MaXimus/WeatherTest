//
//  WeatherTestLocation.swift
//  WeatherTest
//
//  Created by Maxim Pakhotin on 13.03.2026.
//

import Foundation
import CoreLocation

enum WTLocationError: Error {
    case permissionDenied
    case locationNotFound
    case unknown

    var message: String {
        switch self {
            case .permissionDenied:
                String(localized: "Error.Location.permissionDenied")
            case .locationNotFound:
                String(localized: "Error.Location.locationNotFound")
            case .unknown:
                String(localized: "Error.Location.unknown")
        }
    }
}

final class WTLocationManager: NSObject {

    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    // MARK: - Public Methods
    func requestLocation() async throws -> (lat: Double, lon: Double) {

        // Проверяем статус авторизации
        let status = manager.authorizationStatus

        switch status {
            case .notDetermined:
                // Запрашиваем разрешение и ждем
                manager.requestWhenInUseAuthorization()
                let location = try await waitForLocation()
                return (location.coordinate.latitude, location.coordinate.longitude)

            case .authorizedWhenInUse, .authorizedAlways:
                // Уже есть разрешение - просто получаем локацию
                let location = try await waitForLocation()
                return (location.coordinate.latitude, location.coordinate.longitude)

            case .denied, .restricted:
                // Отказано - возвращаем Москву
                return getMoscowLocation()

            @unknown default:
                throw WTLocationError.unknown
        }
    }

    // MARK: - Private Methods
    private func waitForLocation() async throws -> CLLocation {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            manager.requestLocation()
        }
    }

    func getMoscowLocation() -> (lat: Double, lon: Double) {
        return (55.7558, 37.6176)
    }
}

// MARK: - CLLocationManagerDelegate
extension WTLocationManager: CLLocationManagerDelegate {

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        Task { await handleLocation(location) }
    }

    private func handleLocation(_ location: CLLocation) {
        continuation?.resume(returning: location)
        continuation = nil
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { await handleError(error) }
    }

    private func handleError(_ error: Error) {
        continuation?.resume(throwing: WTLocationError.locationNotFound)
        continuation = nil
    }
}
