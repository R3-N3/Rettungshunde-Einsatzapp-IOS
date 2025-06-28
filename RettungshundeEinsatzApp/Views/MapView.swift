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
    @StateObject private var locationManager = LocationManager()
    @State private var isTracking = false



    
    

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                CustomMapView()
                    .edgesIgnoringSafeArea(.all)
                // Menü
                if showMenu {
                    HStack(spacing: 0) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                
                                
                                Text(String(localized: "my_position"))
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                                    .font(.headline)
                                
                                
                                Text("Geographische Koordinaten")
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                                    .font(.footnote)
                                Text("   Latitude: \(locationManager.latitude)")
                                    .padding(.horizontal)
                                    //.padding(.top, 0)
                                Text("   Longitude: \(locationManager.longitude)")
                                    .padding(.horizontal)
                                Text("MGRS")
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                                    .font(.footnote)
                                Text("   ...")
                                    .padding(.horizontal)
                                Text("Genauigkeit")
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                                    .font(.footnote)
                                Text("   \(Int(locationManager.accuracy)) m")
                                    .padding(.horizontal)
                                Text("Letzte Änderung")
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                                    .font(.footnote)
                                Text("\(locationManager.time.formatted(date: .numeric, time: .standard))")
                                    .padding(.horizontal)
                                    .padding(.horizontal)
                                
                                
                                Text(String(localized: "Menü"))
                                    .padding(.horizontal)
                                    .padding(.top, 20)
                                    .font(.headline)
                                
                                
                                Button(action: {
                                    if isTracking {
                                        locationManager.stopUpdating()
                                    } else {
                                        locationManager.startUpdating()
                                    }
                                    isTracking.toggle()
                                }) {
                                    HStack {
                                        Image(systemName: isTracking ? "stop.fill" : "play.fill")
                                        Text(isTracking ? String(localized: "stop_gps") : String(localized: "start_gps"))
                                            .fontWeight(.medium)
                                    }
                                    .buttonStyleREA()
                                }
                                .padding(.horizontal)
                                .padding(.top, 5)
                                

                                Button(action: {
                                    locationManager.fetchAllLocations()
                                }) {
                                    HStack {
                                        Image(systemName: "list.bullet")
                                        Text("Debug Alle GPS Daten")
                                            .fontWeight(.medium)
                                    }
                                    .buttonStyleREAGreen()
                                }
                                .padding(.horizontal)
                                .padding(.top, 20)
                                
                                Button(action: {
                                    
                                }) {
                                    HStack {
                                        Image(systemName: "person.3")
                                        Text(String(localized: "contacts")).fontWeight(.medium)
                                    }
                                    .buttonStyleREARed()
                                }
                                .padding(.horizontal)
                                .padding(.top, 20)
                                
                                
                                Button(action: {
                                    
                                }) {
                                    HStack {
                                        Image(systemName: "trash")
                                        Text(String(localized: "delete_my_gps_data")).fontWeight(.medium)
                                    }
                                    .buttonStyleREARed()
                                }
                                .padding(.horizontal)
                                .padding(.top, 20)
                                
                                
                                Button(action: {
                                    
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text(String(localized: "write_operation_report")).fontWeight(.medium)
                                    }
                                    .buttonStyleREARed()
                                }
                                .padding(.horizontal)
                                .padding(.top, 20)
                                
                                
                                Button(action: {
                                    
                                }) {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                        Text(String(localized: "delete_all_gps_data")).fontWeight(.medium)
                                    }
                                    .buttonStyleREARed()
                                }
                                .padding(.horizontal)
                                .padding(.top, 20)
                                
                                
                                
                                Button(action: {
                                    
                                }) {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                        Text(String(localized: "delete_all_areas")).fontWeight(.medium)
                                    }
                                    .buttonStyleREARed()
                                }
                                .padding(.horizontal)
                                .padding(.top, 20)
                                
                                Button(action: {
                                    
                                }) {
                                    HStack {
                                        Image(systemName: "person.crop.circle.badge.xmark")
                                        Text(String(localized: "manage_users")).fontWeight(.medium)
                                    }
                                    
                                    .buttonStyleREARed()
                                }
                                .padding(.horizontal)
                                .padding(.top, 20)
                                
                                // Settings Button
                                NavigationLink(destination: SettingsView()) {
                                    HStack {
                                        Image(systemName: "gear")
                                        Text(String(localized: "settings")).fontWeight(.medium)
                                    }
                                    .buttonStyleREA()
                                }
                                .padding(.horizontal)
                                .padding(.top, 20)
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
