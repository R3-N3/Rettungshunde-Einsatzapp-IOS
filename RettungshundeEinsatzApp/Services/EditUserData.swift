//
//  EditUserData.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 30.06.25.
//

import Foundation

func editUserData(
    username: String,
    email: String,
    phoneNumber: String,
    callSign: String,
    selectedSecurityLevelSend: String,
    selectedHex: String,
    userID: String,
    completion: @escaping (Bool, String) -> Void
) {
    print("🟢 Starte editUser")

    let defaults = UserDefaults.standard
    let serverApiURL = defaults.string(forKey: "serverApiURL") ?? ""
    let token = KeychainHelper.loadToken() ?? ""

    guard let url = URL(string: serverApiURL + "edituser") else {
        completion(false, "Invalid URL")
        return
    }

    // Request Body
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    let bodyParams = "token=\(token)&username=\(username)&email=\(email)&phoneNumber=\(phoneNumber)&callSign=\(callSign)&selectedSecurityLevelSend=\(selectedSecurityLevelSend)&selectedHex=\(selectedHex)&userID=\(userID)"
    request.httpBody = bodyParams.data(using: .utf8)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("❌ editUser Error: \(error.localizedDescription)")
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
                let message = json["message"] as? String ?? ""

                if status == "success" {
                    print("✅ editUser Success: \(message)")
                    completion(true, message)
                } else {
                    print("❌ editUser Server Error: \(message)")
                    completion(false, message)
                }
            } else {
                completion(false, "Invalid JSON")
            }
        } catch {
            print("❌ editUser JSON parse error: \(error.localizedDescription)")
            completion(false, "Fehler beim Decoding: \(error.localizedDescription)")
        }
    }

    task.resume()
}
