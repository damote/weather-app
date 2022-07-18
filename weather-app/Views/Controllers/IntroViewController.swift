//
//  IntroViewController.swift
//  weather-app
//
//  Created by Dustin Mote on 7/15/22.
//

import UIKit

final class IntroViewController: UIViewController, ForecastNavigationCoordinated {
    
    private var appTitleLabel: UILabel?
    private var introMessageLabel: UILabel?
    private var loadForecastButton: UIButton?
    private var activityIndicator: UIActivityIndicatorView?
    
    private var celsiusContainerView: UIView?
    private var celsiusLabel: UILabel?
    private var celsiusSwitch: UISwitch?
    
    
    private var stackView: UIStackView?
    
    weak var coordinator: ForecastNavigationCooridinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard stackView == nil else { return }
        
        setupLayout()
        setupInteractions()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let coordinator = coordinator {
            celsiusSwitch?.setOn(coordinator.isRequestingCelsius(), animated: true)
        }
    }
    
    private func setupLayout() {
        
        // Containing Stack View
        self.stackView = UIStackView(frame: .zero)
        stackView?.translatesAutoresizingMaskIntoConstraints = false
        stackView?.axis = .vertical
        stackView?.distribution = .fill
        stackView?.alignment = .center
        stackView?.spacing = 32
        if let stackView = stackView {
            view.addSubview(stackView)
        }
        
        // Title
        self.appTitleLabel = UILabel(frame: CGRect(origin: .zero,
                                                   size: CGSize(width: view.bounds.width,
                                                                height: 46)))
        appTitleLabel?.translatesAutoresizingMaskIntoConstraints = false
        appTitleLabel?.text = "Weather Forecast App"
        appTitleLabel?.font = UIFont.boldSystemFont(ofSize: 28)
        appTitleLabel?.textAlignment = .center
        if let appTitleLabel = appTitleLabel {
            stackView?.addArrangedSubview(appTitleLabel)
        }
        
        // Message
        self.introMessageLabel = UILabel(frame: CGRect(origin: .zero,
                                                       size: CGSize(width: view.bounds.width,
                                                                    height: 92)))
        introMessageLabel?.translatesAutoresizingMaskIntoConstraints = false
        introMessageLabel?.text = "The Weekly Forecast for your 5 favorite cities"
        introMessageLabel?.font = UIFont.systemFont(ofSize: 16)
        introMessageLabel?.textAlignment = .center
        introMessageLabel?.numberOfLines = 2
        if let introMessageLabel = introMessageLabel {
            stackView?.addArrangedSubview(introMessageLabel)
        }
        
        // Spacer
        let midSpacerView = UIView(frame: .zero)
        midSpacerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        stackView?.addArrangedSubview(midSpacerView)
        
        // ActivityIndicator
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(origin: .zero,
                                                                       size: CGSize(width: 60,
                                                                                    height: 60)))
        activityIndicator?.style = .large
        activityIndicator?.hidesWhenStopped = true
        if let activityIndicator = activityIndicator {
            
            activityIndicator.center = view.center
            view.addSubview(activityIndicator)
        }

        
        // Load Button
        self.loadForecastButton = UIButton(frame: .zero)
        loadForecastButton?.translatesAutoresizingMaskIntoConstraints = false
        loadForecastButton?.setTitle("Load current forecast", for: .normal)
        loadForecastButton?.setTitleColor(.black, for: .normal)
        loadForecastButton?.layer.borderColor = UIColor.black.cgColor
        loadForecastButton?.layer.borderWidth = 2
        loadForecastButton?.layer.cornerRadius = 8
        if let loadForecastButton = loadForecastButton {
            stackView?.addArrangedSubview(loadForecastButton)
        }
        
        let spacerView = UIView(frame: CGRect(origin: .zero,
                                              size: CGSize(width: view.bounds.width,
                                                           height: 8)))
        stackView?.addArrangedSubview(spacerView)

        // Temp setting
        
        self.celsiusContainerView = UIView(frame: .zero)
        celsiusContainerView?.translatesAutoresizingMaskIntoConstraints = false
        
        self.celsiusLabel = UILabel(frame: .zero)
        celsiusLabel?.translatesAutoresizingMaskIntoConstraints = false
        celsiusLabel?.text = "As Celsius"
        celsiusLabel?.textAlignment = .right
        if let celsiusLabel = celsiusLabel {
            celsiusContainerView?.addSubview(celsiusLabel)
        }
        
        self.celsiusSwitch = UISwitch(frame: .zero)
        celsiusSwitch?.translatesAutoresizingMaskIntoConstraints = false
        celsiusSwitch?.onTintColor = .red
        celsiusSwitch?.tintColor = .lightGray
        celsiusSwitch?.addAction(UIAction(handler: { action in
            self.celsiusSwitchToggled()
        }), for: .primaryActionTriggered)
        if let celsiusSwitch = celsiusSwitch {
            celsiusContainerView?.addSubview(celsiusSwitch)
        }
        
        if let celsiusContainerView = celsiusContainerView {
            stackView?.addArrangedSubview(celsiusContainerView)
        }
        
        
        updateConstraints()
    }
    
    private func setupInteractions() {
    
        let loadForecastAction = UIAction(title: "Load Current Forecast") { (action) in
            self.loadForecastButtonPressed()
        }
        loadForecastButton?.addAction(loadForecastAction,
                                      for: .touchUpInside)
    }
    
    private func updateConstraints() {
        
        guard let stack = stackView,
              let loadButton = loadForecastButton,
              let celsiusContainerView = celsiusContainerView,
              let celsiusSwitch = celsiusSwitch,
              let celsiusLabel = celsiusLabel else {
            
            return
        }

        // Stack view
        stack.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).activate()
        stack.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor).activate()
        stack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).activate()
        stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).activate()
        
        loadButton.widthAnchor.constraint(equalToConstant: 200).activate()
        
        celsiusContainerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).activate()
        celsiusContainerView.heightAnchor.constraint(equalToConstant: 30).activate()
        celsiusContainerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).activate()
        
        celsiusLabel.widthAnchor.constraint(equalTo: celsiusContainerView.widthAnchor, multiplier: 0.5).activate()
        celsiusLabel.heightAnchor.constraint(equalTo: celsiusContainerView.heightAnchor).activate()
        celsiusLabel.leftAnchor.constraint(equalTo: celsiusContainerView.leftAnchor).activate()
        celsiusLabel.topAnchor.constraint(equalTo: celsiusContainerView.topAnchor).activate()
        
        celsiusSwitch.heightAnchor.constraint(equalTo: celsiusContainerView.heightAnchor).activate()
        celsiusSwitch.leftAnchor.constraint(equalTo: celsiusLabel.rightAnchor, constant: 8).activate()
        celsiusSwitch.topAnchor.constraint(equalTo: celsiusContainerView.topAnchor).activate()
        
        
        view.updateConstraintsIfNeeded()
    }
    
    private func loadForecastButtonPressed() {
            
        DispatchQueue.main.async {
            self.activityIndicator?.startAnimating()
        }
        
        coordinator?.didRequestFullForecast({ [weak self] forecastResult in
            
            DispatchQueue.main.async {
                self?.activityIndicator?.stopAnimating()
            }
    
            switch forecastResult {
            
            case .failure(let error):
                self?.coordinator?.didReceiveError(error)
            
            case .success(_):
                self?.coordinator?.didLoadForecast()
            }
        })
    }
    
    private func celsiusSwitchToggled() {
        
        if let celsiusSwitch = celsiusSwitch {
            coordinator?.didToggleCelsiusSetting(celsiusSwitch.isOn )
        }
    }
}
