//
//  WeatherDataFetcher.swift
//  weather-app
//
//  Created by Dustin Mote on 7/15/22.
//

import Foundation
import UIKit

typealias AppResult<T> = Result<T, Error>

/// Result containing fetched Data, or an Error
typealias FetchDataResult = AppResult<Data>

/// Result containing parsed Weather Point Info, or an Error
typealias WeatherLocationPointResult = AppResult<WeatherLocationPointInfo>

/// Result containing parsed Weather forecast data for an individual city, or an Error
typealias WeatherForecastDataCityResult = AppResult<WeatherForecastData>

/// Result containing a Dictionary of [City Name (String) : WeatherForecastData], or an Error
typealias WeatherForecastDataSetResult = AppResult<WeatherForecastDataMap>

typealias WeatherForecastIconImageResult = AppResult<UIImage>


 
/// Class for Weather app to handle direct data /GET calls to `https://api.weather.gov/`
final class WeatherDataFetcher {
    
    let session = URLSession(configuration: .default)
    let jsonDecoder = JSONDecoder()
    
    let syncQueue = DispatchQueue(label: "com.weather.app.data.map.sync", qos: .userInitiated)
    let dispatchQueue = DispatchQueue(label: "com.weather.app.data.fetcher", qos: .userInteractive)
    let dispatchSemaphore = DispatchSemaphore(value: 1)
    let dispatchGroup = DispatchGroup()
    
    let urlBuilder = WeatherURLBuilder()
    
    func getWeatherForecast(completion: @escaping ((WeatherForecastDataSetResult) -> Void)) {
        
        // Project city list
        let cityList = CityCoordinates()
        var weatherPointInfoMap = [String: WeatherLocationPointInfo]()
        
        for city in cityList.cityCoordinates {
            
            dispatchSemaphore.wait()
            dispatchGroup.enter()
            dispatchQueue.async { [weak self] in
                
                self?.getLocationPointInfo(city.coordinates, completion: { weatherLocationPointResult in
                    
                    defer {

                        self?.dispatchSemaphore.signal()
                        self?.dispatchGroup.leave()
                    }
                    
                    if let weatherLocationPointInfo = try? weatherLocationPointResult.get() {
                        weatherPointInfoMap[city.name] = weatherLocationPointInfo
                    }
                })
            }
        }
        dispatchGroup.wait()
        
        var weatherForecastDataMap = WeatherForecastDataMap()
        
        for (cityName, pointInfo) in weatherPointInfoMap {
            
            dispatchSemaphore.wait()
            dispatchGroup.enter()
            dispatchQueue.async { [weak self] in

                self?.getWeatherForecastData(for: pointInfo, completion: { weatherForecastDataResult in
                    
                    defer {

                        self?.dispatchSemaphore.signal()
                        self?.dispatchGroup.leave()
                    }
                    
                    if var weatherForecastData = try? weatherForecastDataResult.get() {
                        self?.syncQueue.sync {
                            weatherForecastData.city = cityName
                            weatherForecastDataMap[cityName] = weatherForecastData
                        }
                    }
                })
            }
        }
        dispatchGroup.wait()
        
        dispatchGroup.notify(queue: .main) {
            completion(.success(weatherForecastDataMap))
        }
    }
    
    func getIconImage(for url: URL, completion:  @escaping ((WeatherForecastIconImageResult) -> Void)) {
        
        fetchData(url) { dataResult in
            
            if let imageData = try? dataResult.get(), let image = UIImage(data: imageData) {
                completion(.success(image))
            }
            else {
                completion(.failure(WeatherDataFetcherError.dataIsMissing("No UIImage")))
            }
        }
    }
}


extension WeatherDataFetcher {
    
    
    fileprivate func getWeatherForecastData(for pointInfo: WeatherLocationPointInfo,
                                            completion: @escaping ((WeatherForecastDataCityResult) -> Void)) {
        
        guard let forecastURL = urlBuilder.forecastURL(from: pointInfo) else {
            
            assertionFailure("Unable to create proper weather forecast URL")
            completion(.failure(WeatherDataFetcherError.invalidURL))
            return
        }
        
        fetchData(forecastURL) { [weak self] resultWithForecastData in
            
            guard let strongSelf = self else {
                
                assertionFailure("Self (WeatherDataFetcher) has been deallocation")
                completion(.failure(WeatherDataFetcherError.unexpectedError))
                return
            }
            
            guard let data = try? resultWithForecastData.get() else {
                
                completion(.failure(WeatherDataFetcherError.dataIsMissing(#function)))
                return
            }

            let result =  Result { try strongSelf.jsonDecoder.decode(WeatherForecastData.self,
                                                                     from: data)}
            completion(result)
        }
    }
    
    
    fileprivate func getLocationPointInfo(_ coordinates: DecimalCoodinates,
                              completion: @escaping ((WeatherLocationPointResult) -> Void)) {
        
        guard let pointURL = urlBuilder.pointsURL(for: coordinates) else {
            
            assertionFailure("Unable to create proper Location point URL")
            completion(.failure(WeatherDataFetcherError.invalidURL))
            return
        }
        
        fetchData(pointURL) { [weak self] resultWithPointData in
            
            guard let strongSelf = self else {
                
                assertionFailure("Self (WeatherDataFetcher) has been deallocation")
                completion(.failure(WeatherDataFetcherError.unexpectedError))
                return
            }
             
            guard let data = try? resultWithPointData.get() else {
                
                completion(.failure(WeatherDataFetcherError.dataIsMissing(#function)))
                return
            }
            
            let result = Result { try strongSelf.jsonDecoder.decode(WeatherLocationPointInfo.self,
                                                                    from: data) }
            completion(result)
        }
    }
    
    /// central func to perform data task.
    /// Data returned in result is intended to be parsed in calling function
    fileprivate func fetchData(_ url: URL, _ completion: @escaping (FetchDataResult) -> Void) {
        
        let request = URLRequest(url: url,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 15)
        print("Fetching : \(url.absoluteString)")
        dispatchQueue.async { [weak self] in
            
            self?.session.dataTask(with: request) { data, response, error in
                
                guard error == nil else {
                    
                    completion(.failure(WeatherDataFetcherError.receivedError(error!)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    
                    completion(.failure(WeatherDataFetcherError.nonHTTPResponse))
                    return
                }
                
                guard (httpResponse.statusCode / 100) == 2 else {
                    
                    completion(.failure(WeatherDataFetcherError.requestFailure(httpResponse.statusCode)))
                    return
                }
                
                guard let data = data else {
                    
                    completion(.failure(WeatherDataFetcherError.dataIsMissing(#function)))
                    return
                }
                
                completion(.success(data))
            }.resume()
        }
    }
}
