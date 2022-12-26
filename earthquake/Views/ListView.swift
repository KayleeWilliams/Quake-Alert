//
//  ListView.swift
//  earthquake
//
//  Created by Kaylee Williams on 20/12/2022.
//

import Foundation
import SwiftUI

struct ListView: View {
    @EnvironmentObject var api: APIClient
    
    var body: some View {
            NavigationStack {
                if let features = api.quakeSummary?.features {
                    List(features.indices, id: \.self) { index in
                        NavigationLink(value: index) {
                            EarthquakeItem(feature: features[index])
                                .environmentObject(api)
                        }
                    }
                    .navigationDestination(for: Int.self) { index in
                        MapView(selectedFeature: features[index], apiClient: api)
                        .environmentObject(api)
                }
            }
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
        
//    func getCountry() {
//        api.getLocation(coords: (feature.geometry?.coordinates)!) { res in
//            if res != nil {
//                self.title = "\((res?[0])!), \((res?[1])!)"
//            }
//        }
//    }
    
    var body: some View {
        HStack() {
            Image("FlagPlaceholder")
                .resizable()
                .frame(width: 24, height: 18)
            VStack(alignment: .leading) {
                Text(self.title)
//                    .onAppear{getCountry()}
                    .fontWeight(.semibold)
                
                Text((feature.properties?.place!)!)
                Text(getDate())

            }
            Spacer()
            Magnitude(quake: feature, mapView: false)
//            HStack {
//                Text("\((feature.properties?.mag!)!)".prefix(3))
//                    .fontWeight(.bold)
//                    .frame(width: 40, height: 40)
//                    .foregroundColor(.yellow)
//                    .background(Color(.darkGray))
//                    .cornerRadius(100)
//                //                    Image(systemName: "chevron.right")
//            }
        }
        
    }
}
