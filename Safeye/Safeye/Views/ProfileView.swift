//
//  ProfileView.swift
//  Safeye
//
//  Created by gintare on 7.4.2022.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var AuthenticationViewModel: AuthenticationViewModel
    @State private var showModal = false

    var body: some View {
        ZStack {
        VStack {
            BasicButtonComponent(label: "Sign out") {
                // Sign out button
                AuthenticationViewModel.signOut()
            }
            Group{
                Spacer()
                Text("FirstName LastName").font(.system(size: 25, weight: .bold))
                AvatarComponent(size: 80)
                Spacer()
            }
            Group {
                Text("My trusted contacts").font(.system(size: 18, weight: .semibold))
                HStack{
                    ListViewComponent(item: "avatar", size: 50)
                    Button(action: {
                        showModal = true
                        print("modal: \($showModal.wrappedValue)")
                    })
                    { Image("icon-add") }
                    Spacer(minLength: 20)
                }
                Spacer()
            }
            UserDetailsComponent()
            Spacer()
            Group {
                Text("My safe spaces").font(.system(size: 18, weight: .semibold))
                
                //size with icons doesn't work properly, will figure this out later
                ListViewComponent(item: "safeSpace", size: 40)
                
                Spacer()
            }
            //a button will be placed here?
        }
            AddContactView(isShowing: $showModal)

        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
