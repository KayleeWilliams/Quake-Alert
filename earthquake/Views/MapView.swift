//
//  MapView.swift
//  earthquake
//
//  Created by Kaylee Williams on 20/12/2022.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var api: APIClient
    @State private var mapRegion: MKCoordinateRegion
    @State var quakes: [Feature] = []
    @State var selectedFeature: Feature?
    @State var selectedLocation: SelectedLocation = SelectedLocation(city: nil, country: nil, countryCode: nil)

    init(selectedFeature: Feature?, apiClient: APIClient) {
        self.selectedFeature = selectedFeature
        self.api = apiClient

        var center = CLLocationCoordinate2D(latitude: 51.5, longitude: -0.12) // FUTURE USER LOCATION
        if selectedFeature != nil {
            center = CLLocationCoordinate2D(latitude: (selectedFeature!.geometry?.coordinates![1])!, longitude: (selectedFeature!.geometry?.coordinates![0])!)
        }
        self.mapRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    }
    
    func getDate(epoch: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(epoch/1000))
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return formatter.string(from: date)
    }
    
    func formatCoords(latitude: Double, longitude: Double) -> String {
        let latDegrees = Int(latitude)
        let latMinutes = Int((latitude - Double(latDegrees)) * 60)
        let latSeconds = ((latitude - Double(latDegrees)) * 3600) - (Double(latMinutes) * 60)

        let lonDegrees = Int(longitude)
        let lonMinutes = Int((longitude - Double(lonDegrees)) * 60)
        let lonSeconds = ((longitude - Double(lonDegrees)) * 3600) - (Double(lonMinutes) * 60)

        let latString = String(format: "%d° %d' %.1f\" %@",
                               abs(latDegrees), abs(latMinutes), latSeconds, latitude >= 0 ? "N" : "S")
        let lonString = String(format: "%d° %d' %.1f\" %@",
                               abs(lonDegrees), abs(lonMinutes), lonSeconds, longitude >= 0 ? "E" : "W")

        return "\(latString), \(lonString)"
    }
    
    func getLocation() {
        if selectedFeature != nil {
            self.api.getLocation(coords: (selectedFeature?.geometry?.coordinates)!) { city, country, code in
                self.selectedLocation.city = city
                self.selectedLocation.country = country
                self.selectedLocation.countryCode = code
            }
        }
    }
    
    var body: some View {
        VStack(spacing: -32) {
            if self.selectedFeature != nil {
                VStack {
                    VStack(spacing: 6) {
                        if selectedLocation.city != nil && selectedLocation.country != nil {
                            Text("\((selectedLocation.city)!), \((selectedLocation.country)!)")
                                .font(.system(size: 18, weight: .bold))
                        } else if selectedLocation.country != nil {
                            Text("\((selectedLocation.country)!)")
                                .font(.system(size: 18, weight: .bold))
                        } else  {
                            Text("")
                            Text("\((selectedFeature?.properties?.title)!)".dropFirst(8))
                                .font(.system(size: 18, weight: .bold))
                        }
                        
                        if selectedLocation.country != nil {
                            Text("\((selectedFeature?.properties?.title)!)".dropFirst(8))
                                .font(.system(size: 18, weight: .light))
                        }
                    }
                    .foregroundColor(.white)
                    .offset(y: self.selectedLocation.countryCode != nil ? 0 : -32)
                    if self.selectedLocation.countryCode != nil {
                        AsyncImage(url: URL(string: "https://countryflagsapi.com/png/\(selectedLocation.countryCode ?? String("GB"))"), content: { returnedImage in
                            if let returnedImage = returnedImage.image {
                                returnedImage
                                    .resizable()
                                    .cornerRadius(100)
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 100)
                                            .stroke(Color("DarkGreen"), lineWidth: 4)
                                    )
                            } else {
                                Rectangle()
                                    .cornerRadius(100)
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 100)
                                            .stroke(Color("DarkGreen"), lineWidth: 4)
                                    )
                            }
                        })
                    }
                }
                .zIndex(1)
                .onAppear{getLocation()}
                // Causes Warning: Modifying state during view update, this will cause undefined behavior.

            }
            Spacer()

            Map(coordinateRegion: $mapRegion, annotationItems: quakes) { quake in
//                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: (quake.geometry?.coordinates![1])!, longitude: (quake.geometry?.coordinates![0])!)) {
//                    MarkerView()
//                }
                MapMarker(coordinate: CLLocationCoordinate2D(latitude: (quake.geometry?.coordinates![1])!, longitude: (quake.geometry?.coordinates![0])!))
            }
            .offset(y: 32)
            .overlay(
                self.selectedFeature != nil ? quakeDetails: nil,
                  alignment: .bottom
            )
        }
        .onAppear{
            self.quakes = api.quakeSummary?.features ?? []
            getLocation()
        }
        .background(Color("DarkGreen"))
    }
    
    private var quakeDetails: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                HStack() {
                    Image(systemName: "clock")
                        .frame(width: 24, height: 24)
                    Text(getDate(epoch: (selectedFeature?.properties?.time)!))
                        .font(.system(size: 16, weight: .regular))
                    
                }
                HStack() {
                    Image(systemName: "location")
                        .frame(width: 24, height: 24)
                    Text(formatCoords(latitude: (selectedFeature?.geometry?.coordinates![1])!, longitude: (selectedFeature?.geometry?.coordinates![0])!))
                        .font(.system(size: 16, weight: .regular))
                    
                }
                HStack() {
                    Image(systemName: "arrow.down.to.line")
                        .frame(width: 24, height: 24)
                    if let depth = selectedFeature?.geometry?.coordinates![2] {
                        Text("\(String(format: "%.1f", depth)) km depth")
                            .font(.system(size: 16, weight: .regular))
                    }
                }
            }
            .foregroundColor(.black)
            Spacer()
            Magnitude(quake: (selectedFeature)!, mapView: true)
        }

        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("Cream"))
        .clipShape(RoundedShape(corners: [.topLeft, .topRight]))
    }
}

struct MarkerView: View {
    var body: some View {
        Rectangle()
            .frame(width: 10, height: 10)
            .foregroundColor(Color.red)
    }
}

struct SelectedLocation {
    var city: String?
    var country: String?
    var countryCode: String?
}
