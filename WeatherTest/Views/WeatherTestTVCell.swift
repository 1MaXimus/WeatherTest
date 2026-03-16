//
//  WeatherTestTVCell.swift
//  WeatherTest
//
//  Created by Maxim Pakhotin on 15.03.2026.
//

import UIKit
import SnapKit

struct WTHourlyCellModel {
    var data: WTHourDisplay
}

// MARK: - HourlyCell
final class WTHourlyCell: UICollectionViewCell {
    static let identifier = "HourlyCell"

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
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
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
    }

    private func setupUI() {
        contentView.addSubview(timeLabel)
        contentView.addSubview(iconImageView)
        contentView.addSubview(tempLabel)

        timeLabel.snp.makeConstraints {
            $0.top.left.right.equalToSuperview().inset(5)
        }

        iconImageView.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(30)
        }

        tempLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(5)
            $0.left.right.bottom.equalToSuperview().inset(5)
        }
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }

    func configure(with model: WTHourlyCellModel) {
        timeLabel.text = model.data.time
        tempLabel.text = model.data.tempDisplay
        Task {
            if let iconURL = model.data.iconURL {
                await iconImageView.loadImage(from: iconURL)
            }
        }
        backgroundColor = model.data.temp.backgroundColor
    }
}
