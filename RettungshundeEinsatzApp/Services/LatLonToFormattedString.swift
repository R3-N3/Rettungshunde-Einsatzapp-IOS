//
//  Untitled.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 29.06.25.
//

func latLonToFormattedString(latitude: Double, longitude: Double) -> String {
    let latDirection = latitude >= 0 ? "N" : "S"
    let lonDirection = longitude >= 0 ? "O" : "W"

    let latAbs = abs(latitude)
    let lonAbs = abs(longitude)

    let latString = String(format: "%.5f", latAbs).replacingOccurrences(of: ".", with: ",")
    let lonString = String(format: "%.5f", lonAbs).replacingOccurrences(of: ".", with: ",")

    return "\(latDirection) \(latString)° \n   \(lonDirection) \(lonString)°"
}


func latToFormattedString(latitude: Double) -> String {
    let latDirection = latitude >= 0 ? "N" : "S"

    let latAbs = abs(latitude)

    let latString = String(format: "%.5f", latAbs).replacingOccurrences(of: ".", with: ",")

    return "\(latDirection) \(latString)°"
}

func lonToFormattedString(longitude: Double) -> String {
    let lonDirection = longitude >= 0 ? "O" : "W"

    let lonAbs = abs(longitude)

    let lonString = String(format: "%.5f", lonAbs).replacingOccurrences(of: ".", with: ",")

    return "\(lonDirection) \(lonString)°"
}
