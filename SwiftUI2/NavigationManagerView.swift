//
//  NavigationManagerView.swift
//  SwiftUI2
//
//  Created by Zane Helton on 6/11/23.
//

import SwiftUI

struct NavigationManagerView: View {
    // 1
    @State var sideBarVisibility: NavigationSplitViewVisibility = .doubleColumn
    
    var body: some View {
        // 2
        NavigationSplitView(columnVisibility: $sideBarVisibility) {
            Text("Users")
        // 3
        } detail: {
            Text("Test")
        }
    }
}
