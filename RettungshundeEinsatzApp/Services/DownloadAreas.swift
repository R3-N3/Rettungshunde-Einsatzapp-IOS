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
        case time = "timestamp" // mapping timestamp -> time
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
                    // Delete all existing Areas
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Areas.fetchRequest()
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    try context.execute(deleteRequest)
                    
                    // Insert new Areas
                    for dto in areaList {
                        let newArea = Areas(context: context)
                        newArea.id = Int64(UUID().uuidString.hashValue) // oder deine eigene ID Logik
                        newArea.name = dto.name
                        newArea.color = dto.color
                        newArea.time = dto.time
                        
                        // Convert points to string "lat,lon;lat,lon"
                        let pointString = dto.points.map { "\($0.lat),\($0.lon)" }.joined(separator: ";")
                        newArea.points = pointString
                        
                        newArea.uploadStatus = false // received = not uploaded
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
