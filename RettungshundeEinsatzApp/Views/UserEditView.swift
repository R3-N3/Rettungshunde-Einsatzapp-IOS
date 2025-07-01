//
//  UserEditView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 30.06.25.
//


import SwiftUI
import CoreData

struct UserEditView: View {
    @ObservedObject var user: AllUserData
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var showSaveModal = false
    @EnvironmentObject var bannerManager: BannerManager
    @State private var isSubmitting = false

    @State private var selectedColor: Color = .blue

    // Neue States für Validierung
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""

    // Picker-Daten
    let securityLevels: [(text: String, value: Int16)] = [
        ("(1) Einsatzkraft", 1),
        ("(2) Zugführer", 2),
        ("(3) Administrator", 3)
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Benutzerdaten")) {
                    TextField("Username", text: Binding(
                        get: { user.username ?? "" },
                        set: { user.username = $0 }
                    ))
                    TextField("E-Mail", text: Binding(
                        get: { user.email ?? "" },
                        set: { user.email = $0 }
                    ))
                    TextField("Handynummer", text: Binding(
                        get: { user.phonenumber ?? "" },
                        set: { user.phonenumber = $0 }
                    ))
                    TextField("Funkrufname", text: Binding(
                        get: { user.radiocallname ?? "" },
                        set: { user.radiocallname = $0 }
                    ))
                }

                Section(header: Text("Sicherheitslevel")) {
                    Picker("Level", selection: $user.securitylevel) {
                        ForEach(securityLevels, id: \.value) { level in
                            Text(level.text).tag(level.value)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Track-Farbe")) {
                    ColorPicker("Farbe auswählen", selection: $selectedColor)
                        .onChange(of: selectedColor) {
                            user.trackcolor = selectedColor.toHex()
                        }
                }

                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                Section {
                    HStack {
                        Button("Abbrechen") {
                            viewContext.rollback()
                            dismiss()
                        }
                        .buttonStyle(buttonStyleREAAnimated())

                        Spacer()

                        Button(action: {
                            if validateInputs() {
                                showSaveModal = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                Text("Speichern")
                                    .fontWeight(.medium)
                            }
                        }
                        .buttonStyle(buttonStyleREAAnimatedGreen())
                        .sheet(isPresented: $showSaveModal) {
                            SaveConfirmationModal(
                                title: "Änderungen speichern?",
                                message: "Möchtest du die Änderungen wirklich speichern?",
                                confirmButtonTitle: "Speichern",
                                onConfirm: {
                                    isSubmitting = true
                                    editUserData(
                                        username: user.username ?? "",
                                        email: user.email ?? "",
                                        phoneNumber: user.phonenumber ?? "",
                                        callSign: user.radiocallname ?? "",
                                        selectedSecurityLevelSend: String(user.securitylevel),
                                        selectedHex: user.trackcolor ?? "",
                                        userID: String(user.id)
                                    ) { success, message in
                                        DispatchQueue.main.async {
                                            isSubmitting = false
                                            if success {
                                                do {
                                                    try viewContext.save()
                                                    print("✅ Benutzer erfolgreich gespeichert. Nachricht: \(message)")
                                                    // ➔ Lade alle Benutzerdaten neu
                                                    downloadAllUserData(context: viewContext) { success, message in
                                                        if success {
                                                            bannerManager.showBanner(String(localized: "banner_edit_user_success"), type: .success)
                                                            isSubmitting = false
                                                        } else {
                                                            bannerManager.showBanner(String(localized: "banner_edit_user_error"), type: .success)
                                                            isSubmitting = false
                                                        }
                                                    }
                                                    dismiss()
                                                } catch {
                                                    print("❌ Fehler beim lokalen Speichern: \(error.localizedDescription)")
                                                    
                                                    isSubmitting = false
                                                    bannerManager.showBanner(String(localized: "banner_edit_user_error"), type: .error)
                                                }
                                            } else {
                                                print("❌ Fehler beim Speichern auf Server: \(message)")
                                                bannerManager.showBanner("Fehler beim Speichern: \(message)", type: .error)
                                            }
                                            showSaveModal = false
                                        }
                                    }
                                },
                                onCancel: {
                                    showSaveModal = false
                                }
                            )
                            .presentationDetents([.height(300)])
                            .presentationDragIndicator(.visible)
                        }
                    }
                }
            }
            .navigationTitle("Benutzer bearbeiten")
            .overlay {
                if isSubmitting {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        ProgressView("Bitte warten...")
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                }
            }
            .onAppear {
                if let hex = user.trackcolor, let color = Color(hex: hex) {
                    selectedColor = color
                }
            }
        }
    }

    // ✅ Eingabevalidierung
    func validateInputs() -> Bool {
        if (user.username ?? "").isEmpty ||
            (user.email ?? "").isEmpty ||
            (user.phonenumber ?? "").isEmpty ||
            (user.radiocallname ?? "").isEmpty {
            errorMessage = "Bitte fülle alle Felder aus."
            showError = true
            return false
        }

        if !isValidEmail(user.email ?? "") {
            errorMessage = "Bitte gib eine gültige E-Mail-Adresse ein."
            showError = true
            return false
        }

        showError = false
        return true
    }

    // ✅ E-Mail Validierung
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
}
