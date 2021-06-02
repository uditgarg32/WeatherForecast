//
//  ViewController.swift
//  WeatherForecast
//
//  Created by Udit Garg on 5/29/21.
//

import UIKit
import Foundation
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate {

    //Declare Outlets for UI
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var ForecastButton: UIButton!
    @IBOutlet weak var ForecastTableView: UITableView!
    
    let apiKey = "f0c61ea48d14c9621a17a7558d10c4ce"

    //Declare variables to hold data needed to call the API
    var city: String = ""
    var lat: Double = 0.0
    var lon: Double = 0.0
    
    //Declare arrays to hold the forecast data for each day
    var tempMax = [Double]()
    var tempMin = [Double]()
    var DayOfWeek = [TimeInterval]()
    var Descriptions = [String]()
    var WeatherIcons = [String]()
    
    //Declare the decoded response as type ForecastData
    var response : ForecastData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI setup
        cityTextField.delegate = self
        self.ForecastButton.layer.cornerRadius = 10
        
        //Establish TableView delegate and datasource
        ForecastTableView.delegate = self
        ForecastTableView.dataSource = self
        
        //Ensure that arrays of forecast data are cleared so new forecast data can be pulled
        tempMax.removeAll()
        tempMin.removeAll()
        Descriptions.removeAll()
        WeatherIcons.removeAll()
        DayOfWeek.removeAll()
    }
    
    //Converts icon identifier into weather icon png to display
    func getWeatherIcon(icon: String) -> String {
        
        var iconName: String = ""
        switch icon {
        case "01d","01n":
            iconName = "clear"
        case "02d","02n":
            iconName = "partly-cloudy"
        case "03d", "03n", "04d", "04n":
            iconName = "cloudy"
        case "09d", "09n", "10d", "10n":
            iconName = "rain"
        case "11d", "11n":
            iconName = "thunderstorms"
        case "13d", "13n":
            iconName = "snow"
        case "50d", "50n":
            iconName = "fog"
        default:
            iconName = ""
        }
        return iconName
    }
    
    //Converts unix date into official date and isolates the day of the week
    func convertDate(date: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        let dateString = dateFormatter.string(from: date)
        
        let target = dateString.firstIndex(of: "y")!
        let dayName = dateString[...target]
        
        return String(dayName)
    }
    
    //IMPORTANT: Updates ForecastTableView with Forecast data of city entered
    //Uses for loop to iterate through each day and assigns data to labels accordingly
    func updateTableView() {
        
        for i in 0...4 {
            let indexPath = IndexPath(row: i, section: 0)
            //Dispatch allows reference to cell outside of tableview function
            DispatchQueue.main.async {
                let cell = self.ForecastTableView.cellForRow(at: indexPath) as! ForecastTableViewCell
                cell.TempMax.text = String(self.tempMax[i])
                cell.TempMin.text = String(self.tempMin[i])
                cell.Description.text = self.Descriptions[i]
                cell.WeatherIcon.image = UIImage(named: "\(self.getWeatherIcon(icon: self.WeatherIcons[i])).png")
                cell.DayName.text = self.convertDate(date: self.DayOfWeek[i])
            }
        }
    }
    
    // Decodes JSON Data and stores values in Forecast Data Arrays
    func decodeJSONData(JSONData: Data) {
        
        //Initialize response to the decoded Forecast Data
        response = try! JSONDecoder().decode(ForecastData.self, from: JSONData)
        
        //Use for loops to access each data type and add values to forecast data arrays
        for i in response.daily {
            tempMax.append(i.temp.max)
            tempMin.append(i.temp.min)
            DayOfWeek.append(i.dt)
            for j in i.weather {
                Descriptions.append(j.description)
                WeatherIcons.append(j.icon)
            }
        }
        //Update the table view with the forecast data for the decoded city
        updateTableView()
    }
    
    //Starts a URL session with the Open Weather Map API to get the data
    func accessJSONData(url: URL?) {
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            
            //Handle errors
            guard let data = data else {
                print("Error : No Response")
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("HTTP Response Error")
                return
            }
            
            if let error = error {
                print("Error : \(error.localizedDescription)")
            }
            
            //Call function to decode JSON data based upon the weather model
            self.decodeJSONData(JSONData: data)
        }
        task.resume()
    }

    //Allows user to control when they want to get the forecast data
    @IBAction func getForecast(_ sender: Any) {
        
        //Set the city equal to the user inputed text
        city = cityTextField.text!
        
        //Ensure Forecast Data arrays are clear so new data can be appended
        tempMax.removeAll()
        tempMin.removeAll()
        Descriptions.removeAll()
        WeatherIcons.removeAll()
        DayOfWeek.removeAll()
        
        //If no city has been entered alert the user
        if(city.isEmpty == true) {
            let alert = UIAlertController(title: "Please enter an existing city", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        
        //Calls function below to geocode city into longitude/latitude coordinates used in API Call
        getCoordinateFrom(address: city) { coordinate, error in
            guard let coordinate = coordinate, error == nil else { return }
            self.lat = coordinate.latitude
            self.lon = coordinate.longitude
            print(self.lat)
            print(self.lon)
            
            //Set url to the API Call with the necessary parameters
            let url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(self.lat)&lon=\(self.lon)&exclude=current,minutely,hourly,alerts&appid=\(self.apiKey)&units=imperial")
            
            //Access, Decode, and Parse JSON Data into the Forecast Table View
            self.accessJSONData(url: url)
        }
    }
    
    //Geocodes the city into a coordinate
    func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1) }
    }
    
    // Hides the keyboard after the user is done editing the textfield.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
    
//Initializes Forecast Table View with 5 rows, a reuseable identifier, and constant height
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ForecastTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ForecastTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
    
    
   
    


