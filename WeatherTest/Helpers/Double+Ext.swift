//
//  Double+Ext.swift
//  WeatherTest
//
//  Created by Maxim Pakhotin on 15.03.2026.
//

import UIKit

extension Double {
    var backgroundColor: UIColor {
        switch self.rounded() {
            case ..<0:
                // Отрицательные температуры — красный
                // Чем ниже температура, тем насыщеннее красный
                let intensity = min(1.0, abs(self) / 30.0) // Максимальная насыщенность при -30° и ниже
                return UIColor(
                    red: 1.0,
                    green: max(0.8 - intensity * 0.3, 0.5),
                    blue: max(0.8 - intensity * 0.3, 0.5),
                    alpha: 0.5
                )

            case 0:
                // Ноль — синий
                return UIColor(
                    red: 0.7,
                    green: 0.8,
                    blue: 1.0,
                    alpha: 0.5
                )

            case 0...:
                // Положительные температуры — зелёный
                // Чем выше температура, тем насыщеннее зелёный
                let intensity = min(1.0, self / 30.0) // Максимальная насыщенность при +30° и выше
                return UIColor(
                    red: max(0.8 - intensity * 0.3, 0.5),
                    green: 1.0,
                    blue: max(0.8 - intensity * 0.3, 0.5),
                    alpha: 0.5
                )
            default:
                return .clear
        }
    }
}
