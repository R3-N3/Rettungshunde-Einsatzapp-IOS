//
//  OperationReportView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 30.06.25.
//

//
//  OperationReportView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 30.06.25.
//

import SwiftUI

struct OperationReportView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showConfirmModal = false
    @EnvironmentObject var bannerManager: BannerManager



    @State private var reportDate: Date = Date()
    @State private var reportText: String = ""

    var body: some View {
        NavigationStack {
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    //Infotext
                    Text(String(localized: "operation_report_info_text"))
                        //.font(.headline)
                    
                    
                    
                    HStack() {
                        
                        let defaults = UserDefaults.standard
                        let myUserName = defaults.string(forKey: "username") ?? ""
                        
                        Text(String(localized: "username"))
                        .font(.headline)
                        
                        Text(myUserName)
                        
                    
                        Spacer()
                    }
                    
                    // Datum Picker
                    HStack(alignment: .center, spacing: 10) {
                        Text(String(localized: "operation_date"))
                            .font(.headline)

                        DatePicker("", selection: $reportDate, displayedComponents: .date)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Textfeld für Bericht
                    Text(String(localized: "report") + ":")
                    .font(.headline)
                    
                    TextEditor(text: $reportText)
                        .frame(height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    Spacer()
                    
                    // Buttons
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Text(String(localized: "cancel"))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(buttonStyleREAAnimated())
                        
                        
                        
                        Button(action: {
                            showConfirmModal = true
                        }) {
                            Text(String(localized: "submit"))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(buttonStyleREAAnimatedGreen())
                        .sheet(isPresented: $showConfirmModal) {
                            DeleteConfirmationModal(
                                title: String(localized: "confirm_send_operation_report_titel"),
                                message: String(localized: "confirm_send_operation_report_text"), //"Möchtest du den Einsatzbericht jetzt absenden?",
                                confirmButtonTitle: String(localized: "send"),
                                onConfirm: {
                                    uploadReport(
                                        selectedDate: formattedDate(reportDate),
                                        reportText: reportText
                                    ) { success, message in
                                        DispatchQueue.main.async {
                                            if success {
                                                print("✅ Einsatzbericht erfolgreich gesendet.")
                                                bannerManager.showBanner("Einsatzbericht erfolgreich gesendet.", type: .success)
                                                dismiss()
                                            } else {
                                                print("❌ Fehler beim Senden: \(message)")
                                                bannerManager.showBanner("Fehler beim Senden des Berichts.", type: .error)
                                            }
                                        }
                                    }
                                    showConfirmModal = false
                                },
                                onCancel: {
                                    showConfirmModal = false
                                }
                            )
                            .presentationDetents([.height(300)])
                            .presentationDragIndicator(.visible)
                        }
                        
                        
                    }
                    .padding(.top)
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .navigationTitle(String(localized: "operation_report"))
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}
