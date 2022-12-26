//
//  Magnitude.swift
//  earthquake
//
//  Created by Kaylee Williams on 26/12/2022.
//

import SwiftUI

struct Magnitude: View {
    let quake: Feature
    let mapView: Bool
    @State var mag: Double = 0.0
    
    var body: some View {
        if let mag = quake.properties?.mag! {
            Text("\((quake.properties?.mag)!)".prefix(3))
                .frame(width: mapView ? 48 : 40, height: mapView ? 48 : 40)
                .font(.system(size: mapView ? 20 : 16, weight: .bold))
                .foregroundColor(mag < 3.0 ? .white : mag < 4.0 ? .yellow : mag < 5.0 ? .orange : .red)
                .background(Color(.darkGray))
                .cornerRadius(100)
        }
    }
}
