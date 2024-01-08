import Foundation

let apiDeclarations = APIDeclarations.init()

public struct GetWeatherInformation: APIRequest {
    public typealias Response = [WeatherData]

    public var lat: Float
    public var long: Float

    public var resourceName: String {
        return String(format: "forecast?latitude=%f&longitude=%f&current=temperature_2m,apparent_temperature,rain,cloud_cover,wind_gusts_10m,wind_direction_10m&wind_speed_unit=mph", lat, long)
    }
}

public struct GetGeometrics: APIRequest {
    public typealias Response = [Geolocation]

    public var search: String

    public var resourceName: String {
        return String(format: "search?q=%@&api_key=%@", search, apiDeclarations.accessKey)
    }
}
