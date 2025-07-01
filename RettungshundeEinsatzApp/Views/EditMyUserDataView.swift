//
//  EditMyUserDataView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 28.06.25.
//

import SwiftUI

struct EditMyUserDataView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var bannerManager: BannerManager
    @EnvironmentObject var router: AppRouter
    @State private var isSubmitting = false

    let defaults = UserDefaults.standard

    @State private var showSaveModal = false
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
                    Section(header: Text(String(localized: "info"))) {
                        Text(String(localized: "edit_user_data_info_text"))
                    }
                    Section(header: Text(String(localized: "user_data"))) {
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(String(localized: "username"))
                                .font(.caption)
                                .foregroundColor(.gray)

                            TextField(String(localized: "username"), text: $username)
                                .padding(12)
                                .background(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                                )
                                .disabled(true)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(String(localized: "email"))
                                .font(.caption)
                                .foregroundColor(.gray)

                            TextField(String(localized: "email"), text: $email)
                                .padding(12)
                                .background(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focusedField == .email ? Color.blue : Color.gray.opacity(0.5), lineWidth: 1.5)
                                )
                                .focused($focusedField, equals: .email)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(String(localized: "phone_number"))
                                .font(.caption)
                                .foregroundColor(.gray)

                            TextField(String(localized: "phone_number"), text: $phoneNumber)
                                .padding(12)
                                .background(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focusedField == .phoneNumber ? Color.blue : Color.gray.opacity(0.5), lineWidth: 1.5)
                                )
                                .focused($focusedField, equals: .phoneNumber)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(String(localized: "radio_call_name"))
                                .font(.caption)
                                .foregroundColor(.gray)

                            TextField(String(localized: "radio_call_name"), text: $radioCallName)
                                .padding(12)
                                .background(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                                )
                                .disabled(true)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(String(localized: "security_level"))
                                .font(.caption)
                                .foregroundColor(.gray)

                            TextField(String(localized: "security_level"), text: .constant(securityLevel.securityLevelText))
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
                    Button(String(localized: "cancel")) {
                        dismiss()
                    }
                    .buttonStyle(buttonStyleREAAnimated())
                    
                    Button(action: {
                        if !isValidEmail(email) {
                            bannerManager.showBanner(String(localized: "banner_insert_valid_email"), type: .error)
                            return
                        }
                        
                        if !isValidPhoneNumber(phoneNumber) {
                            bannerManager.showBanner(String(localized: "banner_insert_valid_phone_number"), type: .error)
                            return
                        }

                        showSaveModal = true
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text(String(localized: "save"))
                                .fontWeight(.medium)
                        }
                    }
                    .buttonStyle(buttonStyleREAAnimatedGreen())
                }
                .padding()
            }
            .navigationTitle(String(localized: "edit_user_data"))
            .onAppear {
                username = defaults.string(forKey: "username") ?? ""
                email = defaults.string(forKey: "email") ?? ""
                phoneNumber = defaults.string(forKey: "phoneNumber") ?? ""
                radioCallName = defaults.string(forKey: "radioCallName") ?? ""
            }
            .sheet(isPresented: $showSaveModal) {
                SaveConfirmationModal(
                    title: String(localized: "confirm_edit_my_user_data_titel"),
                    message: String(localized: "confirm_edit_my_user_data_text"), 
                    confirmButtonTitle: String(localized: "save"),
                    onConfirm: {
                        isSubmitting = true
                        editMyUserData(
                            email: email,
                            phoneNumber: phoneNumber
                        ) { success, message in
                            DispatchQueue.main.async {
                                if success {
                                    bannerManager.showBanner(String(localized: "baner_input_saved_successfully"), type: .success)
                                    checkTokenAndDownloadMyUserData(router: router) { success, message in }
                                    dismiss()
                                } else {
                                    bannerManager.showBanner(String(localized: "banner_input_saved_error"), type: .error)
                                }
                                isSubmitting = false
                                showSaveModal = false
                            }
                        }
                    },
                    onCancel: {
                        showSaveModal = false
                    }
                )
                .presentationDetents([.height(250)])
            }
        }
        
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




