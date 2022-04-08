//
//  ProfileViewModel.swift
//  Safeye
//
//  Created by FUKA on 1.4.2022.
//  Edit by FUKA on 8.4.2022.

import Foundation
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var profileDetails: ProfileModel?
    @Published var profileExists = false
    
    func getProfile() {
        let profileService = ProfileService.getInstance
        
        print("getProfile() called from inside ProfileViewModel")
        
        // Check if user is authenticated, if yes, then get user id, otherwise exit fetching prodile data
        guard let userId = AuthenticationService.getInstance.currentUser?.uid else {
            print("Fetching profile data: No signed in user found")
            self.profileExists = false
            return
        }
        
        
        // Fetch profile data
        profileService.collection("profiles").whereField("userId", isEqualTo: userId).getDocuments() { snapshot, error in
            if let error = error {
                print("Error getting single profile: \(error)")
            } else {
                
                if snapshot!.count < 1 {
                    self.profileExists = false
                    return
                }
                
                for document in snapshot!.documents {
                    self.profileExists = true
                    print("Profile fetched")
                    print("\(document.documentID) => \(document.data())")
                    
                    let profileId = document.documentID
                    let userId = document["userId"]
                    let fullName = document["fullName"]
                    let address = document["address"]
                    let birthday = document["birthday"]
                    let bloodType = document["bloodType"]
                    let illness = document["illness"]
                    let allergies = document["allergies"]
                    
                    // Create new Profile object and update @Published object in main thread
                    DispatchQueue.main.async {
                        self.profileDetails = ProfileModel(id: profileId, userId: userId as! String, fullName: fullName as! String, address: address as! String, birthday: birthday as! String, bloodType: bloodType as! String, illness: illness as! String, allergies: allergies as! String)
                    }
                }
            }
        }
        
        
    } // end of getProfile()
    
    
    // Add profile details for the first time after accound registration
    func addDetails(
        // userId: String,
        fullName: String,
        address: String,
        birthday: String,
        bloodType: String,
        illness: String,
        allergies: String) {
            
            // Check if user is authenticated, if yes, then get user id, otherwise exit
            guard let userId = AuthenticationService.getInstance.currentUser?.uid else {
                print("No signed in user found")
                return
            }
            
            let profileService = ProfileService.getInstance
            
            // Save data in database
            profileService.collection("profiles").addDocument(
                data:[
                    "userId": userId,
                    "fullName": fullName,
                    "address": address,
                    "birthday": birthday,
                    "bloodType": bloodType,
                    "illness": illness,
                    "allergies": allergies,
                ]) { error in
                    if error == nil {
                        // Get updated data and update profileDetails variable
                        
                    } else {
                        // Something went wrong while adding profile details on the first time after account creation
                        print("Something went wrong while adding profile details on the first time after account creation")
                    }
                }
        } // end of addDetails()
    
    
    func upateDetails(fullName: String, address: String, birthday: String, bloodType: String, illness: String, allergies: String) {
        let profileService = ProfileService.getInstance
        let profileId = profileDetails?.id ?? ""
        
        
        
        profileService.collection("profiles").document(profileId).setData(
            [
                "fullName"  : fullName,
                "address"   : address,
                "birthday"  : birthday,
                "bloodType" : bloodType,
                "illness"   : illness,
                "allergies" : allergies
            ], merge: true) { error in
                // Check for errors
                
                if error == nil {
                    // Get the new data and updtae app state
                    self.getProfile()
                }
            }
        
    }
    
    
}
