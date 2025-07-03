//
//  LoginView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 24.06.25.
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var router: AppRouter
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var selectedOrg = "BRH RHS Bonn/Rhein-Sieg"
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSubmitting = false


    @FocusState private var focusedField: Field?

    let defaults = UserDefaults.standard
    let org = ["BRH RHS Bonn/Rhein-Sieg", "Demo", "Debug"]

    enum Field {
        case username, password, role
    }

    var body: some View {
        ZStack {
            NavigationStack {
                GeometryReader { geo in
                    ScrollView {
                        VStack(spacing: 24) {
                            
                            Spacer()
                            
                            // Benutzername
                            VStack(alignment: .leading, spacing: 6) {
                                Text(String(localized: "username"))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                TextField("", text: $username)
                                    .padding(12)
                                    .background(RoundedRectangle(cornerRadius: 12)
                                        .stroke(focusedField == .username ? Color.blue : Color.gray.opacity(0.5), lineWidth: 1.5))
                                    .background(Color(.systemBackground))
                            }
                            .padding(.horizontal)
                            
                            // Passwort
                            VStack(alignment: .leading, spacing: 6) {
                                Text(String(localized: "password"))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                SecureField("", text: $password)
                                    .padding(12)
                                    .background(RoundedRectangle(cornerRadius: 12)
                                        .stroke(focusedField == .password ? Color.blue : Color.gray.opacity(0.5), lineWidth: 1.5))
                                    .background(Color(.systemBackground))
                            }
                            .padding(.horizontal)
                            
                            // Organisation
                            VStack(alignment: .leading, spacing: 6) {
                                Text(String(localized: "organisation"))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Picker(String(localized: "organisation"), selection: $selectedOrg) {
                                    ForEach(org, id: \.self) { role in
                                        Text(role).tag(role)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding(12)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focusedField == .role ? Color.blue : Color.gray.opacity(0.5), lineWidth: 1.5)
                                )
                                .background(Color(.systemBackground))
                                
                            }
                            .padding(.horizontal)
                            
                            // Login Button
                            Button(action: {
                                guard !isSubmitting else { return }
                                isSubmitting = true
                                
                                checkLoginParam(
                                    username: username,
                                    password: password,
                                    org: selectedOrg
                                ) { success, message in
                                    DispatchQueue.main.async {
                                        if success {
                                            if let token = KeychainHelper.loadToken() {
                                                let defaults = UserDefaults.standard
                                                let serverURL = defaults.string(forKey: "serverApiURL") ?? ""
                                                print("🔑 Token geladen: \(token) Server URL: \(serverURL)")
                                            } else {
                                                print("❌❌❌ Kein Token gespeichert ❌❌❌")
                                            }
                                            router.isLoggedIn = true
                                        } else {
                                            print("❌ Login nicht erfolgreich")
                                            alertMessage = message
                                            showAlert = true
                                            isSubmitting = false
                                        }
                                        isSubmitting = false
                                    }
                                }
                            }) {
                                Text(String(localized: "login"))
                            }
                            .buttonStyle(buttonStyleREAAnimated())
                            .frame(maxWidth: 250)
                            .disabled(isSubmitting)
                            .padding(.horizontal)
                            .padding(.top, 20)
                            .alert(String(localized: "error"), isPresented: $showAlert) {
                                Button("OK", role: .cancel) {}
                            } message: {
                                Text(alertMessage)
                            }
                            
                            
                            //ForgotPassword Button
                            NavigationLink(destination: ForgotPasswordView()) {
                                Text(String(localized: "reset_password"))
                            }
                            //.padding(.top, 40)
                            
                            Spacer()
                            
                        }
                        .frame(minHeight: geo.size.height)
                        .frame(maxWidth: 500)
                        .frame(maxWidth: .infinity)
                        .frame(alignment: .center)
                        
                    }
                    .scrollDismissesKeyboard(.interactively)
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
}

#Preview {
    LoginView()
}
