//
//  WeatherViewModel.swift
//  iProgrammerTestSuraj
//
//  Created by ASIPL0035_Suraj on 15/03/21.
//

import Foundation
import RxSwift
import CoreData

class WeatherViewModel {
    
    /// A publisher to notify the weather data come from API.
    public let data : PublishSubject<WeatherData> = PublishSubject()
    
    /// A publisher to notify the weather data come from DB.
    public let dataFromDB : PublishSubject<[WeatherData]> = PublishSubject()
    
    /// A publisher to notify the error come from API.
    public let error : PublishSubject<(String, Int)> = PublishSubject()
    
    
    /**
     This function used to get weather details from API.
     - Parameters:
     - cityName: User entered city name.
     */
    public func getWeatherData(cityName: String) {
        
        let url = APIHelper.shared().serverURL + "q=\(cityName)&appid=\(APIHelper.shared().appId)"
        APIHelper.shared().callPostRequest(serverURL: url, parameter: [:], header: nil) { (result) in
            
            switch result {
            case .success(let response):
                
                /// Convert temp from kelvin into celsius
                var temp = ""
                if let kelvinTemp = response.main?.temp {
                    let celsiusTemp = kelvinTemp - 273.15
                    temp = String(format: "%.0f", celsiusTemp)
                }
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy hh:mm"
                dateFormatter.calendar = Calendar.current
                dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
                
                let obj = WeatherData(cityName: response.name, temp: temp, latSearched: dateFormatter.string(from: date))
                
                /// Save data in DB
                APIHelper.shared().saveData(cityName:  response.name ?? "", temp: temp, lastSearched: dateFormatter.string(from: date))
                
                /// Send data to subscriber of this view model
                self.data.onNext(obj)
               
            case .failure(let errorCode,let message):
                self.error.onNext((message, errorCode))
            }
            
        }
    }
    
    /**
     This function is used to fetch all records from DB.
     */
    public func getDataFromDatabase() {
                
        //1
        let appDelegate =
                UIApplication.shared.delegate as? AppDelegate
        
        let managedContext =
            appDelegate?.persistentContainer.viewContext
        //2
          let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Weather")
       

        
        //3
        do {
            let result = try managedContext?.fetch(fetchRequest)
            var records = [WeatherData]()
            for data in result! {
                
                let obj = WeatherData(cityName: data.value(forKey: "city") as? String, temp: data.value(forKey: "temperature") as? String, latSearched: data.value(forKey: "lastSearched") as? String)
                records.append(obj)
                print(obj)
            }
            /// Send data to subscriber of this view model
            self.dataFromDB.onNext(records)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
}
