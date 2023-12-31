//
//  ForecastView.swift
//  SwiftUI2
//
//  Created by Zane Helton on 6/11/23.
//

import SwiftUI

struct ForecastView: View {
    let station: Station
    
    var body: some View {
        VStack {
            HStack {
                Text("\(self.station.icaoId)")
                    .font(.largeTitle)
                    .bold()
                    .frame(alignment: .leading)
                
                Text("–").padding(.horizontal, 4)
                
                Text("\(self.station.state), \(self.station.country)")
                    .font(.title)
                
                Spacer()
                
                Group {
                    Image(systemName: "location.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                    
                    
                    Text("\(self.station.latitude.formatted(.number)), \(self.station.longitude.formatted(.number))")
                        .font(.title)
                        .frame(alignment: .trailing)
                        .textSelection(.enabled)
                }
            }
            .padding()
            .frame(minWidth: 380)
            
            ForecastBodyView(station: self.station)
            
            Spacer(minLength: 0)
        }
    }
}
