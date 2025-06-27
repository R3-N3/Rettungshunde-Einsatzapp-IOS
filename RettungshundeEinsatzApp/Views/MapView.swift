//
//  MapView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 24.06.25.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.7339, longitude: 7.0997),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    @State private var showMenu = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Map(position: $position) {
               /* if let userCoordinate = locationManager.userLocation {
                    Marker("Deine Position", coordinate: userCoordinate)
                } else {
                    Marker("Bonn", coordinate: CLLocationCoordinate2D(latitude: 50.7339, longitude: 7.0997))
                }*/
            }
            .mapControls {
                MapUserLocationButton()
            }
            
            // Menü
            if showMenu {
                HStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Meine Position")
                            Text("...")
                            Text("Menü")
                        }
                        .padding()
                    }
                    .frame(maxWidth: 250, maxHeight: .infinity)
                    .background(Color.white)
                    .shadow(radius: 4)
                    
                    Spacer()
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
                        Image(systemName: "line.3.horizontal")
                            .font(.title)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)
                    .padding(.bottom, 40)
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    MapView()
}
