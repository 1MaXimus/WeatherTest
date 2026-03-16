//
//  WeatherTestViewController.swift
//  WeatherTest
//
//  Created by Maxim Pakhotin on 13.03.2026.
//

import UIKit
import SnapKit
import Combine

final class WTViewController: UIViewController {

    // MARK: - Properties
    private let viewModel = WTWeatherViewModel()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Elements (те же, что и раньше)
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView = UIView()

    private let loadingView = UIView()
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let errorView = UIView()
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .systemRed
        return label
    }()

    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(String(localized: "Button.Retry.title"), for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()

    private let cityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let currentTempLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 72, weight: .thin)
        label.textAlignment = .center
        return label
    }()

    private let currentIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let detailsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 20
        return stack
    }()

    private let tempIconStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 50
        return stack
    }()

    private let feelsLikeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .gray
        label.numberOfLines = 2
        return label
    }()

    private let humidityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .gray
        label.numberOfLines = 2
        return label
    }()

    private let hourlyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "Forecast.hourly")
        label.font = .italicSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()

    private let hourlyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 70, height: 100)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.contentInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        cv.register(WTHourlyCell.self, forCellWithReuseIdentifier: WTHourlyCell.identifier)
        return cv
    }()

    private let dailyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "Forecast.3days")
        label.font = .italicSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()

    private let dailyStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 10
        return stack
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        Task {
            await viewModel.loadData()
        }
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground

        hourlyCollectionView.dataSource = self

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        view.addSubview(loadingView)
        loadingView.addSubview(activityIndicator)

        view.addSubview(errorView)
        errorView.addSubview(errorLabel)
        errorView.addSubview(retryButton)
        
        contentView.addSubview(tempIconStack)
        contentView.addSubview(cityLabel)
        tempIconStack.addArrangedSubview(currentIconImageView)
        tempIconStack.addArrangedSubview(currentTempLabel)

        contentView.addSubview(detailsStack)
        detailsStack.addArrangedSubview(feelsLikeLabel)
        detailsStack.addArrangedSubview(humidityLabel)

        contentView.addSubview(hourlyTitleLabel)
        contentView.addSubview(hourlyCollectionView)

        contentView.addSubview(dailyTitleLabel)
        contentView.addSubview(dailyStackView)

        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)

        setupConstraints()
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView)
        }

        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        errorView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        errorLabel.snp.makeConstraints {
            $0.top.left.right.equalToSuperview().inset(20)
        }

        retryButton.snp.makeConstraints {
            $0.top.equalTo(errorLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(150)
            $0.height.equalTo(44)
        }

        cityLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.right.equalToSuperview().inset(20)
           // $0.height.equalTo(35)
        }

        tempIconStack.snp.makeConstraints {
            $0.top.equalTo(cityLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(100)
        }

        detailsStack.snp.makeConstraints {
            $0.top.equalTo(tempIconStack.snp.bottom).offset(20)
            $0.left.right.equalToSuperview().inset(40)
            $0.height.equalTo(50)
        }

        hourlyTitleLabel.snp.makeConstraints {
            $0.top.equalTo(detailsStack.snp.bottom).offset(20)
            $0.left.right.equalToSuperview().inset(20)
        }

        hourlyCollectionView.snp.makeConstraints {
            $0.top.equalTo(hourlyTitleLabel.snp.bottom).offset(20)
            $0.height.equalTo(100)
            $0.horizontalEdges.equalToSuperview()
        }

        dailyTitleLabel.snp.makeConstraints {
            $0.top.equalTo(hourlyCollectionView.snp.bottom).offset(30)
            $0.left.right.equalToSuperview().inset(20)
        }

        dailyStackView.snp.makeConstraints {
            $0.top.equalTo(dailyTitleLabel.snp.bottom).offset(20)
            $0.left.right.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }

    private func setupBindings() {
        // State binding
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)

        // Data binding
        viewModel.$displayData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.updateUI(with: data)
            }
            .store(in: &cancellables)
    }

    // MARK: - Handlers
    private func handleStateChange(_ state: WTScreenState) {
        switch state {
            case .loading:
                loadingView.isHidden = false
                errorView.isHidden = true
                contentView.isHidden = true
                activityIndicator.startAnimating()

            case .error(let message):
                loadingView.isHidden = true
                errorView.isHidden = false
                contentView.isHidden = true
                activityIndicator.stopAnimating()
                errorLabel.text = message

            case .success:
                loadingView.isHidden = true
                errorView.isHidden = true
                contentView.isHidden = false
                activityIndicator.stopAnimating()
                hourlyCollectionView.reloadData()
        }
    }

    private func updateUI(with data: WTDisplayData) {
        title = String(localized: "Weather")
        cityLabel.text = data.cityName
        currentTempLabel.text = data.currentTempString
        feelsLikeLabel.text = data.feelsLike
        humidityLabel.text = data.humidity

       // view.backgroundColor = data.currentTemp.backgroundColor.withAlphaComponent(0.2)

        Task {
            if let iconURL = data.currentIconURL {
                await currentIconImageView.loadImage(from: iconURL)
            }
        }

        // Обновление дневного прогноза
        dailyStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for day in data.dailyForecast {
            let dayView =  WTDayView()
            dayView.configure(with: day) 
            dailyStackView.addArrangedSubview(dayView)
        }
    }

    @objc private func retryTapped() {
        Task {
            await viewModel.retry()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension WTViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.displayData.hourlyForecast.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WTHourlyCell.identifier, for: indexPath) as? WTHourlyCell else {
            return UICollectionViewCell()
        }

        let model = WTHourlyCellModel(
            data: viewModel.displayData.hourlyForecast[indexPath.item]
        )
        cell.configure(with: model)

        return cell
    }
}
