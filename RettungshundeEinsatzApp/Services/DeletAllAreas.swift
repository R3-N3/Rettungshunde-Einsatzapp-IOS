//
//  DeletAllAreas.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 01.07.25.
//

import Foundation

func deleteAllAreas(completion: @escaping (Bool, String) -> Void) {
    print("🟢 Starte deleteAllAreas (nur Server)")

    let defaults = UserDefaults.standard
    let serverApiURL = defaults.string(forKey: "serverApiURL") ?? ""
    let token = KeychainHelper.loadToken() ?? ""
    let deleteUrl = serverApiURL + "deleteareas"

    guard let url = URL(string: deleteUrl) else {
        completion(false, "Invalid URL")
        return
    }

    // ➔ Request Body
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    let bodyParams = "token=\(token)"
    request.httpBody = bodyParams.data(using: .utf8)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

    // ➔ URLSession Task
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("❌ deleteAllAreas Error: \(error.localizedDescription)")
            completion(false, error.localizedDescription)
            return
        }

        guard let data = data, let responseBody = String(data: data, encoding: .utf8) else {
            completion(false, "No data received")
            return
        }

        // ➔ Prüfe Server Response
        if responseBody.lowercased().contains("success") {
            print("✅ Alle Areas erfolgreich auf dem Server gelöscht")
            completion(true, "success, Server emptied.")
        } else {
            print("❌ deleteAllAreas Server Error: \(responseBody)")
            completion(false, "error, Server response: \(responseBody)")
        }
    }.resume()
}
