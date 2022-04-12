//
//  AddContactViewModel.swift
//  Safeye
//
//  Created by FUKA on 1.4.2022.
//  Edit by gintare on 10.4.2022.
//  Refactored by FUKA

import SwiftUI

class AddContactViewModel: ObservableObject {
    let profileService = ProfileService.getInstance
    let profileService2 = ProfileService()
    @ObservedObject var ProfileVM = ProfileViewModel()
    
    @Published var connectionDetails: ContactConnectionModel?
    @Published var profileFound = false
    @Published var trustedContactDetails: TrustedContactModel?
    @Published var connectionsPending = false
    @Published var pendingRequest: String? = nil
    @Published var pendingArray = []
    @Published var foundTrustedContacts = false
    @Published var trustedContactList: [String] = [String]()
    //@Published var trustedContacts: Set<ProfileModel> = Set<ProfileModel>()
    @Published var trustedContacts: [ProfileModel] = [ProfileModel]()
    @State var pendingRequests: [ConnectionModel]?
    
    private var targetId: String = ""
    
    func findProfile(searchCode: String?) {
        
        //TODO: user shouldn't be able to find themselves or add themselves!!!
        
        // Fetch profile data
        profileService.collection("profiles").whereField("connectionCode", isEqualTo: searchCode!).getDocuments() { snapshot, error in
            if let error = error {
                print("Error fetching profile: \(error)")
            } else {
                if snapshot!.count < 1 {
                    self.profileFound = false
                    print("Profile not found")
                    return
                }
                
                for document in snapshot!.documents {
                    self.profileFound = true
                    print("Profile found with ID: \(document.documentID)")
                    self.targetId = document["userId"] as! String
                    let profileId = document.documentID
                    let fullName = document["fullName"]
                    
                    // Update @Published object in main thread with Trusted Contact details
                    DispatchQueue.main.async {
                        self.trustedContactDetails = TrustedContactModel(id: profileId, userId: self.targetId , fullName: fullName as! String)
                    }
                }
            }
        }
    } // end of findProfile()
    
    
    // Add user as trusted contact and create a new entry in 'connections' collection
    func addTrustedContact() {
        var hasher = Hasher()
        hasher.combine(AuthenticationService.getInstance.currentUser!.uid)
        hasher.combine(targetId)
        let connectionId = String(hasher.finalize())
        
        let uid = AuthenticationService.getInstance.currentUser!.uid
        let connectionUsers = ["owner": uid, "target": targetId]
        
        // Save data in database
        profileService.collection("connections").addDocument(
            
            data:[
                "connectionId": connectionId,
                //"ownerId": AuthenticationService.getInstance.currentUser!.uid,
                //"targetId": targetId,
                "status": false,
                "connectionUsers": connectionUsers
            ]) { error in
                if error == nil {
                    // TODO: If successful this should trigger a notification sent to target user (Sprint 3?)
                    print("Connection created with ID: \(connectionId)")
                    self.profileFound = false
                } else {
                    // Connection wasn't created
                    print("Failed to add trusted contact")
                }
            }
    } // end of addTrustedContact()
    
    @State var t = [ConnectionModel]()
    
    func getPendingRequests() {
        let r = self.profileService2.getPendingRequests()
        DispatchQueue.main.async {
            self.t = self.profileService2.getPendingRequests()
        }
        print("QQQQQQ => \(t)")
    }
    
    // fetch all pending requests for logged in user
    func getPendingConnectionRequests() {
        self.pendingArray = []
        
        

        profileService.collection("connections").whereField("status", isEqualTo: false).whereField("targetId", isEqualTo: AuthenticationService.getInstance.currentUser!.uid).getDocuments() { snapshot, error in
            if let error = error {
                print("Error fetching connection requests \(error)")
            } else {
                if snapshot!.count < 1 {
                    self.connectionsPending = false
                    print("There are no pending connection requests")
                    return
                }
            }
            
            for document in snapshot!.documents {
                self.connectionsPending = true
                print("There is a pending request with Id: \(document.documentID)")
                
                
                self.pendingRequest = document.documentID
                
                let tcId = document["ownerId"]
                self.pendingArray.append(tcId as! String)
                print(self.pendingArray)
            }
        }
    } // end of getPendingConnectionRequests()
    
    // confirm pending requests
    func confirmConnectionRequest() {
        if pendingRequest == nil {
            print("There is nothing to confirm")
        } else {
            profileService.collection("connections").document(pendingRequest!).setData(["status": true], merge: true) { error in
                if error == nil {
                    print("Request confirmed")
                    self.pendingRequest = nil
                    self.getPendingConnectionRequests()
                } else {
                    print("Error confirming connection request")
                }
            }
        }
    }
    
    
    // TODO: unfinished
    // fetch all user's trusted contacts
    
    //let citiesRef = db.collection("cities")
    //citiesRef.whereField("country", in: ["USA", "Japan"])
    
    func fetchAllUsersContacts() {
        self.trustedContactList = []
        let userId = AuthenticationService.getInstance.currentUser?.uid
        
        
        // Round1: checks for those connections that were sent to current user and they accepted
        profileService.collection("connections").whereField("targetId", isEqualTo: userId!).whereField("status", isEqualTo: true).getDocuments() { snapshot, error in
            if let error = error {
                print("Error fetching contacts: \(error)")
            } else {
                if snapshot!.count < 1 {
                    self.foundTrustedContacts = false
                    print("No trusted contacts yet")
                    return
                }
                
                print("Yes: \(snapshot!.count)")
                
                for document in snapshot!.documents {
                    print("Snapshot: \(document["ownerId"] ?? "")")
                    
                    self.foundTrustedContacts = true
                    let tcId = document["ownerId"]
                    self.trustedContactList.append(tcId! as! String)
                    print("Trusted contact list: \(self.trustedContactList)")
                    
                }
                
            }
            print("before calling fetchProfiles")
            self.profileService2.fetchProfiles(for: self.trustedContactList)
            
            DispatchQueue.main.async {
                self.trustedContacts = self.profileService2.getProfiles()!
            }
        }
        
        // Round 2: checks for those connections that the user sent and other users accepted
        profileService.collection("connections").whereField("ownerId", isEqualTo: userId!).whereField("status", isEqualTo: true).getDocuments() { snapshot, error in
            if let error = error {
                print("Error fetching contacts: \(error)")
            } else {
                if snapshot!.count < 1 {
                    self.foundTrustedContacts = false
                    print("No trusted contacts yet")
                    return
                }
                
                print("Yes: \(snapshot!.count)")
                
                for document in snapshot!.documents {
                    print("Snapshot: \(document["targetId"] ?? "")")
                    
                    self.foundTrustedContacts = true
                    let tcId = document["targetId"]
                    self.trustedContactList.append(tcId! as! String)
                    print("Trusted contact list: \(self.trustedContactList)")
                }
                
            }
            print("before calling fetchProfiles")
            self.profileService2.fetchProfiles(for: self.trustedContactList)
            
            DispatchQueue.main.async {
                self.trustedContacts = self.profileService2.getProfiles()!
            }
            
        }
        
    }
}
