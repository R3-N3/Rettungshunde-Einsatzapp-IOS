//
//  ForgotPasswordView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 27.06.25.
//

//
//  LoginView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 24.06.25.
//
import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss // zum zurück gehen beim drücken des cancel buttons
    
    @State private var email: String = ""
    @State private var selectedOrg = "BRH RHS Bonn/Rhein-Sieg"
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var isSubmitting = false
    

    enum Field {
        case email, role
    }
    
    @FocusState private var focusedField: Field?

    let org = ["BRH RHS Bonn/Rhein-Sieg", "Demo", "Debug"]



    var body: some View {
        ZStack {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {
                        
                        //Text
                        
                        Text(String(localized: "reset_password_info_text"))
                        
                        
                        // E-Mail
                        VStack(alignment: .leading, spacing: 6) {
                            Text(String(localized: "email"))
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            TextField("", text: $email)
                                .padding(12)
                                .background(RoundedRectangle(cornerRadius: 12)
                                    .stroke(focusedField == .email ? Color.blue : Color.gray.opacity(0.5), lineWidth: 1.5))
                                .background(Color(.systemBackground))
                                .keyboardType(.emailAddress)
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
                        
                        
                        
                        
                        
                        
                        HStack(spacing: 40) {
                            
                            // Abbrechen Button
                            Button(action: {
                                dismiss() //zurück zur vorherigen View
                            }) {
                                Text(String(localized: "cancel"))
                            }
                            .buttonStyle(buttonStyleREAAnimated())
 
                            
                            
                            
                            
                            
                            // Zurücksetzen Button
                            Button(action: {
                                guard !isSubmitting else { return }
                                isSubmitting = true
                                resetPassword(
                                    org: selectedOrg,
                                    email: email
                                ) { success, message in
                                    DispatchQueue.main.async {
                                        if success {
                                            print("reset erfolgreich, wenn E-Mail korrekt")
                                            alertTitle = String(localized: "success")
                                            alertMessage = String(localized: "reset_password_success_text")
                                            showAlert = true
                                            isSubmitting = false
                                            email = ""
                                        } else {
                                            print("❌ Reset nicht erfolgreich")
                                            alertTitle = String(localized: "error")
                                            alertMessage = message
                                            showAlert = true
                                            isSubmitting = false
                                        }
                                        isSubmitting = false
                                    }
                                }
                            }) {
                                Text(String(localized: "reset"))
                            }
                            .buttonStyle(buttonStyleREAAnimated())
                            .disabled(isSubmitting)
                            .alert(alertTitle, isPresented: $showAlert) {
                                Button("OK", role: .cancel) {
                                    if alertTitle == String(localized: "success"){
                                        dismiss()
                                    }
                                }
                            } message: {
                                Text(alertMessage)
                            }
                            
                            
                            
                            
                            
                            
                            
                            
                            
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        

                        
                    }
                    .frame(maxWidth: 500)
                    .padding(.horizontal)
                    .padding(.top, 60)
                    .padding(.bottom, 40)
                    .frame(maxWidth: .infinity)
                }
                .scrollDismissesKeyboard(.interactively)
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
