//
//  BannerView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 28.06.25.
//

import SwiftUI

struct InfoBannerView: View {
    let message: String

    var body: some View {
        VStack {
            Text(message)
                .font(.body)
                .foregroundColor(Color(.systemBackground))
                .padding()
                .background(Color(.systemFill).opacity(0.8))
                .cornerRadius(50)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                .padding(.top, 50)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct SuccessBannerView: View {
    let message: String

    var body: some View {
        VStack {
            Text(message)
                .font(.body)
                .foregroundColor(Color(.systemBackground))
                .padding()
                .background(Color(.systemGreen).opacity(0.8))
                .cornerRadius(50)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                .padding(.top, 50)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct ErrorBannerView: View {
    let message: String

    var body: some View {
        VStack {
            Text(message)
                .font(.body)
                .foregroundColor(Color(.systemBackground))
                .padding()
                .background(Color(.systemRed).opacity(0.8))
                .cornerRadius(50)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                .padding(.top, 50)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}


struct WarningBannerView: View {
    let message: String

    var body: some View {
        VStack {
            Text(message)
                .font(.body)
                .foregroundColor(Color(.systemBackground))
                .padding()
                .background(Color(.systemYellow).opacity(0.8))
                .cornerRadius(50)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                .padding(.top, 50)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
