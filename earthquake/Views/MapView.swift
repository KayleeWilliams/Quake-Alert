//
//  MapView.swift
//  earthquake
//
//  Created by Kaylee Williams on 20/12/2022.
//

import Foundation
import SwiftUI
import MapKit
import Map

struct MapView: View {
    @EnvironmentObject var api: APIClient
    @EnvironmentObject var locationManager: LocationManager
    
    @Binding var preferences: UserDefaults
    @State private var mapRegion: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.5, longitude: -0.12), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    @State var mapType: MKMapType = MKMapType(rawValue: UInt(0))!
    @State var selectedFeature: Feature? = nil
    @State var selectedLocation: SelectedLocation = SelectedLocation(city: nil, country: nil, countryCode: nil)
    @Environment(\.dismiss)  private var dismiss
    
    
    init(selectedFeature: Feature?, preferences: Binding<UserDefaults>) {
        // Set preferences & feature
        self._preferences = preferences
        self.selectedFeature = selectedFeature
        self._selectedFeature = State(initialValue: selectedFeature)//
        
        // Set Map Type
        self.mapType = MKMapType(rawValue: UInt(preferences.wrappedValue.integer(forKey: "mapType")))!
        self._mapType = State(initialValue: MKMapType(rawValue: UInt(preferences.wrappedValue.integer(forKey: "mapType")))!)
        
        // Set map posistion
        var center: CLLocationCoordinate2D?
        if self.selectedFeature != nil {
            center = CLLocationCoordinate2D(latitude: (selectedFeature!.geometry?.coordinates![1])!, longitude: (selectedFeature!.geometry?.coordinates![0])!)
        } else {
            center = CLLocationCoordinate2D(latitude: 51.5, longitude: -0.12)
        }
        self.mapRegion = MKCoordinateRegion(center: center!, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        self._mapRegion = State(initialValue: MKCoordinateRegion(center: center!, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)))
        
    }
    
    func updateMapLocation() {
        var center: CLLocationCoordinate2D?
        
        if self.selectedFeature != nil {
            center = CLLocationCoordinate2D(latitude: (selectedFeature!.geometry?.coordinates![1])!, longitude: (selectedFeature!.geometry?.coordinates![0])!)
        } else if locationManager.location != nil {
            center = locationManager.location
        } else {
            center = CLLocationCoordinate2D(latitude: 51.5, longitude: -0.12)
        }
        self.mapRegion = MKCoordinateRegion(center: center!, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    }
    
    // Format the date to be displayed
    func getDate(epoch: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(epoch/1000))
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return formatter.string(from: date)
    }
    
    // Format coordinates to be diplayed
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
    
    // Get quake location
    func getLocation() {
        if selectedFeature != nil {
            self.api.getLocation(coords: (selectedFeature?.geometry?.coordinates)!) { city, country, code in
                self.selectedLocation.city = city
                self.selectedLocation.country = country
                self.selectedLocation.countryCode = code
            }
        }
    }
    
    // Display the map
    var body: some View {
        VStack {
            Map(coordinateRegion: $mapRegion, type: mapType, annotationItems: api.quakes, annotationContent: { quake in
                ViewMapAnnotation(coordinate: CLLocationCoordinate2D(latitude: (quake.geometry?.coordinates![1])!, longitude: (quake.geometry?.coordinates![0])!)) {
                    MarkerView(quake: quake, selectedQuake: $selectedFeature)
                        .onTapGesture {
                            self.selectedFeature = quake
                            self.getLocation()
                            self.updateMapLocation()
                        }
                }
            }
            )
            .ignoresSafeArea()
            .onAppear() {
                self.updateMapLocation()
            }
            
        }
        .background(Color("DarkGreen"))
        .navigationBarBackButtonHidden(true)
        .overlay(self.selectedFeature != nil ? quakeDetails: nil,
                 alignment: .bottom
        )
        .overlay(self.selectedFeature != nil ? quakeHeading: nil,
                 alignment: .top
        )
        .navigationBarItems(leading: BackButton(dismiss: self.dismiss), trailing: LinkButton(quake: selectedFeature))
    }
    
    // Title e.g. Earthquake Location + Image
    private var quakeHeading: some View {
        VStack(spacing: -32) {
            if self.selectedFeature != nil {
                
                VStack(spacing: 6) {
                    if selectedLocation.city != nil && selectedLocation.country != nil {
                        Text("\((selectedLocation.city)!), \((selectedLocation.country)!)")
                            .font(.system(size: 18, weight: .bold))
                    } else if selectedLocation.country != nil {
                        Text("\((selectedLocation.country)!)")
                            .font(.system(size: 18, weight: .bold))
                    } else if self.selectedLocation.countryCode  == nil  {
                        Text("\((selectedFeature?.properties?.title)!)".dropFirst(8))
                            .font(.system(size: 18, weight: .bold))
                    }
                    
                    if selectedLocation.country != nil {
                        Text("\((selectedFeature?.properties?.title)!)".dropFirst(8))
                            .font(.system(size: 18, weight: .light))
                    }
                }
                .foregroundColor(.white)
                .padding(.bottom, self.selectedLocation.countryCode == nil ? 16 : 48)
                .frame(maxWidth: .infinity)
                .background(Color("DarkGreen"))
                
                
                // Display Country Flag
                if self.selectedLocation.countryCode != nil {
                    AsyncImage(url: URL(string: "https://flagcdn.com/h60/\(selectedLocation.countryCode?.lowercased() ?? String("gb")).png"), content: { returnedImage in
                        if let returnedImage = returnedImage.image {
                            returnedImage
                                .resizable()
                                .cornerRadius(100)
                                .frame(width: 48, height: 48)
                                .aspectRatio(1.0, contentMode: .fill)
                                .clipped()
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
        }
        .onAppear { getLocation() }
    }
    
    // Show details about the quake
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
    let quake: Feature
    @Binding var selectedQuake: Feature?
    @State var animate = false
    
    // Animate the marker if selected
    func animateQuake() {
        if (self.selectedQuake != nil) {
            if (self.selectedQuake == self.quake) {
                self.animate = true
            } else {
                self.animate = false
            }
        }
    }
    
    var body: some View {
        ZStack {
            Circle().fill(.orange.opacity(0.25)).frame(width: 48, height: 48).scaleEffect(self.animate ? 1 : 0.01)
            Circle().fill(.orange.opacity(0.50)).frame(width: 32, height: 32).scaleEffect(self.animate ? 1 : 0.01)
            Circle().fill(.orange).frame(width: 16, height: 16)
        }
        .animation(animate ? Animation.easeInOut(duration: 1.75).repeatForever(autoreverses: true) : .default, value: animate)
        .onAppear() { self.animateQuake() }
        .onChange(of: self.selectedQuake ) { change in
            self.animateQuake()
        }
    }
}

struct SelectedLocation {
    var city: String?
    var country: String?
    var countryCode: String?
}

struct BackButton: View {
    let dismiss: DismissAction
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            HStack {
                Image(systemName: "chevron.left")
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
            }
        }
    }
}

struct LinkButton: View {
    let quake: Feature?
    
    var body: some View {
        if (quake != nil) {
            Link(destination: URL(string: (quake?.properties!.url)!)!) {
                HStack {
                    Image(systemName: "globe")
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

