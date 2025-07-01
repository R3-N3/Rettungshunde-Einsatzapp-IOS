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
        case id, userId = "user_id", latitude, longitude, timestamp, accuracy
    }
}

func downloadAllGpsLocations(context: NSManagedObjectContext, completion: @escaping (Bool, String) -> Void) {
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
    request.httpBody = "token=\(token)".data(using: .utf8)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    URLSession.shared.dataTask(with: request) { data, _, error in
        if let error = error {
            completion(false, error.localizedDescription)
            return
        }
        
        guard let data = data else {
            completion(false, "No data received")
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode(ApiResponse<[LocationDTO]>.self, from: data)
            let locations = decoded.data
            
            context.perform {
                do {
                    let userFetch: NSFetchRequest<AllUserData> = AllUserData.fetchRequest()
                    let allUsers = try context.fetch(userFetch)
                    let userDict = Dictionary(uniqueKeysWithValues: allUsers.map { ($0.id, $0) })

                    let fetchRequest: NSFetchRequest<AllUserGPSData> = AllUserGPSData.fetchRequest()
                    let existingGPS = try context.fetch(fetchRequest)
                    let serverIDs = Set(locations.map { $0.id })

                    // 🔴 Delete lokale GPS Punkte, die nicht mehr auf dem Server existieren
                    for gps in existingGPS {
                        if !serverIDs.contains(gps.id) {
                            context.delete(gps)
                        }
                    }

                    // 🔁 Update oder Insert
                    for dto in locations {
                        let gpsEntity: AllUserGPSData
                        if let existing = existingGPS.first(where: { $0.id == dto.id }) {
                            gpsEntity = existing
                        } else {
                            let newEntity = AllUserGPSData(context: context)
                            newEntity.id = dto.id
                            gpsEntity = newEntity
                        }

                        gpsEntity.latitude = Double(dto.latitude) ?? 0
                        gpsEntity.longitude = Double(dto.longitude) ?? 0
                        gpsEntity.time = dto.timestamp
                        gpsEntity.accuracy = dto.accuracy

                        // ➔ User Beziehung setzen aus Dictionary
                        if let user = userDict[dto.userId] {
                            gpsEntity.user = user
                        } else {
                            print("⚠️ Kein User mit ID \(dto.userId) gefunden")
                        }
                    }

                    try context.save()
                    context.refreshAllObjects()
                    print("✅ \(locations.count) GPS Punkte erfolgreich synchronisiert")
                    completion(true, "Erfolg: \(locations.count) GPS Punkte synchronisiert")

                } catch {
                    completion(false, "CoreData Fehler: \(error.localizedDescription)")
                }
            }
        } catch {
            completion(false, "Fehler beim Decoding: \(error.localizedDescription)")
        }
    }.resume()
}
