//
//  CityWeekForecastView.swift
//  weather-app
//
//  Created by Dustin Mote on 7/17/22.
//

import Foundation
import UIKit


protocol CityWeekForecastViewDelegate : AnyObject {
    
    func didSelect(period: WeatherForecastPeriodData)
    func requestIcon(for url: URL, _ completion: @escaping (UIImage?) -> Void)
    func isRequestingCelsius() -> Bool
}



class CityWeekForecastView: UIView {
    
    var forecastData : WeatherForecastData?
    
    weak var delegate: CityWeekForecastViewDelegate?
    
    // Header Info
    var cityName: UILabel?
    var currentTemperature: UILabel?
    var currentIconImageView: UIImageView?
    var currentDescriptionLabel: UILabel?
    
    var weekContainerStackView: UIStackView?
    var weekStacks: [DayStackView]?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(with forecast: WeatherForecastData?,
                  delegate: CityWeekForecastViewDelegate) {
        
        self.forecastData = forecast
        self.delegate = delegate
        
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        setLayout()
    }
}

extension CityWeekForecastView {
    
    func setLayout() {
        
        weekContainerStackView = UIStackView(frame: .zero)
        weekContainerStackView?.translatesAutoresizingMaskIntoConstraints = false
        weekContainerStackView?.axis = .horizontal
        weekContainerStackView?.distribution = .fillEqually
        weekContainerStackView?.spacing = 4
        
        if let weekContainerStackView = weekContainerStackView {
            addSubview(weekContainerStackView)
        }

        // Header info
        cityName = UILabel.init(frame: .zero)
        cityName?.translatesAutoresizingMaskIntoConstraints = false
        cityName?.font = UIFont.systemFont(ofSize: 24)
        cityName?.adjustsFontSizeToFitWidth = true
        
        currentTemperature = UILabel.init(frame: .zero)
        currentTemperature?.translatesAutoresizingMaskIntoConstraints = false
        currentTemperature?.adjustsFontSizeToFitWidth = true
        currentTemperature?.font = UIFont.systemFont(ofSize: 18)
        
        currentIconImageView = UIImageView(frame: .zero)
        currentIconImageView?.translatesAutoresizingMaskIntoConstraints = false
        currentIconImageView?.backgroundColor = .lightGray
        
        currentDescriptionLabel = UILabel(frame: .zero)
        currentDescriptionLabel?.translatesAutoresizingMaskIntoConstraints = false
        currentDescriptionLabel?.numberOfLines = 0
        currentDescriptionLabel?.font = UIFont.systemFont(ofSize: 16)
        currentDescriptionLabel?.adjustsFontSizeToFitWidth = true
        
        if let cityName = cityName {
            addSubview(cityName)
        }
        if let currentTemperature = currentTemperature {
            addSubview(currentTemperature)
        }
        if let currentIconImageView = currentIconImageView {
            addSubview(currentIconImageView)
        }
        if let currentDescriptionLabel = currentDescriptionLabel {
            addSubview(currentDescriptionLabel)
        }
        
        applyConstraints()
    }
    
    private func applyConstraints() {
        
        guard let cityName = cityName,
              let currentTemperature = currentTemperature,
              let currentIconImageView = currentIconImageView,
              let currentDescriptionLabel = currentDescriptionLabel,
              let weekContainerStackView = weekContainerStackView else {
            
            assertionFailure("UI elements should not be nil")
            return
        }
        
        weekContainerStackView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5).activate()
        weekContainerStackView.widthAnchor.constraint(equalTo: self.widthAnchor).activate()
        weekContainerStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).activate()
        weekContainerStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).activate()

        currentIconImageView.topAnchor.constraint(equalTo: cityName.topAnchor).activate()
        currentIconImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2).activate()
        currentIconImageView.heightAnchor.constraint(equalTo: currentIconImageView.widthAnchor, multiplier: 1).activate()
        currentIconImageView.centerXAnchor.constraint(equalTo: centerXAnchor).activate()

        cityName.topAnchor.constraint(equalTo: topAnchor, constant: 4).activate()
        cityName.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).activate()
        cityName.heightAnchor.constraint(equalToConstant: 40).activate()
        cityName.rightAnchor.constraint(equalTo: currentIconImageView.leftAnchor, constant: -8).activate()
        
        currentTemperature.topAnchor.constraint(equalTo: cityName.bottomAnchor, constant: 8).activate()
        currentTemperature.leadingAnchor.constraint(equalTo: cityName.leadingAnchor).activate()
        currentTemperature.widthAnchor.constraint(equalTo: cityName.widthAnchor).activate()
        currentTemperature.bottomAnchor.constraint(equalTo: weekContainerStackView.topAnchor).activate()

        currentDescriptionLabel.topAnchor.constraint(equalTo: cityName.topAnchor).activate()
        currentDescriptionLabel.rightAnchor.constraint(equalTo: rightAnchor).activate()
        currentDescriptionLabel.bottomAnchor.constraint(equalTo: currentTemperature.bottomAnchor).activate()
        currentDescriptionLabel.leftAnchor.constraint(equalTo: currentIconImageView.rightAnchor, constant: 12).activate()
        
        updateConstraintsIfNeeded()
        populateData()
    }
    
    private func populateData() {
        
        cityName?.text = forecastData?.city

        if var temperature = forecastData?.periods.first?.temperature,
           var unit = forecastData?.periods.first?.temperatureUnit {
            
            if delegate?.isRequestingCelsius() == true {
                
                temperature = Int((Float(temperature) - 32.0) * 0.5555)
                unit = .Celsius
            }
                
            currentTemperature?.text = "\(temperature)° : \(unit.rawValue)"
        }

        if let iconURLstr = forecastData?.periods.first?.icon,
           let iconURL = URL(string: iconURLstr) {

            delegate?.requestIcon(for: iconURL) { [weak self] image in
                DispatchQueue.main.async {
                    self?.currentIconImageView?.image = image
                }
            }
        }

        if let currentConditions = forecastData?.periods.first?.shortForecast {
            currentDescriptionLabel?.text = currentConditions
        }
        
        if let periods = forecastData?.periods {
            populateWeekForecast(periods)
        }
    }
    
    private func populateWeekForecast(_ periods: [WeatherForecastPeriodData]) {
    
        for i in 1...7 {
            
            let dayView = DayStackView(frame: .init(origin: .zero,
                                                    size: .init(width: self.bounds.width/6,
                                                                height: self.weekContainerStackView?.bounds.height ?? 5)))
            weekContainerStackView?.addArrangedSubview(dayView)
            
            dayView.setupLayout()
            var dayPeriods = [WeatherForecastPeriodData]()
            if let period = periods.first(where: { $0.number == (i * 2) }) {
                dayPeriods.append(period)
            }
            if let period = periods.first(where: { $0.number == ((i * 2) - 1) }) {
                dayPeriods.append(period)
            }
            dayView.updateWithPeriods(dayPeriods, delegate: self)
        }
    }
}

extension CityWeekForecastView: DayStackViewDelegate {
    
    func isRequestingCelsius() -> Bool {
        return delegate?.isRequestingCelsius() ?? false
    }
    
    func didSelectDayPeriod(_ period: WeatherForecastPeriodData) {
        delegate?.didSelect(period: period)
    }
    
    func didRequestImage(_ url: URL, _ completion: @escaping (UIImage) -> Void) {
        delegate?.requestIcon(for: url, { image in

            if let image = image {
                completion(image)
            }
            else {
                print("MIssing Image for request")
            }
        })
    }
}




protocol DayStackViewDelegate: AnyObject {
    
    func didSelectDayPeriod(_ period: WeatherForecastPeriodData)
    func didRequestImage(_ url: URL, _ completion: @escaping (UIImage) -> Void)
    func isRequestingCelsius() -> Bool
}

class DayStackView: UIView {
    
    var weekDayContainerStackView = UIStackView(frame: .zero)
    var dayLabel = UILabel(frame: .zero)
    var tempRangeLabel = UILabel(frame: .zero)
    var dayImageView = UIImageView(frame: .zero)
    
    var periods: [WeatherForecastPeriodData] = []
    var tapGesture: UITapGestureRecognizer?
    
    weak var delegate: DayStackViewDelegate?
    
    override init(frame: CGRect) {
        
        super.init(frame: .zero)
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(didSelect(_:)))
        if let tapGesture = tapGesture {
            self.addGestureRecognizer(tapGesture)
        }
        
        weekDayContainerStackView.translatesAutoresizingMaskIntoConstraints = false
        weekDayContainerStackView.axis = .vertical
        weekDayContainerStackView.distribution = .fill
        weekDayContainerStackView.alignment = .center
        addSubview(weekDayContainerStackView)
        
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.textAlignment = .center
        dayLabel.font = UIFont.systemFont(ofSize: 11)
        
        tempRangeLabel.translatesAutoresizingMaskIntoConstraints = false
        tempRangeLabel.textAlignment = .center
        tempRangeLabel.font = UIFont.systemFont(ofSize: 10)
        
        dayImageView.translatesAutoresizingMaskIntoConstraints = false
        dayImageView.backgroundColor = .lightGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        
        weekDayContainerStackView.addArrangedSubview(dayLabel)
        weekDayContainerStackView.addArrangedSubview(tempRangeLabel)
        weekDayContainerStackView.addArrangedSubview(dayImageView)
        
        updateLayout()
    }
    
    private func updateLayout() {
        
        weekDayContainerStackView.widthAnchor.constraint(equalTo: widthAnchor).activate()
        weekDayContainerStackView.heightAnchor.constraint(equalTo: heightAnchor).activate()
        weekDayContainerStackView.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
        weekDayContainerStackView.centerYAnchor.constraint(equalTo: centerYAnchor).activate()

        dayImageView.widthAnchor.constraint(equalTo: weekDayContainerStackView.widthAnchor).activate()
        dayImageView.heightAnchor.constraint(equalTo: dayImageView.widthAnchor).activate()
        
        updateConstraintsIfNeeded()
    }
    
    func updateWithPeriods(_ periods: [WeatherForecastPeriodData], delegate: DayStackViewDelegate) {
        
        self.periods = periods
        self.delegate = delegate
        
        var day : String? = nil
        var tempA : Int? = nil
        var tempB : Int? = nil
        var img: String? = nil
        
        for (i, period) in periods.enumerated() {
            
            if let date = DateFormatter.ISO8601dateFormatter.date(from: period.startTime), day == nil {
                day = DateFormatter.shortDayDateFormatter.string(from: date)
            }
            
            if i == 0 {
                tempA = period.temperature
            }
            else {
                tempB = period.temperature
            }
            
            if img == nil {
                img = period.icon
            }
        }
        
        dayLabel.text = day
        
        if let tempA = tempA , let tempB = tempB  {
            
            var min = min(tempA, tempB)
            var max = max(tempA, tempB)
            if self.delegate?.isRequestingCelsius() == true {
                
                min = Int((Float(min) - 32) * 0.5555)
                max = Int((Float(max) - 32) * 0.5555)
            }
            tempRangeLabel.text = "\(min) - \(max)"
        }
        else {
            tempRangeLabel.text = "n/a"
        }
        
        if let img = img, let imageURL = URL(string: img) {
            self.delegate?.didRequestImage(imageURL) { image in
                
                DispatchQueue.main.async { [weak self] in
                    self?.dayImageView.image = image
                }
            }
        }
    }
    
    @objc
    func didSelect(_ sender: Any) {
        if let period = self.periods.first {
            delegate?.didSelectDayPeriod(period)
        }
    }
}


