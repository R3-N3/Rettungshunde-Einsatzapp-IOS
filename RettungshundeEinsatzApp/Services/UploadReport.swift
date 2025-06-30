//
//  UploadReport.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 30.06.25.
//

import Foundation

func uploadReport(
    selectedDate: String,
    reportText: String,
    completion: @escaping (Bool, String) -> Void
) {
    print("🟢 Starte uploadReport")
    
    let defaults = UserDefaults.standard
    let serverApiURL = defaults.string(forKey: "serverApiURL") ?? ""
    let token = KeychainHelper.loadToken() ?? ""
    let myUserName = defaults.string(forKey: "username") ?? ""
    
    // URL bauen
    guard let url = URL(string: serverApiURL + "uploadreport") else {
        completion(false, "Invalid URL")
        return
    }
    
    guard !token.isEmpty else {
        print("❌ uploadReport Failure: Token is missing.")
        completion(false, "Missing token")
        return
    }
    
    // Request vorbereiten
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    // Body Parameter
    let bodyParams = "token=\(token)&username=\(myUserName)&date=\(selectedDate)&text=\(reportText)"
    request.httpBody = bodyParams.data(using: .utf8)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    // URLSession Task
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("❌ uploadReport Error: \(error.localizedDescription)")
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
                    print("✅ Report erfolgreich hochgeladen: \(message)")
                    completion(true, "Report uploaded successfully")
                } else {
                    print("⚠️ uploadReport Failure: \(message)")
                    completion(false, message)
                }
            } else {
                completion(false, "Invalid JSON format")
            }
        } catch {
            print("❌ uploadReport JSON parse error: \(error.localizedDescription)")
            completion(false, error.localizedDescription)
        }
    }
    
    task.resume()
}
