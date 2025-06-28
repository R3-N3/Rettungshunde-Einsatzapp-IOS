//
//  SettingsButtonStyle.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 28.06.25.
//

import SwiftUI

struct ButtonStyleREARed: ViewModifier {
    func body(content: Content) -> some View {
        content
        .padding()
        //.frame(width: 300, height: 40)
        .frame(minWidth: 0, maxWidth: 300)
        .background(Color(.systemRed))
        .foregroundColor(Color(.systemBackground))
        .cornerRadius(50)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

extension View {
    func buttonStyleREARed() -> some View {
        self.modifier(ButtonStyleREARed())
    }
}
