//
//  ContentView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 24.06.25.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)

                Text("Hello, world!")

                NavigationLink(destination: LoginView()) {
                    Text(String(localized: "login"))
                        .fontWeight(.medium)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

#Preview {
    StartView()
}
