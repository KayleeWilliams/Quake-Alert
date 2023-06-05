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
    @StateObject var locationManager = LocationManager()

    @State var selectedTab = Tabs .timeline
        
    @State private var location: CLLocation?
    

    // Initilise values for UserDefaults
    let defaultValues: [String: Any] = [
        "mapType": 0
    ]
    
    let preferences = UserDefaults.standard
    
    
    // Display view based on which tab is active from tabview
    var body: some View {
        
        VStack {
            if selectedTab == .timeline {
                ListView(preferences: .constant(preferences))
                    .environmentObject(api)
                    .environmentObject(locationManager)
            } else if selectedTab == .map {
                MapView(selectedFeature: nil, preferences: .constant(preferences))
                    .environmentObject(api)
                    .environmentObject(locationManager)
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
            locationManager.getLocation()
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
