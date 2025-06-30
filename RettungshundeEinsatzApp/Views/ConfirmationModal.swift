//
//  Untitled.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 30.06.25.
//

import SwiftUI

struct DeleteConfirmationModal: View {
    var title: String
    var message: String
    var confirmButtonTitle: String
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)

            Text(message)
                .multilineTextAlignment(.center)
                .padding()

            HStack(spacing: 20) {
                Button(action: onCancel) {
                    Text("Abbrechen")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(buttonStyleREAAnimated())

                Button(action: onConfirm) {
                    Text(confirmButtonTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(buttonStyleREAAnimatedRed())
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}

struct SaveConfirmationModal: View {
    var title: String
    var message: String
    var confirmButtonTitle: String
    var onConfirm: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)

            Text(message)
                .multilineTextAlignment(.center)
                .padding()

            HStack(spacing: 20) {
                Button(action: onCancel) {
                    Text("Abbrechen")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(buttonStyleREAAnimated())

                Button(action: onConfirm) {
                    Text(confirmButtonTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(buttonStyleREAAnimatedGreen())
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}
