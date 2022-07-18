//
//  WeatherForecastData.swift
//  weather-app
//
//  Created by Dustin Mote on 7/16/22.
//

import Foundation


struct WeatherForecastData {
    
    var city: String?
    var state: String?
    var periods: [WeatherForecastPeriodData]
}

extension WeatherForecastData: Codable {
    
    enum CodingKeys : CodingKey {
        case properties
    }
    
    enum PropertiesCodingKeys : CodingKey {
        case periods
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let propertiesContainer = try container.nestedContainer(keyedBy: PropertiesCodingKeys.self,
                                                                forKey: .properties)
        
        periods = try propertiesContainer.decode([WeatherForecastPeriodData].self,
                                                 forKey: .periods)
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        var propertiesContainer = container.nestedContainer(keyedBy: PropertiesCodingKeys.self,
                                                            forKey: .properties)
        
        try propertiesContainer.encode(periods, forKey: .periods)
    }
}




struct WeatherForecastPeriodData : Codable {
    
    enum TemperatureUnitType : String, Codable {
        case Fahrenheit = "F"
        case Celsius    = "C"
    }
    
    var number: Int
    var name: String
    var startTime: String
    var isDaytime: Bool
    var temperature: Int
    var temperatureUnit: TemperatureUnitType
    var shortForecast: String
    var detailedForecast: String

    var icon: String
}
