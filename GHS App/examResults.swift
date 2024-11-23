//
//  examResults.swift
//  GHS App
//
//  Created by Syed Bukhari on 15/01/2023.
//

import SwiftUI

struct examResults: View {
    
    @State var subject = ""
    @State var score = 0.0
    @State var total = 0.0
    
    @State var data = [String]()
    
    @State var worstSubject = ""
    
    var arr = ["243 Maths", "12 English", "893242 Spanish"] // example
    
    let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()
    
    var body: some View {
        VStack {
            
            Group {
                TextField(text: $subject) {
                    Text("Subject")
                }
                .padding()
                .background(CustomColor.Gray.opacity(0.4)
                .cornerRadius(50))
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                
                HStack {
                    Text("Score:")
                    Spacer()
                }.padding(.horizontal,20)
                    .padding(.top)
                
                HStack {
                    TextField(value: $score, formatter: formatter) {
                        Text("Score")
                    }.padding()
                        .background(CustomColor.Gray.opacity(0.4).cornerRadius(19))
                        .overlay(RoundedRectangle(cornerRadius: 19.0).strokeBorder(style: StrokeStyle(lineWidth: 1.0)))
                        .padding(.leading, 20)
                        //.padding(.trailing, 20)
                        .padding(.top, 10)

                    
                    Image("Slash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 40)
                        
                    
                    TextField(value: $total, formatter: formatter) {
                        Text("Total")
                    }.padding()
                    .background(CustomColor.Gray.opacity(0.4).cornerRadius(19))
                    .overlay(RoundedRectangle(cornerRadius: 19.0).strokeBorder(style: StrokeStyle(lineWidth: 1.0)))
                    .padding(.trailing, 20)
                    .padding(.top, 10)
                }
            }
            
            Button {
                let percentage = Int((score / total) * 100)
                print("percentage:", percentage)
                print(String(percentage))
                data.append(String(percentage) + " " + subject)
                print(data)
                
                self.subject = ""
                self.score = 0
                self.total = 0
                
                self.worstSubject = ""
                
            } label: {
                Text("Add result")
                    .foregroundColor(Color.white)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .frame(maxWidth: .infinity)
                    .frame(height: 23)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(50)
                    .padding(.horizontal, 60)
                    .padding(.top, 50)
            }

            Button {
                
                let sortedSubjects = bubbleSort(data)
                print("DATA:", sortedSubjects)
                worstSubject = sortedSubjects[0]
                
            } label: {
                Text("Generate results")
                    .foregroundColor(Color.white)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .frame(maxWidth: .infinity)
                    .frame(height: 23)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(50)
                    .padding(.horizontal, 60)
                    //.padding(.top, 50)
            }
            
            ScrollView {
                ForEach(data, id: \.self) { subject in
                    HStack {
                        //Text(subject)
                        Text("\(getNumber(item: subject)) %")
                            //.background(Color(hue: 0.632, saturation: 0.665, brightness: 0.881))
                            .padding()
                        Divider()
                            .overlay(.white)
                            //.frame(height: .infinity)
                        Text(getSubject(data: subject)).padding()
                        Spacer()
                    }
                    .foregroundColor(.white)
                    //.padding()
                    .frame(maxWidth: .infinity, maxHeight: 20)
                    .padding()
                    .background(
                        LinearGradient(gradient:
                                  Gradient(colors:
                                     [Color(hue: 0.632, saturation: 0.89, brightness: 0.71), Color(hue: 0.632, saturation: 0.665, brightness: 0.881)]),
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(15)
                    .padding(.horizontal)
                    //.padding()
                }
            }.frame(maxWidth: .infinity, maxHeight: 190)
            .padding()
            
            if worstSubject != "" {
                Text("\(getSubject(data:worstSubject)) is your child's worst subject").padding(.bottom)
            }
        }
    }
    
    func getSubject(data: String) -> String {
        let numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "."]
        //var length = 0
        var subject = ""

        for i in data {
            if (numbers.contains(String(i))) || (i == " ") {

            } else {
                subject += String(i)

            }
        }
        return subject
    }
    
    
    func getNumber(item: String) -> String {
        let numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "."]
        //var length = 0
        var number = ""

        for i in item {
            //let x = i
            if numbers.contains(String(i)) {
                number += String(i)
            }
        }
        return number
    }
    
    func bubbleSort(_ array: [String]) -> [String] {
        var arr = array
        for _ in 0...arr.count {
            for value in 1...arr.count - 1 {
                if getNumber(item: arr[value-1]) > getNumber(item: arr[value]) {
                    let largerValue = arr[value-1]
                    arr[value-1] = arr[value]
                    arr[value] = largerValue
                }
            }
        }
        print("Sorted\(arr)")
        return arr
    }
}

extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}

extension String {
    mutating func replace(_ originalString:String, with newString:String) {
        self = self.replacingOccurrences(of: originalString, with: newString)
    }
}

struct examResults_Previews: PreviewProvider {
    static var previews: some View {
        examResults()
            .previewInterfaceOrientation(.portrait)
    }
}
