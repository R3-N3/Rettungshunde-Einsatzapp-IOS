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
        case username, email, phonenumber, securitylevel, radiocallname, trackcolor = "track_color"
    }
}

func downloadAllUserData(context: NSManagedObjectContext, completion: @escaping (Bool, String) -> Void) {
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
            let decoded = try JSONDecoder().decode(ApiResponse<[UserDataDTO]>.self, from: data)
            let userList = decoded.data
            
            context.perform {
                do {
                    let fetchRequest: NSFetchRequest<AllUserData> = AllUserData.fetchRequest()
                    let localUsers = try context.fetch(fetchRequest)
                    
                    // ➡️ IDs der Serverdaten
                    let serverIDs = Set(userList.map { $0.id })
                    
                    // ➡️ Update bestehender Benutzer
                    for user in localUsers where serverIDs.contains(user.id) {
                        if let serverUser = userList.first(where: { $0.id == user.id }) {
                            user.username = serverUser.username
                            user.email = serverUser.email ?? ""
                            user.phonenumber = serverUser.phonenumber ?? ""
                            user.securitylevel = serverUser.securitylevel ?? 0
                            user.radiocallname = serverUser.radiocallname ?? ""
                            user.trackcolor = serverUser.trackcolor
                        }
                    }
                    
                    // ➡️ Lösche Benutzer, die nicht mehr existieren
                    for user in localUsers where !serverIDs.contains(user.id) {
                        context.delete(user)
                    }
                    
                    // ➡️ Insert neue Benutzer
                    let localIDs = Set(localUsers.map { $0.id })
                    for serverUser in userList where !localIDs.contains(serverUser.id) {
                        let newUser = AllUserData(context: context)
                        newUser.id = serverUser.id
                        newUser.username = serverUser.username
                        newUser.email = serverUser.email ?? ""
                        newUser.phonenumber = serverUser.phonenumber ?? ""
                        newUser.securitylevel = serverUser.securitylevel ?? 0
                        newUser.radiocallname = serverUser.radiocallname ?? ""
                        newUser.trackcolor = serverUser.trackcolor
                    }
                    
                    try context.save()
                    context.refreshAllObjects()
                    print("✅ \(userList.count) Benutzer erfolgreich synchronisiert")
                    completion(true, "Erfolg: \(userList.count) Benutzer synchronisiert")
                    
                } catch {
                    completion(false, "CoreData Fehler: \(error.localizedDescription)")
                }
            }
        } catch {
            completion(false, "Fehler beim Decoding: \(error.localizedDescription)")
        }
    }.resume()
}
