//  AdamSampleProjectTests.swift
//  AdamSampleProjectTests

import XCTest
@testable import AdamSampleProject
import CoreData

class AdamSampleProjectTests: XCTestCase {
    var weather: WeatherInformation?
    let uniqueIdentifier: String = "id"
    let apiClient = APIClient()
    var weatherData: [NSManagedObject] = []
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    func testGettingLatAndLonFromLocation() {
        let expectation = self.expectation(description: "Data should be returned")
        apiClient.send(GetGeometrics(search: "Belfast, Northern Ireland"), endpoint: APIDeclarations.init().geoLocationEndpointUrl) { response in
            _ = response.map { dataContainer in
                expectation.fulfill()
                XCTAssert(dataContainer is [Geolocation])
                if let geoValues = dataContainer as? [Geolocation] {
                    XCTAssert(geoValues.first!.lat.count > 0 && geoValues.first!.lon.count > 0)
                }
            }
        }
        
        waitForExpectations(timeout: 25) { error in
            if let error = error {
                XCTFail("Timeout waiting for expectation: \(error)")
            }
        }
    }
    
    func testGettingWeatherAndPersisitingData() {
        let expectation = self.expectation(description: "Data should be returned as weather information")
        
        apiClient.send(GetWeatherInformation(lat: 54.596391, long: -5.9301829), endpoint: APIDeclarations.init().baseEndpointUrl) { [self] response in
            _ = response.map { dataContainer in
                XCTAssert(dataContainer is Current && (dataContainer as! Current).temperature_2m > 0)
                if let weatherObject = dataContainer as? Current {
                    CoreDataHelper.mainContext().delete((WeatherInformation.mapFromDictionaryOfObjects(weatherObject, context: CoreDataHelper.mainContext())))
                    weatherData.append(WeatherInformation.mapFromDictionaryOfObjects(weatherObject, context: CoreDataHelper.mainContext()))
                    expectation.fulfill()
                    XCTAssert(((weatherData as? [WeatherInformation])?.first!.temperature)! > 0)
                    
                    let entity = WeatherInformation.mapFromDictionaryOfObjects(weatherObject, context: CoreDataHelper.mainContext()).entity
                    // Perform assertions to check if your entity is initialized with data
                    XCTAssertNotNil(entity, "YourEntity instance is nil")
                }
            }
        }
        waitForExpectations(timeout: 25) { error in
            if let error = error {
                XCTFail("Timeout waiting for expectation: \(error)")
            }
        }
    }
}

