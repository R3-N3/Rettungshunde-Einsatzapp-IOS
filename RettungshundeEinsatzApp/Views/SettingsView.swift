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
    @State private var showLogoutModal = false
    
    var body: some View {
        
        NavigationStack {
            List{
                Section(header: Text(String(localized: "my_user_data"))){
                    NavigationLink(destination: EditMyUserDataView()) {
                        VStack(alignment: .leading, spacing: 0){
                            Text("👤 " + (defaults.string(forKey: "username") ?? ""))
                                .font(.largeTitle)
                            
                            Text((defaults.string(forKey: "email") ?? String(localized: "unknown_email")))
                            
                            Text((defaults.string(forKey: "phoneNumber") ?? String(localized: "unknown_phonenumber")))
                            
                            Text((defaults.string(forKey: "radioCallName") ?? String(localized: "unknown_radiocallname")))
                            
                            Text(((defaults.string(forKey: "securityLevel") ?? String(localized: "unknown_securitylevel"))).securityLevelText)
                        }
                    }
                    
                }
                
                Section(header: Text(String(localized: "my_local_track_color"))){
                    
                    HStack {
                        Text(String(localized: "edit_local_track_color"))
                        
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
                        
                        Spacer()
                        
                        ColorPicker("", selection: $selectedColor)
                            .onChange(of: selectedColor) { _, newValue in
                                if let uiColor = UIColor(newValue).cgColor.components {
                                    let r = Int((uiColor[0] * 255.0).rounded())
                                    let g = Int((uiColor[1] * 255.0).rounded())
                                    let b = Int((uiColor[2] * 255.0).rounded())
                                    let hexString = String(format: "#%02X%02X%02X", r, g, b)
                                    defaults.set(hexString, forKey: "trackColor")
                                }
                            }
                            .frame(maxWidth: 50)
                            .labelsHidden()
                    }
                }
                
                Section(header: Text(String(localized: "logout"))){
                    // Logout Button
                    HStack {
                        Button(role: .destructive) {
                            showLogoutModal = true
                        } label: {
                            Label(String(localized: "logout"), systemImage: "arrow.backward.circle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(buttonStyleREAAnimatedRed())
                    }
                    .frame(maxWidth: .infinity)
                }
                
            }
            .navigationTitle(String(localized: "settings"))
            .sheet(isPresented: $showLogoutModal) {
                DeleteConfirmationModal(
                    title: String(localized: "confirm_logout_titel"), //"⚠️ Logout bestätigen",
                    message: String(localized: "confirm_logout_text"), //"Möchtest du dich wirklich ausloggen?",
                    confirmButtonTitle: String(localized: "logout"),
                    onConfirm: {
                        router.logout()
                        bannerManager.showBanner(String(localized: "banner_logout_success"), type: .success)
                        showLogoutModal = false
                    },
                    onCancel: {
                        showLogoutModal = false
                    }
                )
                .presentationDetents([.height(250)])
            }
        }
    }
}

