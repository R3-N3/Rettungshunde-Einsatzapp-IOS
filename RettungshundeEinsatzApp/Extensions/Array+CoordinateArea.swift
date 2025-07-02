//
//  Untitled.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 02.07.25.
//

import Foundation
import CoreLocation

extension Array where Element == CLLocationCoordinate2D {
    /// Berechnet den Flächeninhalt in Quadratmetern (approx.) mithilfe der Shoelace-Formel und Erdradius
    func calculateArea() -> Double {
        guard self.count > 2 else { return 0.0 }
        
        let radius = 6378137.0 // Erdradius in Metern (WGS84)
        var area: Double = 0.0
        
        for i in 0..<self.count {
            let p1 = self[i]
            let p2 = self[(i + 1) % self.count]
            
            let lat1 = p1.latitude * .pi / 180
            let lat2 = p2.latitude * .pi / 180
            let lon1 = p1.longitude * .pi / 180
            let lon2 = p2.longitude * .pi / 180
            
            area += (lon2 - lon1) * (2 + sin(lat1) + sin(lat2))
        }
        
        area = -(area * radius * radius / 2)
        return abs(area)
    }
}
