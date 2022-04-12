//
//  ProfileService.swift
//  Safeye
//
//  Created by FUKA on 1.4.2022.
//  EDited by FUKA 8.4.2022.
//  Edited by FUKA


import Foundation
import Firebase // Import firebase


// TODO: Database is in test mode, set rules and change to production mode

class ProfileService {
    static let getInstance = Firestore.firestore() // Get instance of Firestore database
    private var profileDB = Firestore.firestore().collection("profiles")
    private var connectionsDB = Firestore.firestore().collection("connections")
    
    var profiles: [ProfileModel] = [ProfileModel]()
    private var PendingConnectionRequests = [ConnectionModel]()
    // var profiles: Set<ProfileModel> = Set<ProfileModel>()
    
    func getProfiles() -> [ProfileModel]? {
        return self.profiles
    }
    
    func getPendingRequests() -> [ConnectionModel] {
        self.fetchPendingConnectionRequests()
        print("RRRRR => \(self.PendingConnectionRequests)")
        return self.PendingConnectionRequests
    }
    
    
    
    func fetchConnectionProfiles(users: [String]) {
        self.profileDB.whereField("userId", in: users).getDocuments() { profiles, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for profile in profiles!.documents {
                    print("\(profile.documentID) => \(profile.data())")
                }
            }
        }
    } // end of fetchConnectionProfiles
    
    
    
    func fetchPendingConnectionRequests() {
        let currentUserId = AuthenticationService.getInstance.currentUser!.uid
        print("Current id: => \(currentUserId)")
        
        self.connectionsDB.whereField("connectionUsers.target", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: false).getDocuments() { requests, error in
                
                if let error = error {
                    print("Error fetching connection requests \(error)")
                    return
                }
                else {
                    if requests!.count < 1 { print("There are no pending connection requests"); return }
                    if let requests = requests {
                        print("Pending connections: => \(requests.count)")
                        for request in requests.documents {
                            //print("req => \(request.data())")
                            do {
                                let convertedRequest = try request.data(as: ConnectionModel.self)
                                self.PendingConnectionRequests.append(convertedRequest)
                            } catch {
                                print(error)
                            }
                        }
                    }
                }
            }
    }
    
    
    
    
    func fetchProfiles(for userIds: [String]) {
        // var users = ["gJFO91ZLJTabKfU5QH0HcuaZ2Uj1", "td8IykGIgAgjbwgN8Po3zilnNOj2"]
        
        
        for id in userIds {
            profileDB.whereField("userId", isEqualTo: id).getDocuments() {  (profiles, error) in
                if let error = error {
                    print("Error getting single profile: \(error)")
                } else {
                    if profiles!.count < 1 {
                        print("no profile")
                        return
                    }
                    for profile in profiles!.documents {
                        // print("single profile: \(profile.data()["fullName"] ?? "")")
                        
                        let document = profile.data()
                        
                        let profileId = profile.documentID
                        let userId = document["userId"]
                        let fullName = document["fullName"]
                        let address = document["address"]
                        let birthday = document["birthday"]
                        let bloodType = document["bloodType"]
                        let illness = document["illness"]
                        let allergies = document["allergies"]
                        let connectionCode = document["connectionCode"]
                        
                        let temProfile = ProfileModel(id: profileId, userId: userId as! String, fullName: fullName as! String, address: address as! String, birthday: birthday as! String, bloodType: bloodType as! String, illness: illness as! String, allergies: allergies as! String, connectionCode: connectionCode as! String)
                        
                        // self.profiles.insert(temProfile)
                        self.profiles.append(temProfile)
                        // print("SINGLE: \(temProfile.fullName)")
                    }
                }
            }
        }
        
        // print("docs: \(docs)")
        // return nil
    }
    
}
