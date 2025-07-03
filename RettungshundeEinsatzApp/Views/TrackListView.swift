//
//  TrackListView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 03.07.25.
//


import SwiftUI
import MapKit
import CoreData

struct TrackListView: View {
    @Environment(\.managedObjectContext) var context
    
    @State private var userTracks: [UserTrack] = []
    @State private var myTrack: UserTrack? = nil
    @EnvironmentObject var router: AppRouter
    @State private var showShareSheet = false
    @State private var gpxURL: URL?
    @State private var isExporting = false
    @State private var showDeleteAllGPSDataModal = false
    @State private var showDeleteMyGPSDataModal = false
    @EnvironmentObject var bannerManager: BannerManager

    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    
                    HStack{
                        Spacer()
                        Button(action: {
                            showDeleteMyGPSDataModal = true
                        }) {
                            Label(String(localized: "delete_my_gps_data"), systemImage: "trash")
                        }
                        .buttonStyle(buttonStyleREAAnimatedRed())
                        .sheet(isPresented: $showDeleteMyGPSDataModal) {
                            deleteMyGPSDataSheet()
                        }
                        .padding(.horizontal)
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                        
                    if router.isLevelFuehrungskraft || router.isLevelAdmin {
                        HStack{
                            Spacer()
                            Button(action: {
                                showDeleteAllGPSDataModal = true
                            }) {
                                Label(String(localized: "delete_all_gps_data"), systemImage: "trash")
                            }
                            .buttonStyle(buttonStyleREAAnimatedRed())
                            .sheet(isPresented: $showDeleteAllGPSDataModal) {
                                deleteAllGPSDataSheet()
                            }
                            .padding(.horizontal)
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                        
     
                    
                    
                        HStack{
                            Spacer()
                            Button(action: {
                                exportTracksAsGPX()
                            }) {
                                Label("Alle Tracks als GPX exportieren", systemImage: "square.and.arrow.up")
                            }
                            .disabled(isExporting)
                            .buttonStyle(buttonStyleREAAnimatedGreen())
                            
                            if isExporting {
                                ProgressView("Exportiere…")
                            }
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                
                Section(header: Text("Mein Track")) {
                    if let myTrack = myTrack {
                        Text("\(myTrack.coordinates.count) Punkte")
                    } else {
                        Text("Keine eigenen Tracks vorhanden")
                            .foregroundColor(.secondary)
                    }
                }
                
                if router.isLevelFuehrungskraft || router.isLevelAdmin {
                    Section(header: Text("Alle Benutzer")) {
                        if userTracks.isEmpty {
                            Text("Keine Benutzertracks vorhanden")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(userTracks.indices, id: \.self) { index in
                                let track = userTracks[index]
                                Text("\(track.user?.username ?? "Unknown"): \(track.coordinates.count) Punkte")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Alle Tracks")
            .onAppear {
                loadAllTracks()
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = gpxURL {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }
    
    private func exportTracksAsGPX() {
        isExporting = true
        DispatchQueue.global(qos: .background).async {
            let gpxString = buildGPXString()
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("tracks_export.gpx")
            
            do {
                try gpxString.write(to: tempURL, atomically: true, encoding: .utf8)
                
                DispatchQueue.main.async {
                    self.gpxURL = tempURL
                    self.showShareSheet = true
                    self.isExporting = false
                }
            } catch {
                print("❌ Fehler beim Schreiben der GPX Datei: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isExporting = false
                }
            }
        }
    }
    
    private func buildGPXString() -> String {
        var gpx = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="RettungshundeEinsatzApp" xmlns="http://www.topografix.com/GPX/1/1">
        """
        
        let outputFormatter = ISO8601DateFormatter()
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        inputFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // 🟢 Eigener Track
        if let myTrack = myTrack {
            gpx += "\n<trk><name>Mein Track</name><trkseg>"
            for coord in myTrack.coordinates {
                let time = outputFormatter.string(from: Date()) // Falls kein Zeitfeld vorhanden
                gpx += "\n<trkpt lat=\"\(coord.latitude)\" lon=\"\(coord.longitude)\"><time>\(time)</time></trkpt>"
            }
            gpx += "\n</trkseg></trk>"
        }
        
        // 🔵 Alle Benutzertracks
        for track in userTracks {
            gpx += "\n<trk><name>\(track.user?.username ?? "Unknown")</name><trkseg>"
            
            if let user = track.user,
               let locationsSet = user.locations,
               let locations = locationsSet.allObjects as? [AllUserGPSData] {
                
                let sorted = locations.sorted { ($0.time ?? "") < ($1.time ?? "") }
                
                for loc in sorted {
                    let timeString = loc.time ?? ""
                    var isoTime = ""
                    if let date = inputFormatter.date(from: timeString) {
                        isoTime = outputFormatter.string(from: date)
                    } else {
                        isoTime = outputFormatter.string(from: Date())
                    }
                    
                    gpx += "\n<trkpt lat=\"\(loc.latitude)\" lon=\"\(loc.longitude)\"><time>\(isoTime)</time></trkpt>"
                }
            }
            gpx += "\n</trkseg></trk>"
        }
        
        gpx += "\n</gpx>"
        return gpx
    }
    
    private func loadAllTracks() {
        var tracks: [UserTrack] = []
        let fetch: NSFetchRequest<AllUserData> = AllUserData.fetchRequest()
        if let users = try? context.fetch(fetch) {
            for user in users {
                if let locationsSet = user.locations,
                   let locations = locationsSet.allObjects as? [AllUserGPSData],
                   !locations.isEmpty {
                    
                    let sorted = locations.sorted { ($0.time ?? "") < ($1.time ?? "") }
                    let coords = sorted.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
                    
                    let colorHex = user.trackcolor ?? "#FF0000"
                    tracks.append(UserTrack(
                        user: user,
                        coordinates: coords,
                        color: UIColor(hex: colorHex) ?? .systemRed,
                        iconColor: UIColor(hex: colorHex) ?? .systemRed
                    ))
                }
            }
        }
        self.userTracks = tracks
        
        let myFetch: NSFetchRequest<MyGPSData> = MyGPSData.fetchRequest()
        if let myLocations = try? context.fetch(myFetch), !myLocations.isEmpty {
            let sorted = myLocations.sorted { ($0.time ?? Date.distantPast) < ($1.time ?? Date.distantPast) }
            let coords = sorted.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
            let hexString = UserDefaults.standard.string(forKey: "trackColor") ?? "#FF0000"
            self.myTrack = UserTrack(
                user: nil,
                coordinates: coords,
                color: UIColor(hex: hexString) ?? .systemRed
            )
        } else {
            self.myTrack = nil
        }
    }
    
    @ViewBuilder
    func deleteMyGPSDataSheet() -> some View {
        DeleteConfirmationModal(
            title: String(localized: "confirm_delete_my_gps_titel"),
            message: String(localized: "confirm_delete_my_gps_text"),
            confirmButtonTitle: String(localized: "delete"),
            onConfirm: {
                let success = deleteLokalGPSData()
                if success {
                    bannerManager.showBanner(String(localized: "delete_my_gps_data_success"), type: .success)
                    loadAllTracks()
                    //userTracks = loadUserTracks(context: context)
                    //locationManager.fetchAllCoordinates()
                } else {
                    bannerManager.showBanner(String(localized: "delete_my_gps_data_error"), type: .error)
                }
                showDeleteMyGPSDataModal = false
            },
            onCancel: {
                showDeleteMyGPSDataModal = false
            }
        )
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
    }
    
    @ViewBuilder
    func deleteAllGPSDataSheet() -> some View {
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
                                loadAllTracks()
                                //userTracks = loadUserTracks(context: context)
                                //refreshUserTracks = true
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
    
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}





#Preview {
    TrackListView()
}
/*

import SwiftUI
import MapKit
import CoreData

struct TrackListView: View {
    @Environment(\.managedObjectContext) var context
    
    @State private var userTracks: [UserTrack] = []
    @State private var myTrack: UserTrack? = nil
    @EnvironmentObject var router: AppRouter
    @State private var showDeleteAllGPSDataModal = false
    @State private var showDeleteMyGPSDataModal = false
    @EnvironmentObject var bannerManager: BannerManager
    @State private var isExporting = false
    @State private var gpxURL: URL? = nil
    @State private var showShareSheet = false


    
    var body: some View {
        NavigationStack {
            List {
               
                Section{
                    HStack{
                        Spacer()
                        Button(action: {
                            showDeleteMyGPSDataModal = true
                        }) {
                            Label(String(localized: "delete_my_gps_data"), systemImage: "trash")
                        }
                        .buttonStyle(buttonStyleREAAnimatedRed())
                        .sheet(isPresented: $showDeleteMyGPSDataModal) {
                            deleteMyGPSDataSheet()
                        }
                        .padding(.horizontal)
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                        
                    if router.isLevelFuehrungskraft || router.isLevelAdmin {
                        HStack{
                            Spacer()
                            Button(action: {
                                showDeleteAllGPSDataModal = true
                            }) {
                                Label(String(localized: "delete_all_gps_data"), systemImage: "trash")
                            }
                            .buttonStyle(buttonStyleREAAnimatedRed())
                            .sheet(isPresented: $showDeleteAllGPSDataModal) {
                                deleteAllGPSDataSheet()
                            }
                            .padding(.horizontal)
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                        
                        HStack{
                            Spacer()
                            Button(action: {
                                exportTracks()
                            }) {
                                Label("Tracks exportieren", systemImage: "square.and.arrow.up")
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isExporting)
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                
                
                // 🟢 Eigener Track
                Section(header: Text("Mein Track")) {
                    if let myTrack = myTrack {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Mein Track")
                                    .font(.headline)
                                Text("\(myTrack.coordinates.count) Punkte")
                                    .font(.subheadline)
                                let distance = myTrack.coordinates.totalDistance()
                                Text(String(format: "Distanz: %.1f m", distance))
                                    .font(.subheadline)
                            }
                            Spacer()
                            Circle()
                                .fill(Color(myTrack.color))
                                .frame(width: 20, height: 20)
                        }
                    } else {
                        Text("Keine eigenen Tracks vorhanden")
                            .foregroundColor(.secondary)
                    }
                }
                
                // 🔵 Alle Benutzertracks
                    if router.isLevelFuehrungskraft || router.isLevelAdmin {
                        Section(header: Text("Alle Benutzer")) {
                            if userTracks.isEmpty {
                                Text("Keine Benutzertracks vorhanden")
                                    .foregroundColor(.secondary)
                            } else {
                                ForEach(userTracks.indices, id: \.self) { index in
                                    let track = userTracks[index]
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(track.user?.username ?? "Unknown")
                                                .font(.headline)
                                            Text("\(track.coordinates.count) Punkte")
                                                .font(.subheadline)
                                            let distance = track.coordinates.totalDistance()
                                            Text(String(format: "Distanz: %.1f m", distance))
                                                .font(.subheadline)
                                        }
                                        Spacer()
                                        Circle()
                                            .fill(Color(track.color))
                                            .frame(width: 20, height: 20)
                                    }
                                }
                            }
                        }
                    }
            }
            .navigationTitle("Alle Tracks")
            .onAppear {
                loadAllTracks()
            }
        }
    }

    
    private func loadAllTracks() {
        var tracks: [UserTrack] = []

        // 🔵 Alle Benutzertracks
        let fetch: NSFetchRequest<AllUserData> = AllUserData.fetchRequest()
        if let users = try? context.fetch(fetch) {
            for user in users {
                if let locationsSet = user.locations,
                   let locations = locationsSet.allObjects as? [AllUserGPSData],
                   !locations.isEmpty {

                    let sorted = locations.sorted { ($0.time ?? "") < ($1.time ?? "") }
                    let coords = sorted.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }

                    let colorHex = user.trackcolor ?? "#FF0000"
                    tracks.append(UserTrack(
                        user: user,
                        coordinates: coords,
                        color: UIColor(hex: colorHex) ?? .systemRed,
                        iconColor: UIColor(hex: colorHex) ?? .systemRed
                    ))
                }
            }
        }
        self.userTracks = tracks

        // 🟢 Eigene Trackdaten
        let myFetch: NSFetchRequest<MyGPSData> = MyGPSData.fetchRequest()
        if let myLocations = try? context.fetch(myFetch), !myLocations.isEmpty {
            let sorted = myLocations.sorted { ($0.time ?? Date.distantPast) < ($1.time ?? Date.distantPast) }
            let coords = sorted.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
            let hexString = UserDefaults.standard.string(forKey: "trackColor") ?? "#FF0000"
            self.myTrack = UserTrack(
                user: nil,
                coordinates: coords,
                color: UIColor(hex: hexString) ?? .systemRed
            )
        } else {
            // 🔴 Keine eigenen Tracks ➔ myTrack auf nil setzen
            self.myTrack = nil
        }
    }
    
    @ViewBuilder
    func deleteAllGPSDataSheet() -> some View {
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
                                loadAllTracks() 
                                //userTracks = loadUserTracks(context: context)
                                //refreshUserTracks = true
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
    
    @ViewBuilder
    func deleteMyGPSDataSheet() -> some View {
        DeleteConfirmationModal(
            title: String(localized: "confirm_delete_my_gps_titel"),
            message: String(localized: "confirm_delete_my_gps_text"),
            confirmButtonTitle: String(localized: "delete"),
            onConfirm: {
                let success = deleteLokalGPSData()
                if success {
                    bannerManager.showBanner(String(localized: "delete_my_gps_data_success"), type: .success)
                    loadAllTracks()
                    //userTracks = loadUserTracks(context: context)
                    //locationManager.fetchAllCoordinates()
                } else {
                    bannerManager.showBanner(String(localized: "delete_my_gps_data_error"), type: .error)
                }
                showDeleteMyGPSDataModal = false
            },
            onCancel: {
                showDeleteMyGPSDataModal = false
            }
        )
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
    }
    
    private func exportTracks() {
        isExporting = true

        DispatchQueue.global(qos: .userInitiated).async {
            let gpx = generateGPX()

            let url = FileManager.default.temporaryDirectory.appendingPathComponent("AllTracks.gpx")
            do {
                try gpx.write(to: url, atomically: true, encoding: .utf8)

                DispatchQueue.main.async {
                    self.gpxURL = url
                    self.isExporting = false
                    self.showShareSheet = true
                }
            } catch {
                print("❌ Fehler beim Schreiben der GPX Datei: \(error)")
                DispatchQueue.main.async {
                    self.isExporting = false
                }
            }
        }
    }
    
    private func generateGPX() -> String {
        var gpxString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="RettungshundeEinsatzApp" xmlns="http://www.topografix.com/GPX/1/1">
        """

        // 🟢 Mein Track
        if let myTrack = myTrack {
            gpxString += gpxTrackString(track: myTrack, name: "Mein Track")
        }

        // 🔵 Benutzertracks
        for track in userTracks {
            let username = track.user?.username ?? "Unbekannter Benutzer"
            gpxString += gpxTrackString(track: track, name: username)
        }

        gpxString += "</gpx>"
        return gpxString
    }

    private func gpxTrackString(track: UserTrack, name: String) -> String {
        var trackString = """
        
        <trk>
            <name>\(name)</name>
            <trkseg>
        """

        for coord in track.coordinates {
            trackString += """
            
                <trkpt lat="\(coord.latitude)" lon="\(coord.longitude)">
                </trkpt>
            """
        }

        trackString += """
        
            </trkseg>
        </trk>
        """
        return trackString
    }
    
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}



#Preview {
    TrackListView()
}
*/
