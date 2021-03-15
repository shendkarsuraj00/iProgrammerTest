//
//  APIHelper.swift
//  iProgrammerTestSuraj
//
//  Created by ASIPL0035_Suraj on 15/03/21.
//

import Foundation
import Alamofire

import CoreData
/**
 This class is used to handle the various almofire methods used for calling API.
 */
class APIHelper {
    
    
    /**
     * Private static reference to the shared instance.
     */
    private static var sharedInstance: APIHelper = {
        let APIHelperObj = APIHelper()
        return APIHelperObj
    }()
    
    /**
     * Dispatch queue for creating thread-safe access to shared variables.
     */
    private let internalQueue = DispatchQueue(label: "APIHelperQueue", qos: .default,
                                              attributes: .concurrent)
    /**
     * Shared instance of the [APIHelper] class.
     */
    class func shared() -> APIHelper {
        return sharedInstance
    }
    
    /**
     * Public init, you know the drill ;]
     */
    public init() {}
    
    public let serverURL = "http://api.openweathermap.org/data/2.5/weather?"
    
    public let appId = "8da93cf6ae725964b54973109c307608"
    
    /// Callback from API response
    public typealias responseCallback = (responseResult) -> Void
    
    public enum responseResult {
        
        case success(APIResponse)
        
        case failure(Int, String)
    }
    
    /**
     This function is used to call post request with empty header API using almofire
     - Parameters:
        - serverURL: API URL
        - parameter: parameter required for API
        - header: header string for authentication
        - callback: to handle the API response
     */
    func callPostRequest(serverURL: String, parameter: [String:Any], header: [String:String]?, callback: @escaping responseCallback) {
        
        
        let request = Alamofire.request(serverURL, method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: nil)
        request.validate().responseJSON { (response) in
            
            guard response.error == nil else {
                
                print(response.error!)
                callback(.failure(401, "The Internet connection appears to be offline. Please check your Internet"))
                return
            }
            guard let data = response.data else {
                print("No Data")
                callback(.failure(0,"Unable to get response."))
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(APIResponse.self, from: data)
                print(response)
                if response.name != ""  {
                    
                    callback(.success(response))
                }
            } catch {
                print(error)
            }
        }
    }
    
    /**
     This function is used to update data in data base
     */
    func updateData(cityName: String, temp: String, lastSearched: String) {
        
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Weather")
        let predicate = NSPredicate(format: "city = '\(cityName)'")
        fetchRequest.predicate = predicate
        do
            {
                let object = try managedContext.fetch(fetchRequest)
                if object.count == 1
                {
                    let objectUpdate = object.first as! NSManagedObject
                    objectUpdate.setValue(cityName, forKey: "city")// User token
                    objectUpdate.setValue(temp, forKey: "temperature") // Flag to indicate user is signup with facebook
                    objectUpdate.setValue(lastSearched, forKey: "lastSearched") // Flag to indicate tutorial screen showed to user.
                    do{
                        try managedContext.save()
                    }
                    catch
                    {
                        print(error)
                    }
                }
            }
        catch
        {
            print(error)
        }
    }
    
    /**
     This function is used to update data in data base
     */
    func saveData(cityName: String, temp: String, lastSearched: String) {
        
        
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Weather",
                                       in: managedContext)!
        
        let object = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
        
        // 3
        object.setValue(cityName, forKey: "city")
        object.setValue(temp, forKey: "temperature")
        object.setValue(lastSearched, forKey: "lastSearched")
        
        // 4
        do {
            try managedContext.save()
           
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    /**
     This function is used to get data from database.
     - Parameters:
        - userid: User id
     */
    func getData(cityName: String) -> NSManagedObject? {
        
        var user: NSManagedObject?
        
        //1
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return user
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        //2
          let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Weather")
       
        let predicate = NSPredicate(format: "city = '\(cityName)'")
        fetchRequest.predicate = predicate
        
        //3
        do {
            let data = try managedContext.fetch(fetchRequest)
            
            //if data.count == 1 {
                
                user = data.first
            //}
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return user
    }
    
    /**
     This function is used to delete specific data from database.
     */
    func deleteData(cityName: String) {
        
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Weather")
        let predicate = NSPredicate(format: "city = '\(cityName)'")
        fetchRequest.predicate = predicate
        do
            {
                let object = try managedContext.fetch(fetchRequest)
                if object.count == 1
                {
                    let objectUpdate = object.first as! NSManagedObject
                    managedContext.delete(objectUpdate)
                    do{
                        try managedContext.save()
                    }
                    catch
                    {
                        print(error)
                    }
                }
            }
        catch
        {
            print(error)
        }
    }
    
    /**
     This function is used to delete all data from data base
     */
    func deleteAllData() {
        
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Weather")
        
        do
            {
                let result = try managedContext.fetch(fetchRequest)
                
                for object in result {
                    guard let objectData = object as? NSManagedObject else {continue}
                    managedContext.delete(objectData)
                }
                
                do{
                    try managedContext.save()
                }
                catch
                {
                    print(error)
                }
            }
        catch
        {
            print(error)
        }
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
