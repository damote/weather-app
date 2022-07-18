//
//  WeatherURLBuilder.swift
//  weather-app
//
//  Created by Dustin Mote on 7/15/22.
//

import Foundation


final class WeatherURLBuilder {
    
    let scheme = "https"
    let host  = "api.weather.gov"
    
    fileprivate func baseComponents() -> URLComponents {
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        return components
    }
    
    func pointsURL(for cityCoordinate: DecimalCoodinates) -> URL? {
        
        var components = baseComponents()
        
        components.path = "/points/" + "\(cityCoordinate.latitude)" + "," + "\(cityCoordinate.longitude)"
       
        return components.url
    }
    
    func forecastURL(from pointInfo: WeatherLocationPointInfo) -> URL? {
        
        var components = baseComponents()
        let gridInfo = pointInfo.grid
        
        components.path = "/gridpoints/\(gridInfo.id)/\(gridInfo.x),\(gridInfo.y)/forecast"
       
        return components.url
    }
    
}
