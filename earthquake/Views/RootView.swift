//
//  RootView.swift
//  earthquake
//
//  Created by Kaylee Williams on 20/12/2022.
//

import SwiftUI
import MapKit

struct RootView: View {
    @StateObject var api = APIClient()
    @State var selectedTab = Tabs .timeline
    @State var quakes: [Feature] = []
    
    // Initilise values for UserDefaults
    let defaultValues: [String: Any] = [
        "mapType": 0
    ]
    
    let preferences = UserDefaults.standard

    // Display view based on which tab is active from tabview
    var body: some View {
        VStack {
            if selectedTab == .timeline {
                ListView(preferences: .constant(preferences), api: api)
            } else if selectedTab == .map {
                MapView(selectedFeature: nil, apiClient: api, quakes: $quakes, preferences: .constant(preferences))
                    .environmentObject(api)
                    .onAppear{self.quakes = api.quakeSummary?.features ?? []}
            } else if selectedTab == .settings {
                SettingsView(preferences: .constant(preferences))
            }
            Spacer()
            TabBar(selectedTab: $selectedTab)
        }   
        .background(Color("DarkGreen"))
        .onAppear{
            // Set default values and sync
            preferences.register(defaults: defaultValues)
            preferences.synchronize()
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
