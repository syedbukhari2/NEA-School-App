//
//  ContentView.swift
//  GHS App
//
//  Created by Syed Bukhari on 01/08/2022.
//

import SwiftUI
import Firebase

struct ContentView: View {
    
    let didCompleteLoginProcess: () -> ()
    
    @ObservedObject private var viewModel = MainViewModel()
    
    @State public var showCover = false
    
    @State var email = ""
    @State var password = ""
    
    @State var teacherUI = UserDefaults.standard.object(forKey: "teacherUI") as? String ?? ""
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Image("Home Background")
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .scaledToFill()
                    Spacer()
                }
                VStack {
                    Group {
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        
                        HStack {
                            Image(systemName: "envelope").foregroundColor(.black.opacity(0.45))
                            TextField("", text: $email)
                                .placeholder(when: email.isEmpty) {
                                    Text("Email").foregroundColor(.gray)
                            }
                        }.padding()
                        .foregroundColor(.black)
                        .background(colorScheme == .light ? Color(red: 0.901, green: 0.906, blue: 0.902).cornerRadius(50) : Color(red: 0.219, green: 0.224, blue: 0.245).cornerRadius(50))
                        .overlay(RoundedRectangle(cornerRadius: 50.0).strokeBorder(style: StrokeStyle(lineWidth: 1.0)))
                        .padding(.horizontal, 40)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        
                        HStack {
                            Image(systemName: "lock").foregroundColor(.black.opacity(0.45))
                            SecureField("", text: $password)
                                .placeholder(when: password.isEmpty) {
                                    Text("Password").foregroundColor(.gray)
                            }
                        }.padding()
                        .foregroundColor(.black)
                        .background(colorScheme == .light ? Color(red: 0.901, green: 0.906, blue: 0.902).cornerRadius(50) : Color(red: 0.219, green: 0.224, blue: 0.245).cornerRadius(50))
                        .overlay(RoundedRectangle(cornerRadius: 50.0).strokeBorder(style: StrokeStyle(lineWidth: 1.0)))
                        .padding(.horizontal, 40)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding(.bottom, 30)
                        
                        if LogInStatusMessage == "Logged in successfully" {
                            Text(self.LogInStatusMessage)
                                .foregroundColor(.green)
                                .fontWeight(.bold)
                                .padding()
                        } else {
                            Text(self.LogInStatusMessage)
                                .foregroundColor(.red)
                                .fontWeight(.bold)
                                .padding()
                        }
                        
                        Button {
                            Log_In_Function()
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                            impactMed.impactOccurred()
                        } label: {
                            Text("Log in")
                                .foregroundColor(Color.white)
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                .frame(maxWidth: .infinity)
                                .frame(height: 23)
                                .padding()
                                .background(CustomColor.Green)
                                .cornerRadius(50)
                        }.padding(.horizontal, 40)

                        Text("or")
                        
                    }
                    
                    Group {
                        NavigationLink {
                            SignUpView(showCover: $showCover, didCompleteLoginProcess: {
                                
                            })
                        } label: {
                            Text("Create Account")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 23)
                                .padding()
                                .background(CustomColor.Purple)
                                .cornerRadius(50)
                        }.padding(.horizontal, 40)
                        
                        Spacer()
                    }
                }
            }
        }.onAppear{
            showCover = UserDefaults.standard.bool(forKey: "showCover")
            self.teacherUI = UserDefaults.standard.object(forKey: "teacherUI") as? String ?? ""
        }
        .fullScreenCover(isPresented: $showCover, content: {
            MainView(showCover: $showCover)
        })
    }
    
    @State var LogInStatusMessage = ""
    
    private func Log_In_Function() {
            
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) {
            result, error in
            if let err = error {
                if password.count < 6 {
                    self.LogInStatusMessage = "Incorrect password"
                } else {
                    self.LogInStatusMessage = "Failed to log in user: \(err)"
                }
                return
            }
                
            self.LogInStatusMessage = "Logged in successfully"
            self.showCover = true
            
            UserDefaults.standard.set(showCover, forKey: "showCover")
            UserDefaults.standard.set(teacherUI, forKey: "teacherUI")
            self.didCompleteLoginProcess()
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct SignUpView: View {
    
    @Binding var showCover: Bool
    
    let didCompleteLoginProcess: () -> ()
    
    @State var name = ""
    @State var email = ""
    @State var password = ""
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject private var viewModel = MainViewModel()
    
    var body: some View {
        ZStack {
            Image("Sign Up")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()
            VStack {
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                
                HStack {
                    Image(systemName: "person").foregroundColor(.black.opacity(0.45))
                    TextField("", text: $name)
                        .placeholder(when: name.isEmpty) {
                            Text("Full name").foregroundColor(.gray)
                    }
                }.padding()
                .foregroundColor(.black)
                .background(colorScheme == .light ? Color(red: 0.901, green: 0.906, blue: 0.902).cornerRadius(50) : Color(red: 0.219, green: 0.224, blue: 0.245).cornerRadius(50))
                .overlay(RoundedRectangle(cornerRadius: 50.0).strokeBorder(style: StrokeStyle(lineWidth: 1.0)))
                .padding(.horizontal, 40)
            
                
                HStack {
                    Image(systemName: "envelope").foregroundColor(.black.opacity(0.45))
                    TextField("", text: $email)
                        .placeholder(when: email.isEmpty) {
                            Text("Email").foregroundColor(.gray)
                    }
                }.padding()
                .foregroundColor(.black)
                .background(colorScheme == .light ? Color(red: 0.901, green: 0.906, blue: 0.902).cornerRadius(50) : Color(red: 0.219, green: 0.224, blue: 0.245).cornerRadius(50))
                .overlay(RoundedRectangle(cornerRadius: 50.0).strokeBorder(style: StrokeStyle(lineWidth: 1.0)))
                .padding(.horizontal, 40)
                .keyboardType(.emailAddress)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                
                HStack {
                    Image(systemName: "lock").foregroundColor(.black.opacity(0.45))
                    SecureField("", text: $password)
                        .placeholder(when: password.isEmpty) {
                            Text("Password").foregroundColor(.gray)
                    }
                }.padding()
                .foregroundColor(.black)
                .background(colorScheme == .light ? Color(red: 0.901, green: 0.906, blue: 0.902).cornerRadius(50) : Color(red: 0.219, green: 0.224, blue: 0.245).cornerRadius(50))
                .overlay(RoundedRectangle(cornerRadius: 50.0).strokeBorder(style: StrokeStyle(lineWidth: 1.0)))
                .padding(.horizontal, 40)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .padding(.bottom, 30)
                
                Button {
                    Sign_Up_Function(showCover: showCover)
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                    impactMed.impactOccurred()
                    if viewModel.isCurrentlyLoggedOut == false {
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Text("Create account")
                        .foregroundColor(Color.white)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .frame(maxWidth: .infinity)
                        .frame(height: 23)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(50)
                }.padding(.horizontal, 40)
                
                if SignUpStatusMessage == "Account created successfully" {
                    Text(self.SignUpStatusMessage)
                        .foregroundColor(.green)
                        .fontWeight(.bold)
                        .padding()
                } else {
                    Text(self.SignUpStatusMessage)
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                        .padding()
                }
            Spacer()
            }
        }
    }
    
    @State var SignUpStatusMessage = ""
    
    private func Sign_Up_Function(showCover: Bool) {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) {
            result, error in
            if let err = error {
                print("Failed to create user:", err)
                if password.count < 6 {
                    self.SignUpStatusMessage = "Please create a password longer than 6 characters."
                } else{
                    self.SignUpStatusMessage = "Failed to create user: \(err)"
                }
                return
            }
            
            self.SignUpStatusMessage = "Account created successfully"
            self.store_full_name(showCover: showCover) // this function stores the user's full name in Firebase
        }
    }
    
    @State var isTeacher = false
    
    private func store_full_name(showCover: Bool) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        
        let userData = ["email": self.email, "uid": uid, "full name": name, "is teacher": isTeacher] as [String : Any]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { err in
                if let err = err {
                    self.SignUpStatusMessage = "\(err)"
                    return
                }
                self.showCover = true
                UserDefaults.standard.set(showCover, forKey: "showCover")
                self.didCompleteLoginProcess()
                
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(didCompleteLoginProcess: {
            
        }, showCover: true)
    }
}

struct CustomColor {
    static let Green = Color("Green Accent")
    static let Purple = Color("Purple Accent")
    static let Gray = Color("Gray")
    // Add more here...
}
