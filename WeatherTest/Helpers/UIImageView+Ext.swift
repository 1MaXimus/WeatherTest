//
//  UIImageView+Ext.swift
//  WeatherTest
//
//  Created by Maxim Pakhotin on 15.03.2026.
//

import UIKit

extension UIImageView {
    func loadImage(from url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            self.image = UIImage(data: data)
        } catch {
            self.image = nil
        }
    }
}
