//
//  DataSources.swift
//  weather-app
//
//  Created by Dustin Mote on 7/17/22.
//

import Foundation
import UIKit

/// Dictionary of [City Name (String) :  WeatherForecastData]
typealias WeatherForecastDataMap = [String: WeatherForecastData]

/// Dictionary of previously fetched [URL : Forecast image icon]
typealias WeatherForecastImageMap = [URL: UIImage]



final class DataSources {
    
    var forecastDataMap = WeatherForecastDataMap()
    var imageMap = WeatherForecastImageMap()
    var requestsCelsius: Bool = false
    
    
    private var dataFetcher = WeatherDataFetcher()
    
    
    func requestFullForecast(_ completion: @escaping ((WeatherForecastDataMap?) -> Void)) {
        
        guard forecastDataMap.isEmpty else  {

            completion(forecastDataMap)
            return
        }
        
        dataFetcher.getWeatherForecast { [weak self] forecastResult in
            
            if let forecastMap = try? forecastResult.get() {
                
                self?.forecastDataMap = forecastMap
                completion(forecastMap)
            }
            else {
                completion(nil)
            }
        }
    }
    
    
    func image(for url: URL, _ completion: @escaping ((UIImage?) -> Void)) {
        
        if let image = imageMap[url] {
            completion(image)
        }
        else {
            
            dataFetcher.getIconImage(for: url) { [weak self] imageResult in
                
                if let image = try? imageResult.get() {
                    
                    self?.imageMap[url] = image
                    completion(image)
                }
                else {
                    completion(nil)
                }
            }
        }
    }
}
