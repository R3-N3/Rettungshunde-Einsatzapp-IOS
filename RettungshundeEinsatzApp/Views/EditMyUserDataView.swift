//
//  EditMyUserDataView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 28.06.25.
//

import SwiftUI

struct EditMyUserDataView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var bannerManager: BannerManager
    @EnvironmentObject var router: AppRouter
    @State private var isSubmitting = false


    let defaults = UserDefaults.standard

    @State private var showSaveConfirmation = false
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @State private var email: String = UserDefaults.standard.string(forKey: "email") ?? ""
    @State private var phoneNumber: String = UserDefaults.standard.string(forKey: "phoneNumber") ?? ""
    @State private var radioCallName: String = UserDefaults.standard.string(forKey: "radioCallName") ?? ""
    @State private var securityLevel: String = UserDefaults.standard.string(forKey: "securityLevel") ?? ""

    @FocusState private var focusedField: Field?

    
    enum Field {
        case email, phoneNumber
    }

        var body: some View {
            NavigationStack {
                VStack {
                    Form {
                        Section(header: Text("Info")) {
                            Text("Bitte beachten Sie: Nur Ihre E-Mail Adresse, Handynummer und Track-Farbe können selbst angepasst werden. Für Änderungen anderer Angaben wenden Sie sich bitte an den Administrator oder eine befugte Person.")
                        }
                        Section(header: Text("Benutzerdaten")) {
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Benutzername")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                TextField("Benutzername", text: $username)
                                    .padding(12)
                                    .background(Color(.systemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                                        )
                                    .disabled(true)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("E-Mail")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                TextField("E-Mail", text: $email)
                                    .padding(12)
                                    .background(Color(.systemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(focusedField == .email ? Color.blue : Color.gray.opacity(0.5), lineWidth: 1.5)
                                        )
                                        .focused($focusedField, equals: .email)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Handynummer")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                TextField("Handynummer", text: $phoneNumber)
                                    .padding(12)
                                    .background(Color(.systemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(focusedField == .phoneNumber ? Color.blue : Color.gray.opacity(0.5), lineWidth: 1.5)
                                        )
                                        .focused($focusedField, equals: .phoneNumber)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Funkrufname")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                TextField("Funkrufname", text: $radioCallName)
                                    .padding(12)
                                    .background(Color(.systemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                                        )
                                    .disabled(true)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Sicherheitslevel")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                TextField("Sicherheitslevel", text: .constant(securityLevel.securityLevelText))
                                    .padding(12)
                                    .background(Color(.systemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                                        )
                                    .disabled(true)
                            }
                            
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        Button("Abbrechen") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .buttonStyleREA()
                        
                        Button("Speichern") {
                            focusedField = nil
                            showSaveConfirmation = true
                            // Speicherung in UserDefaults (Beispiel)
                            /*defaults.set(username, forKey: "username")
                            defaults.set(email, forKey: "email")
                            defaults.set(phoneNumber, forKey: "phoneNumber")
                            defaults.set(radioCallName, forKey: "radioCallName")
                            */
                            // Schließe View
                            //presentationMode.wrappedValue.dismiss()
                        }
                        .buttonStyleREAGreen()
                    }
                    .padding()
                }
                .navigationTitle("Benutzerdaten ändern")
                .onAppear {
                    // Bestehende Daten laden
                    username = defaults.string(forKey: "username") ?? ""
                    email = defaults.string(forKey: "email") ?? ""
                    phoneNumber = defaults.string(forKey: "phoneNumber") ?? ""
                    radioCallName = defaults.string(forKey: "radioCallName") ?? ""
                }
                .confirmationDialog("Möchten Sie die Daten wirklich speichern?", isPresented: $showSaveConfirmation, titleVisibility: .visible) {
                    Button("Speichern", role: .destructive) {
                        isSubmitting = true
                        editMyUserData(
                            email: email,
                            phoneNumber: phoneNumber
                        ) { success, message in
                            DispatchQueue.main.async {
                                if success {
                                    bannerManager.showBanner("Eingabe erfolgreich gespeichert!", type: .success)
                                    checkTokenAndDownloadMyUserData(router: router) { success, message in}
                                    presentationMode.wrappedValue.dismiss()
                                } else {
                                    bannerManager.showBanner("Daten konnten nicht gespeichert werden.", type: .error)
                                    
                                }
                                isSubmitting = false
                            }
                        }
                        
                        
                        
                        
                        
                        
                        bannerManager.showBanner("Erfolgreich gespeichert!", type: .success)
                        //bannerManager.showBanner("Nicht Erfolgreich gespeichert!", type: .error)
                        //bannerManager.showBanner("Erfolgreich gespeichert!", type: .warning)
                        //bannerManager.showBanner("Erfolgreich gespeichert!", type: .info)
                        //router.logout() // Startet die Speicherung
                    }
                    Button("Abbrechen", role: .cancel) { }
                }
            }
            // Lade-Overlay
            if isSubmitting {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    Text(String(localized: "processing"))
                        .foregroundColor(.white)
                }
                .padding(40)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.7)))
            }
        }
    
}



#Preview {
    EditMyUserDataView()
}
