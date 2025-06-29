//
//  SettingsButtonStyle.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 28.06.25.
//
import SwiftUI

struct buttonStyleREAAnimatedRed: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(minWidth: 0, maxWidth: 300)
            .background(Color(.systemRed))
            .foregroundColor(Color(.systemBackground))
            .cornerRadius(50)
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
