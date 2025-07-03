//
//  StartView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 24.06.25.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ScrollView {
                    VStack(spacing: 10) {
                        
                        Spacer()
                        
                        Image("LogoWithoutBackgroundRettungshundeEinsatzapp")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(alignment: .firstTextBaseline, spacing: 0) {
                                Text("R")
                                    .foregroundColor(.red)
                                    .font(.largeTitle)
                                    .bold()
                                Text("ettungshunde")
                                    .foregroundColor(.primary)
                                    .font(.title)
                            }
                            HStack(alignment: .firstTextBaseline, spacing: 0) {
                                Text("E")
                                    .foregroundColor(.red)
                                    .font(.largeTitle)
                                    .bold()
                                Text("insatz")
                                    .foregroundColor(.primary)
                                    .font(.title)
                            }
                            HStack(alignment: .firstTextBaseline, spacing: 0) {
                                Text("A")
                                    .foregroundColor(.red)
                                    .font(.largeTitle)
                                    .bold()
                                Text("pp")
                                    .foregroundColor(.primary)
                                    .font(.title)
                            }
                        }
                        .frame(width: 220)
                        .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        NavigationLink(destination: LoginView()) {
                            Text("Start")
                        }
                        .padding(.horizontal)
                        .buttonStyle(buttonStyleREAAnimated())
                        .padding(.bottom, 30)
                        
                    }
                    .frame(minHeight: geo.size.height) // nimmt volle Höhe ein
                    .frame(maxWidth: .infinity)
                    .frame(alignment: .center) // zentriert Inhalt vertikal
                }
            }
        }
    }
}

#Preview {
    StartView()
}
