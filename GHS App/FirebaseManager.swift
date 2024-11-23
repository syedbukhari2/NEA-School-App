//
//  FirebaseManager.swift
//  GHS App
//
//  Created by Syed Bukhari on 08/08/2022.
//

import Foundation
import Firebase

class FirebaseManager: NSObject {
    
    let auth: Auth
    let firestore: Firestore
    static let shared = FirebaseManager()
    
    override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
}
