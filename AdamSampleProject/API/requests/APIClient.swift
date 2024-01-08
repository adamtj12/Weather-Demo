import Foundation

public typealias ResultCallback<Value> = (Result<Value, Error>) -> Void

public class APIClient {
    let apiDeclarations = APIDeclarations.init()
	private let session = URLSession(configuration: .default)

	public init() {
	}
    
    public func send<T: APIRequest>(_ request: T, endpoint: URL, completion: @escaping ResultCallback<Any>) {
        
        let endpoint = self.endpoint(for: request, endPoint: endpoint)
        
        
         let task = session.dataTask(with: URLRequest(url: endpoint)) { data, response, error in
            if let data = data {
                do {
                    if request is GetWeatherInformation {
                        let weatherResponse = try JSONDecoder().decode(WeatherData.self, from: data)
                        print(weatherResponse)
                        completion(.success(weatherResponse.current))
                    } else {
                        let geolocationResponse = try JSONDecoder().decode([Geolocation].self, from: data)
                        print(geolocationResponse)
                        completion(.success(geolocationResponse))
                    }
                } catch {
                    completion(.failure(error))
                    print(error)
                }
            } else if let error = error {
                completion(.failure(error))
                print(error)
            }
        }
        task.resume()
    }
    
	/// Encodes a URL based on the given request
    private func endpoint<T: APIRequest>(for request: T, endPoint: URL) -> URL {
            guard let baseUrl = URL(string: request.resourceName, relativeTo: endPoint) else {
                fatalError("Bad resourceName: \(request.resourceName)")
            }
        let components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)!
		return components.url!
	}
}
