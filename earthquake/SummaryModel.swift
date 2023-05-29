//
//  SummaryModel.swift
//  earthquake
//
//  Created by Kaylee Williams on 20/12/2022.
//

import Foundation

struct SummaryModel: Codable {
//    let type: String?
//    let metadata: Metadata?
    let features: [Feature]?
//    let bbox: [Double]?
}

// MARK: - Feature
struct Feature: Codable, Identifiable {
    let type: FeatureType?
    let properties: Properties?
    let geometry: Geometry?
    let id: String?
}

// MARK: - Geometry
struct Geometry: Codable {
    let type: GeometryType?
    let coordinates: [Double]?
}

enum GeometryType: String, Codable {
    case point = "Point"
}

// MARK: - Properties
struct Properties: Codable {
    let mag: Double?
    let place: String
    let time, updated: Int?
//    let tz: JSONNull?
    let url: String
    let detail: String?
    let felt: Int?
    let cdi: Double?
//    let mmi, alert: JSONNull?
    let status: Status?
    let tsunami, sig: Int?
    let net, code, ids, sources: String?
    let types: String?
    let nst: Int?
    let dmin: Double?
    let rms: Double?
    let gap: Double?
//    let magType: MagType?
//    let type: PropertiesType?
    let title: String?
}

enum MagType: String, Codable {
    case md = "md"
    case ml = "ml"
}

enum Status: String, Codable {
    case automatic = "automatic"
    case reviewed = "reviewed"
}

enum PropertiesType: String, Codable {
    case earthquake = "earthquake"
    case quarryBlast = "quarry blast"
}

enum FeatureType: String, Codable {
    case feature = "Feature"
}

struct Metadata: Codable {
    let generated: Int?
    let url: String?
    let title: String?
    let status: Int?
    let api: String?
    let count: Int?
}
