//  AdamSampleProject

import Foundation
import CoreData

@objc(WeatherInformation)
public class WeatherInformation: NSManagedObject {
    
    static var uniqueIdentifier: String = "id"

    @objc
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    init(entity: NSEntityDescription, context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(time: String, temperature: Float, apparentTemperature: Float, rain: Float, cloudCover: Float, windGusts: Float, entity: NSEntityDescription, context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        self.time = time
        self.temperature = temperature
        self.apparentTemperature = apparentTemperature
        self.cloudCover = cloudCover
        self.windGusts = windGusts
    }
}

protocol ManagedWeatherInformationFromCollection {
    static func mapFromDictionaryOfObjects(_ WeatherInformationJson: Current, context: NSManagedObjectContext) -> NSManagedObject
}

extension WeatherInformation: ManagedWeatherInformationFromCollection {
    static func mapFromDictionaryOfObjects(_ WeatherInformationJson: Current, context: NSManagedObjectContext) -> NSManagedObject {
        let weatherValues: WeatherInformation = createObject(ofType: WeatherInformation.self, attributeName: uniqueIdentifier, value: "test", context: context)
        
        CoreDataHelper.performClosureOnContext(context, wait: true, save: true) { (context) in
            weatherValues.temperature = WeatherInformationJson.temperature_2m
            weatherValues.apparentTemperature = WeatherInformationJson.apparent_temperature
            weatherValues.rain = WeatherInformationJson.rain
            weatherValues.cloudCover = WeatherInformationJson.cloud_cover
            weatherValues.windGusts = WeatherInformationJson.wind_gusts_10m
            weatherValues.interval = WeatherInformationJson.interval
            weatherValues.windDirection = WeatherInformationJson.wind_direction_10m
        }

        return weatherValues
    }
}
