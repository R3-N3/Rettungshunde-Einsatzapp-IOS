//
//  Untitled.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 03.07.25.
//

import CoreLocation

extension Array where Element == CLLocationCoordinate2D {
    func totalDistance() -> CLLocationDistance {
        guard count > 1 else { return 0.0 }
        var distance: CLLocationDistance = 0.0
        for i in 1..<count {
            let start = CLLocation(latitude: self[i-1].latitude, longitude: self[i-1].longitude)
            let end = CLLocation(latitude: self[i].latitude, longitude: self[i].longitude)
            distance += start.distance(from: end)
        }
        return distance
    }
}
