//
//  ForecastView.swift
//  SwiftUI2
//
//  Created by Zane Helton on 6/11/23.
//

import SwiftUI

struct ForecastView: View {
    let icaoId: String
    
    var body: some View {
        HStack {
            VStack {
                Text("\(self.icaoId)")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForecastBodyView(icaoId: self.icaoId)
                    .padding()
                
                Spacer()
            }.padding()
            
            Spacer()
        }
    }
}
