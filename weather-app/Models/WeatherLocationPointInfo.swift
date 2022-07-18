//
//  WeatherLocationPointInfo.swift
//  weather-app
//
//  Created by Dustin Mote on 7/15/22.
//

import Foundation


struct WeatherLocationPointInfo {
    
    struct GridInfo: Codable {
        
        var id : String
        var x : Int
        var y : Int
    }
    
    var grid : GridInfo
    var forecast : String
    var forecastHourly : String
    
    var city: String
    var state: String

    /// Nested Containers
    //  properties: [String : Any]
    //  relativeLocation : [String : Any]
    //  locationProperties: [String : Any]
}


/// Codable conformance
extension WeatherLocationPointInfo: Codable {
    
    enum CodingKeys: CodingKey {
        case properties
    }
    
    enum PropertiesCodingKeys: String, CodingKey {
        
        case forecast, forecastHourly, relativeLocation
        
        // Grid Info
        case id = "gridId"
        case x = "gridX"
        case y = "gridY"
    }
    
    enum RelativeLocationCodingKeys: String,  CodingKey {
        case locationProperties = "properties"
    }
    
    enum LocationPropertiesCodingKeys: CodingKey {
        case city, state
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        /// Top Level Properties dictionary
        let propertiesContainer = try container.nestedContainer(keyedBy: PropertiesCodingKeys.self,
                                                                forKey: .properties)
        
        
        /// Forecast URLs (as strings)
        forecast = try propertiesContainer.decode(String.self, forKey: .forecast)
        forecastHourly = try propertiesContainer.decode(String.self, forKey: .forecastHourly)
        
        /// Grid Info
        let id =  try propertiesContainer.decode(String.self, forKey: .id)
        let x =  try propertiesContainer.decode(Int.self, forKey: .x)
        let y =  try propertiesContainer.decode(Int.self, forKey: .y)
        grid = GridInfo(id: id, x: x, y: y)
        
        /// City, State
        let relativeLocationContainer = try propertiesContainer.nestedContainer(keyedBy: RelativeLocationCodingKeys.self,
                                                                                forKey: .relativeLocation)
        
        let locationPropertiesContainer = try relativeLocationContainer.nestedContainer(keyedBy: LocationPropertiesCodingKeys.self,
                                                                                        forKey: .locationProperties)
        
        city = try locationPropertiesContainer.decode(String.self, forKey: .city)
        state = try locationPropertiesContainer.decode(String.self, forKey: .state)
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        var propertiesContainer = container.nestedContainer(keyedBy: PropertiesCodingKeys.self,
                                                           forKey: .properties)
        
        /// Forecast URLs (as strings)
        try propertiesContainer.encode(forecast, forKey: .forecast)
        try propertiesContainer.encode(forecastHourly, forKey: .forecastHourly)
        
        /// Grid Info
        try propertiesContainer.encode(grid.id, forKey: .id)
        try propertiesContainer.encode(grid.x, forKey: .x)
        try propertiesContainer.encode(grid.y, forKey: .y)
        
        /// City, State
        var relativeLocationContainer = propertiesContainer.nestedContainer(keyedBy: RelativeLocationCodingKeys.self,
                                                                            forKey: .relativeLocation)
        
        var locationPropertiesContainer = relativeLocationContainer.nestedContainer(keyedBy: LocationPropertiesCodingKeys.self,
                                                                                        forKey: .locationProperties)
        try locationPropertiesContainer.encode(city, forKey: .city)
        try locationPropertiesContainer.encode(state, forKey: .state)
    }
}
