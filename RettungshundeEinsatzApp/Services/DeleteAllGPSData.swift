
//
//  DeleteAllGPSData.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 30.06.25.
//

import Foundation

func deleteAllGPSData(completion: @escaping (Bool, String) -> Void) {
    
    print("🟢 Starte deleteAllGPSData")
    
    let defaults = UserDefaults.standard
    let serverApiURL = defaults.string(forKey: "serverApiURL") ?? ""
    let token = KeychainHelper.loadToken() ?? ""
    
    guard let url = URL(string: serverApiURL + "deleteallgpsdata") else {
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
            print("❌ deleteAllGPSData Error: \(error.localizedDescription)")
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
                    print("✅ deleteAllGPSData Success: \(message)")
                    completion(true, message) // ➡️ hinzugefügt
                } else {
                    print("⚠️ deleteAllGPSData Failure: \(message)")
                    completion(false, message)
                }
            } else {
                completion(false, "Invalid JSON format")
            }
        } catch {
            print("❌ deleteAllGPSData JSON parse error: \(error.localizedDescription)")
            completion(false, error.localizedDescription)
        }
    }
    
    task.resume()
}
