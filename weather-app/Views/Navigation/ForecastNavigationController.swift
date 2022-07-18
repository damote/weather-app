//
//  ForecastNavigationController.swift
//  weather-app
//
//  Created by Dustin Mote on 7/16/22.
//

import Foundation
import UIKit


protocol ForecastNavigationCoordinated {
    var coordinator: ForecastNavigationCooridinator? { get set }
}


protocol ForecastNavigationCooridinator: AnyObject {
    
    func didReceiveError(_ error: Error)
    func didLoadForecast()

    func currentForecast() -> WeatherForecastDataMap?
    
    func didRequestFullForecast(_ completion: @escaping (WeatherForecastDataSetResult) -> Void)
    func didRequestImage(for url: URL, _ completion: @escaping (WeatherForecastIconImageResult) -> Void)
    
    func didToggleCelsiusSetting(_ requestsCelsius: Bool)
    func isRequestingCelsius() -> Bool
    func didSelectForecastPeriod(_ period: WeatherForecastPeriodData)
}



final class ForecastNavigationController: UINavigationController {
        
    var dataSourceManager = DataSources()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        delegate = self
    }
}


extension ForecastNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        
        if var coordinatedViewController = viewController as? ForecastNavigationCoordinated {
            coordinatedViewController.coordinator = self
        }
    }
}


extension ForecastNavigationController: ForecastNavigationCooridinator {
    
    
    func didReceiveError(_ error: Error) {
        
        var message: String
        if let fetchError = error as? WeatherDataFetcherError {
            message = fetchError.errorMessage()
        }
        else {
            message = error.localizedDescription
        }
        
        let alertController = UIAlertController(title: "Error",
                                               message: message,
                                               preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok",
                                               style: .cancel))
        
        if let topController = self.topViewController {
            topController.present(alertController,
                                  animated: true)
        }
    }
    
    func didLoadForecast() {
        
        let forecastViewController = ForecastViewController()
        pushViewController(forecastViewController, animated: true)
    }
    
    func currentForecast() -> WeatherForecastDataMap? {
        return dataSourceManager.forecastDataMap
    }
    
    
    func didRequestFullForecast(_ completion: @escaping (WeatherForecastDataSetResult) -> Void) {
        
        dataSourceManager.requestFullForecast { forecastMap in
            
            if let forecastMap = forecastMap {
                completion(.success(forecastMap))
            }
            else {
                completion(.failure(WeatherDataFetcherError.dataIsMissing("Forecast fetch failed")))
            }
        }
    }
    
    
    func didRequestImage(for url: URL, _ completion: @escaping (WeatherForecastIconImageResult) -> Void) {
        
        dataSourceManager.image(for: url) { image in
            
            if let image = image {
                completion(.success(image))
            }
            else {
                completion(.failure(WeatherDataFetcherError.dataIsMissing("Image fetch failed")))
            }
        }
    }
    
    
    func didToggleCelsiusSetting(_ requestsCelsius: Bool) {
        dataSourceManager.requestsCelsius = requestsCelsius
    }
    
    func isRequestingCelsius() -> Bool {
        return dataSourceManager.requestsCelsius
    }
    
    func didSelectForecastPeriod(_ period: WeatherForecastPeriodData) {
        
        let forecastPeriodViewController = ForecastPeriodViewController()
        forecastPeriodViewController.update(with: period)
        pushViewController(forecastPeriodViewController, animated: true)
        
    }
}
