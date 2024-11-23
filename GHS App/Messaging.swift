//
//  Messaging.swift
//  GHS App
//
//  Created by Syed Bukhari on 27/08/2022.
//

import SwiftUI
import FirebaseFirestore

struct Contacts: View {
    
    @State var destination: String
    
    let contactSelected: (TheUsers) -> ()
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = ViewContacts()
    
    var body: some View {
        ScrollView {
            Text(vm.errorMessage)
                .fontWeight(.bold)
                .foregroundColor(.red)
            ForEach(vm.users) { user in
                
                ZStack {
                    if destination == "Messaging" {
                        NavigationLink {
                            ChatView(recepientName: user.fullName, toID: user.uid)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(user.fullName)
                                        .fontWeight(.bold)
                                        .padding(.bottom, 2)
                                    Text(user.email)
                                }.padding(.horizontal)
                                Spacer()
                            }
                        }
                    } else if destination == "Notifications" {
                        NavigationLink {
                            Other_Notifications_Admin(recepient: user)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(user.fullName)
                                        .fontWeight(.bold)
                                        .padding(.bottom, 2)
                                    Text(user.email)
                                }.padding(.horizontal)
                                Spacer()
                            }
                        }
                    } else {
                        NavigationLink {
                            sendPostcard(recepient: user)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(user.fullName)
                                        .fontWeight(.bold)
                                        .padding(.bottom, 2)
                                    Text(user.email)
                                }.padding(.horizontal)
                                Spacer()
                            }
                        }
                    }
                }
                Divider()
            }
        }.navigationTitle("Select user")
    }
}

struct MessageElements: Identifiable {
    var id: String = UUID().uuidString
    
    var fromID, toID, message: String
}

class HandleMessages: ObservableObject {
    @Published var messageElements = [MessageElements]()
    private var db = Firestore.firestore()
    
    func sendMessage(toId: String, Message: String, fromId: String) {
        db.collection("Messages")
            .document(fromId)
            .collection(toId)
            .addDocument(data: ["To ID": toId, "Message": Message, "From ID": fromId, "timestamp": Timestamp()]) { error in
            
            if error == nil {
                self.recieveMessage(fromId: fromId, toId: toId)
            }
            else {
                // Handle the error
            }
        }
        
        db.collection("Messages")
            .document(toId)
            .collection(fromId)
            .addDocument(data: ["To ID": toId, "Message": Message, "From ID": fromId, "timestamp": Timestamp()]) { error in
            
            if error == nil {
                self.recieveMessage(fromId: fromId, toId: toId)
            }
            else {
                // Handle the error
            }
        }
    }
    
    func recieveMessage(fromId: String, toId: String) {
        
        db.collection("Messages").document(fromId).collection(toId).order(by: "timestamp", descending: false).addSnapshotListener { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.messageElements = documents.map { (queryDocumentSnapshot) -> MessageElements in
                let Data = queryDocumentSnapshot.data()
                let fromID = Data["From ID"] as? String ?? ""
                let toID = Data["To ID"] as? String ?? ""
                let message = Data["Message"] as? String ?? ""
                
                let messageData = MessageElements(fromID: fromID, toID: toID, message: message)
                
                print("messageData", messageData)
                
                return messageData
            }
        }
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct ChatView: View {

    
    @ObservedObject private var HandleMessaging = HandleMessages()
    @ObservedObject private var viewModel = MainViewModel()
    
    @State var recepientName: String
    @State var toID: String
    
    @Environment(\.colorScheme) var colorScheme
    @State var chatText = ""

    var body: some View {
        ZStack {
            messagesView
            VStack(spacing: 0) {
                Spacer()
                ZStack {
                    if colorScheme == .dark {
                        VisualEffectView(effect: UIBlurEffect(style: .dark))
                            .ignoresSafeArea()
                            .frame(height: 60.8)
                    } else {
                        VisualEffectView(effect: UIBlurEffect(style: .light))
                            .ignoresSafeArea()
                            .frame(height: 60.8)
                    }
                    chatBottomBar
                }
            }
        }
        .navigationTitle("\(recepientName) \(toID)")
        .navigationBarTitleDisplayMode(.inline)
    }
    private var messagesView: some View {
        ScrollView {
            ForEach(HandleMessaging.messageElements) { messages in
                if messages.fromID == viewModel.CurrentUsersUID {
                    HStack {
                        Spacer()
                        HStack {
                            Text(messages.message)
                                .foregroundColor(.white)
                        }
                        .padding(10)
                        .background(Color(red: 0.675, green: 0.548, blue: 1.03))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                } else {
                    HStack {
                        HStack {
                            Text(messages.message)
                        }
                        .padding(10)
                        .background(colorScheme == .dark ? Color(red: 0.15, green: 0.145, blue: 0.158) : Color(red: 0.915, green: 0.91, blue: 0.918))
                        .background(Color(hue: 0.729, saturation: 0.553, brightness: 0.713))
                        .cornerRadius(16)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                }
            }

            HStack{ Spacer() }
            .frame(height: 50)
        }
        .background(Color(.systemBackground))
        .onAppear() {
            self.HandleMessaging.recieveMessage(fromId: viewModel.CurrentUsersUID, toId: toID)
        }
    }

    private var chatBottomBar: some View {
        ZStack {
            HStack(spacing: 16) {
                ZStack {
                    if chatText.isEmpty {
                        DescriptionPlaceholder()
                    }
                    TextEditor(text: $chatText)
                        .padding(5)
                        .padding(.leading, 7)
                        .opacity(chatText.isEmpty ? 0.9 : 1)
                        
                        .foregroundColor(Color(.label)).opacity(0.7)
                        .frame(height: 45)
                        .cornerRadius(25)
                        .overlay(RoundedRectangle(cornerRadius: 25).strokeBorder(Color(.label), lineWidth: 0.3))
                }
                .frame(height: 45)
                
                Button {
                    HandleMessaging.sendMessage(toId: toID, Message: chatText, fromId: viewModel.CurrentUsersUID)
                    self.chatText = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(11.5)
                }
                .background(Color.blue)
                .cornerRadius(50)
            }
            .padding(.horizontal)
        }.padding(.vertical, 8)
        
        
    }
}

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Message")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 15)
            Spacer()
        }
    }
}

struct Messaging_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView(recepientName: "Syed", toID: "")
        }
        .preferredColorScheme(.light)
    }
}
