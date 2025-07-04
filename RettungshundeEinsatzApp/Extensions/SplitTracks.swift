//
//  SplitTracks.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 04.07.25.
//

import CoreLocation

extension Array where Element == CLLocationCoordinate2D {
    
    func splitSegments(maxDistance: CLLocationDistance) -> [[CLLocationCoordinate2D]] {
        guard self.count > 1 else { return [self] }
        
        var segments: [[CLLocationCoordinate2D]] = []
        var currentSegment: [CLLocationCoordinate2D] = [self.first!]
        
        for i in 1..<self.count {
            let prev = self[i - 1]
            let curr = self[i]
            let loc1 = CLLocation(latitude: prev.latitude, longitude: prev.longitude)
            let loc2 = CLLocation(latitude: curr.latitude, longitude: curr.longitude)
            let distance = loc1.distance(from: loc2)
            
            if distance > maxDistance {
                segments.append(currentSegment)
                currentSegment = [curr]
            } else {
                currentSegment.append(curr)
            }
        }
        
        if !currentSegment.isEmpty {
            segments.append(currentSegment)
        }
        
        return segments
    }
}
