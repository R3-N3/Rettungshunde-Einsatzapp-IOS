//
//  AreaView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 02.07.25.
//

import SwiftUI
import CoreData

struct AreasListView: View {
    @State private var showDeleteAllAreasModal = false
    @EnvironmentObject var bannerManager: BannerManager
    @EnvironmentObject var router: AppRouter
    @State private var isSubmitting = false
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.managedObjectContext) var context

    
    
    @FetchRequest(
        entity: Area.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Area.title, ascending: true)]
    ) var areas: FetchedResults<Area>
    
    var body: some View {
        NavigationStack {
            List {
                Section{
                    if router.isLevelFuehrungskraft || router.isLevelAdmin {
                        Button(action: {
                            showDeleteAllAreasModal = true
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text(String(localized: "delete_all_areas")).fontWeight(.medium)
                            }
                        }
                        .buttonStyle(buttonStyleREAAnimatedRed())
                        .sheet(isPresented: $showDeleteAllAreasModal) {
                            deleteAllAreasSheet()
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                }
                
                Section(header: Text("Alle Flächen")){
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
                
            }
        }
    }
    
    @ViewBuilder
    func deleteAllAreasSheet() -> some View {
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
                            downloadAreas(context: context) { success, message in
                                print("Download Areas: \(message)")
                                if success {

                                } else {
                                    bannerManager.showBanner("Fehler beim Download: \(message)", type: .error)
                                }
                            }
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
}
