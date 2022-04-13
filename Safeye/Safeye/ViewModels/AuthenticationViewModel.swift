//
//  AuthenticationViewModel.swift
//  Safeye
//
//  Created by FUKA on 6.4.2022.
//  Edited by FUKA on 8.4.2022.
//


/*
 TODO: Class Explanation
 */

import SwiftUI

class AuthenticationViewModel: ObservableObject {
    static let instance = AuthenticationViewModel() ;  private init() {}
    let authService = AuthenticationService.getInstance
    
    @Published var signedIn = false
    @Published var signinError = false
    
    var isSignedIn: Bool {
        return authService.currentUser != nil
    }
    
    
    // Get and return current logged in user, if user is not logged in return nil
    func getCurrentUser() -> UserModel? {
        // Google recommended way of getting current user
        if authService.currentUser != nil { // User is signed in, get id and email TODO: refacor code
            let userId = authService.currentUser?.uid
            let userEmail = authService.currentUser?.email
            return UserModel(id: userId, email: userEmail!)
        } else {
            // No user is signed in.
            return nil
        }
        
    } // end of getCurrentUser()
    
    
    
    func signIn(email: String, password: String) { // Login user with email and password
        authService.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else {
                self?.signinError = true
                // print("Error in signIn() -> viewModel: \(error?.localizedDescription)")
                return
            }
            // Login Success
            DispatchQueue.main.async {
                self?.signinError = false
                self?.signedIn = true
            }
        }
    }
    
    func signUp(email: String, password: String) { // Create new user account with email and password
        authService.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard result != nil, error == nil else {
                return
            }
            // Account creation Success
            DispatchQueue.main.async {
                self?.signedIn = true
            }
        }
    }
    
    func signOut() { // Logout user
        try? authService.signOut()
        self.signedIn = false
    }
    
}
