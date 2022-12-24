//
//  RootView.swift
//  earthquake
//
//  Created by Kaylee Williams on 20/12/2022.
//

import SwiftUI



struct RootView: View {
    @StateObject var apiClient = APIClient()
    @State var selectedTab = Tabs .timeline
    
    var body: some View {
        VStack {
            if selectedTab == .timeline {
                ListView()
                    .environmentObject(apiClient)
            } else if selectedTab == .map {
                MapView(selectedFeature: nil)
                    .environmentObject(apiClient)
            }
            Spacer()
            TabBar(selectedTab: $selectedTab)
        }
        .background(Color("DarkGreen"))
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
