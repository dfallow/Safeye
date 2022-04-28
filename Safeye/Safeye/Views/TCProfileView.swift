//
//  TCProfileView.swift
//  Safeye
//
//  Created by gintare on 24.4.2022.
//

import SwiftUI

struct TCProfileView: View {
    @EnvironmentObject var ProfileVM: ProfileViewModel
    @EnvironmentObject var FileVM: FileViewModel
    @EnvironmentObject var appState: Store
    
    var body: some View {
        VStack {
            Spacer(minLength: 30)
            VStack {
                Text(appState.tCProfile?.fullName ?? "")
                if appState.trustedContactPhoto != nil {
                    ProfileImageComponent(size: 70, avatarImage: appState.trustedContactPhoto!)
                } else {
                    ProgressView()
                }
                
            }
            Form {
                TrustContactDetailsComponent(profile: appState.tCProfile!)
            }
        }
    }
}
