//
//  MapView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 24.06.25.
//
import SwiftUI
import CoreData
import MapKit

struct MapView: View {
    @State private var showMenu = false
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var router: AppRouter // Für die Logout Funktion notwendig
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var bannerManager: BannerManager
    let thinSpace = "\u{2009}"
    @State private var mapType: MKMapType = .standard
    @State private var userTracks: [UserTrack] = []
    @State private var selectedUser: AllUserData? = nil
    @State private var refreshUserTracks = false
    @State private var showDeleteModal = false
    @State private var showDeleteAllGPSDataModal = false
    @State private var showDeleteAllAreasModal = false
    @State private var isSubmitting = false
    @State private var selectedArea: Areas? = nil
    @State private var refreshAreas = false


    
    @FetchRequest(
        entity: Areas.entity(),
        sortDescriptors: []
    ) var areas: FetchedResults<Areas>


    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                
                CustomMapView(
                    coordinates: locationManager.coordinates,
                    userTracks: userTracks,
                    mapType: $mapType,
                    refreshUserTracks: $refreshUserTracks,
                    selectedUser: $selectedUser,
                    selectedArea: $selectedArea,
                    areas: areas,
                    refreshAreas: $refreshAreas // ➡️ NEU
                )
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    locationManager.fetchAllCoordinates()
                    userTracks = loadUserTracks(context: context)
                }
                
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
                                
                                Text("   ±" + "\(Int(locationManager.accuracy))\(thinSpace)m")
                                    .padding(.horizontal)
                                
                                Text(String(localized: "last_change"))
                                    .padding(.horizontal)
                                    .padding(.top, 5)
                                    .font(.footnote)
                                
                                Text(locationManager.time.formatted(date: .numeric, time: .standard))
                                    .padding(.horizontal)
                                    .padding(.horizontal)
                                
                                Text(String(localized: "menu"))
                                    .padding(.horizontal)
                                    .padding(.top, 20)
                                    .font(.headline)
                                
                                // Start Stop GPS Button
                                Button(action: {
                                    if locationManager.isUpdating {
                                        locationManager.stopUpdating()
                                        bannerManager.showBanner(String(localized: "stop_gps_done"), type: .success)
                                    } else {
                                        locationManager.startUpdating()
                                        bannerManager.showBanner(String(localized: "start_gps_done"), type: .success)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: locationManager.isUpdating ? "stop.fill" : "play.fill")
                                        Text(locationManager.isUpdating ? String(localized: "stop_gps") : String(localized: "start_gps"))
                                            .fontWeight(.medium)
                                    }
                                }
                                .buttonStyle(buttonStyleREAAnimated())
                                .padding(.horizontal)
                                .padding(.top, 5)
                                
                                // Contacts Button
                                NavigationLink(destination: ContactsView()) {
                                    HStack {
                                        Image(systemName: "person.3")
                                        Text(String(localized: "contacts")).fontWeight(.medium)
                                    }
                                }
                                .buttonStyle(buttonStyleREAAnimated())
                                .padding(.horizontal)
                                .padding(.top, 20)
                                
                                
                                Button(action: {
                                    showDeleteModal = true
                                }) {
                                    HStack {
                                        Image(systemName: "trash")
                                        Text(String(localized: "delete_my_gps_data"))
                                            .fontWeight(.medium)
                                    }
                                }
                                .buttonStyle(buttonStyleREAAnimated())
                                .sheet(isPresented: $showDeleteModal) {
                                    DeleteConfirmationModal(
                                        title: String(localized: "confirm_delete_my_gps_titel"), //"⚠️ Wirklich löschen?",
                                        message: String(localized: "confirm_delete_my_gps_text"), //"Möchtest du wirklich alle deine GPS-Daten löschen? Diese Aktion kann nicht rückgängig gemacht werden.",
                                        confirmButtonTitle: String(localized: "delete"),
                                        onConfirm: {
                                            let success = deleteLokalGPSData()
                                            if success {
                                                bannerManager.showBanner(String(localized: "delete_my_gps_data_success"), type: .success)
                                                userTracks = loadUserTracks(context: context)
                                                locationManager.fetchAllCoordinates()
                                            } else {
                                                bannerManager.showBanner(String(localized: "delete_my_gps_data_error"), type: .error)
                                            }
                                            showDeleteModal = false
                                        },
                                        onCancel: {
                                            showDeleteModal = false
                                        }
                                    )
                                    .presentationDetents([.height(300)]) // ➔ Höhe auf 300pt begrenzt
                                    .presentationDragIndicator(.visible) // ➔ optional, Drag-Indikator oben anzeigen
                                }
                                .padding(.horizontal)
                                .padding(.top, 20)
                                
                                
                                NavigationLink(destination: OperationReportView()) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text(String(localized: "write_operation_report")).fontWeight(.medium)
                                    }
                                }
                                .buttonStyle(buttonStyleREAAnimated())
                                .padding(.horizontal)
                                .padding(.top, 20)
                                
                                
                                Button(action: {
                                    showDeleteAllGPSDataModal = true
                                }) {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                        Text(String(localized: "delete_all_gps_data")).fontWeight(.medium)
                                    }
                                }
                                .buttonStyle(buttonStyleREAAnimated())
                                .sheet(isPresented: $showDeleteAllGPSDataModal) {
                                    DeleteConfirmationModal(
                                        title: String(localized: "confirm_delete_all_user_gps_titel"),
                                        message: String(localized: "confirm_delete_all_user_gps_text"),
                                        confirmButtonTitle: String(localized: "delete"),
                                        onConfirm: {
                                            showDeleteAllGPSDataModal = false
                                            deleteAllGPSData { success, message in
                                                DispatchQueue.main.async {
                                                    if success {
                                      
                                                            
                                                            // Download alle GPS Locations aller Benutzer und trigger update der UI
                                                            downloadAllGpsLocations(context: context) { success, message in
                                                                refreshUserTracks = true
                                                                userTracks = loadUserTracks(context: context)
                                                            }
                                                        
                                                    } else {
                                                        bannerManager.showBanner(String(localized: "delete_all_gps_data_error"), type: .error)
                                                    }
                                                }
                                            }
                                        },
                                        onCancel: {
                                            showDeleteAllGPSDataModal = false
                                        }
                                    )
                                    .presentationDetents([.height(300)])
                                    .presentationDragIndicator(.visible)
                                }
                                .padding(.horizontal)
                                .padding(.top, 20)
                                
                                
                                Button(action: {
                                    showDeleteAllAreasModal = true
                                }) {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                        Text(String(localized: "delete_all_areas")).fontWeight(.medium)
                                    }
                                }
                                .buttonStyle(buttonStyleREAAnimated())
                                .sheet(isPresented: $showDeleteAllAreasModal) {
                                    DeleteConfirmationModal(
                                        title: String(localized: "confirm_delete_all_areas_titel"),
                                        message: String(localized: "confirm_delete_all_areas_text"),
                                        confirmButtonTitle: String(localized: "delete"),
                                        onConfirm: {
                                            isSubmitting = true
                                            deleteAllAreas { success, message in
                                                DispatchQueue.main.async {
                                                    isSubmitting = false
                                                    if success {
                                                        bannerManager.showBanner(String(localized: "delete_all_areas_success"), type: .success)
                                                    } else {
                                                        bannerManager.showBanner("Fehler beim Löschen: \(message)", type: .error)
                                                    }
                                                    showDeleteAllAreasModal = false
                                                }
                                            }
                                        },
                                        onCancel: {
                                            showDeleteAllAreasModal = false
                                        }
                                    )
                                    .presentationDetents([.height(300)])
                                    .presentationDragIndicator(.visible)
                                }
                                .padding(.horizontal)
                                .padding(.top, 20)
                                
                                NavigationLink(destination: UserListView()) {
                                    HStack {
                                        Image(systemName: "person.crop.circle.badge.xmark")
                                        Text(String(localized: "manage_users")).fontWeight(.medium)
                                    }
                                }.buttonStyle(buttonStyleREAAnimated())
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
                                    locationManager.fetchAllMyLocations()
                                    fetchAllUserData()
                                }) {
                                    HStack {
                                        Image(systemName: "list.bullet")
                                        Text(String(localized: "debug_button"))
                                            .fontWeight(.medium)
                                    }
                                    .buttonStyle(buttonStyleREAAnimatedGreen())
                                }
                                .buttonStyle(buttonStyleREAAnimatedYellow())
                                .padding(.horizontal)
                                .padding(.top, 20)
                                .padding(.bottom, 150)
                                
                                
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
                
                // Bttons auf der Karte
                VStack {
                    
                    Spacer()
                    
                    HStack {
    
                        Spacer()
                        
                        Button(action: {
                            downloadAllUserData(context: context) { success, message in
                                bannerManager.showBanner(String(localized: "banner_user_data_update_success"), type: .success)
                                
                                // Download alle GPS Locations aller Benutzer
                                downloadAllGpsLocations(context: context) { success, message in
                                    if success {
                                        bannerManager.showBanner(String(localized: "banner_download_all_gps_data_success"), type: .success)
                                        downloadAreas(context: context) { success, message in
                                            if success {
                                                bannerManager.showBanner(String(localized: "banner_download_all_areas_success"), type: .success)
                                                refreshUserTracks = true
                                                refreshAreas.toggle()
                                                userTracks = loadUserTracks(context: context)
                                            } else {
                                                bannerManager.showBanner(String(localized: "banner_download_all_areas_error"), type: .error)
                                            }
                                        }
                                    } else {
                                        bannerManager.showBanner(String(localized: "banner_user_data_update_error"), type: .error)
                                    }
                                }
                            }

                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title)
                                .padding()
                                .background(Color(.tertiarySystemBackground).opacity(0.8))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 5)
                    }
  
                    HStack {
    
                        Spacer()
                        
                        Button(action: {
                            if locationManager.isUpdating {
                                locationManager.stopUpdating()
                                bannerManager.showBanner(String(localized: "stop_gps_done"), type: .success)
                            } else {
                                locationManager.startUpdating()
                                bannerManager.showBanner(String(localized: "start_gps_done"), type: .success)
                            }
                        }) {
                            Image(systemName: locationManager.isUpdating ? "stop.fill" : "play.fill")
                                .font(.title)
                                .padding()
                                .background(Color(.tertiarySystemBackground).opacity(0.8))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 5)
                    }
                    
                    
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
                        
                        Spacer()
                          
                        Button(action: {
                            if mapType == .standard {
                                mapType = .satellite
                                } else {
                                    mapType = .standard
                                }
                        }) {
                            Image(systemName: "map.fill")
                                .font(.title)
                                .padding()
                                .background(Color(.tertiarySystemBackground).opacity(0.8))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 40)
                    }
                }
                
            }
            .sheet(item: $selectedArea) { area in
                VStack {
                    Text("🗺️ Fläche: \(area.name ?? "Unknown")")
                        .font(.title)
                    
                    Text("Farbe: \(area.color ?? "Unknown")")
                        .padding(.top)
                    
                    Text("Punkte:")
                        .font(.headline)
                        .padding(.top)
                    
                    Text(area.points ?? "Keine Punkte")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
            }
            .sheet(item: $selectedUser) { user in
                VStack {
                    Text("👤 " + (user.username ?? String(localized: "unknown")))
                        .font(.title)
                    
                    if let locationsSet = user.locations,
                               let locations = locationsSet.allObjects as? [AllUserGPSData],
                               let lastLocation = locations.sorted(by: { ($0.time ?? "") > ($1.time ?? "") }).first {
                        
                        Text(String(localized: "geographical_coordinates"))
                            .padding(.top, 0)
                            .font(.footnote)
                        
                        Text(latLonToFormattedString(latitude: lastLocation.latitude, longitude: lastLocation.longitude))
                        
                        Text(String(localized: "MGRS"))
                            .padding(.top, 2)
                            .font(.footnote)
                        
                        Text(latLonToMGRS(latitude: lastLocation.latitude, longitude: lastLocation.longitude))
                        
                        Text(String(localized: "accuracy"))
                            .padding(.top, 2)
                            .font(.footnote)
                        
                        Text(String(Int(lastLocation.accuracy)) + "\(thinSpace)" + "m")
                            .padding(.horizontal)
                        
                        Text(String(localized: "last_change"))
                            .padding(.top, 2)
                            .font(.footnote)
                        
                        Text(lastLocation.time ?? "Unknown")
                            .padding(.horizontal)
                        
                        
                            } else {
                                Text(String(localized: "no_coordinates_available"))
                            }
                }
                .padding()
                .presentationDetents([.height(320), .large])
                .presentationDragIndicator(.visible) // ➔ optional, Drag-Indikator anzeigen
            }
        }
        .onAppear {
            // Checke token, wenn keiner vorhanden wird Logout ausgeführt
            checkTokenAndDownloadMyUserData(router: router) { success, message in }

            // Download alle user data – verwende direkt den Environment Context
            downloadAllUserData(context: context) { success, message in
                bannerManager.showBanner(String(localized: "banner_user_data_update_success"), type: .success)
                
                // Download alle GPS Locations aller Benutzer
                downloadAllGpsLocations(context: context) { success, message in
                    if success {
                        bannerManager.showBanner(String(localized: "banner_download_all_gps_data_success"), type: .success)
                        refreshUserTracks = true
                        userTracks = loadUserTracks(context: context)
                    } else {
                        bannerManager.showBanner(String(localized: "banner_download_all_gps_data_error"), type: .error)
                    }
                }
            }
            
        }
        .overlay {
            if isSubmitting {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView(String(localized: "processing"))
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    func loadUserTracks(context: NSManagedObjectContext) -> [UserTrack] {
        let fetch: NSFetchRequest<AllUserData> = AllUserData.fetchRequest()
        var tracks: [UserTrack] = []

        // 🔵 Lade alle fremden Benutzertracks
        if let users = try? context.fetch(fetch) {
            for user in users {

                if let locationsSet = user.locations,
                   let locations = locationsSet.allObjects as? [AllUserGPSData],
                   !locations.isEmpty {

                    let sorted = locations.sorted { (a: AllUserGPSData, b: AllUserGPSData) in
                        (a.time ?? "") < (b.time ?? "")
                    }

                    let coords = sorted.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }

                    let colorHex = user.trackcolor ?? "#FF0000" // Fallback auf rot
                    //let colorHex = "#19FF00"
                    tracks.append(UserTrack(
                        user: user,
                        coordinates: coords,
                        color: (UIColor(hex: colorHex) ?? UIColor.systemRed),
                        iconColor: (UIColor(hex: colorHex) ?? UIColor.systemRed) // ➔ gleiche Farbe auch für iconColor
                    ))
                }
            }
        }

        // 🟢 Lade eigene MyGPSData Trackdaten
        let myFetch: NSFetchRequest<MyGPSData> = MyGPSData.fetchRequest()

        if let myLocations = try? context.fetch(myFetch), !myLocations.isEmpty {
            let sorted = myLocations.sorted { (a: MyGPSData, b: MyGPSData) in
                (a.time ?? Date.distantPast) < (b.time ?? Date.distantPast)
            }

            let coords = sorted.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }

            let hexString = UserDefaults.standard.string(forKey: "trackColor") ?? "#FF0000"
            let myTrack = UserTrack(user: nil, coordinates: coords, color: (UIColor(hex: hexString) ?? UIColor.systemRed))

            tracks.append(myTrack)
        }

        return tracks
    }
    
}


#if DEBUG
// Nur für Debug/Test zwecke
func fetchAllUserData() {
    let context = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest<AllUserData> = AllUserData.fetchRequest()

    do {
        let users = try context.fetch(fetchRequest)
        for user in users {
            print("🔍 User:")
            print("ID: \(user.id)")
            print("Name: \(user.username ?? "nil")")
            print("TrackColor: \(user.trackcolor ?? "nil")")
            print("Locations Count: \(user.locations?.count ?? 0)")
        }
    } catch {
        print("❌ Fehler beim Abrufen der Benutzerdaten: \(error.localizedDescription)")
    }
}
#endif



#Preview {
    MapView()
}
