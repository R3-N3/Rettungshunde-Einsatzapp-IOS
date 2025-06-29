//
//  RootView.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 27.06.25.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var router: AppRouter
    @StateObject var bannerManager = BannerManager()

    var body: some View {
        ZStack {
            if router.isLoggedIn {
                MapView()
            } else {
                StartView()
            }
            
            if bannerManager.show {
                Group {
                    switch bannerManager.bannerType {
                    case .success:
                        SuccessBannerView(message: bannerManager.message)
                    case .error:
                        ErrorBannerView(message: bannerManager.message)
                    case .warning:
                        WarningBannerView(message: bannerManager.message)
                    case .info:
                        InfoBannerView(message: bannerManager.message)
                    }
                }
                .transition(.move(edge: .top))
                .zIndex(1) // wichtig für Animation über Content
            }
        }
        .environmentObject(router)
        .environmentObject(bannerManager)
    }
}

