//
//  ViewController.swift
//  iProgrammerTestSuraj
//
//  Created by ASIPL0035_Suraj on 15/03/21.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    /// A textField to get user input
    @IBOutlet weak var cityNameTextField: UITextField!
    
    /// A label to display City Name
    @IBOutlet weak var cityName: UILabel!
    
    /// A label to display temperature of city
    @IBOutlet weak var temperatureLabel: UILabel!
    
    /// A label to display last searched
    @IBOutlet weak var lastSearched: UILabel!

    /// A tableView to display list of last searched
    @IBOutlet weak var searchedTableView: UITableView!
    
    /// View Model
    var viewModel = WeatherViewModel()
    let disposeBag = DisposeBag()
    
    /// Array [WeatherData] to display list on tableview
    var weatherRecords = [WeatherData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        subscribeToViewModel()
        viewModel.getDataFromDatabase()
    }
    
    /**
     This function is used to subscribe to view model data
     */
    private func subscribeToViewModel() {
        
        //add observer to error
        viewModel.error.observe(on: MainScheduler.instance).subscribe(onNext: { (errorMessage, errorCode) in
        print(errorCode)
           print(errorMessage)
           
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        //add observer to error
        viewModel.data.observe(on: MainScheduler.instance).subscribe(onNext: { (data) in
            print(data)
            self.cityName.text = data.cityName
            self.lastSearched.text = data.latSearched
            self.temperatureLabel.text = data.temp
            self.viewModel.getDataFromDatabase()
            
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        //add observer to error
        viewModel.dataFromDB.observe(on: MainScheduler.instance).subscribe(onNext: { (data) in
            print(data)
            self.weatherRecords = data
            self.searchedTableView.reloadData()
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    


}

extension ViewController: UITextFieldDelegate  {

    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        /// Get data based on city name from DB
        let data = APIHelper.shared().getData(cityName: textField.text?.capitalizingFirstLetter() ?? "")
        
        if data != nil {
            
            self.cityName.text = data?.value(forKey: "city") as? String
            self.temperatureLabel.text = data?.value(forKey: "temperature") as? String
            self.lastSearched.text = data?.value(forKey: "lastSearched") as? String
        } else {
            
            /// Get data from api.
            viewModel.getWeatherData(cityName: textField.text?.capitalizingFirstLetter() ?? "")
        }
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = searchedTableView.dequeueReusableCell(withIdentifier: "records", for: indexPath) as? WeatherTableViewCell else {
            return UITableViewCell()
        }

        /// City Label
        if let cityLabel = cell.viewWithTag(100) as? UILabel {
            cityLabel.text = weatherRecords[indexPath.row].cityName
        }
        
        /// temperature Label
        if let tempLabel = cell.viewWithTag(101) as? UILabel {
            
            tempLabel.text = weatherRecords[indexPath.row].temp
            
        }
        
        /// last Searched Label
        if let lastSearched = cell.viewWithTag(102) as? UILabel {
            
            lastSearched.text = weatherRecords[indexPath.row].latSearched
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 120
    }
    
    
    
}
