//
//  Pages.swift
//  earthquake
//
//  Created by Kaylee Williams on 20/12/2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject var apiClient = APIClient()

    var body: some View {
        TabView {
            ListView()
                .environmentObject(apiClient)
                .tabItem {Label("", systemImage: "list.bullet")}
            
            MapView()
                .tabItem {
                    Label("", systemImage: "map")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
