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
        HStack {
            VStack {
                HStack {
                    Text("\(self.station.icaoId)")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("\(self.station.state), \(self.station.country)")
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                ForecastBodyView(station: self.station)
                
                Spacer()
            }.padding()
            
            Spacer()
        }
    }
}
