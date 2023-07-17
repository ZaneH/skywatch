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
import MapKit

class ForecastBodyViewModel: ObservableObject {
    @Published var station: Station?
    @Published var metar: METAR?
    @Published var selectedSegment = 0
    @Published var isLoadingMetar: Bool = false
    
    var flightCategoryCode: String? {
        guard let metar = metar else {
            return nil
        }
        
        return MetarTaf.shared.getFlightCategory(metar.rawString)
    }
    
    var formattedFlightCategory: String {
        guard let flightCategoryCode = flightCategoryCode else {
            return "N/A"
        }
        
        return MetarTaf.shared.formatFlightCategory(flightCategoryCode)
    }
    
    var flightCategoryColor: Color {
        switch flightCategoryCode {
        case "VFR":
            return Color.green
        case "MVFR":
            return Color.blue
        case "IFR":
            return Color.red
        case "LIFR":
            return Color.pink
        default:
            return Color.gray
        }
    }
    
    var formattedVisibility: String {
        guard let metar = metar else {
            return "N/A"
        }
        
        return MetarTaf.shared.formatVisibility(metar.rawString)
    }
    
    var formattedAltimeter: String {
        guard let metar = metar else {
            return "N/A"
        }
        
        return "\(metar.altimeter.value) \(metar.altimeter.unit)"
    }
    
    func loadData() {
        guard let icaoId = station?.icaoId else { return }
        
        metar = nil
        
        self.isLoadingMetar = true
        AviationAPI.shared.fetchMetarString(icaoId: icaoId) { metarString in
            Task {
                let metar = await MetarTaf.shared.parseMetar(metarString!)
                DispatchQueue.main.async {
                    self.metar = metar
                    self.isLoadingMetar = false
                }
            }
        }
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
        VStack {
            if let metar = viewModel.metar {
                ScrollView(.vertical) {
                    VStack {
                        Group {
                            HStack(spacing: 0) {
                                Text("Display mode")
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
                            
                            Spacer()
                                .frame(height: 32)
                        }
                        
                        Group {
                            Text("Overview")
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider()
                            
                            WrappingHStack(lineSpacing: 12) {
                                ImageWidget(imageName: "sunrise.fill", heading: "Sunrise", subheading: getSunriseSunset().0, color: .yellow)
                                ImageWidget(imageName: "sunset", heading: "Sunset", subheading: getSunriseSunset().1, color: .yellow)
                                ImageWidget(imageName: "mountain.2.fill", heading: "Elevation", subheading: "\(station.elevation) feet", color: .gray)
                                if (metar.wind != nil) {
                                    ImageWidget(
                                        imageName: "location.north.fill",
                                        heading: "Wind",
                                        subheading: "\(metar.wind?.degrees ?? 0)° @ \(metar.wind?.speed ?? 0) knots",
                                        color: .gray,
                                        rotation: metar.wind?.degrees ?? 0 + 180
                                    )
                                }
                                ImageWidget(imageName: "airplane.circle.fill", heading: "Flight Category", subheading: viewModel.formattedFlightCategory, color: viewModel.flightCategoryColor)
                                ImageWidget(imageName: "eye.fill", heading: "Visibility", subheading: viewModel.formattedVisibility, color: .gray)
                                ImageWidget(imageName: "arrow.up.and.down", heading: "Altimeter", subheading: viewModel.formattedAltimeter, color: .gray)
                            }.frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                                .frame(height: 32)
                        }
                        
                        Group {
                            Text("Temperatures")
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider()
                            
                            WrappingHStack(lineSpacing: 12) {
                                if (metar.temperature != nil) {
                                    ImageWidget(imageName: "thermometer.sun.fill", heading: "Temperature", subheading: "\(metar.temperature ?? 0)°C", color: .red)
                                }
                                
                                if (metar.dewPoint != nil) {
                                    ImageWidget(imageName: "thermometer.snowflake", heading: "Dewpoint", subheading: "\(metar.dewPoint ?? 0)°C", color: .blue)
                                }
                                
                                if (metar.temperature == nil && metar.dewPoint == nil) {
                                    Text("No temperature data found. Inspect the raw METAR to double-check.")
                                        .foregroundColor(.gray)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }.frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                                .frame(height: 32)
                        }
                        
                        Group {
                            HStack(alignment: .top) {
                                if (metar.clouds.count > 0) {
                                    VStack {
                                        Text("Wind")
                                            .font(.title2)
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Divider()
                                        
                                        Text(MetarTaf.shared.formatClouds(metar.rawString))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Spacer()
                                            .frame(height: 32)
                                    }
                                }
                                
                                VStack {
                                    Text("Map")
                                        .font(.title2)
                                        .bold()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Divider()
                                    
                                    MapEmbed(region: MKCoordinateRegion(
                                        center: CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude),
                                        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                                    ))
                                    
                                    Spacer()
                                        .frame(height: 32)
                                }
                            }
                        }
                        
                        Group {
                            Text("Raw Description")
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider()
                            
                            Text(metar.description)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }.padding()
                }
            } else {
                if (viewModel.isLoadingMetar) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 44, height: 44)
                } else {
                    Text("There was an issue loading data from this station. This is to be expected for some stations.")
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
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
