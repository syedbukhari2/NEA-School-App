//
//  Other.swift
//  GHS App
//
//  Created by Syed Bukhari on 18/09/2022.
//

import SwiftUI
import FirebaseFirestore
import SDWebImageSwiftUI

struct NotificationElements: Identifiable {
    //var id: ObjectIdentifier
    
    var id: String = UUID().uuidString
    var notificationType: String
    var imageURL: String
    var details: String
    var consentGiven: Bool
}

class HandleOtherNotifications: ObservableObject {
    
    @Published var notificationElements = [NotificationElements]()
    
    private var db = Firestore.firestore()
    
    func addData(notificationType: String, imageURL: String, details: String, consentGiven: Bool, uid: String, CurrentUsersUID: String) {
        db.collection("Notifications").document(uid).collection("Recieved").addDocument(data: ["Notification type": notificationType, "Image URL": imageURL, "Details": details, "Consent given": consentGiven, "timestamp": Timestamp()]) { error in
            
            if error == nil {
                // No errors so call fetchData to retrieve latest data
                
                self.fetchData(CurrentUsersUID: CurrentUsersUID)
            }
            else {
                // Handle the error
            }
        }
    }
    
    func fetchData(CurrentUsersUID: String) {
        db.collection("Notifications").document(CurrentUsersUID).collection("Recieved").order(by: "timestamp", descending: true).addSnapshotListener { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.notificationElements = documents.map { (queryDocumentSnapshot) -> NotificationElements in
                let Data = queryDocumentSnapshot.data()
                let notificationType = Data["Notification type"] as? String ?? ""
                let imageURL = Data["Image URL"] as? String ?? ""
                let details = Data["Details"] as? String ?? ""
                let consentGiven = Data["Consent given"] as? Bool ?? false
                let notificationData = NotificationElements(notificationType: notificationType, imageURL: imageURL, details: details, consentGiven: consentGiven)
                
                return notificationData
            }
        }
    }
}

struct Other_Notifications: View {
    
    @ObservedObject private var notificationsViewModel = HandleOtherNotifications()
    
    var body: some View {
        
        VStack {
            ScrollView {
                ForEach(notificationsViewModel.notificationElements) { notification in
                    NavigationLink {
                        Text(notification.details)
                    } label: {
                        ZStack {
                            ProgressView() // Shows the loading spinning indicator
                            Image("AdminAbsnce")
                                .resizable()
                            HStack {
                                VStack {
                                    Text(notification.notificationType)
                                        .font(.custom("Arial", fixedSize: 24.38184))
                                        .fontWeight(.bold)
                                        .padding([.top, .leading], 10)
                                    .cornerRadius(8)
                                Spacer()
                                }
                            Spacer()
                            }
                        Spacer()
                        }
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(18)
                        .padding(.horizontal, 10)
                    }
                }
            }
        }
    }
}

struct Other_Notifications_Admin: View {
    @ObservedObject private var HandleNotification = HandleOtherNotifications()
    @ObservedObject private var viewModel = MainViewModel()
    
    let recepient: TheUsers?
    
    let options = ["School trip", "Medical consent", "Meeting reminder"]
    
    @State var typeChosen = "Select notification type:"
    @State var isExpanded = false
    @State var description = ""
    @State var imageURL = ""
    
    
    var body: some View {
        ScrollView {
            VStack {
                ScrollView {
                    DisclosureGroup(isExpanded ? "Select subject:" : "\(typeChosen)", isExpanded: $isExpanded) {
                        VStack (alignment: .leading) {
                            ForEach (options, id: \.self) {
                                option in Text("\(option)")
                                    .font(.title2)
                                    .padding(14)
                                    .onTapGesture {
                                        self.typeChosen = option
                                        withAnimation{
                                            self.isExpanded.toggle()
                                        }
                                    }
                            
                            }
                        }
                    }
                    .accentColor(.white)
                    .foregroundColor(.white)
                    .padding()
                    .font(.title2)
                    .background(.black.opacity(0.6))
                    .cornerRadius(8)
                }.frame(height: isExpanded ? 200 : 67)
                
                HStack {
                    Text("Details:")
                        Spacer()
                }
                
                TextEditor(text: $description)
                    .foregroundColor(Color.red)
                    .lineSpacing(5)
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                    .padding(.bottom)
                
                TextField("Image thumbnail URL", text: $imageURL)
                    .padding(10)
                    .foregroundColor(Color.red)
                    .font(.custom("HelveticaNeue", size: 23))
                    .frame(maxWidth: .infinity)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                    .padding([.leading, .bottom, .trailing])
                
                Button {
                    HandleNotification.addData(notificationType: typeChosen, imageURL: imageURL, details: description, consentGiven: false, uid: recepient?.uid ?? "", CurrentUsersUID: viewModel.CurrentUsersUID)
                    
                } label: {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("Post")
                    }.foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 20)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(50)
                    .hoverEffect(/*@START_MENU_TOKEN@*/.automatic/*@END_MENU_TOKEN@*/)
                }
                
                Spacer()
            }.padding(.horizontal)
        }
    }
}



struct Other_Previews: PreviewProvider {
    static var previews: some View {
        examResults()
    }
}
