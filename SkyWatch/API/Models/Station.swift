//
//  Station.swift
//  SwiftUI2
//
//  Created by Zane Helton on 6/11/23.
//

import Foundation

struct Station: Codable, Identifiable, Equatable, Hashable {
    var id = UUID()
    var idNum: String
    var icaoId: String
    var faaId: String
    var elevation: Int
    var latitude: Double
    var longitude: Double
    var state: String
    var country: String
    var siteType: String
    
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
    
    init(id: UUID = UUID()) {
        self.id = id
        self.idNum = ""
        self.icaoId = ""
        self.faaId = ""
        self.elevation = 0
        self.latitude = 0
        self.longitude = 0
        self.state = ""
        self.country = ""
        self.siteType = ""
    }
    
    static func == (lhs: Station, rhs: Station) -> Bool {
        lhs.icaoId == rhs.icaoId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.icaoId)
    }
}
