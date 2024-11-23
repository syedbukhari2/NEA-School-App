//
//  Postcards.swift
//  GHS App
//
//  Created by Syed Bukhari on 25/08/2022.
//

import SwiftUI
import FirebaseFirestore
import SDWebImageSwiftUI

struct TheUsers: Identifiable {
    var id: String { uid }
    
    var uid, email, fullName: String
    var isTeacher: Bool
}

struct PostcardElements: Identifiable {
    var id: String = UUID().uuidString
    
    var imageURL: String
    var postcardText: String
}

class HandlePostcardsData: ObservableObject {
    
    @Published var postcardElements = [PostcardElements]()
    
    private var db = Firestore.firestore()
    
    func addData(postcardText: String, image: String, uid: String, CurrentUsersUID: String) {
        db.collection("Postcards").document(uid).collection("Recieved").addDocument(data: ["Postcard text": postcardText, "Image URL": image, "timestamp": Timestamp()]) { error in
            
            if error == nil {
                
                self.fetchData(CurrentUsersUID: CurrentUsersUID)
            }
            else {
                // error
            }
        }
    }
    
    func fetchData(CurrentUsersUID: String) {
        db.collection("Postcards").document(CurrentUsersUID).collection("Recieved").order(by: "timestamp", descending: true).addSnapshotListener { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.postcardElements = documents.map { (queryDocumentSnapshot) -> PostcardElements in
                let Data = queryDocumentSnapshot.data()
                let postcardURL = Data["Image URL"] as? String ?? ""
                let postcardText = Data["Postcard text"] as? String ?? ""
                let postcardData = PostcardElements(imageURL: postcardURL, postcardText: postcardText)
                
                return postcardData
            }
        }
    }
    
}

struct recievePostcards: View {
    
    @ObservedObject private var HandlePostcards = HandlePostcardsData()
    @ObservedObject private var viewModel = MainViewModel()
    
    var deviceWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    var body: some View {
        VStack {
            Text("Your postcards will appear here!").font(.title2)
                .fontWeight(.bold)
                .padding()
            ScrollView {
                ForEach(HandlePostcards.postcardElements) { postcard in
                    VStack {
                        HStack (spacing: 0) {
                            ZStack {
                                ProgressView() // Shows the loading spinning indicator
                                AnimatedImage(url: URL(string: postcard.imageURL))
                                    .resizable()
                                    .scaledToFill()
                            }.frame(width: deviceWidth/2.1)
                            .clipped()
                            
                            ZStack {
                                Color(.systemBackground)
                                ScrollView {
                                    HStack {
                                        Text("\(postcard.postcardText)").padding(5)
                                        Spacer()
                                    }
                                }
                            }.frame(width: deviceWidth/2.1)
                        
                        }.overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.gray, lineWidth: 0.8)
                        )
                        .cornerRadius(15)
                        .padding(.horizontal)
                        .frame(height: 250)
                        .shadow(radius: 4, x: 3, y: 4)
                        .padding(.bottom, 10)
                    }
                }
            }
        }
        .onAppear() {
            self.HandlePostcards.fetchData(CurrentUsersUID: viewModel.CurrentUsersUID)
        }
    }
}

class ViewContacts: ObservableObject {
    
    @ObservedObject private var viewModel = MainViewModel()
    
    @Published var users = [TheUsers]()
    @Published var errorMessage = ""
    
    private var db = Firestore.firestore()
    
    init() {
        fetchAllUsers()
    }
    
    private func fetchAllUsers() {
        
        db.collection("users")
            .addSnapshotListener { (querySnapshot, error) in
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                self.users = documents.map { (queryDocumentSnapshot) -> TheUsers in
                    
                    let data = queryDocumentSnapshot.data()
                    let uid = data["uid"] as? String ?? ""
                    let email = data["email"] as? String ?? ""
                    let name = data["full name"] as? String ?? ""
                    let is_teacher = data["is teacher"] as? Bool ?? false
                    
                    let usersInfo = TheUsers(uid: uid, email: email, fullName: name, isTeacher: is_teacher)
                    return usersInfo
    
                }
            }
    }
}

struct sendPostcard: View {
    
    @ObservedObject private var HandlePostcards = HandlePostcardsData()
    @ObservedObject private var viewModel = MainViewModel()
    
    let recepient: TheUsers?
    
    let subjects = ["Art", "Business", "Computer Studies", "Drama", "DT", "Economics", "English", "French", "Geophagy", "German", "History", "Maths", "Music", "PE", "RE", "Science", "Spanish"]
    
    @State var subjectChosen = "Select subject:"
    @State var isExpanded = false
    @State var postcardText = ""
    
    
    var body: some View {
        ScrollView {
            VStack {
                ScrollView {
                    DisclosureGroup(isExpanded ? "Select subject:" : "\(subjectChosen)", isExpanded: $isExpanded) {
                        VStack (alignment: .leading) {
                            ForEach (subjects, id: \.self) {
                                subject in Text("\(subject)")
                                    .font(.title2)
                                    .padding(14)
                                    .onTapGesture {
                                        self.subjectChosen = subject
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
                    Text("Message:")
                        Spacer()
                }
                
                TextEditor(text: $postcardText)
                    .foregroundColor(Color.red)
                    .lineSpacing(5)
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                    .padding(.bottom)
                
                Button {
                    HandlePostcards.addData(postcardText: postcardText, image: getPostcard(subjectChosen: subjectChosen), uid: recepient?.uid ?? "", CurrentUsersUID: viewModel.CurrentUsersUID)
                    postcardText = ""
                } label: {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("Send postcard")
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
            
        
        }.navigationTitle("To: \(recepient?.fullName ?? "")")
    }
    
    func getPostcard(subjectChosen: String) -> String {
        switch subjectChosen {
        case "Art":
            return "https://cdn.glitch.me/fe78e907-e60f-4b82-a394-50b65de99139/Untitled%20design-16.gif?v=1662413452799"
            
        case "Business":
            return "https://cdn.glitch.global/fe78e907-e60f-4b82-a394-50b65de99139/Untitled%20design-14.gif?v=1662413429406"
            
        case "Computer Studies":
            return "https://cdn.glitch.me/fe78e907-e60f-4b82-a394-50b65de99139/Untitled%20design-17.gif?v=1662413467936"
            
        case "Drama":
            return "https://cdn.glitch.global/fe78e907-e60f-4b82-a394-50b65de99139/Untitled%20design-15.gif?v=1662413436795"
            
        case "DT":
            return "https://cdn.glitch.me/fe78e907-e60f-4b82-a394-50b65de99139/Untitled%20design-13.gif?v=1662413424199"
            
        case "Economics":
            return "https://cdn.glitch.global/fe78e907-e60f-4b82-a394-50b65de99139/Untitled%20design-14.gif?v=1662413429406"
            
        case "English":
            return "https://cdn.glitch.global/fe78e907-e60f-4b82-a394-50b65de99139/Untitled%20design-12.gif?v=1662413406513"
            
        case "French":
            return "https://cdn.glitch.global/fe78e907-e60f-4b82-a394-50b65de99139/Untitled%20design-11.gif?v=1662413392775"
            
        case "Geophagy":
            return "https://cdn.glitch.global/fe78e907-e60f-4b82-a394-50b65de99139/Untitled%20design-9.gif?v=1662413372400"
            
        case "German":
            return "https://cdn.glitch.global/fe78e907-e60f-4b82-a394-50b65de99139/Untitled%20design-10.gif?v=1662413380466"
            
        case "History":
            return "https://cdn.glitch.me/fe78e907-e60f-4b82-a394-50b65de99139/Untitled%20design-8.gif?v=1662413368120"
            
        case "Maths":
            return "https://cdn.glitch.global/fe78e907-e60f-4b82-a394-50b65de99139/Untitled%20design-7.gif?v=1662413346610"
            
        case "Music":
            return "https://cdn.glitch.global/fe78e907-e60f-4b82-a394-50b65de99139/Untitled%20design-5.gif?v=1662413262506"
            
        case "PE":
            return "https://cdn.glitch.global/fe78e907-e60f-4b82-a394-50b65de99139/Untitled%20design-6.gif?v=1662413265319"
            
        case "RE":
            return "https://cdn.glitch.global/fe78e907-e60f-4b82-a394-50b65de99139/Untitled%20design-4.gif?v=1662413231574"
            
        case "Science":
            return "https://cdn.glitch.me/fe78e907-e60f-4b82-a394-50b65de99139/Untitled%20design-2.gif?v=1662413211455"
            
        case "Spanish":
            return "https://cdn.glitch.global/fe78e907-e60f-4b82-a394-50b65de99139/Untitled%20design-3.gif?v=1662413222758"
            
        default:
            return "https://www.greenford.ealing.sch.uk/_site/data/files/images/slideshow/3/502B1A2BDDC4E044CC5494DB7B9492AF.jpg"
        }
    }
}


struct Postcards: View {
    
    let postcardRecipientSelected: (TheUsers) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = ViewContacts()
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(vm.errorMessage)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                ForEach(vm.users) { user in
                    Button {
                        print("\(user.fullName) was selected")
                        postcardRecipientSelected(user)
                        presentationMode.wrappedValue.dismiss()
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
                    Divider()
                }
            }.navigationTitle("Select user")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

struct Postcards_Previews: PreviewProvider {
    static var previews: some View {
        MainView(showCover: .constant(true))
    }
}
