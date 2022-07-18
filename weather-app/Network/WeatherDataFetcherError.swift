//
//  WeatherDataFetcherError.swift
//  weather-app
//
//  Created by Dustin Mote on 7/16/22.
//

import Foundation


indirect enum WeatherDataFetcherError: Error {
    
    case dataIsMissing(String)
    case nonHTTPResponse
    case requestFailure(Int)
    case receivedError(Error)
    case fetchError(WeatherDataFetcherError)
    case invalidURL
    case decodingError(Error)
    case unexpectedError
    
}

extension WeatherDataFetcherError {
    
    func errorMessage() -> String {
        switch self {
        case .dataIsMissing(let str):
            return "Data is missing : \(str)"
        case .nonHTTPResponse:
            return "invalid HTTP repsonse"
        case .requestFailure(let int):
            return "request failed \(int)"
        case .receivedError(let error):
            return error.localizedDescription
        case .fetchError(let weatherDataFetcherError):
            return weatherDataFetcherError.errorMessage()
        case .invalidURL:
            return "invalid URL"
        case .decodingError(let error):
            return error.localizedDescription
        case .unexpectedError:
            return "not implemented"
        }
        
    }
}
