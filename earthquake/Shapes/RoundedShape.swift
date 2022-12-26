//
//  RoundedShape.swift
//  earthquake
//
//  Created by Kaylee Williams on 26/12/2022.
//

import SwiftUI

struct RoundedShape: Shape {
    let corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: 24, height: 24))
        return Path(path.cgPath)
    }
}
