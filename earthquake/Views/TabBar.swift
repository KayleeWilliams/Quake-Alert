//
//  TabBar.swift
//  earthquake
//
//  Created by Kaylee Williams on 24/12/2022.
//

import SwiftUI


enum Tabs: Int {
    case timeline = 0
    case map = 1
}

struct TabBar: View {
    @Binding var selectedTab: Tabs
    
    var body: some View {
        HStack(alignment: .center) {
            Button(action: { selectedTab = .timeline}) {
                GeometryReader { geo in
                    VStack(alignment: .center) {
                        Image(systemName: "list.bullet")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(selectedTab == .timeline ? Color("Selected") : .white)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
            }
            
            Button(action: {selectedTab = .map}) {
                GeometryReader { geo in
                    VStack(alignment: .center) {
                        Image(systemName: "map")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(selectedTab == .map ? Color("Selected") : .white)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
            }
        }
        .frame(height: 24)
        .padding(.top, 10)
        .background(Color("DarkGreen"))
    }
}

