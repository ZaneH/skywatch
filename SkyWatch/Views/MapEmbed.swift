//
//  MapEmbed.swift
//  SkyWatch
//
//  Created by Zane Helton on 6/11/23.
//

import MapKit
import SwiftUI

struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct MapEmbed: View {
    @State private var region: MKCoordinateRegion
    private var pinLocation: CLLocationCoordinate2D
    
    init(region: MKCoordinateRegion) {
        self.region = region
        self.pinLocation = region.center
    }
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [MapAnnotationItem(coordinate: self.pinLocation)]) { item in
            MapMarker(coordinate: item.coordinate, tint: .red)
        }
            .frame(height: 200)
            .cornerRadius(8)
    }
}
