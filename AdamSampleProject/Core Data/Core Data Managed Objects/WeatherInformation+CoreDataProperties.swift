//  AdamSampleProject

import Foundation
import CoreData

extension WeatherInformation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeatherInformation> {
        return NSFetchRequest<WeatherInformation>(entityName: "WeatherInformation")
    }

    @NSManaged public var time: String
    @NSManaged public var interval: Float
    @NSManaged public var temperature: Float
    @NSManaged public var apparentTemperature: Float
    @NSManaged public var rain: Float
    @NSManaged public var cloudCover: Float
    @NSManaged public var windGusts: Float
    @NSManaged public var windDirection: Float

}
