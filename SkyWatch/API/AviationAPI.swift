//
//  AviationAPI.swift
//  SwiftUI2
//
//  Created by Zane Helton on 6/11/23.
//

import Foundation

class AviationAPI: ObservableObject {
    static let shared = AviationAPI()
    
    @Published var stations: [Station] = []
    
    func fetchStations(completion: @escaping([Station]) -> ()) {
        guard let url = URL(string: "https://beta.aviationweather.gov/cgi-bin/data/stationinfo.php?format=json") else {
            print("Invalid URL for fetching station data")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            let result = try! JSONDecoder().decode([Station].self, from: data!)
            
            DispatchQueue.main.async {
                completion(result)
                self.stations = result
            }
        }.resume()
    }
    
    func fetchMetarString(icaoId: String, completion: @escaping(String?) -> ()) {
        guard let url = URL(string: "https://beta.aviationweather.gov/cgi-bin/data/metar.php?ids=\(icaoId)") else {
            print("Invalid URL for fetching METAR string")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                completion(String(data: data!, encoding: .utf8)?.filter {
                    !"\n".contains($0)
                } ?? nil)
            }
        }.resume()
    }
}
