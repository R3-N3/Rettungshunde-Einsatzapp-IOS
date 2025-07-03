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
                if router.isLevelFuehrungskraft || router.isLevelAdmin {
                    Section{
                        HStack{
                            Spacer()
                        
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
                            
                            Spacer()
                        }
                    }
                }
                
                Section(header: Text(String(localized: "all_areas"))){
                    ForEach(areas, id: \.self) { area in
                        VStack(alignment: .leading) {
                            Text(area.title ?? String(localized: "unknown"))
                                .font(.headline)
                            Text(area.desc ?? String(localized: "no_describtion"))
                                .font(.subheadline)
                            Text(String(localized: "uploaded") + " " + (area.uploadedToServer ? String(localized: "yes") : String(localized: "no")))
                                .font(.caption)
                            Text(String(localized: "color") + (area.color ?? "#FF0000"))
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
