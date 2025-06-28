//
//  BannerManager.swift
//  RettungshundeEinsatzApp
//
//  Created by René Nettekoven on 28.06.25.
//

import SwiftUI

class BannerManager: ObservableObject {
    @Published var message: String = ""
    @Published var show: Bool = false
    @Published var bannerType: BannerType = .success

    enum BannerType {
        case success
        case error
        case warning
        case info
    }

    func showBanner(_ text: String, type: BannerType) {
        message = text
        bannerType = type
        withAnimation(.easeInOut(duration: 0.3)) {
            show = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 0.5)) {
                self.show = false
            }
        }
    }
}
