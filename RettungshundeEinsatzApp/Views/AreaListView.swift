//
//  AreaView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 02.07.25.
//

import SwiftUI
import CoreData

struct AreasListView: View {
    @FetchRequest(
        entity: Area.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Area.title, ascending: true)]
    ) var areas: FetchedResults<Area>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(areas, id: \.self) { area in
                    VStack(alignment: .leading) {
                        Text(area.title ?? "Unbenannt")
                            .font(.headline)
                        Text(area.desc ?? "Keine Beschreibung")
                            .font(.subheadline)
                        Text("Hochgeladen: \(area.uploadedToServer ? "Ja" : "Nein")")
                            .font(.caption)
                        Text("Farbe: \(area.color ?? "#FF0000")")
                            .font(.caption2)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Alle Flächen")
        }
    }
}
