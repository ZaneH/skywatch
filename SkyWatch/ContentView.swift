//
//  ContentView.swift
//  SwiftUI2
//
//  Created by Zane Helton on 6/10/23.
//

import SwiftUI
import CoreData

class ContentViewModel: ObservableObject {
    @Published var selectedFolder: String = "All"
    @Published var selectedItem: String?
    
    @Published var stations: [Station] = []
    
    @Published var folders = [
        "All": [],
        "Favorites": ["KFJK"]
    ]
    
    private var favorites: [Favorite]
    
    init(favorites: [Favorite]) {
        self.favorites = favorites
        
        fetchStations()
        loadFavorites()
    }
    
    func fetchStations() {
        AviationAPI().fetchStations { [weak self] result in
            DispatchQueue.main.async {
                self?.stations = result
                self?.folders["All"] = self?.stations.map { $0.icaoId }
            }
        }
    }
    
    func loadFavorites() {
        folders["Favorites"] = favorites.map { $0.icaoId! }
    }
    
    func isFavorite(_ item: String) -> Bool {
        return favorites.contains { $0.icaoId == item }
    }
    
    func toggleFavorite(_ item: String) {
        if let index = favorites.firstIndex(where: { $0.icaoId == item }) {
            favorites.remove(at: index)
        } else {
            let newFavorite = Favorite(context: PersistenceController.shared.container.viewContext)
            newFavorite.icaoId = item
            favorites.append(newFavorite)
        }
        
        try? PersistenceController.shared.container.viewContext.save()
        loadFavorites()
    }
}

struct ContentView: View {
    @StateObject private var viewModel: ContentViewModel
    @State private var visibility: NavigationSplitViewVisibility = .all
    
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(sortDescriptors: []) private var favorites: FetchedResults<Favorite>
    
    init() {
        let favorites = PersistenceController.shared.favorites
        let viewModel = ContentViewModel(favorites: favorites)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $visibility) {
            SidebarView(selectedFolder: $viewModel.selectedFolder, folders: viewModel.folders)
                .navigationTitle("Sidebar")
        } content: {
            ListView(selectedItem: $viewModel.selectedItem, items: viewModel.folders[viewModel.selectedFolder, default: []])
                .navigationTitle(viewModel.selectedFolder)
                .navigationSplitViewColumnWidth(250)
        } detail: {
            DetailView(selectedItem: viewModel.selectedItem, stations: viewModel.stations, isFavorite: viewModel.isFavorite, toggleFavorite: viewModel.toggleFavorite)
        }
        .navigationSplitViewStyle(.balanced)
    }
}

struct SidebarView: View {
    @Binding var selectedFolder: String
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
    let isFavorite: (String) -> Bool
    let toggleFavorite: (String) -> Void
    
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
                                    Button(action: {
                                        toggleFavorite(selectedItem)
                                    }) {
                                        if isFavorite(selectedItem) {
                                            Image(systemName: "star.fill")
                                        } else {
                                            Image(systemName: "star")
                                        }
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
