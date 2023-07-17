//
//  SettingsView.swift
//  SkyWatch
//
//  Created by Zane Helton on 7/16/23.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            LocationSettingsView()
                .tabItem {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
        }
        .frame(width: 450, height: 250)
    }
}
