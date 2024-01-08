import Foundation

public struct WeatherData: Decodable {
    public let current: Current
}

public struct Current: Decodable {
    let time: String
    let interval: Float
    let temperature_2m: Float
    let apparent_temperature: Float
    let rain: Float
    let cloud_cover: Float
    let wind_gusts_10m: Float
    let wind_direction_10m: Float
}

public struct Geolocation: Decodable {
    let lat: String
    let lon: String
    let display_name: String
}


typealias weather = WeatherData
