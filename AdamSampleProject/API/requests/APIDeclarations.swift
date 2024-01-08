import Foundation

public struct APIDeclarations {
    public var baseEndpointUrl: URL {
        return URL(string: "https://api.open-meteo.com/v1/")!
    }
    
    public var geoLocationEndpointUrl: URL {
        return URL(string: "https://geocode.maps.co/")!
    }
    
    public var accessKey: String {
        return "659934a15a4f1677473928qwf29482c"
    }
}


