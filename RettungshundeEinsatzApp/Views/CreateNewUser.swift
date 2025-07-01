//
//  CreateNewUser.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 01.07.25.
//

import SwiftUI
import CoreData


struct CreateUserView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var bannerManager: BannerManager
    @Environment(\.managedObjectContext) private var context


    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var phoneNumber = ""
    @State private var callSign = ""
    @State private var securityLevel: Int16 = 1
    @State private var selectedColor: Color = .blue

    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSubmitting = false

    let securityLevels: [(text: String, value: Int16)] = [
        ("(1) Einsatzkraft", 1),
        ("(2) Zugführer", 2),
        ("(3) Administrator", 3)
    ]

        var body: some View {
            NavigationStack {
                VStack {
                    Form {
                        Section(header: Text(String(localized: "user_data"))) {
                            TextField(String(localized: "username"), text: $username)
                            TextField(String(localized: "email"), text: $email)
                                .keyboardType(.emailAddress)
                            SecureField(String(localized: "password"), text: $password)
                            TextField(String(localized: "phone_number"), text: $phoneNumber)
                                .keyboardType(.phonePad)
                            TextField(String(localized: "radio_call_name"), text: $callSign)
                        }

                        Section(header: Text(String(localized: "security_level"))) {
                            Picker(String(localized: "security_level"), selection: $securityLevel) {
                                ForEach(securityLevels, id: \.value) { level in
                                    Text(level.text).tag(level.value)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        Section(header: Text(String(localized: "track_color"))) {
                            ColorPicker(String(localized: "choose_color"), selection: $selectedColor)
                        }

                        if showError {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                    }

                    // ➡️ Sticky Buttons außerhalb der Form
                    HStack {
                        Button(String(localized: "cancel")) {
                            dismiss()
                        }
                        .buttonStyle(buttonStyleREAAnimated())

                        Spacer()

                        Button(action: {
                            if validateInputs() {
                                createUser()
                            }
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text(String(localized: "create"))
                                    .fontWeight(.medium)
                            }
                        }
                        .buttonStyle(buttonStyleREAAnimatedGreen())
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    //.shadow(radius: 2)
                }
                .navigationTitle(String(localized: "create_new_user"))
                .overlay {
                    if isSubmitting {
                        ZStack {
                            Color.black.opacity(0.3).ignoresSafeArea()
                            ProgressView(String(localized: "processing"))
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }

    // ✅ Eingabevalidierung
    func validateInputs() -> Bool {
        if username.isEmpty || email.isEmpty || password.isEmpty || phoneNumber.isEmpty || callSign.isEmpty {
            errorMessage = String(localized: "fill_in_al_fields") //"Bitte fülle alle Felder aus."
            showError = true
            return false
        }

        if !isValidEmail(email) {
            errorMessage = String(localized: "enter_valid_email") //"Bitte gib eine gültige E-Mail-Adresse ein."
            showError = true
            return false
        }

        if !isValidPassword(password) {
            errorMessage = String(localized: "password_need_to_be")//"Passwort muss min. 8 Zeichen, Buchstaben, Zahlen und Sonderzeichen enthalten."
            showError = true
            return false
        }

        showError = false
        return true
    }

    // ✅ Erstellen-Funktion
    func createUser() {
        isSubmitting = true

        uploadNewUser(
            username: username,
            email: email,
            password: password,
            phoneNumber: phoneNumber,
            callSign: callSign,
            securityLevel: String(securityLevel),
            colorHex: selectedColor.toHex()
        ) { success, message in
            DispatchQueue.main.async {
                if success {
                    bannerManager.showBanner(String(localized: "banner_user_create_sucessfull"), type: .success)
                    // ➔ Lade alle Benutzerdaten neu
                    downloadAllUserData(context: context) { success, message in
                    }
                    isSubmitting = false
                    dismiss()
                } else {
                    errorMessage = message
                    showError = true
                    bannerManager.showBanner(String(localized: "error") + ": \(message)", type: .error)
                    isSubmitting = false
                }
            }
        }
    }

    // ✅ Passwortvalidierung
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&*(),.?\":{}|<>])[A-Za-z\\d!@#$%^&*(),.?\":{}|<>]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }

    // ✅ E-Mail Validierung
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
}
