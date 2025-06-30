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


    @State private var selectedColor: Color = .blue

    // Picker-Daten
    let securityLevels: [(text: String, value: Int16)] = [
        ("(1) Einsatzkraft", 1),
        ("(2) Zugführer", 2),
        ("(3) Administrator", 3)
    ]

    var body: some View {
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
                Picker("", selection: $user.securitylevel) {
                    ForEach(securityLevels, id: \.value) { level in
                        Text(level.text).tag(level.value)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }

            Section(header: Text("Track-Farbe")) {
                ColorPicker("Farbe auswählen", selection: $selectedColor)
                    .onChange(of: selectedColor) {
                        user.trackcolor = selectedColor.toHex()
                    }
            }

            Section {
                HStack {
                    Button("Abbrechen") {
                        viewContext.rollback() // ➔ Änderungen verwerfen
                        dismiss()
                    }
                    .buttonStyle(buttonStyleREAAnimated())

                    Spacer()

                    Button(action: {
                        showSaveModal = true
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
                                        if success {
                                            do {
                                                try viewContext.save()
                                                print("✅ Benutzer erfolgreich auf Server gespeichert. Nachricht: \(message)")
                                                bannerManager.showBanner(String(localized: "banner_edit_user_success"), type: .success)
                                                dismiss()
                                            } catch {
                                                print("❌ Fehler beim lokalen Speichern: \(error.localizedDescription)")
                                                bannerManager.showBanner(String(localized: "banner_edit_user_error"), type: .error)
                                            }
                                        } else {
                                            print("❌ Fehler beim Speichern auf Server: \(message)")
                                            // ➔ Optional: Banner oder Alert anzeigen
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
        .onAppear {
            if let hex = user.trackcolor, let color = Color(hex: hex) {
                selectedColor = color
            }
        }
    }
}
