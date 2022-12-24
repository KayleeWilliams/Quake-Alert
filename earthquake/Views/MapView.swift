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
    @EnvironmentObject var api: APIClient
    @State private var mapRegion: MKCoordinateRegion
    let selectedFeature: Feature?
    
    init(selectedFeature: Feature?) {
        self.selectedFeature = selectedFeature
        var center = CLLocationCoordinate2D(latitude: 51.5, longitude: -0.12) // FUTURE USER LOCATION
        if selectedFeature != nil {
            center = CLLocationCoordinate2D(latitude: (selectedFeature!.geometry?.coordinates![1])!, longitude: (selectedFeature!.geometry?.coordinates![0])!)
        }
        self.mapRegion = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    }
    
    var quakes: [Feature]? {
        api.quakeSummary?.features
    }
    
    func getDate(epoch: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(epoch))
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return formatter.string(from: date)
    }
    
    
    var body: some View {
        VStack(spacing: -32) {
            if self.selectedFeature != nil {
                VStack {
                    Text("\((selectedFeature?.properties?.title)!)")
                        .foregroundColor(.white)
                    Image("FlagPlaceholder")
                        .resizable()
                        .cornerRadius(100)
                        .frame(width: 48, height: 48)
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(Color("DarkGreen"), lineWidth: 4)
                        )
                }
                .zIndex(1)
            }
            Spacer()
            Map(coordinateRegion: $mapRegion, annotationItems: quakes?.prefix(5) ?? []) { quake in
                //            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: (quake.geometry?.coordinates![1])!, longitude: (quake.geometry?.coordinates![0])!)) {
                //                MarkerView()
                //            }
                MapMarker(coordinate: CLLocationCoordinate2D(latitude: (quake.geometry?.coordinates![1])!, longitude: (quake.geometry?.coordinates![0])!))
            }
            .offset(y: 32)
            .overlay(
                self.selectedFeature != nil ? quakeDetails: nil,
                  alignment: .bottom
            )
        }.background(Color("DarkGreen"))
    }
    
    private var quakeDetails: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack() {
                Image(systemName: "clock")
                Text(getDate(epoch: (selectedFeature?.properties?.time)!))
            }
            HStack() {
                Image(systemName: "location")
                Text("123° 55' 36.6\" W, 40° 29' 53.4\" N")
            }
            HStack() {
                Image(systemName: "arrow.down.to.line")
                Text("6 km")
            }
        }
        .foregroundColor(.black)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
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

struct RoundedShape: Shape {
    let corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: 24, height: 24))
        return Path(path.cgPath)
    }
}
