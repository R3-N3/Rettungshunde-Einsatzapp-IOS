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
            ScrollView{
                VStack(spacing: 30) {
                    
                    Spacer().frame(height: 70)
                    
                    Image("LogoWithoutBackgroundRettungshundeEinsatzapp")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
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
                    .font(.title)
                    .frame(width: 220)
                    .multilineTextAlignment(.leading)
                    
                    Spacer().frame(height:70)
                    
                    NavigationLink(destination: LoginView()) {
                        Text("Start")
                            .fontWeight(.medium)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(50)
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    
                    
                }
                .padding()
            }
        }
    }
}

#Preview {
    StartView()
}
