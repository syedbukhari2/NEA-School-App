//
//  MainView.swift
//  GHS App
//
//  Created by Syed Bukhari on 05/08/2022.
//

import SwiftUI
import CoreLocation
import UserNotifications

struct User: Identifiable {
    var id: String { uid }
    
    let uid, email, fullName: String
    let isTeacher: Bool

}

class MainViewModel: ObservableObject {
    
    @Published var full_name = ""
    @Published var email = ""
    @Published var CurrentUsersUID = ""
    @Published var currentUser: User?
    @Published var is_teacher = false
    
    init() {
        DispatchQueue.main.async {
            self.isCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()
    }
    func fetchCurrentUser() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.full_name = "Could not retrieve current user"
            return
        }
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch current user:", error)
                return
            }
            guard let data = snapshot?.data() else {
                self.full_name = "No data found"
                return
            }
            
            self.full_name = "Data: \(data.description)"
            self.email = "Email: \(data.description)"
            
            let uid = data["uid"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let fullName = data["full name"] as? String ?? ""
            let isTeacher = data["is teacher"] as? Bool ?? false
            let currentUser = User(uid: uid, email: email, fullName: fullName, isTeacher: isTeacher)
            
            self.full_name = currentUser.fullName
            self.email = currentUser.email
            self.is_teacher = currentUser.isTeacher
            self.CurrentUsersUID = currentUser.uid
        }
    }
    
    @Published var isCurrentlyLoggedOut = false
    
    func SignOut() {
        isCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
}

struct MainView: View {
    
    @StateObject var locationViewModel = LocationViewModellll()
    var coordinate: CLLocationCoordinate2D? {
        locationViewModel.lastSeenLocation?.coordinate
    }
    
    @ObservedObject private var viewModel = MainViewModel()
    @Binding var showCover: Bool
    
    @ViewBuilder
    var body: some View {
        
        if viewModel.is_teacher {
            TeacherView(showCover: $showCover)
        } else if viewModel.is_teacher == false {
            TabView {
                Home(showCover: $showCover).tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                
                Information(defaultLatitude: 51.50853, defaultLongitude: -0.12574).tabItem {
                    Image(systemName: "newspaper")
                    Text("Information")
                }
            }.onAppear {
                
                if #available(iOS 15.0, *) {
                    let appearance = UITabBarAppearance()
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
            }
            .accentColor(Color(red: 0.4196, green: 0.1568, blue: 0.8745))
        }
    }
}

struct Home: View {
    
    @ObservedObject private var viewModel = MainViewModel()
    @Binding var showCover: Bool
    
    let backgroundGradient = LinearGradient(
        colors: [Color.red, Color.blue],
        startPoint: .top, endPoint: .bottom)
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button {
                        
                    } label: {
                        Image("GHS Logo").resizable()
                            .frame(width: 40, height: 43.18).padding(.leading)
                            .shadow(color: .gray, radius: 5)
                    }
 
                    Text("Greenford High School")
                        .font(.custom("Arial", fixedSize: 20.0))
                        .fontWeight(.heavy)
                        .padding(.vertical)
                        .padding(.horizontal, 4)
                    Spacer()
                    Button {
                        viewModel.SignOut()
                        self.showCover = false
                        UserDefaults.standard.set(showCover, forKey: "showCover")
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right").padding(.horizontal)
                    }
                }
                
                ScrollView {
                    VStack(spacing: 0) {
                        HStack {
                            Text("\(getGreeting()) \(viewModel.full_name)")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.top)
                                .padding(.bottom, 12)
                            Spacer()
                        }
                        
                        HStack(spacing: 20) {
                            VStack(spacing: 20) {
                                NavigationLink {
                                    absence()
                                } label: {
                                    ZStack {
                                        Image("Absence")
                                            .resizable()
                                            .frame(height: 200)
                                            .cornerRadius(20)
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("Report Absense")
                                                    .font(.custom("Arial", fixedSize: 25.0))
                                                    .foregroundColor(.white)
                                                    .fontWeight(.bold)
                                                    .multilineTextAlignment(.leading)
                                                    .padding([.top, .leading], 15)
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                    }
                                }.shadow(radius: 4, x: 3, y: 4)
                                
                                NavigationLink  {
                                    News()
                                } label: {
                                    ZStack {
                                        Image("News")
                                            .resizable()
                                            .frame(height: 115)
                                            .cornerRadius(20)
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("News")
                                                    .font(.custom("Arial", fixedSize: 25.0))
                                                    .foregroundColor(.white)
                                                    .fontWeight(.bold)
                                                    .padding([.top, .leading], 15)
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                    }
                                }.shadow(radius: 4, x: 3, y: 4)
                            }
                            VStack(spacing: 20) {
                                NavigationLink  {
                                    recievePostcards()
                                } label: {
                                    ZStack {
                                        Image("Postcards")
                                            .resizable()
                                            .frame(height: 115)
                                            .cornerRadius(20)
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("Postcards")
                                                    .font(.custom("Arial", fixedSize: 20.38184))
                                                    .foregroundColor(.white)
                                                    .fontWeight(.bold)
                                                    .padding([.top, .leading], 15)
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                    }.shadow(radius: 4, x: 3, y: 4)
                                }.padding(.top)
                                
                                NavigationLink  {
                                    //Other_Notifications()
                                    examResults()
                                } label: {
                                    ZStack {
                                        Image("Notifications")
                                            .resizable()
                                            .frame(height: 170)
                                            .cornerRadius(20)
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("Other notifications")
                                                    .font(.custom("Arial", fixedSize: 23.047183))
                                                    .foregroundColor(.white)
                                                    .fontWeight(.bold)
                                                    .multilineTextAlignment(.leading)
                                                    .padding([.top, .leading], 15)
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                    }.shadow(radius: 4, x: 3, y: 4)
                                }
                                Spacer()
                            }
                        }
                        
                        HStack {
                            Text("Quick contacts")
                                .font(.custom("Arial", fixedSize: 20.0))
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.top, 20)
                        
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(1..<6) { index in
                                    ZStack {
                                        VStack {
                                            Image("Blocks")
                                                .resizable()
                                                .frame(width: 65, height: 65)
                                                .cornerRadius(100)
                                            Text("Example")
                                                .fontWeight(.bold)
                                            
                                            Text("Staff")
                                                .foregroundColor(.gray)
                                            NavigationLink {
                                                ChatView(recepientName: "Admin Account", toID: "d0vFfwjMlSbdKO7HKKAS5bjkqlP2")
                                            } label: {
                                                Text("Contact")
                                                    .padding(7)
                                                    .foregroundColor(.white)
                                                    .background(Color.blue)
                                                    .cornerRadius(50)
                                            }
                                        }
                                    }.frame(width: 150, height: 180)
                                        .background(.gray.opacity(0.15))
                                        .cornerRadius(15)
                                }
                            }
                        }
                        .padding(.top, 8)
                        
                        Text("Learning to succeed").foregroundColor((CustomColor.Purple))
                            .padding(.vertical, 30)
                            .font(.system(size: 20))
                    }.padding(.horizontal, 10)
                }
            }
            .navigationTitle("Home")
            .navigationBarHidden(true)
        }.onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("Access to send notifications granted!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func getGreeting() -> String {
        let time = Calendar.current.component( .hour, from:Date() )
        print(time)
        if Calendar.current.component( .hour, from:Date() ) > 11 && Calendar.current.component( .hour, from:Date() ) < 17 {
            return "Good afternoon,"
        } else if Calendar.current.component( .hour, from:Date() ) < 11 {
            return "Good morning,"
        }
        return "Good evening,"
        }
}

struct Fonts: View {
    let allFontNames = UIFont.familyNames
        .flatMap { UIFont.fontNames(forFamilyName: $0) }

    var body: some View {
        List(allFontNames, id: \.self) { name in
            Text(name)
                .font(Font.custom(name, size: 20))
        }
    }
}

struct Settings: View {
    @ObservedObject private var viewModel = MainViewModel()
    var body: some View {
        VStack {
            Spacer()
            Text("\(viewModel.full_name)")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.horizontal, 15)
                .padding(.top)
            Text("\(viewModel.email)")
                .font(.title2)
                .foregroundColor(.red)
                .fontWeight(.bold)
                .padding(.top, 1)
            Button {
                // Handle sign out
                viewModel.SignOut()
            } label: {
                Text("Sign out")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .cornerRadius(13)
            }.padding(.horizontal)

            Spacer()
        }
        .fullScreenCover(isPresented: $viewModel.isCurrentlyLoggedOut, onDismiss: nil) {
            ContentView(didCompleteLoginProcess: {
                self.viewModel.isCurrentlyLoggedOut = false
                self.viewModel.fetchCurrentUser()
            }, showCover: true)
        }
    }
}




struct MainView_Previews: PreviewProvider {
    var showCover = false
    static var previews: some View {
        MainView(showCover: .constant(false)).preferredColorScheme(.light).previewInterfaceOrientation(.portrait)
        /*
        Settings().preferredColorScheme(.light)
        TeacherView(showCover: .constant(false))
        News()
        NewsAdmin()*/
    }
}

