//
//  ContentView.swift
//  SwiftUI2
//
//  Created by Zane Helton on 6/10/23.
//

import SwiftUI
import CoreData

class ContentViewModel: ObservableObject {
    @Published var selectedFolder: String? = "All"
    @Published var selectedItem: String?
    
    @Published var stations: [Station] = []
    @Published var favorites: [String] = []
    
    private var viewContext: NSManagedObjectContext
    
    @Published var folders: [String: [String]] = [
        "All": [],
        "Favorites": []
    ]
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        
        fetchStations()
        fetchFavorites()
    }
    
    func fetchStations() {
        AviationAPI().fetchStations { [weak self] result in
            DispatchQueue.main.async {
                self?.stations = result
                self?.folders["All"] = self?.stations.map { $0.icaoId }
            }
        }
    }
    
    func fetchFavorites() {
        let fetchRequest: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        
        do {
            let favorites = try viewContext.fetch(fetchRequest)
            self.favorites = favorites.compactMap { $0.icaoId }
            folders["Favorites"] = self.favorites
        } catch {
            // Handle fetch error
            print("Error fetching favorites: \(error)")
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject private var viewModel: ContentViewModel
    @State private var visibility: NavigationSplitViewVisibility = .all
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Favorite.icaoId, ascending: true)],
        animation: .default)
    private var favorites: FetchedResults<Favorite>
    
    func toggleFavorite(_ icaoId: String) {
        if let index = favorites.firstIndex(where: { $0.icaoId == icaoId }) {
            viewContext.delete(favorites[index])
        } else {
            let newFavorite = Favorite(context: viewContext)
            newFavorite.icaoId = icaoId
            
            viewContext.insert(newFavorite)
        }
        
        try? viewContext.save()
        
        viewModel.fetchFavorites()
    }
    
    func isFavorite(_ icaoId: String) -> Bool {
        return favorites.contains { $0.icaoId == icaoId }
    }
    
    init() {
        let viewModel = ContentViewModel(viewContext: PersistenceController.shared.container.viewContext)
        _viewModel = StateObject(wrappedValue: viewModel)
    
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $visibility) {
            SidebarView(selectedFolder: $viewModel.selectedFolder, folders: [
                "All": viewModel.folders["All", default: []],
                "Favorites": viewModel.favorites
            ])
            .navigationTitle("Sidebar")
        } content: {
            ListView(selectedItem: $viewModel.selectedItem, items: viewModel.folders[viewModel.selectedFolder ??  "All", default: []])
                .navigationTitle(viewModel.selectedFolder ?? "All")
                .navigationSplitViewColumnWidth(250)
        } detail: {
            DetailView(selectedItem: viewModel.selectedItem, stations: viewModel.stations, toggleFavorite: toggleFavorite, isFavorite: isFavorite)
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
    let toggleFavorite: (String) -> Void
    let isFavorite: (String) -> Bool
    
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
                                        withAnimation {
                                            toggleFavorite(selectedItem)
                                        }
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
