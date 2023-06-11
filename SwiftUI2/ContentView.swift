//
//  ContentView.swift
//  SwiftUI2
//
//  Created by Zane Helton on 6/10/23.
//

import SwiftUI

struct ContentView: View {
    @State private var visibility: NavigationSplitViewVisibility = .all
    @State private var selectedFolder: String = "All"
    @State private var selectedItem: String?
    
    @State private var folders = [
        "All": [],
        "Favorites": [
            "KFJK"
        ]
    ]
    
    var body: some View {
        NavigationSplitView(columnVisibility: $visibility) {
            List(selection: $selectedFolder) {
                ForEach(Array(folders.keys.sorted()), id: \.self) { folder in
                    NavigationLink(value: folder) {
                        Text(verbatim: folder)
                    }
                }
            }
            .navigationTitle("Sidebar")
        } content: {
            List(selection: $selectedItem) {
                ForEach(folders[selectedFolder, default: []], id: \.self) { item in
                    NavigationLink(value: item) {
                        Text(verbatim: item)
                    }
                }
            }
            .navigationTitle(selectedFolder)
            .navigationSplitViewColumnWidth(150)
        } detail: {
            NavigationStack {
                ZStack {
                    if let selectedItem {
                        ForecastView(icaoId: selectedItem)
                            .toolbar {
                                ToolbarItem(placement: .navigation) {
                                    Text(selectedItem)
                                }
                                
                                ToolbarItem(placement: .primaryAction) {
                                    Button(role: .none) {
                                        visibility = .detailOnly
                                    } label: {
                                        Image(systemName: "plus")
                                        Text("Add to Favorites")
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
        .navigationSplitViewStyle(.balanced)
        .onAppear() {
            AviationAPI().fetchStations(completion: { result in
                folders["All"] = result.map { $0.icaoId }
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
