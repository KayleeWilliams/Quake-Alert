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
    
    var body: some View {
        Map(coordinateRegion: $mapRegion, annotationItems: quakes ?? []) { quake in
            MapMarker(coordinate: CLLocationCoordinate2D(latitude: (quake.geometry?.coordinates![1])!, longitude: (quake.geometry?.coordinates![0])!))
        }
    }
}
