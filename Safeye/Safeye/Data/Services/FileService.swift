//
 //  FileService.swift
 //  Safeye
 //
 //  Created by gintare on 14.4.2022.
 //

 import SwiftUI
 import FirebaseStorage
 import FirebaseFirestore

 class FileService {
     static let shared = FileService() ; private init() {}
     private let storageRef = Storage.storage().reference()
     private let fileDB = Firestore.firestore()
     private let appStore = Store.shared
     private var fetchedPhoto: UIImage?

     @State private var path = "avatars/\(UUID().uuidString).jpg"

     func getPhoto(avatarUrlFetched: String?) -> UIImage? {
         fetchPhoto(avatarUrlFetched: avatarUrlFetched)
         return fetchedPhoto
     }

     func putPhoto(_ selectedPhoto: UIImage?, _ avatarUrl: String?) -> String {
         uploadPhoto(selectedPhoto, avatarUrl)
         return self.path
     }

     func uploadPhoto(_ selectedPhoto: UIImage?, _ avatarUrl: String?) {
         // Make sure that selected image property isn't nil
         guard selectedPhoto != nil else {
             return
         }

         // Turn image into data
         // TODO: check if compression could be even lower
         let imageData = selectedPhoto!.jpegData(compressionQuality: 0.05)
         // check that we were able to convert image to data
         guard imageData != nil else {
             return
         }
         // Specify the file path and name
         self.path = avatarUrl!
         let fileRef = storageRef.child(avatarUrl!)

         // Upload data
         fileRef.putData(imageData!, metadata: nil) { metadata, error in
             // checks for errors
             if error == nil && metadata != nil {
                 DispatchQueue.main.async {
                     self.fetchedPhoto = selectedPhoto!
                 }
             }
         }
     }

     func fetchPhoto(avatarUrlFetched: String?)  {
         // Get the data from the database
         fileDB.collection("avatars").getDocuments { snapshot, error in
             if error == nil && snapshot != nil {
                 var path: String = ""

                 for doc in snapshot!.documents {
                     // extract the file path
                     path = doc["url"] as! String
                 }
                 // fetch the data from storage
                 let storageRef = Storage.storage().reference()
                 let fileRef = storageRef.child(avatarUrlFetched ?? "")
                 fileRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                     if error == nil && data != nil {
                         // Create a UIImage and assign it to fetchedPhoto for display
                         if let image = UIImage(data: data!) {
                             DispatchQueue.main.async {
                                 self.fetchedPhoto = image
                             }
                         }
                     }
                 }
             }
         }
     }
 }