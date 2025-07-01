//
//  OploadNewUser.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 01.07.25.
//

import Foundation

func uploadNewUser(
    username: String,
    email: String,
    password: String,
    phoneNumber: String,
    callSign: String,
    securityLevel: String,
    colorHex: String,
    completion: @escaping (Bool, String) -> Void
) {
    print("🟢 Starte uploadNewUser")

    let defaults = UserDefaults.standard
    let serverApiURL = defaults.string(forKey: "serverApiURL") ?? ""
    let token = KeychainHelper.loadToken() ?? ""

    // URL bauen
    guard let url = URL(string: serverApiURL + "uploadnewuser") else {
        completion(false, "Invalid URL")
        return
    }

    guard !token.isEmpty else {
        print("❌ uploadNewUser Failure: Token is missing.")
        completion(false, "Missing token")
        return
    }

    // Request vorbereiten
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    // Body Parameter
    let bodyParams = "token=\(token)&username=\(username)&email=\(email)&password=\(password)&phone=\(phoneNumber)&callSign=\(callSign)&securelevel=\(securityLevel)&color=\(colorHex)"
    request.httpBody = bodyParams.data(using: .utf8)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    // URLSession Task
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("❌ uploadNewUser Error: \(error.localizedDescription)")
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
                    print("✅ Neuer Benutzer erfolgreich erstellt: \(message)")
                    completion(true, message)
                } else {
                    print("❌ uploadNewUser Failure: \(message)")
                    completion(false, message)
                }
            } else {
                completion(false, "Invalid JSON format")
            }
        } catch {
            print("❌ uploadNewUser JSON parse error: \(error.localizedDescription)")
            completion(false, error.localizedDescription)
        }
    }

    task.resume()
}
