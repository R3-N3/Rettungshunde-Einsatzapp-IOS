//
//  DownloadAreas.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 01.07.25.
//

import Foundation
import CoreData

struct DownloadArea: Codable {
    var id: Int
    var title: String
    var description: String
    var color: String
    var points: [DownloadAreaPoint]
}

struct DownloadAreaPoint: Codable {
    var lat: Double
    var lon: Double
    var order_index: Int
}

func downloadAreas(context: NSManagedObjectContext, completion: @escaping (Bool, String) -> Void) {
    print("🟢 Starte downloadAreasFromServer")
    
    let defaults = UserDefaults.standard
    let serverApiURL = defaults.string(forKey: "serverApiURL") ?? ""
    let token = KeychainHelper.loadToken() ?? ""
    
    guard let url = URL(string: serverApiURL + "downloadareas") else {
        completion(false, "Invalid URL")
        return
    }
    
    guard !token.isEmpty else {
        completion(false, "Missing token")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let payload: [String: Any] = ["token": token]
    request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("❌ downloadAreasFromServer Error: \(error.localizedDescription)")
            completion(false, error.localizedDescription)
            return
        }
        
        guard let data = data else {
            completion(false, "No data received")
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let status = json["status"] as? String,
               let message = json["message"] as? String {
                
                if status == "success", let areasData = json["data"] as? [[String: Any]] {
                    
                    // ➡️ CoreData löschen
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Area.fetchRequest()
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    try context.execute(deleteRequest)
                    
                    context.perform {
                        // ➡️ Alle Inserts und Relationship Zuweisungen hier
                        for areaDict in areasData {
                            let area = Area(context: context)
                            area.title = areaDict["title"] as? String ?? "Unbenannt"
                            area.desc = areaDict["description"] as? String ?? ""
                            area.color = areaDict["color"] as? String ?? "#FF0000"
                            area.uploadedToServer = true

                            if let pointsArray = areaDict["points"] as? [[String: Any]] {
                                for (index, pointDict) in pointsArray.enumerated() {
                                    let coord = AreaCoordinate(context: context)
                                    coord.latitude = pointDict["lat"] as? Double ?? 0.0
                                    coord.longitude = pointDict["lon"] as? Double ?? 0.0
                                    coord.orderIndex = Int32(pointDict["order_index"] as? Int ?? index)
                                    coord.area = area
                                }
                            }
                        }

                        do {
                            try context.save()
                            DispatchQueue.main.async {
                                completion(true, "Areas erfolgreich synchronisiert")
                            }
                        } catch {
                            print("❌ CoreData Save Error: \(error.localizedDescription)")
                            DispatchQueue.main.async {
                                completion(false, "CoreData Save Error: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                    print("✅ Flächen erfolgreich synchronisiert")
                    completion(true, message)
                    
                } else {
                    completion(false, message)
                }
            } else {
                completion(false, "Invalid JSON format")
            }
        } catch {
            print("❌ downloadAreasFromServer JSON parse error: \(error.localizedDescription)")
            completion(false, error.localizedDescription)
        }
    }
    task.resume()
}
