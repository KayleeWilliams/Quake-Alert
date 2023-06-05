//
//  ListView.swift
//  earthquake
//
//  Created by Kaylee Williams on 20/12/2022.
//

import Foundation
import SwiftUI

struct ListView: View {
    @Binding var preferences: UserDefaults
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var locationManager: LocationManager

    @State private var selectedRating = Rating.all
    @State var isLoading: Bool = false

    // Filter the quakes based on magnitude
    private var filteredQuakes: [Feature] {
        api.quakes.reversed().filter { quake in
            if selectedRating == .all {
                return true
            } else {
                return quake.properties?.mag ?? 0.0 >= Double(selectedRating.rawValue.dropLast())!
            }
        }
    }
    
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack() {
                    Spacer()
                    Text("QuakeAlert")
                        .font(.system(size: 24, weight: .bold))
                    Spacer()
                }
                Spacer()
                MagnitudeFilter(selectedRating: $selectedRating)
                    .padding([.leading], 16)
                    .padding([.bottom], 8)
                
                if isLoading {
                    Text("Loading...")
                        .onAppear{
                            if api.quakes.count == 0 {
                                self.isLoading.toggle()
                            }
                        }
                    
                } else {
                    Group {
                        List(filteredQuakes.indices , id: \.self) { index in
                            NavigationLink(value: index) {
                                EarthquakeItem(feature: filteredQuakes[index])
                                    .environmentObject(api)
                            }
                            .foregroundColor(.black)
                            .listRowBackground(Color("Cream"))
                        }
                        .listStyle(.plain)
                        .background(Color("Cream"))
                        .clipShape(RoundedShape(corners: [.topLeft, .topRight]))
                        .frame(maxHeight: 560)
                        .navigationDestination(for: Int.self) { index in
                            MapView(selectedFeature: filteredQuakes[index], preferences: .constant(preferences))
                                .environmentObject(api)
                        }
                    }
                }
            }.background(Color("DarkGreen"))
        }
    }
}

struct EarthquakeItem: View {
    @EnvironmentObject var api: APIClient
    @State private var title: String = ""
    @State var date: String = ""
    let feature: Feature
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Get the time of earthquake & how long ago it was
    func timeSinceDate() -> String {
        let epoch = feature.properties?.time!
        let date = Date(timeIntervalSince1970: TimeInterval(epoch!/1000))
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let time = timeFormatter.string(from: date)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .short
        
        // Format the time interval between the date and now
        let interval = Date().timeIntervalSince(date)
        let intervalString = formatter.string(from: interval)!
        
        return "\(time) (\(intervalString) ago)"
    }
    
    var body: some View {
        HStack() {
            VStack(alignment: .leading) {
                Text(feature.properties!.place)
                    .font(.system(size: 16, weight: .semibold))
                Text(self.date)
            }
            .onAppear() {
                self.date = self.timeSinceDate()
            }
            .onReceive(self.timer) { time in
                // When recievedm update date
                self.date = self.timeSinceDate()
            }
            Spacer()
            Magnitude(quake: feature, mapView: false)
            
        }
        
    }
}

