//
//  SwiftUIView.swift
//  GHS App
//
//  Created by Syed Bukhari on 13/08/2022.
//

import SwiftUI
import Firebase

struct TeacherView: View {
    @ObservedObject private var viewModel = MainViewModel()
    @Binding var showCover: Bool
    
    @State var showEveryUser = false // When this is true, a full screen cover opens up with the contacts.
    @State var showAdminPostcardUINavigation = false
    @State var postcardRecepient: TheUsers?
    
    private func getGreeting() -> String {
        let time = Calendar.current.component( .hour, from:Date() )
        print(time)
        if Calendar.current.component( .hour, from:Date() ) > 11 && Calendar.current.component( .hour, from:Date() ) < 17 {
            return "Good afternoon"
        } else if Calendar.current.component( .hour, from:Date() ) < 11 {
            return "Good morning"
        }
        return "Good evening"
    }
    
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
                    VStack {
                        Group {
                            Text("\(getGreeting()). You are signed in as as admin: \(viewModel.email)")
                                .padding(.top)
                                .padding(.bottom)
                            
                            Spacer()
                            
                            NavigationLink {
                                AbsenceAdmin()
                            } label: {
                                ZStack {
                                    Image("AdminAbsence")
                                        .resizable()
                                    HStack {
                                        VStack {
                                            Text("Student Absence")
                                                .font(.custom("Arial", fixedSize: 24.38184))
                                                .foregroundColor(.white)
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
                            
                            NavigationLink {
                                NewsAdmin()
                            } label: {
                                ZStack {
                                    Image("AdminNews")
                                        .resizable()
                                    HStack {
                                        VStack {
                                            Text("Upload News")
                                                .font(.custom("Arial", fixedSize: 24.38184))
                                                .foregroundColor(.white)
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
                            
                            NavigationLink {
                                AppointmentsAdmin()
                            } label: {
                                ZStack {
                                    Image("AdminAppointments")
                                        .resizable()
                                    HStack {
                                        VStack {
                                            
                                            Text("Appointments")
                                                .font(.custom("Arial", fixedSize: 24.38184))
                                                .foregroundColor(.white)
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
                            
                            NavigationLink {
                                Contacts(destination: "Postcards", contactSelected: { user in })
                            } label: {
                                ZStack {
                                    Image("AdminPostcards")
                                        .resizable()
                                    HStack {
                                        VStack {
                                            Text("Send Postcards")
                                                .font(.custom("Arial", fixedSize: 24.38184))
                                                .foregroundColor(.white)
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
                            
                            NavigationLink {
                                Contacts(destination: "Messaging", contactSelected: { user in })
                            } label: {
                                ZStack {
                                    Image("AdminMessages")
                                        .resizable()
                                    HStack {
                                        VStack {
                                            Text("Messages")
                                                .font(.custom("Arial", fixedSize: 24.38184))
                                                .foregroundColor(.white)
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
                        
                        Group {
                            NavigationLink {
                                Contacts(destination: "Notifications", contactSelected: { user in })
                            } label: {
                                ZStack {
                                    Image("AdminNotifications")
                                        .resizable()
                                    HStack {
                                        VStack {
                                            Text("Other Notifications")
                                                .font(.custom("Arial", fixedSize: 24.38184))
                                                .foregroundColor(.white)
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
                Spacer()
                
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showEveryUser) {
            Postcards(postcardRecipientSelected: { user in
                self.showAdminPostcardUINavigation.toggle()
                self.postcardRecepient = user
            })
        }
    }
}


struct TeacherView_Previews: PreviewProvider {
    static var previews: some View {
        TeacherView(showCover: .constant(false))
    }
}
