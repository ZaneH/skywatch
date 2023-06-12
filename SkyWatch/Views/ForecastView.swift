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
                Text("\(self.station.icaoId)")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForecastBodyView(station: self.station)
                
                Spacer()
            }.padding()
            
            Spacer()
        }
    }
}
