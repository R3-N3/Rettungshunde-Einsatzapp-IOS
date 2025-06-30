//
//  UploadLocationToServer.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 28.06.25.
//

import Foundation


func uploadLocation(
    latitude: Double,
    longitude: Double,
    accuracy: Double,
    time: Date,
    completion: @escaping (Bool, String) -> Void
) {
    print("🟢 Starte uploadLocation")
    
    let defaults = UserDefaults.standard
    let serverApiURL = defaults.string(forKey: "serverApiURL") ?? ""
    let token = KeychainHelper.loadToken() ?? ""
    
    // URL bauen
    guard let url = URL(string: serverApiURL + "uploadmygpspoint") else {
        completion(false, "Invalid URL")
        return
    }
    
    // Timestamp formatieren
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let formattedTimestamp = formatter.string(from: time)
    
    // Request vorbereiten
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    guard !token.isEmpty else {
        print("❌ uploadLocation Failure: Token is missing.")
        completion(false, "Missing token")
        return
    }
    
    // Body Parameter
    let bodyParams = "latitude=\(latitude)&longitude=\(longitude)&accuracy=\(accuracy)&token=\(token)&timestamp=\(formattedTimestamp)"
    request.httpBody = bodyParams.data(using: .utf8)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    // URLSession Task
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("❌ uploadLocation Error: \(error.localizedDescription)")
            completion(false, error.localizedDescription)
            return
        }
        
        guard let data = data else {
            completion(false, "No data received")
            return
        }
        
        do {
            // JSON parsen
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let status = json["status"] as? String ?? "error"
                let message = json["message"] as? String ?? "Unknown error"
                
                if status == "success" {
                    print("✅ Standort erfolgreich auf Server geladen: \(message)")
                    completion(true, message)
                } else {
                    print("❌ uploadLocation Failure: \(message)")
                    completion(false, message)
                }
            } else {
                completion(false, "Invalid JSON format")
            }
        } catch {
            print("❌ uploadLocation JSON parse error: \(error.localizedDescription)")
            completion(false, error.localizedDescription)
        }
    }
    
    task.resume()
}
