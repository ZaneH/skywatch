//
//  ForecastBodyView.swift
//  SwiftUI2
//
//  Created by Zane Helton on 6/11/23.
//

import SwiftUI
import Solar
import CoreLocation
import WrappingHStack

class ForecastBodyViewModel: ObservableObject {
    @Published var station: Station?
    @Published var metar: METAR?
    @Published var selectedSegment = 0
    
    func loadData() {
        guard let icaoId = station?.icaoId else { return }
        
        metar = nil
        
        AviationAPI.shared.fetchMetarString(icaoId: icaoId) { metarString in
            Task {
                let metar = await MetarTaf.shared.parseMetar(metarString!)
                DispatchQueue.main.async {
                    self.metar = metar
                }
            }
        }
    }
}

struct ImageWidget: View {
    let imageName: String
    let heading: String
    let subheading: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(color)
                .font(.system(size: 34))
            
            VStack(spacing: 4) {
                Text(heading)
                    .font(.headline)
                    .bold()
                
                Text(subheading)
                    .font(.subheadline)
                    .bold()
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.25))
        .cornerRadius(8)
        .fixedSize()
    }
}

struct ForecastBodyView: View {
    let station: Station
    @StateObject private var viewModel: ForecastBodyViewModel
    
    init(station: Station) {
        self.station = station
        self._viewModel = StateObject(wrappedValue: ForecastBodyViewModel())
    }
    
    func getSunriseSunset() -> (String, String) {
        let solar = Solar(for: Date(), coordinate: CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude))
        let sunrise = solar?.sunrise?.formatted(date: .omitted, time: .shortened)
        let sunset = solar?.sunset?.formatted(date: .omitted, time: .shortened)
        
        return (sunrise ?? "N/A", sunset ?? "N/A")
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text("METAR/TAF")
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Picker("", selection: $viewModel.selectedSegment) {
                Text("METAR").tag(0)
                Text("TAF").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color.secondary.opacity(0.25))
        .cornerRadius(8)
        
        VStack {
            if let metar = viewModel.metar {
                ScrollView(.vertical) {
                    VStack {
                        Text("Overview")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider()
                        
                        WrappingHStack(lineSpacing: 12) {
                            ImageWidget(imageName: "sunrise.fill", heading: "Sunrise", subheading: getSunriseSunset().0, color: .yellow)
                            ImageWidget(imageName: "sunset", heading: "Sunset", subheading: getSunriseSunset().1, color: .yellow)
                            ImageWidget(imageName: "mountain.2.fill", heading: "Elevation", subheading: "\(station.elevation) feet", color: .gray)
                            ImageWidget(imageName: "location.fill", heading: "Coordinates", subheading: "\(station.latitude), \(station.longitude)", color: .blue)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                            .frame(height: 32)
                        
                        Text("Description")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider()
                        
                        Text(metar.description)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.top)
        .onAppear {
            viewModel.station = station
            viewModel.loadData()
        }
        .onChange(of: station) { newValue in
            viewModel.station = newValue
            viewModel.loadData()
        }
    }
}
