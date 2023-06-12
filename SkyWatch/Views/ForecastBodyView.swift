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

struct ImageWidget: View {
    let imageName: String
    let heading: String
    let subheading: String
    let color: Color
    var rotation: Int = 0
    
    init(imageName: String, heading: String, subheading: String, color: Color) {
        self.imageName = imageName
        self.heading = heading
        self.subheading = subheading
        self.color = color
    }
    
    init(imageName: String, heading: String, subheading: String, color: Color, rotation: Int) {
        self.imageName = imageName
        self.heading = heading
        self.subheading = subheading
        self.color = color
        self.rotation = rotation
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: imageName)
                .aspectRatio(contentMode: .fill)
                .foregroundColor(color)
                .font(.system(size: 32))
                .rotationEffect(Angle(degrees: Double(self.rotation)))
            
            VStack(spacing: 4) {
                Text(heading)
                    .font(.headline)
                    .bold()
                
                Text(subheading)
                    .font(.subheadline)
                    .bold()
            }
        }
        .frame(height: 52) // Set a fixed width for the widget
        .padding()
        .background(Color.secondary.opacity(0.25))
        .cornerRadius(8)
        .fixedSize(horizontal: false, vertical: true)
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
                                ImageWidget(imageName: "location.north.fill", heading: "Wind", subheading: "\(metar.wind.degrees ?? 0)° @ \(metar.wind.speed) knots", color: .gray, rotation: metar.wind.degrees ?? 0 + 180)
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
                                ImageWidget(imageName: "thermometer.sun.fill", heading: "Temperature", subheading: "\(metar.temperature)°C", color: .red)
                                ImageWidget(imageName: "thermometer.snowflake", heading: "Dewpoint", subheading: "\(metar.dewPoint)°C", color: .blue)
                            }.frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                                .frame(height: 32)
                        }
                        
                        Group {
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
                        
                        Group {
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
                        
                        Group {
                            Text("Raw Description")
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider()
                            
                            Text(metar.description)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
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
