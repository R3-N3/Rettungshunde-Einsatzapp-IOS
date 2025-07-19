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
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var router: AppRouter
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var bannerManager: BannerManager

    let thinSpace = "\u{2009}"

    @State private var showMenu = false
    @State private var mapType: MKMapType = .standard
    @State private var userTracks: [UserTrack] = []
    @State private var selectedUser: AllUserData? = nil
    @State private var refreshUserTracks = false
    @State private var isSubmitting = false
    @State private var selectedArea: Area? = nil
    @State private var refreshAreas = false
    @State private var isDrawingArea = false
    @State private var drawingAreaCoordinates: [CLLocationCoordinate2D] = []
    @State private var showAreaInputSheet = false
    @State private var newAreaTitle = ""
    @State private var newAreaDescription = ""
    @State private var newAreaColor = "#FF0000"
    @State private var refreshMapView = false
    @State private var animate = false

    

    @FetchRequest(entity: Area.entity(), sortDescriptors: []) var newAreas: FetchedResults<Area>

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                mapViewContent

                if showMenu {
                    menuView
                }

                buttonsOverlay
            }
            .onAppear {
                onAppearActions()
            }
            .onChange(of: locationManager.isUpdating) { oldValue, newValue in
                animate = newValue
            }
            .overlay {
                if isSubmitting {
                    loadingOverlay
                }
            }
            .sheet(item: $selectedUser) { user in
                userDetailSheet(user: user)
            }
            .sheet(isPresented: $showAreaInputSheet, onDismiss: {
                drawingAreaCoordinates = []
                refreshMapView = true
                isDrawingArea = false
            }) {
                areaInputSheetView()
            }
            .sheet(item: $selectedArea) { area in
                areaDetailSheet(area: area)
            }
        }
    }

    
    
    
    
    
    
    
    // MARK: - Subviews

    private var mapViewContent: some View {
        CustomMapView(
            coordinates: locationManager.coordinates,
            userTracks: userTracks,
            mapType: $mapType,
            refreshUserTracks: $refreshUserTracks,
            selectedUser: $selectedUser,
            selectedArea: $selectedArea,
            newAreas: Array(newAreas),
            refreshAreas: $refreshAreas,
            isDrawingArea: $isDrawingArea,
            drawingAreaCoordinates: $drawingAreaCoordinates,
            refreshMapView: $refreshMapView
        )
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            locationManager.fetchAllCoordinates()
            userTracks = loadUserTracks(context: context)
        }
    }

    private var menuView: some View {
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
                            if locationManager.isUpdating {
                                Image(systemName: "record.circle")
                                    .foregroundColor(.red)
                            } else {
                                Image(systemName: "record.circle")
                                    //.foregroundColor(.blue)
                            }
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
                            Image(systemName: "person.3.fill")
                            Text(String(localized: "contacts")).fontWeight(.medium)
                        }
                    }
                    .buttonStyle(buttonStyleREAAnimated())
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
                    
                    NavigationLink(destination: TrackListView()) {
                        HStack {
                            Image(systemName: "point.bottomleft.forward.to.point.topright.filled.scurvepath")
                            Text(String(localized: "manage_tracks")).fontWeight(.medium)
                        }
                    }
                    .buttonStyle(buttonStyleREAAnimated())
                    .padding(.horizontal)
                    .padding(.top, 20)

                    NavigationLink(destination: AreasListView()) {
                        HStack {
                            Image(systemName: "square.3.stack.3d.top.fill")
                            Text(String(localized: "manage_areas")).fontWeight(.medium)
                        }
                    }
                    .buttonStyle(buttonStyleREAAnimated())
                    .padding(.horizontal)
                    .padding(.top, 20)

                    
                    // Zeige Button Benutzerverwaltung für Admin
                    if router.isLevelAdmin {
                        NavigationLink(destination: UserListView()) {
                            HStack {
                                Image(systemName: "person.2.badge.gearshape.fill")
                                Text(String(localized: "manage_users")).fontWeight(.medium)
                            }
                        }.buttonStyle(buttonStyleREAAnimated())
                            .padding(.horizontal)
                            .padding(.top, 20)
                    }
                    
                    
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
                    
                }
                .padding()
                
            }
            .frame(maxWidth: 280, maxHeight: .infinity)
            .background(Color(.secondarySystemBackground))
            .shadow(radius: 4)
        }
        .edgesIgnoringSafeArea(.bottom)
    }

    private var buttonsOverlay: some View {
        VStack {
            
            if isDrawingArea {
                Text(String(format: "Fläche: %.2f m²", drawingAreaCoordinates.calculateArea()))
                    .font(.headline)
                    .padding(8)
                    .background(Color(.systemBackground).opacity(0.8))
                    .cornerRadius(8)
                    .padding(.top, 50)
            }
            
            Spacer()
            
            HStack {
                VStack{
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            showMenu.toggle()
                        }
                    }) {
                        Image(systemName: showMenu ? "xmark" : "line.3.horizontal")
                            .font(.title)
                            .frame(width: 30, height: 30)
                            .padding()
                            .background(Color(.tertiarySystemBackground).opacity(0.8))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)
                    .padding(.bottom, 40)
                    .disabled(isDrawingArea)
                    
                }
                
                Spacer()
                
                VStack{
                    Spacer()
                    
                    if router.isLevelFuehrungskraft || router.isLevelAdmin {
                        Button(action: {
                            if isDrawingArea {
                                finishDrawingArea()
                            } else {
                                showMenu = false
                                drawingAreaCoordinates = []
                                isDrawingArea = true
                                refreshMapView = false
                            }
                        }) {
                            Image(systemName: isDrawingArea ? "square.and.arrow.down" : "plus.square.dashed")
                                .font(.title)
                                .frame(width: 30, height: 30)
                                .padding()
                                .background(Color(.tertiarySystemBackground).opacity(0.8))
                                .clipShape(Circle())
                                .foregroundColor(isDrawingArea ? Color(.systemGreen) : Color(.systemBlue))
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 5)
                    }
                    
                    Button(action: {
                        downloadAllUserData(context: context) { success, message in
                        }
                        
                        
                        if router.isLevelAdmin || router.isLevelFuehrungskraft {
                            downloadAllGpsLocations(context: context) { success, _ in
                                refreshUserTracks = success
                            }
                            
                            uploadAreasToServer(context: context) { success, message in
                                if success {
                                    downloadAreas(context: context) { success, message in
                                        print("Download Areas: \(message)")
                                        if success {
                                            context.perform {
                                                do {
                                                    try context.save()
                                                    context.refreshAllObjects()                                            } catch {
                                                        print("❌ Fehler beim CoreData Save nach downloadAreas: \(error.localizedDescription)")
                                                    }
                                            }
                                            DispatchQueue.main.async {
                                                refreshAreas = true
                                            }
                                        } else {
                                            if message == "Bereits in Bearbeitung"{
                                                
                                            }else{
                                                bannerManager.showBanner("Fehler beim Download der Flächen: \(message)", type: .error)
                                            }
                                        }
                                    }                            } else {
                                        print("❌ Upload fehlgeschlagen: \(message)")
                                    }
                                
                            }
                        }else{
                            downloadAreas(context: context) { success, message in
                                print("Download Areas: \(message)")
                                if success {
                                    // ggf. deine State-Variablen aktualisieren
                                    refreshAreas = true
                                } else {
                                    if message == "Bereits in Bearbeitung"{
                                        
                                    }else{
                                        bannerManager.showBanner("Fehler beim Download der Flächen: \(message)", type: .error)
                                    }
                                }
                            }
                        }
                        
                        if router.isLevelAdmin || router.isLevelFuehrungskraft{
                            downloadAllGpsLocations(context: context) { success, message in
                                if success {
                                    userTracks = loadUserTracks(context: context)
                                    refreshUserTracks = true
                                } else {
                                    bannerManager.showBanner(String(localized: "banner_user_data_update_error"), type: .error)
                                }
                            }
                        }
                        
                        
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title)
                            .frame(width: 30, height: 30)
                            .padding()
                            .background(Color(.tertiarySystemBackground).opacity(0.8))
                            .clipShape(Circle())
                    }
                    .disabled(isDrawingArea)
                    .padding(.trailing, 20)
                    .padding(.bottom, 5)
                    
                    Button(action: {
                        if locationManager.isUpdating {
                            locationManager.stopUpdating()
                            bannerManager.showBanner(String(localized: "stop_gps_done"), type: .success)
                        } else {
                            locationManager.startUpdating()
                            bannerManager.showBanner(String(localized: "start_gps_done"), type: .success)
                        }
                    }) {
                        Image(systemName: "record.circle")
                            .foregroundColor(locationManager.isUpdating ? .red : .blue)
                            .font(.title)
                            .frame(width: 30, height: 30)
                            .padding()
                            .background(Color(.tertiarySystemBackground).opacity(0.8))
                            .clipShape(Circle())
                            .scaleEffect(animate ? 0.8 : 1.0)
                            .animation(
                                animate ?
                                    Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                                    : .default,
                                value: animate
                            )
                    }
                    .disabled(isDrawingArea)
                    .padding(.trailing, 20)
                    .padding(.bottom, 5)
                    
                    Button(action: {
                        if mapType == .standard {
                            mapType = .satellite
                            } else {
                                mapType = .standard
                            }
                    }) {
                        Image(systemName: "map.fill")
                            .font(.title)
                            .frame(width: 30, height: 30)
                            .padding()
                            .background(Color(.tertiarySystemBackground).opacity(0.8))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 40)
                    .disabled(isDrawingArea)
                    
                }
            }
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            ProgressView(String(localized: "processing"))
                .padding()
                .background(Color.white)
                .cornerRadius(10)
        }
    }

    // MARK: - Sheets
    
    @ViewBuilder
    func areaDetailSheet(area: Area) -> some View {
        VStack(alignment: .leading, spacing: 0){
            HStack{
                if let areaColor = area.color {
                    Image(systemName: "hexagon.fill")
                        .foregroundColor(Color(hex: areaColor) ?? Color(.systemGray))
                }else{
                    Image(systemName: "hexagon.fill")
                }
                Text((area.title ?? String(localized: "unknown")))
                    .font(.title)
                    .padding(.leading, 20)
            }
            .padding(.horizontal)
            
            HStack{
                Image(systemName: "text.bubble")
                Text(area.desc ?? String(localized: "no_describtion"))
                .padding(.leading, 20)
            }
            .padding(.horizontal)
            
            HStack{
                Image(systemName: "base.unit")
                if let coordsSet = area.coordinates as? Set<AreaCoordinate> {
                    let sortedCoords = coordsSet.sorted { $0.orderIndex < $1.orderIndex }
                    let coords = sortedCoords.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
                    let areaSize = coords.calculateArea()
                    Text(String(format: "%.2f m²", areaSize))
                        .padding(.leading, 20)
                } else {
                    Text(String(localized: "not_available"))
                        .padding(.leading, 20)
                }
            }
            .padding(.horizontal)
 
            HStack{
                Image(systemName: "checkmark.square")
                Text(String(localized: "uploaded") + ": " +  (area.uploadedToServer ? String(localized: "yes") : String(localized: "no")))
                    .padding(.leading, 20)
            }
            .padding(.horizontal)
        }
        .padding()
        .presentationDetents([.height(220), .large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    func userDetailSheet(user: AllUserData) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack{
                if let trackColor = user.trackcolor {
                    Image(systemName: "person.fill")
                        .foregroundColor(Color(hex: trackColor) ?? .red)
                        //.frame(width: 30, height: 30)
                }else{
                    Image(systemName: "person.fill")
                }
                Text(user.username ?? String(localized: "unknown"))
                    .font(.title)
                    .padding(.leading, 20)
            }
            .padding(.horizontal)
            
            if let locationsSet = user.locations,
                let locations = locationsSet.allObjects as? [AllUserGPSData],
                let lastLocation = locations.sorted(by: { ($0.time ?? "") > ($1.time ?? "") }).first {
                
                HStack{
                    Image(systemName: "mappin.and.ellipse")
                    VStack(alignment: .leading, spacing: 0){
                        Text(latToFormattedString(latitude: lastLocation.latitude))
                        Text(lonToFormattedString(longitude: lastLocation.longitude))
                        Text(latLonToMGRS(latitude: lastLocation.latitude, longitude: lastLocation.longitude))
                    }
                    .padding(.leading, 20)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                HStack{
                    Image(systemName: "clock")
                    if let timeString = lastLocation.time {
                        Text((timeString))
                            .padding(.leading, 20)
                    } else {
                        Text("-")
                            .padding(.leading, 20)
                    }
                    
                    
                }
                .padding()
            } else {
                HStack{
                    Image(systemName: "mappin.and.ellipse")
                    VStack(alignment: .leading, spacing: 0){
                        Text("-")
                        Text("-")
                        Text("-")
                    }
                    .padding(.leading, 20)
                    
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                HStack{
                    Image(systemName: "clock")
                    Text("-")
                    .padding(.leading, 20)
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
        }
        .padding()
        .presentationDetents([.height(220), .large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    func areaInputSheetView() -> some View {Form {
        Section(header: Text(String(localized: "add_area"))) {
            TextField(String(localized: "title"), text: $newAreaTitle)
            TextField(String(localized: "describtion"), text: $newAreaDescription)
        }

        Section(header: Text(String(localized: "color_and_size"))) {
            ColorPicker(String(localized: "choose_area_color"), selection: Binding(
                get: {
                    Color(hex: newAreaColor) ?? .red
                },
                set: { newValue in
                    newAreaColor = newValue.toHex()
                }
            ))
            let areaSize = drawingAreaCoordinates.calculateArea()
            Text(String(localized: "area") + " " + String(format: "%.2f m²", areaSize))
        }


        Section {
            HStack{
                
                Button(String(localized: "cancel")) {
                    drawingAreaCoordinates = []
                    refreshMapView = true
                    isDrawingArea = false
                    showAreaInputSheet = false
                }
                .buttonStyle(buttonStyleREAAnimated())
                
                Button(String(localized: "save")) {
                    saveArea(
                        coordinates: drawingAreaCoordinates,
                        title: newAreaTitle,
                        description: newAreaDescription,
                        colorHex: newAreaColor
                    )
                    newAreaTitle = ""
                    newAreaDescription = ""
                    newAreaColor = "#FF0000"
                    drawingAreaCoordinates = []
                    refreshMapView = true
                    isDrawingArea = false
                    showAreaInputSheet = false
                }
                .buttonStyle(buttonStyleREAAnimatedGreen())

            }
        }
    }
        .presentationDetents([.height(400)])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Functions

    func onAppearActions() {
        print("🟢🟢 Starte Abschnitt onAppearActions")
        
        checkTokenAndDownloadMyUserData(router: router) { _, _ in }
        
        downloadAllUserData(context: context) { success, _ in
        }

        if router.isLevelAdmin || router.isLevelFuehrungskraft {
            downloadAllGpsLocations(context: context) { success, _ in
                refreshUserTracks = success
            }
            
            uploadAreasToServer(context: context) { success, message in
                if success {
                    downloadAreas(context: context) { success, message in
                        print("Download Areas: \(message)")
                        if success {
                            // ggf. deine State-Variablen aktualisieren
                            refreshAreas = true
                        } else {
                            bannerManager.showBanner("Fehler beim Download: \(message)", type: .error)
                        }
                    }
                } else {
                    print("❌ Upload fehlgeschlagen: \(message)")
                }
                
            }
        }else{
            downloadAreas(context: context) { success, message in
                print("Download Areas: \(message)")
                if success {
                    // ggf. deine State-Variablen aktualisieren
                    refreshAreas = true
                } else {
                    bannerManager.showBanner("Fehler beim Download: \(message)", type: .error)
                }
            }
        }
    }

    func finishDrawingArea() {
        isDrawingArea = false
        showAreaInputSheet = true
    }

    func saveArea(coordinates: [CLLocationCoordinate2D], title: String, description: String, colorHex: String) {
        addAreaToLocalDataModel(context: context, title: title, description: description, colorHex: colorHex, coordinates: coordinates)

        uploadAreasToServer(context: context) { success, message in
            if success {
                for area in newAreas {
                    context.delete(area)
                }
                try? context.save()
                downloadAreas(context: context) { success, message in
                    print("Download Areas: \(message)")
                    if success {
                        bannerManager.showBanner("Fläche gespeichert", type: .success)
                        refreshAreas = true
                    } else {
                        bannerManager.showBanner("Fehler beim Hochladen der Fläche: \(message)", type: .error)
                    }
                }
            } else {
                print("❌ Upload fehlgeschlagen: \(message)")
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

#Preview {
    MapView()
}
