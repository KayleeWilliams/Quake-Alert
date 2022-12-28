//
//  APIClient.swift
//  earthquake
//
//  Created by Kaylee Williams on 20/12/2022.
//

import Foundation
import CoreLocation

class APIClient: ObservableObject {
    @Published var quakeSummary: SummaryModel?

    init() {
        self.quakeSummary = nil
        self.updateQuakeSummary()
        Timer.scheduledTimer(withTimeInterval: 120, repeats: true) { timer in
            self.updateQuakeSummary()
        }
    }
    
    func updateQuakeSummary() {
        fetchQuakeSummary() { result in
            DispatchQueue.main.async {
                self.quakeSummary = result!
            }
        }
    }
    
    func getLocation(coords: [Double], completion: ((String?, String?, String?) -> Void)?) {
        let location = CLLocation(latitude: coords[1], longitude: coords[0])

        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            var city: String?
            var country: String?
            var countryCode: String?

            if let placemark = placemarks?.first {
                city = placemark.locality
                country = placemark.country
                countryCode = placemark.isoCountryCode
            }
            
            completion?(city, country, countryCode)
        }
    }
    
    func fetchQuakeSummary(completion: @escaping (SummaryModel?) -> Void) {
        let url = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/1.0_day.geojson")
        self.fetch(url: url!) { json in
            let decoder = JSONDecoder()
            do {
                let result = try decoder.decode(SummaryModel.self, from: json)
                completion(result)
            } catch { print(error) }
        
        }
    }
    
    private func fetch(url: URL, completion: @escaping (Data) -> Void) {
        // Create a URLRequest object with the URL
        let request = URLRequest(url: url)
        
        // Send request & return the data
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let data = data {
                completion(data)
            }
        }
        
        task.resume()
    }
}
