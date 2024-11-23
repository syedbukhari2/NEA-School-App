//
//  Appointments.swift
//  GHS App
//
//  Created by Syed Bukhari on 05/09/2022.
//

import SwiftUI
import Firebase

struct AppointmentReportComponents: Identifiable {
    var id: String = UUID().uuidString
    var parentEmail: String
    var childName: String
    var form: String
    var AppointmentDate: String
    var AppointmentTime: String
    var details: String
    var reportDate: String
}

class AppointmentsViewModel: ObservableObject {
    @Published var appointmentInfo = [AppointmentReportComponents]()
    
    private var db = Firestore.firestore()
    
    
    func addData(parentEmail: String, childName: String, form: String, AppointmentDate: String, AppointmentTime: String, details: String, date: String) {
        
        // Add a document to a collection
        db.collection("Appointments").addDocument(data: ["parent's email": parentEmail, "child's name": childName, "form": form, "appointment date": AppointmentDate, "appointment time": AppointmentTime, "other details": details, "date": date, "timestamp": Timestamp()]) { error in
            
            // Check for errors
            if error == nil {
                // No errors
                
                // Call get data to retrieve latest data
                self.fetchData()
            }
            else {
                // Handle the error
            }
        }
    }
    
    func fetchData() {
        db.collection("Appointments").order(by: "timestamp", descending: true).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.appointmentInfo = documents.map { (queryDocumentSnapshot) -> AppointmentReportComponents in
                let Data = queryDocumentSnapshot.data()
                let parentEmail = Data["parent's email"] as? String ?? ""
                let childName = Data["child's name"] as? String ?? ""
                let form = Data["form"] as? String ?? ""
                let AppointmentDate = Data["appointment date"] as? String ?? ""
                let AppointmentTime = Data["appointment time"] as? String ?? ""
                let details = Data["other details"] as? String ?? ""
                let reportDate = Data["date"] as? String ?? ""
                
                let absenceData = AppointmentReportComponents(parentEmail: parentEmail, childName: childName, form: form, AppointmentDate: AppointmentDate, AppointmentTime: AppointmentTime, details: details, reportDate: reportDate)
                return absenceData
            }
        }
        
    }
}

struct Appointments: View {
    
    @ObservedObject private var appointmentsViewModel = AppointmentsViewModel()
    
    init() {
        UITextView.appearance().backgroundColor = .clear
    }
    
    @State var parentEmail = ""
    @State var childName = ""
    @State var form = ""
    @State var AppointmentDate = ""
    @State var AppointmentTime = ""
    @State var details = ""
    
    func getDate() -> String {
        let now = Date()

        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short

        let datetime = formatter.string(from: now)
        return datetime
    }
    
    @State var reportDate = ""
    
    var body: some View {
        ScrollView {
            VStack {
                
                Group {
                    TextField(text: $parentEmail) {
                        Text("Parent's email")
                    }
                    TextField(text: $childName) {
                        Text("Child's full name")
                    }
                    TextField(text: $form) {
                        Text("Form e.g. 9M2")
                    }
                    TextField(text: $AppointmentDate) {
                        Text("Appointment date")
                    }
                    TextField(text: $AppointmentTime) {
                        Text("Appointment time")
                    }
                }.padding()
                    //.foregroundColor(.black)
                    .background(CustomColor.Gray.opacity(0.4).cornerRadius(50))
                    //.overlay(RoundedRectangle(cornerRadius: 50.0).strokeBorder(style: StrokeStyle(lineWidth: 1.0)))
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                HStack {
                    Text("Other details:").padding(.horizontal, 23)
                    Spacer()
                }
                
                TextEditor(text: $details)
                    .padding(5)
                    .background(CustomColor.Gray.opacity(0.5)).cornerRadius(25)
                    //.padding(5)
                    //.foregroundColor(Color.red)
                    .font(.custom("HelveticaNeue", size: 20))
                    .lineSpacing(5)
                    .frame(height: 170)
                    .frame(maxWidth: .infinity)
                    //.overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.gray))
                    .padding(.horizontal, 20)
                    .padding(.bottom)
                
                Button {
                    /*
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()*/
                    self.reportDate = "\(getDate())"
                    
                    appointmentsViewModel.addData(parentEmail: parentEmail, childName: childName, form: form, AppointmentDate: AppointmentDate, AppointmentTime: AppointmentTime, details: details, date: reportDate)
                    
                    parentEmail = ""
                    childName = ""
                    form = ""
                    AppointmentDate = ""
                    AppointmentTime = ""
                    details = ""
                    
                } label: {
                    Text("Submit")
                        .foregroundColor(Color.white)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .frame(maxWidth: .infinity)
                        .frame(height: 23)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(50)
                }.padding(.horizontal, 40)
                    .padding(.bottom)
                
            }
        }.navigationTitle("Appointments")
    }
}

struct AppointmentsAdmin: View {
    
    @ObservedObject private var appointmentsViewModel = AppointmentsViewModel()
    
    var body: some View {
        ScrollView {
            ForEach(appointmentsViewModel.appointmentInfo) { appointment in
                VStack {
                    ZStack {
                        Color.blue.opacity(0.3)
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Name: \(appointment.childName)")
                                    .font(.title3)
                                    .padding(.leading, 10.0)
                                    .padding(.top, 4)
                                Text("Form: \(appointment.form)")
                                    .font(.title3)
                                    .padding(.leading, 10.0)
                                    .padding(.top, 4)
                                Text("Appointment date: \(appointment.AppointmentDate)")
                                    .font(.title3)
                                    .padding(.leading, 10.0)
                                    .padding(.top, 4)
                                Text("Time: \(appointment.AppointmentTime)")
                                    .font(.title3)
                                    .padding(.leading, 10.0)
                                    .padding(.top, 4)
                                Text("Details: \(appointment.details)")
                                    .font(.title3)
                                    .padding(.leading, 10.0)
                                    .padding(.top, 4)
                            Spacer()
                            Text("Submitted on \(appointment.reportDate)")
                                .padding(.bottom, 10)
                            }
                        Spacer()
                        }
                    Spacer()
                    }
                    .frame(minHeight: 80)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
                .padding(.horizontal, 7)
                }
            }.onAppear() {
                self.appointmentsViewModel.fetchData()
        }
        }.navigationTitle("Student Appointments")
    }
}

struct Appointments_Previews: PreviewProvider {
    static var previews: some View {
        Appointments()
    }
}
