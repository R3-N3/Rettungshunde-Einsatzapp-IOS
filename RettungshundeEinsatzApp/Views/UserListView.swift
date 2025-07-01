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
                // ➔ Section mit Button ganz oben
                Section {
                    HStack{
                        NavigationLink(destination: CreateUserView()) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text(String(localized: "create_new_user"))
                                    .fontWeight(.semibold)
                            }
                            .padding()
                        }
                        
                    }
                }

                // ➔ Users anzeigen
                ForEach(users, id: \.self) { user in
                    NavigationLink(destination: UserEditView(user: user)) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.username ?? String(localized: "unknown"))
                                .font(.headline)
                            Text(String(localized: "email") + " \(user.email ?? "")")
                                .font(.subheadline)
                            Text(String(localized: "phone_number") + ": \(user.phonenumber ?? "")")
                                .font(.subheadline)
                            Text(String(localized: "radio_call_name") + ": \(user.radiocallname ?? "")")
                                .font(.subheadline)
                            Text(String(localized: "security_level") + ": " + user.securitylevel.securityLevelTextFromInt16)
                                .font(.subheadline)
                            
                            HStack {
                                Text(String(localized: "track_color"))
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
                                    Text(String(localized: "unknown"))
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(String(localized: "all_user"))
        }
    }
}
