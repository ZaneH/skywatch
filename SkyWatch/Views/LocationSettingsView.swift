//
//  LocationSettingsView.swift
//  SkyWatch
//
//  Created by Zane Helton on 7/16/23.
//

import SwiftUI

struct LocationSettingsView: View {
    @State var stateFilter: String = ""
    
    var body: some View {
//        Text("Location Settings")
//            .font(.title)
        VStack {
            Form {
                TextField("Filter by state(s)", text: $stateFilter, prompt: Text("CA, NY, WY"))
                Text("Narrow stations to these US states or Canadian provinces.")
                    .foregroundStyle(.gray)
                    .font(.caption)
                
                TextField("Filter by countries", text: $stateFilter, prompt: Text("US, AU, UK"))
                Text("Narrow stations to these two-letter country abbreviations.")
                    .foregroundStyle(.gray)
                    .font(.caption)
            }.padding()
            
            Spacer()
        }
    }
}
