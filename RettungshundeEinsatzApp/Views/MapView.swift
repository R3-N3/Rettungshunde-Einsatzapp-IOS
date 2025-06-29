//
//  MapView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 24.06.25.
//
import SwiftUI
import MapKit

struct MapView: View {
    @State private var showMenu = false
    @EnvironmentObject var router: AppRouter // Für die Logout Funktion notwendig
    @StateObject private var locationManager = LocationManager()
    @State private var isTracking = false
    @EnvironmentObject var bannerManager: BannerManager
    let thinSpace = "\u{2009}"
    @State private var mapType: MKMapType = .standard

    
    




    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                CustomMapView(coordinates: locationManager.fetchAllCoordinates(), mapType: $mapType)
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
                                
                                
                                Text(String(localized: "geographical_coordinates"))
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                                    .font(.footnote)
                                Text("   " + latLonToFormattedString(latitude: locationManager.latitude, longitude: locationManager.longitude))
                                    .padding(.horizontal)
                                    //.padding(.top, 0)
                                Text("MGRS")
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                                    .font(.footnote)
                                Text("   " + latLonToMGRS(latitude: locationManager.latitude, longitude: locationManager.longitude))
                                    .padding(.horizontal)
                                Text(String(localized: "accuracy"))
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                                    .font(.footnote)
                                Text("   ±\(Int(locationManager.accuracy))\(thinSpace)m")
                                    .padding(.horizontal)
                                Text(String(localized: "last_change"))
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                                    .font(.footnote)
                                Text("\(locationManager.time.formatted(date: .numeric, time: .standard))")
                                    .padding(.horizontal)
                                    .padding(.horizontal)
                                
                                
                                Text(String(localized: "menu"))
                                    .padding(.horizontal)
                                    .padding(.top, 20)
                                    .font(.headline)
                                
                                
                                Button(action: {
                                    if isTracking {
                                        locationManager.stopUpdating()
                                        bannerManager.showBanner(String(localized: "stop_gps_done"), type: .success)
                                    } else {
                                        locationManager.startUpdating()
                                        bannerManager.showBanner(String(localized: "start_gps_done"), type: .success)
                                    }
                                    isTracking.toggle()
                                }) {
                                    HStack {
                                        Image(systemName: isTracking ? "stop.fill" : "play.fill")
                                        Text(isTracking ? String(localized: "stop_gps") : String(localized: "start_gps"))
                                            .fontWeight(.medium)
                                    }
                                }
                                .buttonStyle(buttonStyleREAAnimated())
                                .padding(.horizontal)
                                .padding(.top, 5)
                                
                                
                                Button(action: {
                                    
                                }) {
                                    HStack {
                                        Image(systemName: "person.3")
                                        Text(String(localized: "contacts")).fontWeight(.medium)
                                    }
                                }
                                .buttonStyle(buttonStyleREAAnimatedRed())
                                .padding(.horizontal)
                                .padding(.top, 20)

                                
                                Button(action: {
                                    let success = deleteLokalGPSData()
                                    if success {
                                        bannerManager.showBanner(String(localized: "delete_my_gps_data_success"), type: .success)
                                    } else {
                                        bannerManager.showBanner(String(localized: "delete_my_gps_data_error"), type: .error)
                                    }
                                    
                                }) {
                                    HStack {
                                        Image(systemName: "trash")
                                        Text(String(localized: "delete_my_gps_data")).fontWeight(.medium)
                                    }
                                }
                                .buttonStyle(buttonStyleREAAnimated())
                                .padding(.horizontal)
                                .padding(.top, 20)
                                
                                
                                Button(action: {
                                    
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text(String(localized: "write_operation_report")).fontWeight(.medium)
                                    }
                                }
                                .buttonStyle(buttonStyleREAAnimatedRed())
                                .padding(.horizontal)
                                .padding(.top, 20)
                                
                                
                                Button(action: {
                                    
                                }) {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                        Text(String(localized: "delete_all_gps_data")).fontWeight(.medium)
                                    }
                                }
                                .buttonStyle(buttonStyleREAAnimatedRed())
                                .padding(.horizontal)
                                .padding(.top, 20)
                                
                                
                                
                                Button(action: {
                                    
                                }) {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                        Text(String(localized: "delete_all_areas")).fontWeight(.medium)
                                    }
                                }
                                .buttonStyle(buttonStyleREAAnimatedRed())
                                .padding(.horizontal)
                                .padding(.top, 20)
                                
                                Button(action: {
                                    
                                }) {
                                    HStack {
                                        Image(systemName: "person.crop.circle.badge.xmark")
                                        Text(String(localized: "manage_users")).fontWeight(.medium)
                                    }
                                }
                                .buttonStyle(buttonStyleREAAnimatedRed())
                                .padding(.horizontal)
                                .padding(.top, 20)
                                
                                // Settings Button
                                NavigationLink(destination: SettingsView()) {
                                    HStack {
                                        Image(systemName: "gear")
                                        Text(String(localized: "settings")).fontWeight(.medium)
                                    }
                                }
                                .buttonStyle(buttonStyleREAAnimated())
                                .padding(.horizontal)
                                .padding(.top, 20)
                                .padding(.bottom, 150)
                                
                                // Debug Button
                                #if DEBUG
                                Button(action: {
                                    locationManager.fetchAllLocations()
                                }) {
                                    HStack {
                                        Image(systemName: "list.bullet")
                                        Text(String(localized: "debug_button"))
                                            .fontWeight(.medium)
                                    }
                                    .buttonStyleREAGreen()
                                }
                                .padding(.horizontal)
                                .padding(.top, 20)
                                #endif
                                
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
                                .background(Color(.tertiarySystemBackground).opacity(0.8))
                                .clipShape(Circle())
                        }
                        .padding(.leading, 20)
                        .padding(.bottom, 40)
                        
                    }
                }
                
                Button(action: {
                    if mapType == .standard {
                        mapType = .satellite
                    } else {
                        mapType = .standard
                    }
                }) {
                    Image(systemName: "map")
                        .padding()
                        .background(Color(.tertiarySystemBackground).opacity(0.8))
                        .clipShape(Circle())
                }
                .padding()
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
