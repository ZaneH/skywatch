//
//  StationsXMLParser.swift
//  SkyWatch
//
//  Created by Zane Helton on 7/17/23.
//

import Foundation

class StationsXMLParser: NSObject, XMLParserDelegate {
    private var _stations: [Station] = []
    private var currentStation: Station? = nil
    private var currentProperty: String = ""
    
    var stations: [Station] {
        Array(Set(_stations.filter {
            $0.siteType.contains("METAR") ||
            $0.siteType.contains("TAF")
        }))
    }
    
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String : String] = [:]
    ) {
        switch elementName.lowercased() {
        case "station_id":
            if (self.currentStation != nil) {
                self._stations.append(currentStation!)
            }
            
            currentStation = Station.init()
            break
        case "metar":
            self.currentStation?.siteType.append("METAR,")
            break
        case "taf":
            self.currentStation?.siteType.append("TAF,")
            break
        default:
            break
        }
        
        currentProperty = elementName
    }
    
    func parser(
        _ parser: XMLParser,
        foundCharacters string: String
    ) {
        if (string.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
            switch self.currentProperty {
            case "station_id":
                self.currentStation?.icaoId = string
                break
            case "latitude":
                self.currentStation?.latitude = Double(string) ?? 0.0
                break
            case "longitude":
                self.currentStation?.longitude = Double(string) ?? 0.0
                break
            case "elevation_m":
                self.currentStation?.elevation = Int(string) ?? 0
                break
            case "state":
                self.currentStation?.state = string
                break
            case "country":
                self.currentStation?.country = string
                break
            default:
                break
            }
        }
    }
}
