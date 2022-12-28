//
//  SettingsView.swift
//  earthquake
//
//  Created by Kaylee Williams on 28/12/2022.
//

import SwiftUI
import MapKit

struct SettingsView: View {
    @Binding var preferences: UserDefaults
    @State var mapType: MKMapType
    @State var showFaultLines: Bool = false
    @State private var notifications: Bool = false
    @State private var notificationMag: Double = 3.0
    
    // Set selected values based on UserDefault data
    init(preferences: Binding<UserDefaults>) {
        self._preferences = preferences
        self.mapType = MKMapType(rawValue: UInt(preferences.wrappedValue.integer(forKey: "mapType")))!
    }
    
    var body: some View {
        List {
            Section(header:
                Text("Notifications")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                ) {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "bell.fill")
                        Toggle("Push Notifications", isOn: $notifications)
                    }
                    VStack(alignment: .leading, spacing: -2) {
                        Text("Magnitude")
                        Slider(value: $notificationMag, in: 1.0...5.0, step: 0.5)
                            .tint(.red)

                        }
                    Text("Notifications for quakes ≥ \(notificationMag, specifier: "%.1f")")
                        .font(.system(size: 16, weight: .light))
                }
                .listRowBackground(Color("Cream"))
            }
                
            Section(header:
                        Text("Map Settings")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            ) {
                Picker("Map Type", selection: $mapType) {
                    Text("Standard").tag(MKMapType.standard)
                    Text("Satellite").tag(MKMapType.satellite)
                    Text("Hybrid").tag(MKMapType.hybrid)
                }
                .foregroundColor(.black)
                .tint(.black)
                .pickerStyle(.menu)
                .listRowBackground(Color("Cream"))
                Toggle("Fault Lines", isOn: $showFaultLines)
                    .listRowBackground(Color("Cream"))
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.automatic)
        .foregroundColor(.black)
        .background(Color("DarkGreen"))
        // Listen for changes and update the UserDefault
        .onChange(of: mapType) { newType in
            self.preferences.set(self.mapType.rawValue, forKey: "mapType")
            preferences.synchronize()
        }
    }
}

