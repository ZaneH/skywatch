//
//  FilterSettingsView.swift
//  SkyWatch
//
//  Created by Zane Helton on 7/16/23.
//

import SwiftUI

struct FilterSettingsView: View {
    @AppStorage("statesFilter") private var statesFilter: String = ""
    @AppStorage("countriesFilter") private var countriesFilter: String = ""
    
    var body: some View {
        VStack {
            Form {
                TextField("Filter by state(s)", text: $statesFilter, prompt: Text("CA, NY, WY"))
                Text("Narrow stations to these US states or Canadian provinces.")
                    .foregroundStyle(.gray)
                    .font(.caption)
                
                TextField("Filter by countries", text: $countriesFilter, prompt: Text("US, AU, UK"))
                Text("Narrow stations to these two-letter country abbreviations.")
                    .foregroundStyle(.gray)
                    .font(.caption)
            }.padding()
            
            Spacer()
        }
    }
}
