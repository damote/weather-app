//
//  Cities.swift
//  weather-app
//
//  Created by Dustin Mote on 7/15/22.
//

import Foundation


typealias DecimalCoodinates = (latitude: Double, longitude: Double)


struct CityCoordinates {
    
    var cityCoordinates : [(name: String, coordinates: DecimalCoodinates)] = [

        ("Cupertino", (37.323056, -122.031944)),
        ("Denver", (39.740105, -104.987429)),
        ("Chicago", (41.881944, -87.627778)),
        ("New York", (40.712778, -74.006111)),
        ("London", (37.128767, -84.083901)) // London, KY
    ]
}

