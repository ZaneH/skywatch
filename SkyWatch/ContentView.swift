//
//  ContentView.swift
//  SwiftUI2
//
//  Created by Zane Helton on 6/10/23.
//

import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var selectedFolder: String?
    @Published var selectedItem: String?
    
    @Published var stations: [Station] = []
    
    @Published var folders = [
        "All": [],
        "Favorites": ["KFJK"]
    ]
    
    init() {
        fetchStations()
    }
    
    func fetchStations() {
        AviationAPI().fetchStations { [weak self] result in
            DispatchQueue.main.async {
                self?.stations = result
                self?.folders["All"] = self?.stations.map { $0.icaoId }
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var visibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $visibility) {
            SidebarView(selectedFolder: $viewModel.selectedFolder, folders: viewModel.folders)
                .navigationTitle("Sidebar")
        } content: {
            ListView(selectedItem: $viewModel.selectedItem, items: viewModel.folders[viewModel.selectedFolder ?? "All", default: []])
                .navigationTitle(viewModel.selectedFolder ?? "All")
                .navigationSplitViewColumnWidth(250)
        } detail: {
            DetailView(selectedItem: viewModel.selectedItem, stations: viewModel.stations)
        }
        .navigationSplitViewStyle(.balanced)
    }
}

struct SidebarView: View {
    @Binding var selectedFolder: String?
    let folders: [String: [String]]
    
    var body: some View {
        List(selection: $selectedFolder) {
            ForEach(Array(folders.keys.sorted()), id: \.self) { folder in
                NavigationLink(value: folder) {
                    Text(folder)
                }
            }
        }
    }
}

struct ListView: View {
    @Binding var selectedItem: String?
    let items: [String]
    
    var body: some View {
        List(selection: $selectedItem) {
            ForEach(items, id: \.self) { item in
                NavigationLink(value: item) {
                    Text(item)
                }
            }
        }
    }
}

struct DetailView: View {
    let selectedItem: String?
    let stations: [Station]
    
    var body: some View {
        NavigationStack {
            ZStack {
                if let selectedItem = selectedItem {
                    if let selectedStation = stations.first(where: { $0.icaoId == selectedItem }) {
                        ForecastView(station: selectedStation)
                            .toolbar {
                                ToolbarItem(placement: .navigation) {
                                    Text(selectedItem)
                                }
                                ToolbarItem(placement: .primaryAction) {
                                    Button(action: {}) {
                                        Image(systemName: "plus")
                                        Text("Add to Favorites")
                                    }
                                }
                            }
                    }
                } else {
                    Text("Select a location to view its data")
                        .padding()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
