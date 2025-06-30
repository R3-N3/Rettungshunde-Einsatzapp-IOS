//
//  Untitled.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 29.06.25.
//

import Foundation
import CoreData

struct LocationDTO: Codable {
    let id: Int64
    let userId: Int64
    let latitude: String
    let longitude: String
    let timestamp: String
    let accuracy: Int16

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case latitude
        case longitude
        case timestamp
        case accuracy
    }
}


func downloadAllGpsLocations(
    context: NSManagedObjectContext,
    completion: @escaping (Bool, String) -> Void
) {
    print("🟢 Starte downloadAllGpsLocations")
    
    let defaults = UserDefaults.standard
    let serverApiURL = defaults.string(forKey: "serverApiURL") ?? ""
    let token = KeychainHelper.loadToken() ?? ""
    
    guard let url = URL(string: serverApiURL + "downloadalluserlocation") else {
        completion(false, "Invalid URL")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    let bodyParams = "token=\(token)"
    request.httpBody = bodyParams.data(using: .utf8)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("❌ downloadAllGpsLocations Error: \(error.localizedDescription)")
            completion(false, error.localizedDescription)
            return
        }
        
        guard let data = data else {
            completion(false, "No data received")
            return
        }
        
        do {
            // 🔍 Debug: Server Response als String ausgeben
            /*if let jsonString = String(data: data, encoding: .utf8) {
                print("🔍 Server Response JSON: \(jsonString)")
            } else {
                print("⚠️ Server Response konnte nicht als String decodiert werden")
            }*/
            
            let decodedResponse = try JSONDecoder().decode(ApiResponse<[LocationDTO]>.self, from: data)
            let status = decodedResponse.status
            let message = decodedResponse.message ?? ""
            
            if status == "success" {
                let locationList = decodedResponse.data
                
                context.perform {
                    // 🔴 Alte Locations löschen
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = AllUserGPSData.fetchRequest()
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    do {
                        try context.execute(deleteRequest)
                    } catch {
                        print("❌ Fehler beim Löschen: \(error)")
                    }
                    
                    // 🔵 Neue Locations speichern
                    for dto in locationList {
                        let entity = AllUserGPSData(context: context)
                        entity.id = dto.id
                        entity.latitude = Double(dto.latitude) ?? 0.0
                        entity.longitude = Double(dto.longitude) ?? 0.0
                        entity.time = dto.timestamp
                        entity.accuracy = dto.accuracy
                        
                        // Beziehung zu User setzen
                        let userFetch: NSFetchRequest<AllUserData> = AllUserData.fetchRequest()
                        userFetch.predicate = NSPredicate(format: "id == %d", dto.userId)
                        if let user = try? context.fetch(userFetch).first {
                            entity.user = user
                        } else {
                            print("⚠️ Kein User mit ID \(dto.userId) gefunden")
                        }
                    }
                    
                    do {
                        try context.save()
                        print("✅ \(locationList.count) GPS Punkte erfolgreich gespeichert")
                        completion(true, "Erfolg: \(locationList.count) GPS Punkte gespeichert")
                    } catch {
                        print("❌ Fehler beim Speichern: \(error.localizedDescription)")
                        completion(false, "Fehler beim Speichern: \(error.localizedDescription)")
                    }
                }
            } else {
                print("❌ Serverstatus: \(status), Nachricht: \(message)")
                completion(false, "Serverstatus: \(status), Nachricht: \(message)")
            }
        } catch {
            print("❌ JSON parse error: \(error.localizedDescription)")
            completion(false, "Fehler beim Decoding: \(error.localizedDescription)")
        }
    }
    
    task.resume()
}
