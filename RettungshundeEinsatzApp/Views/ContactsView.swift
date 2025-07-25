//
//  ContactsView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 29.06.25.
//

//
//  ContactsView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 29.06.25.
//

import SwiftUI
import CoreData

struct ContactsView: View {
    @FetchRequest(
        entity: AllUserData.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \AllUserData.username, ascending: true)]
    ) var users: FetchedResults<AllUserData>
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(users, id: \.id) { user in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.username ?? String(localized: "unknown"))
                            .font(.headline)
                        
                        Text(String(localized: "radio_call_name") + ": \(user.radiocallname ?? "")")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        if let phone = user.phonenumber, !phone.isEmpty {
                            Button(action: {
                                callNumber(phone)
                            }) {
                                Text(String(localized: "phone_number") + ": \(phone)")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(String(localized: "contacts"))
        }
    }
    
    /// Funktion zum Öffnen der Telefon-App
    func callNumber(_ number: String) {
        let formatted = number.replacingOccurrences(of: " ", with: "")
        if let url = URL(string: "tel://\(formatted)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    ContactsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
