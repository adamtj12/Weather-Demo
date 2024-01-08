//  AdamSampleProject

import UIKit
import CoreData

class WeatherTableViewModel: TableViewModel {
    var title: String = ""
    var cellIdentifier: String = NibNameValue
    var cellIdentifierSearch: String = NibNameValueSearch
    weak var containingVC: UIViewController!
    var rowSelectedAction: TableViewRowSelectedAction?
    var weatherData: [NSManagedObject] = []
    var geoLocations: [Geolocation] = []
    
    let apiClient = APIClient()
    
    init() {
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func leftBarButtonItems() -> [UIBarButtonItem] {
        return [UIBarButtonItem.init()]
    }
    
    func rightBarButtonItems() -> [UIBarButtonItem] {
        return []
    }
    
    func getCellNibs() -> [(nib: UINib, identifier: String)]? {
        let nib = UINib(nibName: FieldCollectionViewCell.getNibName(), bundle: nil)
        let nibSearch = UINib(nibName: FieldCollectionViewCell.getNibNameSearch(), bundle: nil)
        
        return [(nib, cellIdentifier), (nibSearch, cellIdentifierSearch)]
    }
    
    func titleForSection(_ section: Int) -> String {
        return "Weather"
    }
    
    func getGeolocation(text: String) {
        apiClient.send(GetGeometrics(search: text), endpoint: APIDeclarations.init().geoLocationEndpointUrl) { [self] response in
            _ = response.map { dataContainer in                
                syncMainThread {
                    if let vc = self.containingVC as? WeatherInformationViewController {
                        if let geoObject = dataContainer as? [ Geolocation] {
                            geoLocations = geoObject
                            vc.searchView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func performDataGetterAndSetter(geolocation: Geolocation) {
        apiClient.send(GetWeatherInformation(lat: Float(geolocation.lat) ?? 0.0, long: Float(geolocation.lon) ?? 0.0), endpoint: APIDeclarations.init().baseEndpointUrl) { [self] response in
            _ = response.map { dataContainer in
                print(dataContainer)
                
                weatherData.removeAll()
                
                if let geoObject = dataContainer as? Current {
                    CoreDataHelper.mainContext().delete((WeatherInformation.mapFromDictionaryOfObjects(geoObject, context: CoreDataHelper.mainContext())))
                    weatherData.append(WeatherInformation.mapFromDictionaryOfObjects(geoObject, context: CoreDataHelper.mainContext()))
                }
                
                syncMainThread {
                    if let vc = self.containingVC as? WeatherInformationViewController {
                        vc.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func refreshValues() {
        weatherData.removeAll()
        getGeolocation(text: " ")
    }
    
    func configureCellForWeather(_ cell: DefaultTableViewCell, object: [WeatherInformation], indexPath: IndexPath) -> DefaultTableViewCell {
        guard let weatherCell = cell as? VerticleTitleTwoSubTitleTableViewCell else {
            return cell
        }
        
        let weatherInformation = object[indexPath.row]
        weatherCell.tempLabel.text = "Temperature :  " + String(weatherInformation.temperature) + "(C)"
        weatherCell.cloudCoverLabel.text = "Cloud Cover :  " + String(weatherInformation.cloudCover)
        weatherCell.rainLabel.text = "Rain:  " + String(weatherInformation.rain)
        weatherCell.apparentTempLabel.text = "Apparent Temp :  " + String(weatherInformation.apparentTemperature) + "(C)"
        weatherCell.intervalLabel.text = "Interval :  " + String(weatherInformation.interval)
        weatherCell.windGustsLabel.text = "Wind Gusts :  " + String(weatherInformation.windGusts) + "(MPH)"
        weatherCell.windDirectionLabel.text = "Wind Direction : " + String(weatherInformation.windDirection) + "(MPH)"
        return weatherCell
    }
    
    func configureCellForSearch(_ cell: DefaultTableViewCell, object: [Geolocation], indexPath: IndexPath) -> DefaultTableViewCell {
        guard let weatherCell = cell as? SearchTableViewCell else {
            return cell
        }
        let geolocation = object[indexPath.row]
        weatherCell.titleLabel.text = String(geolocation.display_name)
        return weatherCell
    }
    
    
    func handleDidSelectOnTable(indexPath: IndexPath) {
        let object = geoLocations[indexPath.row]
        performDataGetterAndSetter(geolocation: object)
        if let weatherVC = containingVC as? WeatherInformationViewController {
            weatherVC.tableView.reloadData()
            weatherVC.locationEntryField.endEditing(true)
        }
    }
    
    func getHeight(_ indexPath: IndexPath, object: NSManagedObject?) -> CGFloat {
        return 70
    }
}
