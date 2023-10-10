//
//  MainView.swift
//  OneMoreTurn
//
//  Created by Zhang, Mark on 30/9/2023.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            CurrentGameView()
                .tabItem {
                    Label("Tonight", systemImage: "figure.soccer")
                }
            BillboardView()
                .tabItem {
                    Label("History", systemImage: "chart.line.uptrend.xyaxis")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "list.dash")
                }
        }
    }
}

#Preview {
    MainView()
}
