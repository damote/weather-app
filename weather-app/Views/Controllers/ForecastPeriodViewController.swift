//
//  ForecastPeriodViewController.swift
//  weather-app
//
//  Created by Dustin Mote on 7/17/22.
//

import UIKit

class ForecastPeriodViewController: UIViewController, ForecastNavigationCoordinated {

    weak var coordinator: ForecastNavigationCooridinator?
    
    var period: WeatherForecastPeriodData?
    
    var stackView = UIStackView(frame: .zero)
    var name = UILabel(frame: .zero)
    var temp = UILabel(frame: .zero)
    var forecast = UILabel(frame: .zero)
    var detail = UILabel(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemMint
   }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupLayout()
    }
    
    func setupLayout() {
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 20
        view.addSubview(stackView)
        
        name.translatesAutoresizingMaskIntoConstraints = false
        name.textAlignment = .center
        name.font = UIFont.systemFont(ofSize: 26)
        name.numberOfLines = 0
        stackView.addArrangedSubview(name)
        
        temp.translatesAutoresizingMaskIntoConstraints = false
        temp.textAlignment = .center
        temp.font = UIFont.systemFont(ofSize: 26)
        temp.numberOfLines = 0
        stackView.addArrangedSubview(temp)
        
        forecast.translatesAutoresizingMaskIntoConstraints = false
        forecast.textAlignment = .center
        forecast.font = UIFont.systemFont(ofSize: 26)
        forecast.numberOfLines = 0
        stackView.addArrangedSubview(forecast)
        
        detail.translatesAutoresizingMaskIntoConstraints = false
        detail.textAlignment = .center
        detail.font = UIFont.systemFont(ofSize: 26)
        detail.numberOfLines = 0
        detail.adjustsFontSizeToFitWidth = true
        stackView.addArrangedSubview(detail)
        
        updateConstraints()
    }
    
    func updateConstraints() {
        
        stackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).activate()
        stackView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.8).activate()
        stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).activate()
        stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).activate()
        
        populateData()
    }
    
    func update(with period: WeatherForecastPeriodData) {
        self.period = period
    }
    
    func populateData() {
        
        guard let period = period else {
            
            assertionFailure("Period should not be nil")
            return
        }

        
        self.name.text = period.name
        self.forecast.text = period.shortForecast
        self.detail.text = period.detailedForecast
    
        if let celcius = coordinator?.isRequestingCelsius() {
            
            let temp = celcius ? Int((Float(period.temperature) - 32) * 0.5555) : period.temperature
            self.temp.text = "\(temp)" + " : \(celcius ? "C": "F")"
        }
    }
}
