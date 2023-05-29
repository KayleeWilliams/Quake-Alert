//
//  MagnitudeFilter.swift
//  earthquake
//
//  Created by Kaylee Williams on 14/05/2023.
//

import Foundation
import SwiftUI

enum Rating: String, CaseIterable {
    case all = "All"
    case threePlus = "3.0+"
    case fourPlus = "4.0+"
    case fivePlus = "5.0+"
}

struct MagnitudeFilter: View {
    @Binding var selectedRating: Rating
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Filter By Magnitude")
                .font(.system(size: 18, weight: .bold))
            HStack(spacing: 8) {
                ForEach(Rating.allCases, id: \.self) { rating in
                    Button(action: {
                        self.selectedRating = rating
                    }) {
                        Text(rating.rawValue)
                            .font(.system(size: 16, weight: .bold))
                    }
                    .frame(width: 48, height: 48)
                    .foregroundColor(self.selectedRating == rating ? Color("DarkestGreen") : .black)
                    .background(self.selectedRating == rating ? Color("Selected") : Color("Cream"))
                    .cornerRadius(100)
                }
            }
        }
    }
}
