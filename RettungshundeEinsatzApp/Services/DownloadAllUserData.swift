//
//  DownloadAllUserData.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 29.06.25.
//

import Foundation
import CoreData

struct UserDataDTO: Codable {
    let id: Int64
    let username: String
    let email: String?
    let phonenumber: String?
    let securitylevel: Int16?
    let radiocallname: String?
    let trackcolor: String?

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case username
        case email
        case phonenumber
        case securitylevel
        case radiocallname
        case trackcolor = "track_color"
    }
}


func downloadAllUserData(
    context: NSManagedObjectContext,
    completion: @escaping (Bool, String) -> Void
) {
    print("🟢 Starte downloadAllUserData")
    
    let defaults = UserDefaults.standard
    let serverApiURL = defaults.string(forKey: "serverApiURL") ?? ""
    let token = KeychainHelper.loadToken() ?? ""
    
    guard let url = URL(string: serverApiURL + "downloadalluserdata") else {
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
            print("❌ downloadAllUserData Error: \(error.localizedDescription)")
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
            
            let decodedResponse = try JSONDecoder().decode(ApiResponse<[UserDataDTO]>.self, from: data)
            let status = decodedResponse.status
            let message = decodedResponse.message ?? ""
            
            if status == "success" {
                let userList = decodedResponse.data
                
                context.perform {
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = AllUserData.fetchRequest()
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    do {
                        try context.execute(deleteRequest)
                    } catch {
                        print("❌ Fehler beim Löschen: \(error)")
                    }
                    
                    for dto in userList {
                        let entity = AllUserData(context: context)
                        entity.id = dto.id
                        entity.username = dto.username
                        entity.email = dto.email ?? ""
                        entity.phonenumber = dto.phonenumber ?? ""
                        entity.securitylevel = dto.securitylevel ?? 0
                        entity.radiocallname = dto.radiocallname ?? ""
                        entity.trackcolor = dto.trackcolor
                    }
                    
                    do {
                        try context.save()
                        print("✅ \(userList.count) Benutzer erfolgreich gespeichert")
                        completion(true, "Erfolg: \(userList.count) Benutzer gespeichert")
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
