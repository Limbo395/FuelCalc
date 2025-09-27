//
//  RootTabs.swift
//  FuelCalc
//
//  Created by Максим Гайдук on 26.09.2025.
//

import SwiftUI

struct RootTabs: View {
    var body: some View {
        TabView {
            RawMassView()
                .tabItem {
                    Label("Робоча", systemImage: "flame")
                }
            
            OilView()
                .tabItem {
                    Label("Мазут", systemImage: "drop.fill")
                }
            
            HelpView()
                .tabItem {
                    Label("Довідка", systemImage: "book")
                }
        }
        .tint(.primary)
    }
}

#Preview {
    RootTabs()
}
