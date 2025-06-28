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
                    Text("Meine Daten")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("Benutzername: \(defaults.string(forKey: "username") ?? "")")
                        .padding(.top)
                    
                    Text("E-Mail: \(defaults.string(forKey: "email") ?? "")")
                    
                    Text("Handynummer: \(defaults.string(forKey: "phoneNumber") ?? "")")
                    
                    Text("Funkrufname: \(defaults.string(forKey: "radioCallName") ?? "")")
                    
                    Text("Sicherheitslevel: \((defaults.string(forKey: "securityLevel") ?? "").securityLevelText)")
                    
                    HStack {
                        Text("Track-Farbe:")
                        
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
                            Label("Benutzerdaten ändern", systemImage: "person.fill")
                        }
                        .buttonStyleREA()
                        .padding(.top, 16)
                        }
                    .frame(maxWidth: .infinity)
                    
                    
                    // "Farbe ändern" Button
                    HStack {
                        ColorPicker("Neue Track-Farbe auswählen:", selection: $selectedColor)
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
                            Label("Logout", systemImage: "arrow.backward.circle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyleREARed()
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
                .confirmationDialog("Möchten Sie sich wirklich abmelden?", isPresented: $showLogoutConfirmation, titleVisibility: .visible) {
                    Button("Logout", role: .destructive) {
                        router.logout() // Startet Logout Funktion in AppRouter.swift
                        bannerManager.showBanner("Erfolgreich ausgeloggt!", type: .success)
                    }
                    Button("Abbrechen", role: .cancel) { }
                }
            }
            .navigationTitle("Einstellungen")
        }
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        var r: Double = 0, g: Double = 0, b: Double = 0, a: Double = 1.0
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        if length == 6 {
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
}

extension Color {
    func toHex() -> String {
        if let uiColor = UIColor(self).cgColor.components {
            let r = Int((uiColor[0] * 255.0).rounded())
            let g = Int((uiColor[1] * 255.0).rounded())
            let b = Int((uiColor[2] * 255.0).rounded())
            return String(format: "#%02X%02X%02X", r, g, b)
        }
        return "#000000"
    }
}

