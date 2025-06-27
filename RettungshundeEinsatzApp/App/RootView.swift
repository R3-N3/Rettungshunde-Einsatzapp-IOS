//
//  RootView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 27.06.25.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        if router.isLoggedIn {
            MapView()
        } else {
            StartView()
        }
    }
}
