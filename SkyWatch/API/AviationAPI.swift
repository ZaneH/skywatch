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
    
    private func splitCSV(string: String) -> [String] {
        return string.replacingOccurrences(of: " ", with: "").components(separatedBy: ",").filter({ $0 != "" })
    }
    
    func fetchStations(statesFilter: String, countriesFilter: String, completion: @escaping([Station]) -> ()) {
        let statesFilterTokens = splitCSV(string: statesFilter)
        let countriesFilterTokens = splitCSV(string: countriesFilter)
        
        var qsValue = "\(statesFilterTokens.map({ "@\($0)," }).joined())\(countriesFilterTokens.map({ "~\($0)," }).joined())"
        if (qsValue.count == 0) {
            qsValue = "~us"
        }
        
        guard let url = URL(string: "https://www.aviationweather.gov/adds/dataserver_current/httpparam?dataSource=stations&requestType=retrieve&format=xml&stationString=\(qsValue)") else {
            print("Invalid URL for fetching station data")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            let parser = StationsXMLParser()
            let xmlParser = XMLParser(data: data!)
            xmlParser.delegate = parser
            xmlParser.parse()
            
            DispatchQueue.main.async {
                completion(parser.stations)
                self.stations = parser.stations.sorted(by: { a, b in
                    a.icaoId < b.icaoId
                })
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
