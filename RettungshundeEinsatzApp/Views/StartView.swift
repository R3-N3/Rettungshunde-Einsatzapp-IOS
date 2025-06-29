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
                VStack(spacing: 10) {
                    
                    Spacer().frame(height: 120)
                    
                    Image("LogoWithoutBackgroundRettungshundeEinsatzapp")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                    
                    Spacer().frame(height: 0)
                    
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
                    .font(.title)
                    .frame(width: 220)
                    .multilineTextAlignment(.leading)
                    
                    Spacer().frame(height:70)
                    
                    NavigationLink(destination: LoginView()) {
                        Text("Start")
                    }
                    .padding(.horizontal)
                    .buttonStyle(buttonStyleREAAnimated())
                    
                    
                }
                .frame(maxWidth: 500)
                .padding(.horizontal)
                .padding(.top, 60)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    StartView()
}
