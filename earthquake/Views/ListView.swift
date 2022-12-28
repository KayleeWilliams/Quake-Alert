//
//  ListView.swift
//  earthquake
//
//  Created by Kaylee Williams on 20/12/2022.
//

import Foundation
import SwiftUI


enum Rating: String, CaseIterable {
    case all = "All"
    case threePlus = "3.0+"
    case fourPlus = "4.0+"
    case fivePlus = "5.0+"
}


struct ListView: View {
    @State var api: APIClient
    @State private var selectedRating = Rating.all
    @State var quakes: [Feature] = []
    @State var isLoading: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Values", selection: $selectedRating) {
                    ForEach(Rating.allCases, id: \.self) { rating in
                        Text(rating.rawValue).tag(rating)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                Spacer()
                
                if isLoading {
                    Text("Loading...")
                        .onAppear{
                            if api.quakeSummary?.features == nil {
                                api.fetchQuakeSummary() { _ in
                                    self.quakes = api.quakeSummary?.features ?? []
                                    self.isLoading.toggle() }}
                            else {
                                self.quakes = api.quakeSummary?.features ?? []
                                self.isLoading.toggle()
                            }
                        }
                } else {
                    let filteredQuakes = api.quakeSummary?.features?.filter { feature in
                        if selectedRating == .all { return true } else {
                            return feature.properties?.mag ?? 0.0 >= Double(selectedRating.rawValue.dropLast())!
                        }
                    }
                    List(filteredQuakes?.indices ?? [].indices, id: \.self) { index in
                        NavigationLink(value: index) {
                            EarthquakeItem(feature: filteredQuakes![index])
                                .environmentObject(api)
                        }
                        .foregroundColor(.black)
                        .listRowBackground(Color("Cream"))
                    }
                    .listStyle(.plain)
                    .clipShape(RoundedShape(corners: [.topLeft, .topRight]))
                    .background(Color("DarkGreen"))
                    .frame(maxHeight: 500)
                    .navigationDestination(for: Int.self) { index in
                        MapView(selectedFeature: filteredQuakes![index], apiClient: api, quakes: $quakes)
                            .environmentObject(api)
                    }
                }
            }.background(Color("DarkGreen"))
        }
    }
}

struct EarthquakeItem: View {
    @EnvironmentObject var api: APIClient
    @State private var title: String = ""
    let feature: Feature


    func getDate() -> String {
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
//            Image("FlagPlaceholder")
//                .resizable()
//                .frame(width: 24, height: 18)
            VStack(alignment: .leading) {
//                Text(self.title)
//                    .onAppear{getCountry()}
//                    .fontWeight(.semibold)
                
                Text((feature.properties?.place!)!)
                    .font(.system(size: 16, weight: .semibold))
                Text(getDate())

            }
            Spacer()
            Magnitude(quake: feature, mapView: false)
        }
        
    }
}

