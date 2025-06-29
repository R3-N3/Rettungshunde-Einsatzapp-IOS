//
//  Settings.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 28.06.25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var router: AppRouter // Für die Logout Funktion notwendig
    @EnvironmentObject var bannerManager: BannerManager

    let defaults = UserDefaults.standard
    @State private var selectedColor: Color = .blue
    @State private var showLogoutConfirmation = false



    var body: some View {

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // z.B. Section-Titel
                    Text(String(localized: "my_user_data"))
                        .font(.headline)
                        .padding(.top)
                    
                    Text(String(localized: "username") + ": " + (defaults.string(forKey: "username") ?? ""))
                        .padding(.top)
                    
                    Text(String(localized: "email") + ": " + (defaults.string(forKey: "email") ?? ""))
                    
                    Text(String(localized: "phone_number") + ": " + (defaults.string(forKey: "phoneNumber") ?? ""))
                    
                    Text(String(localized: "radio_call_name") + ": " + (defaults.string(forKey: "radioCallName") ?? ""))
                    
                    Text(String(localized: "security_level") + ": " + ((defaults.string(forKey: "securityLevel") ?? "")).securityLevelText)
                    
                    HStack {
                        Text(String(localized: "track_color") + ": ")
                        
                        Rectangle()
                            .fill(selectedColor)
                            .frame(width: 80, height: 30)
                            .cornerRadius(4)
                            .overlay(
                                Text(selectedColor.toHex())
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .shadow(radius: 1)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                    }
                    

                    // Divider für visuelle Trennung
                    Divider()
                        .padding(.top)
                    

                    // Weitere Einstellungen
                    
                    //Benutzerdaten ändern
                    HStack {
                        NavigationLink(destination: EditMyUserDataView()) {
                            Label(String(localized: "edit_user_data"), systemImage: "person.fill")
                        }
                        .buttonStyle(buttonStyleREAAnimated())
                        .padding(.top, 16)
                        }
                    .frame(maxWidth: .infinity)
                    
                    
                    // "Farbe ändern" Button
                    HStack {
                        ColorPicker(String(localized: "select_new_track_color") + ": ", selection: $selectedColor)
                            .onChange(of: selectedColor) { _, newValue in
                            if let uiColor = UIColor(newValue).cgColor.components {
                                let r = Int((uiColor[0] * 255.0).rounded())
                                let g = Int((uiColor[1] * 255.0).rounded())
                                let b = Int((uiColor[2] * 255.0).rounded())
                                let hexString = String(format: "#%02X%02X%02X", r, g, b)
                                defaults.set(hexString, forKey: "trackColor")
                            }
                        }
                        .buttonStyleREA()
                        .padding(.top, 16)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Logout Button
                    HStack {
                        Button(role: .destructive) {
                            showLogoutConfirmation = true
                        } label: {
                            Label(String(localized: "logout"), systemImage: "arrow.backward.circle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(buttonStyleREAAnimatedRed())
                        .padding(.top, 50)
                    }
                    .frame(maxWidth: .infinity)
                    

                }
                .padding()
                .onAppear {
                    if let hex = defaults.string(forKey: "trackColor"),
                       let color = Color(hex: hex) {
                        selectedColor = color
                    }
                }
                .confirmationDialog(String(localized: "confirmation_logout"), isPresented: $showLogoutConfirmation, titleVisibility: .visible) {
                    Button(String(localized: "logout"), role: .destructive) {
                        router.logout() // Startet Logout Funktion in AppRouter.swift
                        bannerManager.showBanner("Erfolgreich ausgeloggt!", type: .success)
                    }
                    Button(String(localized: "cancel"), role: .cancel) { }
                }
            }
            .navigationTitle(String(localized: "settings"))
        }
    }
}


