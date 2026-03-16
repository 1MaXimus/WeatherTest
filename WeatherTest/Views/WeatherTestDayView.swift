//
//  WeatherTestDayView.swift
//  WeatherTest
//
//  Created by Maxim Pakhotin on 16.03.2026.
//

import UIKit
import SnapKit

final class WTDayView: UIView {

    // MARK: - UI Elements
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemBackground
        imageView.layer.cornerRadius = 5
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let tempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .right
        return label
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
        backgroundColor = .secondarySystemBackground

        let container = UIView()
        container.addSubview(iconImageView)

        addSubview(stackView)
        stackView.addArrangedSubview(dayLabel)
        stackView.addArrangedSubview(container)
        stackView.addArrangedSubview(tempLabel)

        iconImageView.snp.makeConstraints {
            $0.size.equalTo(40)
            $0.center.equalToSuperview()
            $0.verticalEdges.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }
    }

    // MARK: - Configuration
    func configure(with day: WTDayDisplay) {
        dayLabel.text = day.day
        tempLabel.text = "\(day.maxTemp) / \(day.minTemp)"

        if let iconURL = day.iconURL {
            Task { [weak self] in
                await self?.iconImageView.loadImage(from: iconURL)
            }
        }
    }
}
