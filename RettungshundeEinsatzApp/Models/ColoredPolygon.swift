//
//  Untitled.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 01.07.25.
//

import MapKit

class ColoredPolygon: MKPolygon {
    var color: UIColor?
    var name: String?
}

class AreaAnnotation: MKPointAnnotation {
    var color: UIColor?
    var area: Areas? // ➡️ Referenz zur CoreData Area Entity
}
