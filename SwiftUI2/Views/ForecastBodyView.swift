//
//  ForecastBodyView.swift
//  SwiftUI2
//
//  Created by Zane Helton on 6/11/23.
//

import SwiftUI

struct ForecastBodyView: View {
    let icaoId: String
    
    @State var metarString: String?
    @State var metar: METAR?
    
    var body: some View {
        VStack {
            if let metar = self.metar {
                Text(metar.description)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }.onChange(of: icaoId) { newValue in
            loadData(icaoId: newValue)
        }.onAppear {
            loadData(icaoId: self.icaoId)
        }
    }
    
    func loadData(icaoId: String) {
        self.metar = nil
        
        AviationAPI.shared.fetchMetarString(icaoId: icaoId) { metarString in
            self.metarString = metarString
            
            Task {
                let metar = await MetarTaf.shared.parseMetar(metarString!)
                DispatchQueue.main.async {
                    self.metar = metar
                }
            }
        }
    }
}
