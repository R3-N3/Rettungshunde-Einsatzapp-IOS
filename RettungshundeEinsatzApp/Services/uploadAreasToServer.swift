//
//  Untitled.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 02.07.25.
//

import Foundation
import CoreData
import CoreLocation

struct UploadArea: Codable {
    var title: String
    var description: String
    var color: String
    var points: [UploadAreaPoint]
}

struct UploadAreaPoint: Codable {
    var lat: Double
    var lon: Double
}

func uploadAreasToServer(context: NSManagedObjectContext, completion: @escaping (Bool, String) -> Void) {
    print("🟢 Starte uploadAreasToServer")
    
    let defaults = UserDefaults.standard
    let serverApiURL = defaults.string(forKey: "serverApiURL") ?? ""
    let token = KeychainHelper.loadToken() ?? ""
    
    guard let url = URL(string: serverApiURL + "uploadarea") else {
        completion(false, "Invalid URL")
        return
    }
    
    guard !token.isEmpty else {
        completion(false, "Missing token")
        return
    }
    
    // ➡️ Fetch Areas mit uploadedToServer == false
    let fetchRequest: NSFetchRequest<Area> = Area.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "uploadedToServer == %@", NSNumber(value: false))
    
    do {
        let areasToUpload = try context.fetch(fetchRequest)
        
        // ➡️ Nichts zum Hochladen
        if areasToUpload.isEmpty {
            print("🟡 Keine Flächen zum hochladen")
            completion(true, "Keine Flächen zum Hochladen.")
            return
        }
        
        // ➡️ Mapping
        let uploadAreas: [UploadArea] = areasToUpload.compactMap { area in
            guard let coordsSet = area.coordinates as? Set<AreaCoordinate> else { return nil }
            let sortedCoords = coordsSet.sorted { $0.orderIndex < $1.orderIndex }
            let points = sortedCoords.map { UploadAreaPoint(lat: $0.latitude, lon: $0.longitude) }
            
            return UploadArea(
                title: area.title ?? "Unbenannt",
                description: area.desc ?? "",
                color: area.color ?? "#FF0000",
                points: points
            )
        }
        
        // ➡️ HTTP Request vorbereiten
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "token": token,
            "areas": uploadAreas.map { area in
                [
                    "title": area.title,
                    "description": area.description,
                    "color": area.color,
                    "points": area.points.map { ["lat": $0.lat, "lon": $0.lon] }
                ]
            }
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ uploadAreasToServer Error: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
                return
            }
            
            guard let data = data else {
                completion(false, "No data received")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let status = json["status"] as? String ?? "error"
                    let message = json["message"] as? String ?? "Unknown error"
                    
                    if status == "success" {
                        print("✅ Flächen erfolgreich hochgeladen: \(message)")
                        
                        // ➡️ Nach Erfolg: uploadedToServer = true setzen
                        context.perform {
                            for area in areasToUpload {
                                area.uploadedToServer = true
                            }
                            do {
                                try context.save()
                                completion(true, message)
                            } catch {
                                completion(false, "Daten gespeichert, aber CoreData Save-Fehler: \(error.localizedDescription)")
                            }
                        }
                    } else {
                        print("❌ uploadAreasToServer Failure: \(message)")
                        completion(false, message)
                    }
                } else {
                    completion(false, "Invalid JSON format")
                }
            } catch {
                print("❌ uploadAreasToServer JSON parse error: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
            }
        }
        
        task.resume()
        
    } catch {
        completion(false, "CoreData fetch error: \(error.localizedDescription)")
    }
}
