//
//  AddContactView.swift
//  Safeye
//
//  Created by gintare on 9.4.2022.
//

import SwiftUI

struct AddContactView: View {
    @Binding var isShowing: Bool
    @State var searchInput: String
        
    @State private var curHeight: CGFloat = 600
    let minHeight: CGFloat = 500
    let maxHeight: CGFloat = 700
    
    let startOpacity: Double = 0.8
    let endOpacity: Double = 0.9
    
    var dragPercentage: Double {
        let res = Double((curHeight - minHeight) / (maxHeight - minHeight))
        return max(0, min(1, res))
    }
    
    
    
    ///////////
    @EnvironmentObject var ConnectionVM: ConnectionViewModel
    @EnvironmentObject var ProfileVM: ProfileViewModel
    @EnvironmentObject var FileVM: FileViewModel
    @EnvironmentObject var appState: Store
    var translationManager = TranslationService.shared
    @State var error = "Nothing to display."
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isShowing {
                Color(UIColor.systemBackground)
                    .opacity(startOpacity + (endOpacity - startOpacity) * dragPercentage)
                    .ignoresSafeArea()
                    .onTapGesture { isShowing = false}
                mainView
                    .transition(.move(edge: .bottom))
            }
        }
//        .onAppear {
//            ConnectionVM.getConnections()
//            ConnectionVM.getConnectionProfiles()
//            ConnectionVM.getPendingRequests()
//            ConnectionVM.getPendingReqProfiles()
//            ConnectionVM.getSentReqProfiles()
//        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
    }
    
    var mainView: some View {
        VStack {
            ZStack {
                Capsule()
                    .frame(width: 40, height: 6)
            }
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemBackground))
            .gesture(dragGesture)
            
            ZStack {
                VStack {
                    
                    //  Search for contact with a code
                    VStack {
                        SearchFieldComponent(searchInput: $searchInput)
                        Button(action: {
                            
                            let filterResult = ConnectionVM.filterSearchResult(searchInput)
                            if filterResult != nil {
                                self.error = filterResult!
                                return
                            }
                            ProfileVM.getProfileByConnectionCode(withCode: searchInput)
//                        }, label: {Text("Search")})
                        }, label: {Text(translationManager.searchBtn)})
                            .foregroundColor(.blue)
                            .buttonStyle(BorderlessButtonStyle())
                    }

                    Spacer()
                    //  If searched code matches an existing profile, display avatar, full name and 'add' button
                    if appState.profileSearch != nil {
                        
                        if appState.searchResultPhoto != nil {
                            ProfileImageComponent(size: 90, avatarImage: appState.searchResultPhoto!)
                        } else {
                            ProgressView()
                                .onAppear {
                                    FileVM.fetchPhoto(avatarUrlFetched: appState.profileSearch?.avatar, isSearchResultPhoto: true, isTrustedContactPhoto: false)
                                }
                        }
                        
                        Text("\(appState.profileSearch?.fullName ?? "No name")")
                            .padding(.bottom)
//                      BasicButtonComponent(label: "Add", action: {
                        Button(action: {
                            if appState.profileSearch != nil {
                                ConnectionVM.addConnection()
                            }
                            searchInput = ""
                            self.error = ""
                            appState.profileSearch = nil
                        }, label: {Text(translationManager.addBtn)})
                            .foregroundColor(.blue)
                            .buttonStyle(BorderlessButtonStyle())
                    } else {
                        //Text(translationManager.nothingTitle)
                        Text(self.error)
                            .frame(alignment: .center)
                            .padding()
                    }
                    Spacer()
                }
            }
            .frame(maxHeight: .infinity)
            .padding(.bottom, 35)
        }
        .frame(height: curHeight)
        .frame(maxWidth: .infinity)


        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                Rectangle()
                    .frame(height: curHeight / 2)
            }
                .foregroundColor(Color(UIColor.systemBackground))
        )
        .onDisappear {
            curHeight = 600
            searchInput = ""
            self.error = "Nothing to display"
            appState.searchResultPhoto = nil
            appState.profileSearch = nil
        }
    }
    
    @State private var prevDragTransition = CGSize.zero
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { val in
                let dragAmount = val.translation.height - prevDragTransition.height
                if curHeight > maxHeight {
                    curHeight -= dragAmount / 6
                } else if curHeight < minHeight {
                    isShowing = false
                } else {
                    curHeight -= dragAmount
                }
                
                prevDragTransition = val.translation
            }
            .onEnded { val in
                prevDragTransition = .zero
            }
    }
}



struct AddContactView_Previews: PreviewProvider {
    static var previews: some View {
        AddContactView(isShowing: .constant(true), searchInput: "")
    }
}
