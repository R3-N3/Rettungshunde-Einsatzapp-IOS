//
//  Untitled.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 28.06.25.
//

import Foundation

extension String {
    var securityLevelText: String {
        switch self {
        case "1":
            return "(1) Einsatzkraft"
        case "2":
            return "(2) Zugführer"
        case "3":
            return "(3) Administrator"
        default:
            return "Unbekannt"
        }
    }
}
