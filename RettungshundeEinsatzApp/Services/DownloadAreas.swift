//
//  DownloadAreas.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 01.07.25.
//

import Foundation
import CoreData

// MARK: - DTOs

struct AreaDTO: Codable {
    let name: String
    let color: String
    let time: Int64
    let points: [PointDTO]

    enum CodingKeys: String, CodingKey {
        case name
        case color
        case time = "timestamp"
        case points
    }
}

struct PointDTO: Codable {
    let lat: Double
    let lon: Double
}

// MARK: - Download Function

func downloadAreas(context: NSManagedObjectContext, completion: @escaping (Bool, String) -> Void) {
    print("🟢 Starte downloadAreas")
    
    let defaults = UserDefaults.standard
    let serverApiURL = defaults.string(forKey: "serverApiURL") ?? ""
    let token = KeychainHelper.loadToken() ?? ""
    
    guard let url = URL(string: serverApiURL + "downloadareas") else {
        completion(false, "Invalid URL")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = "token=\(token)".data(using: .utf8)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    URLSession.shared.dataTask(with: request) { data, _, error in
        if let error = error {
            print("❌ Fehler \(error.localizedDescription)")
            completion(false, error.localizedDescription)
            return
        }
        
        guard let data = data else {
            print("❌ No data received")
            completion(false, "No data received")
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode(ApiResponse<[AreaDTO]>.self, from: data)
            let areaList = decoded.data
            
            context.perform {
                do {
                    // 🔵 1. IDs der heruntergeladenen Flächen sammeln
                    let downloadedKeys = Set(areaList.map { "\($0.name)|\($0.time)" })
                    
                    // 🔴 2. Alle lokalen Flächen abrufen
                    let fetchAllRequest: NSFetchRequest<Areas> = Areas.fetchRequest()
                    let localAreas = try context.fetch(fetchAllRequest)
                    
                    // 🔴 3. Lösche alle lokalen Flächen, die nicht mehr heruntergeladen wurden
                    for area in localAreas {
                        let key = "\(area.name ?? "")|\(area.time)"
                        if !downloadedKeys.contains(key) {
                            context.delete(area)
                        }
                    }
                    
                    // 🟢 4. Danach wie bisher updaten oder einfügen
                    for dto in areaList {
                        let fetchRequest: NSFetchRequest<Areas> = Areas.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "name == %@ AND time == %lld", dto.name, dto.time)
                        
                        let existingAreas = try context.fetch(fetchRequest)
                        let area = existingAreas.first ?? Areas(context: context)
                        
                        if existingAreas.isEmpty {
                            area.id = Int64(UUID().uuidString.hashValue)
                        }
                        
                        area.name = dto.name
                        area.color = dto.color
                        area.time = dto.time
                        area.points = dto.points.map { "\($0.lat),\($0.lon)" }.joined(separator: ";")
                        area.uploadStatus = false
                    }
                    
                    try context.save()
                    context.refreshAllObjects()
                    print("✅ \(areaList.count) Areas erfolgreich synchronisiert")
                    completion(true, "Erfolg: \(areaList.count) Areas synchronisiert")
                    
                } catch {
                    print("❌ CoreData Fehler: \(error.localizedDescription)")
                    completion(false, "CoreData Fehler: \(error.localizedDescription)")
                }
            }
        } catch {
            print("❌ Fehler beim Decoding: \(error.localizedDescription)")
            completion(false, "Fehler beim Decoding: \(error.localizedDescription)")
        }
    }.resume()
}
