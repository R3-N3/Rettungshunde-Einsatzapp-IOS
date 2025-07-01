//
//  DeleteUser.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 01.07.25.
//

import Foundation

func deleteUserData(
    username: String,
    completion: @escaping (Bool, String) -> Void
) {
    print("🟢 Starte deleteUserData für \(username)")

    let defaults = UserDefaults.standard
    let serverApiURL = defaults.string(forKey: "serverApiURL") ?? ""
    let token = KeychainHelper.loadToken() ?? ""

    guard let url = URL(string: serverApiURL + "deleteuser") else {
        completion(false, "Invalid URL")
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    let bodyParams = "token=\(token)&username=\(username)"
    request.httpBody = bodyParams.data(using: .utf8)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("❌ deleteUserData Error: \(error.localizedDescription)")
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
                let message = json["message"] as? String ?? "Unbekannter Fehler"

                if status == "success" {
                    print("✅ deleteUserData Success: \(message)")
                    completion(true, message)
                } else {
                    print("❌ deleteUserData Server Error: \(message)")
                    completion(false, message)
                }
            } else {
                completion(false, "Invalid JSON")
            }
        } catch {
            print("❌ deleteUserData JSON parse error: \(error.localizedDescription)")
            completion(false, error.localizedDescription)
        }
    }

    task.resume()
}
