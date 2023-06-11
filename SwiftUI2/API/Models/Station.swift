//
//  Station.swift
//  SwiftUI2
//
//  Created by Zane Helton on 6/11/23.
//

import Foundation

struct Station: Codable, Identifiable, Equatable {
    var id = UUID()
    let idNum: String
    let icaoId: String
    let faaId: String
    let elevation: Int
    let latitude: Double
    let longitude: Double
    let state: String
    let country: String
    let siteType: String
    
    private enum CodingKeys: String, CodingKey {
        case idNum
        case icaoId
        case faaId
        case elevation = "elev"
        case latitude = "lat"
        case longitude = "lon"
        case state
        case country
        case siteType
    }
    
    static func == (lhs: Station, rhs: Station) -> Bool {
        lhs.icaoId == rhs.icaoId
    }
}
