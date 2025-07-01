//
//  CheckIsValidEmail.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 27.06.25.
//

//Diese Funktion prüft, ob die eingegebene E-Mail Adresse ein gültiges E-Mail Format besitzt

import Foundation

func isValidPhoneNumber(_ phone: String) -> Bool {
    let phoneRegEx = "^[0-9+]{6,15}$"
    return NSPredicate(format: "SELF MATCHES %@", phoneRegEx).evaluate(with: phone)
}
