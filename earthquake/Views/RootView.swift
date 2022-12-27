//
//  RootView.swift
//  earthquake
//
//  Created by Kaylee Williams on 20/12/2022.
//

import SwiftUI



struct RootView: View {
    @StateObject var api = APIClient()
    @State var selectedTab = Tabs .timeline
    @State var quakes: [Feature] = []

    var body: some View {
        VStack {
            if selectedTab == .timeline {
                ListView(api: api)
            } else if selectedTab == .map {
                MapView(selectedFeature: nil, apiClient: api, quakes: $quakes)
                    .environmentObject(api)
                    .onAppear{self.quakes = api.quakeSummary?.features ?? []}
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
