//
//  MapView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 24.06.25.
//
import SwiftUI

struct MapView: View {
    @State private var showMenu = false
    @EnvironmentObject var router: AppRouter // Für die Logout Funktion notwendig

    
    

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                CustomMapView()
                    .edgesIgnoringSafeArea(.all)
                // Menü
                if showMenu {
                    HStack(spacing: 0) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                
                                
                                Text(String(localized: "my_position"))
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                                
                                
                                Text("...")
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                                
                                
                                Text("Menü")
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                                
                                
                                Button(action: {
                                    
                                }) {
                                    HStack {
                                        Image(systemName: "play.fill")
                                        Text(String(localized: "start_gps")).fontWeight(.medium)
                                    }
                                    .padding()
                                    .frame(width: 220, height: 40)
                                    .background(Color(.systemRed))
                                    .foregroundColor(Color(.systemBackground))
                                    .cornerRadius(50)
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                }
                                .padding(.horizontal)
                                .padding(.top, 5)
                                
                                
                                Button(action: {
                                    
                                }) {
                                    HStack {
                                        Image(systemName: "person.3")
                                        Text(String(localized: "contacts")).fontWeight(.medium)
                                    }
                                    .padding()
                                    .frame(width: 220, height: 40)
                                    .background(Color(.systemRed))
                                    .foregroundColor(Color(.systemBackground))
                                    .cornerRadius(50)
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                }
                                .padding(.horizontal)
                                .padding(.top, 5)
                                
                                
                                Button(action: {
                                    
                                }) {
                                    HStack {
                                        Image(systemName: "trash")
                                        Text(String(localized: "delete_mx_gps_data")).fontWeight(.medium)
                                    }
                                    .padding()
                                    .frame(width: 220, height: 80)
                                    .background(Color(.systemRed))
                                    .foregroundColor(Color(.systemBackground))
                                    .cornerRadius(50)
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                }
                                .padding(.horizontal)
                                .padding(.top, 5)
                                
                                
                                Button(action: {
                                    
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text(String(localized: "write_operation_report")).fontWeight(.medium)
                                    }
                                    .padding()
                                    .frame(width: 220, height: 80)
                                    .background(Color(.systemRed))
                                    .foregroundColor(Color(.systemBackground))
                                    .cornerRadius(50)
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                }
                                .padding(.horizontal)
                                .padding(.top, 5)
                                
                                
                                Button(action: {
                                    
                                }) {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                        Text(String(localized: "delete_all_gps_data")).fontWeight(.medium)
                                    }
                                    .padding()
                                    .frame(width: 220, height: 80)
                                    .background(Color(.systemRed))
                                    .foregroundColor(Color(.systemBackground))
                                    .cornerRadius(50)
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                }
                                .padding(.horizontal)
                                .padding(.top, 5)
                                
                                
                                
                                Button(action: {
                                    
                                }) {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                        Text(String(localized: "delete_all_areas")).fontWeight(.medium)
                                    }
                                    .padding()
                                    .frame(width: 220, height: 40)
                                    .background(Color(.systemRed))
                                    .foregroundColor(Color(.systemBackground))
                                    .cornerRadius(50)
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                }
                                .padding(.horizontal)
                                .padding(.top, 5)
                                
                                Button(action: {
                                    
                                }) {
                                    HStack {
                                        Image(systemName: "person.crop.circle.badge.xmark")
                                        Text(String(localized: "manage_users")).fontWeight(.medium)
                                    }
                                    .padding()
                                    .frame(width: 220, height: 40)
                                    .background(Color(.systemRed))
                                    .foregroundColor(Color(.systemBackground))
                                    .cornerRadius(50)
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                }
                                .padding(.horizontal)
                                .padding(.top, 5)
                                
                                
                                NavigationLink(destination: SettingsView()) {
                                    HStack {
                                        Image(systemName: "gear")
                                        Text(String(localized: "settings")).fontWeight(.medium)
                                    }
                                    .padding()
                                    .frame(width: 220, height: 40)
                                    .background(Color(.systemBlue))
                                    .foregroundColor(Color(.systemBackground))
                                    .cornerRadius(50)
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                }
                                .padding(.horizontal)
                                .padding(.top, 5)
                                .padding(.bottom, 150)
                                
                                
                                
                            }
                            .padding()
                        }
                        .frame(maxWidth: 280, maxHeight: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .shadow(radius: 4)
                        
                    }
                    .edgesIgnoringSafeArea(.bottom)
                }
                
                // Menü-Button immer sichtbar
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            withAnimation {
                                showMenu.toggle()
                            }
                        }) {
                            Image(systemName: showMenu ? "xmark" : "line.3.horizontal")
                                .font(.title)
                                .padding()
                                .background(Color(.tertiarySystemBackground))
                                .clipShape(Circle())
                        }
                        .padding(.leading, 20)
                        .padding(.bottom, 40)
                        
                    }
                }
            }
        }
        .onAppear {
            // Checke token, wenn keiner vorhanden wird Logout ausgeführt
            checkTokenAndDownloadMyUserData(router: router) { success, message in}
        }
    }
    
}

#Preview {
    MapView()
}
