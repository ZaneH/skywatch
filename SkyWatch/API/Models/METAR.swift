//
//  METAR.swift
//  SwiftUI2
//
//  Created by Zane Helton on 6/11/23.
//

import Foundation

struct METAR: Codable, Identifiable {
    let id = UUID()
    
    let station: String
    let day: Int
    let hour: Int
    let minute: Int
    let message: String
    let remarks: [Remark]
    let clouds: [Cloud?]
    let wind: Wind?
    let visibility: Visibility
    let temperature: Int?
    let dewPoint: Int?
    let altimeter: Altimeter
    var rawString: String = ""
    
    struct Remark: Codable {
        let type: String
        let description: String?
        let raw: String
        let phenomenon: String?
        let startMin: Int?
        let endMin: Int?
        let pressure: Double?
        let amount: Double?
        let periodInHours: Int?
        let max: Double?
        let min: Double?
        let code: Int?
        let pressureChange: Double?
    }
    
    struct Cloud: Hashable, Codable {
        let quantity: String
        let height: Int
    }
    
    struct Wind: Codable {
        let speed: Int
        let direction: String
        var degrees: Int?
        let unit: String
        let minVariation: Int?
        let maxVariation: Int?
    }
    
    struct Visibility: Codable {
        let value: Double
        let unit: String
    }
    
    struct Altimeter: Codable {
        let value: Double
        let unit: String
    }
    
    private enum CodingKeys: String, CodingKey {
        case station, day, hour, minute, message, remarks, clouds, wind, visibility, temperature, dewPoint, altimeter
    }
    
    var description: String {
        var result = ""
        
        result += "Raw METAR: \(message)\n"
        result += "Station: \(station)\n"
        result += "Day: \(day), Hour: \(hour), Minute: \(minute)\n"
        
        // Append remarks
        result += "Remarks:\n"
        for remark in remarks {
            result += "  Type: \(remark.type), Description: \(remark.description ?? "N/A"), Raw: \(remark.raw)\n"
        }
        
        // Append clouds
        result += "Clouds:\n"
        for cloud in clouds {
            result += "  Quantity: \(cloud?.quantity ?? "N/A"), Height: \(cloud?.height ?? 0)\n"
        }
        
        // Append wind
        result += "Wind: Speed: \(wind?.speed ?? 0), Direction: \(wind?.direction ?? "N/A"), Degrees: \(wind?.degrees ?? 0), Unit: \(wind?.unit ?? "N/A")\n"
        
        // Append visibility
        result += "Visibility: Value: \(visibility.value), Unit: \(visibility.unit)\n"
        
        // Append temperature, dew point, and altimeter
        result += "Temperature: \(temperature ?? 0), Dew Point: \(dewPoint ?? 0)\n"
        result += "Altimeter: Value: \(altimeter.value), Unit: \(altimeter.unit)\n"
        
        return result
    }
}

