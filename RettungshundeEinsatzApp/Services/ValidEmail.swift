//
//  CheckIsValidEmail.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 27.06.25.
//

//Diese Funktion prüft, ob die eingegebene E-Mail Adresse ein gültiges E-Mail Format besitzt

import Foundation

func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "(?:[a-zA-Z0-9._%+-]+)@(?:[a-zA-Z0-9-]+)\\.[a-zA-Z]{2,}"
    
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}
