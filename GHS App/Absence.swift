//
//  Absence.swift
//  GHS App
//
//  Created by Syed Bukhari on 14/08/2022.
//

import SwiftUI
import Firebase

struct reportComponents: Identifiable {
    var id: String = UUID().uuidString
    var parentEmail: String
    var childName: String
    var form: String
    var firstDateOfAbsence: String
    var expectedReturn: String
    var absenseReason: String
    var reportDate: String
}

class AbsenceViewModel: ObservableObject {
    @Published var absenceInfo = [reportComponents]()
    
    private var db = Firestore.firestore()
    
    
    func addData(parentEmail: String, childName: String, form: String, firstDateOfAbsence: String, expectedReturn: String, absenseReason: String, date: String) {
        
        db.collection("Absence reports").addDocument(data: ["parent's email": parentEmail, "child's name": childName, "form": form, "first date of absence": firstDateOfAbsence, "expected return": expectedReturn, "absense reason": absenseReason, "date": date, "timestamp": Timestamp()]) { error in
            
            if error == nil {
                self.fetchData()
            }
            else {
                
            }
        }
    }
    
    func fetchData() {
        db.collection("Absence reports").order(by: "timestamp", descending: true).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.absenceInfo = documents.map { (queryDocumentSnapshot) -> reportComponents in
                let Data = queryDocumentSnapshot.data()
                let parentEmail = Data["parent's email"] as? String ?? ""
                let childName = Data["child's name"] as? String ?? ""
                let form = Data["form"] as? String ?? ""
                let firstDateOfAbsence = Data["first date of absence"] as? String ?? ""
                let expectedReturn = Data["expected return"] as? String ?? ""
                let absenseReason = Data["absense reason"] as? String ?? ""
                let reportDate = Data["date"] as? String ?? ""
                
                let absenceData = reportComponents(parentEmail: parentEmail, childName: childName, form: form, firstDateOfAbsence: firstDateOfAbsence, expectedReturn: expectedReturn, absenseReason: absenseReason, reportDate: reportDate)
                return absenceData
            }
        }
    }
}

struct absence: View {
    @State var absenceType: String = "Absence"
    var body: some View {
        VStack {
            Picker("Absence type", selection: $absenceType) {
                Text("Absence").tag("Absence")
                Text("Appointment").tag("Appointment")
            }.pickerStyle(SegmentedPickerStyle())
                .padding()
        
            if absenceType == "Absence" {
                Absence()
            } else {
                Appointments()
            }
        }
    }
}

struct Absence: View {
    
    @ObservedObject private var absenceViewModel = AbsenceViewModel()
    
    init() {
        UITextView.appearance().backgroundColor = .clear
    }
    
    @State var parentEmail = ""
    @State var childName = ""
    @State var form = ""
    @State var firstDateOfAbsence = ""
    @State var expectedReturn = ""
    @State var absenseReason = ""
    
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
                        Text("Form e.g. 8M2")
                    }
                    TextField(text: $firstDateOfAbsence) {
                        Text("Date of absence")
                    }
                    TextField(text: $expectedReturn) {
                        Text("Expected date of return")
                    }
                }.padding()
                    .background(CustomColor.Gray.opacity(0.4).cornerRadius(50))
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                HStack {
                    Text("Reason for absense:").padding(.horizontal, 23)
                    Spacer()
                }
                
                TextEditor(text: $absenseReason)
                    .padding(5)
                    .background(CustomColor.Gray.opacity(0.5)).cornerRadius(25)
                    .font(.custom("HelveticaNeue", size: 20))
                    .lineSpacing(5)
                    .frame(height: 170)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.bottom)
                
                Button {
                    self.reportDate = "\(getDate())"
                    
                    absenceViewModel.addData(parentEmail: parentEmail, childName: childName, form: form, firstDateOfAbsence: firstDateOfAbsence, expectedReturn: expectedReturn, absenseReason: absenseReason, date: reportDate)
                    
                    parentEmail = ""
                    childName = ""
                    form = ""
                    firstDateOfAbsence = ""
                    expectedReturn = ""
                    absenseReason = ""
                    
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
        }.navigationTitle("Report Absence")
    }
}

struct AbsenceAdmin: View {
    
    @ObservedObject private var absenceViewModel = AbsenceViewModel()
    
    var body: some View {
        ScrollView {
            ForEach(absenceViewModel.absenceInfo) { absenceReport in
                VStack {
                    ZStack {
                        Color.blue.opacity(0.3)
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Name: \(absenceReport.childName)")
                                    .font(.title3)
                                    .padding(.leading, 10.0)
                                    .padding(.top, 4)
                                Text("Form: \(absenceReport.form)")
                                    .font(.title3)
                                    .padding(.leading, 10.0)
                                    .padding(.top, 4)
                                Text("Absent on: \(absenceReport.firstDateOfAbsence)")
                                    .font(.title3)
                                    .padding(.leading, 10.0)
                                    .padding(.top, 4)
                                Text("Details: \(absenceReport.absenseReason)")
                                    .font(.title3)
                                    .padding(.leading, 10.0)
                                    .padding(.top, 4)
                                Text("Return date: \(absenceReport.expectedReturn)")
                                    .font(.title3)
                                    .padding(.leading, 10.0)
                                    .padding(.top, 4)
                                HStack {
                                    Spacer()
                                    Text("Submitted on \(absenceReport.reportDate)")
                                        .padding()
                                }
                            Spacer()
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
                self.absenceViewModel.fetchData()
        }
        }.navigationTitle("Absence Reports")
    }
}

struct Absence_Previews: PreviewProvider {
    static var previews: some View {
        Absence()
            .preferredColorScheme(.light)
    }
}
