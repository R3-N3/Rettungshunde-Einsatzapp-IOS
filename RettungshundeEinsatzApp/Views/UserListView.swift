//
//  UserListView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on xx.xx.25.
//

import SwiftUI
import CoreData

struct UserListView: View {
    @FetchRequest(
        entity: AllUserData.entity(),
        sortDescriptors: [
            NSSortDescriptor(key: "username", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare))
        ]
    ) var users: FetchedResults<AllUserData>

    var body: some View {
        NavigationStack {
            List {
                ForEach(users, id: \.self) { user in
                    NavigationLink(destination: UserEditView(user: user)) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.username ?? "Unbekannt")
                                    .font(.headline)
                                Text("E-Mail: \(user.email ?? "")")
                                    .font(.subheadline)
                                Text("Handy: \(user.phonenumber ?? "")")
                                    .font(.subheadline)
                                Text("Funkrufname: \(user.radiocallname ?? "")")
                                    .font(.subheadline)
                                Text("Sicherheitslevel: " + user.securitylevel.securityLevelTextFromInt16)
                                    .font(.subheadline)
                                
                                HStack {
                                    Text("Track-Farbe:")
                                        .font(.subheadline)
                                    if let hex = user.trackcolor, let color = Color(hex: hex) {
                                        ZStack {
                                            Rectangle()
                                                .fill(color)
                                                .frame(width: 80, height: 30)
                                                .cornerRadius(4)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                                )
                                            Text(hex)
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .shadow(radius: 1)
                                        }
                                    } else {
                                        Text("-")
                                            .font(.subheadline)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Alle Benutzer")
        }
    }
}
