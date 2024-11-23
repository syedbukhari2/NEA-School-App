//
//  News.swift
//  GHS App
//
//  Created by Syed Bukhari on 14/08/2022.
//

import SwiftUI
import FirebaseFirestore
import SDWebImageSwiftUI
import UserNotifications

struct news: Identifiable {
    var id: String = UUID().uuidString
    var title: String
    var newsBody: String
    var imageURL: String
    var isLiked: Bool
    var likes: Int
    var date: String
}

class NewsViewModel: ObservableObject {
    @Published var newsInfo = [news]()
    
    private var db = Firestore.firestore()
    
    func addLike(newsStory: news) {
        
        // Get a reference to the database
        let db = Firestore.firestore()
        
        // Set the data to update
        db.collection("news").document(newsStory.id).setData(["likes": newsStory.likes + 1], merge: true) { error in
            
            // Check for errors
            if error == nil {
                // Get the new data
                self.fetchData()
            }
        }
    }
    
    func isLikedTrue(newsStory: news) {
        
        // Get a reference to the database
        let db = Firestore.firestore()
        
        // Set the data to update
        db.collection("news").document(newsStory.id).setData(["isLiked": true], merge: true) { error in
            
            // Check for errors
            if error == nil {
                // Get the new data
                self.fetchData()
            }
        }
    }
    
    func removeLike(newsStory: news) {
        
        // Get a reference to the database
        let db = Firestore.firestore()
        
        // Set the data to update
        db.collection("news").document(newsStory.id).setData(["likes": newsStory.likes - 1], merge: true) { error in
            
            // Check for errors
            if error == nil {
                // Get the new data
                self.fetchData()
            }
        }
    }
    
    func isLikedFalse(newsStory: news) {
        
        // Get a reference to the database
        let db = Firestore.firestore()
        
        // Set the data to update
        db.collection("news").document(newsStory.id).setData(["isLiked": false], merge: true) { error in
            
            // Check for errors
            if error == nil {
                // Get the new data
                self.fetchData()
            }
        }
    }
    
    func addData(title: String, newsBody: String, imageURL: String, likes: Int, date: String) {
        @State var isLiked = false
        // Add a document to a collection
        db.collection("news").addDocument(data: ["title": title, "news body": newsBody, "thumbnail URL": imageURL, "isLiked": isLiked, "likes": likes, "date": date, "timestamp": Timestamp()]) { error in
            
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
        db.collection("news").order(by: "timestamp", descending: true).addSnapshotListener { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.newsInfo = documents.map { (queryDocumentSnapshot) -> news in
                let Data = queryDocumentSnapshot.data()
                let title = Data["title"] as? String ?? ""
                let newsBody = Data["news body"] as? String ?? ""
                let date = Data["date"] as? String ?? ""
                let imageURL = Data["thumbnail URL"] as? String ?? ""
                let isLiked = Data["isLiked"] as? Bool ?? false
                let likes = Data["likes"] as? Int ?? 0
                
                let ID = queryDocumentSnapshot.documentID
                
                let newsData = news(id: ID, title: title, newsBody: newsBody, imageURL: imageURL, isLiked: isLiked, likes: likes, date: date)
                return newsData
            }
        }
        
    }
}

struct newsListHeader: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .frame(width: 10, height: 10)
                                .padding(3)
                        }
                        Spacer()
                        Image(colorScheme == .dark ? "GHS white logo" : "GHS Logo")
                            .resizable()
                            .frame(width: 26, height: 30)
                        Text("GHS News")
                            .foregroundColor(.white)
                            .font(.title2)
                            .fontWeight(.heavy)
                        Spacer()
                    }.padding()
                }
                Spacer()
            }
        }
    }
}


struct newsReaderHeader: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        }
                        Spacer()
                        Text("News")
                            .fontWeight(.bold)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        Spacer()
                        Image(colorScheme == .dark ? "GHS white logo" : "GHS Logo")
                            .resizable()
                            .frame(width: 26, height: 30)
                    }.padding()
                }
                Spacer()
            }
        }
    }
}

struct newsReader: View {
    var title: String
    var newsBody: String
    var date: String
    var imageURL: String
    
    @GestureState private var dragOffset = CGSize.zero
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            ZStack {
                newsReaderHeader()
                ScrollView {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 10)
                    
                    HStack {
                        Text(date)
                            .font(.footnote)
                        Spacer()
                    }.padding()
                    
                    WebImage(url: URL(string: imageURL))
                        .resizable()
                        .scaledToFill()
                        .frame(minHeight: 200)
                        .frame(maxHeight: 200)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    HStack {
                        Text(newsBody)
                            .font(.body)
                        Spacer()
                    }.padding()
                Spacer()
                }.padding(.top, 70)
            }
        }.navigationBarHidden(true)
        .gesture(DragGesture().updating($dragOffset, body: { (value, state, transaction) in
            if (value.startLocation.x < 20 && value.translation.width > 100) {
                self.presentationMode.wrappedValue.dismiss()
            }
        }))
    }
}

struct News: View {
    
    @GestureState private var dragOffset = CGSize.zero
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject private var newsViewModel = NewsViewModel()
    
    var body: some View {
        ZStack {
            
            if colorScheme == .light {
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.023, green: 0.689, blue: 0.94), Color(red: 0.444, green: 0.185, blue: 0.63)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            } else {
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.008, green: 0.219, blue: 0.385), Color(red: 0.32, green: 0.148, blue: 0.393)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            }
            
            newsListHeader()
                .padding(.bottom, 20)
            
            VStack {
                ScrollView {
                    ForEach(newsViewModel.newsInfo) { newsStory in
                        VStack {
                            NavigationLink {
                                newsReader(title: newsStory.title, newsBody: newsStory.newsBody, date: newsStory.date, imageURL: newsStory.imageURL)
                            } label: {
                                ZStack {
                                    
                                    if colorScheme == .light {
                                        Color.white.opacity(0.85)
                                    } else {
                                        Color.black.opacity(0.4)
                                    }
                                    HStack {
                                        VStack(alignment: .leading, spacing: 0) {
                                            HStack {
                                                VStack(alignment: .leading) {
                                                    Text(newsStory.date)
                                                        .padding(.leading, 10)
                                                        .padding(.top, 10)
                                                        .font(.footnote)
                                                        .padding(.bottom, 3)
                                                    
                                                    Text(newsStory.title)
                                                        .fontWeight(.bold)
                                                        .padding(.leading, 10)
                                                        .font(.title2)
                                                }
                                                Spacer()
                                                
                                                VStack {
                                                    WebImage(url: URL(string: newsStory.imageURL))
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 125, height: 125)
                                                        .clipped()
                                                        .cornerRadius(20)
                                                        .overlay(RoundedRectangle(cornerRadius: 20)
                                                            .stroke(Color(.black), lineWidth: 0.3)
                                                        )
                                                    .padding(.top, 10)
                                                    Spacer()
                                                }
                                            }
                                            HStack {
                                                Spacer()
                                                Text("\(newsStory.likes)")
                                                Button {
                                                    if newsStory.isLiked == true {
                                                        print("Remove like")
                                                        newsViewModel.removeLike(newsStory: newsStory)
                                                        newsViewModel.isLikedFalse(newsStory: newsStory)
                                                    } else {
                                                        print("Add like")
                                                        newsViewModel.addLike(newsStory: newsStory)
                                                        newsViewModel.isLikedTrue(newsStory: newsStory)
                                                    }
                                                    
                                                    let impactMed = UIImpactFeedbackGenerator(style: .light)
                                                    impactMed.impactOccurred()
                                                    
                                                } label: {
                                                    if newsStory.isLiked == true {
                                                        Image(systemName: "hand.thumbsup.fill")
                                                            .resizable()
                                                            .frame(width: 20, height: 20)
                                                            .padding(.trailing, 10)
                                                            .padding(.bottom, 3)
                                                            .foregroundColor(.blue)
                                                    } else {
                                                        Image(systemName: "hand.thumbsup")
                                                            .resizable()
                                                            .frame(width: 20, height: 20)
                                                            .padding(.trailing, 10)
                                                            .padding(.bottom, 3)
                                                            .foregroundColor(.blue)
                                                    }
                                                }
                                            }
                                        Spacer()
                                        }
                                    Spacer()
                                    }
                                }.frame(minHeight: 20)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(25)
                                .padding(.horizontal, 10)
                                .padding(.leading, 8)
                                .padding(.bottom, 10)
                                .shadow(radius: 4, x: 3, y: 4)
                            Spacer()
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }.onAppear() {
                        self.newsViewModel.fetchData()
                    }
                }.padding(.top, 60)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }.navigationBarHidden(true)
            .gesture(DragGesture().updating($dragOffset, body: { (value, state, transaction) in
                if (value.startLocation.x < 20 && value.translation.width > 100) {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }))
    }
}

struct NewsAdmin: View {
    
    @ObservedObject var newsViewModel = NewsViewModel()
    
    @State var newsTitle = ""
    @State var newsBody = ""
    @State var imageURL = ""
    
    @State private var shouldShowImagePicker = false
    
    func getDate() -> String {
        let now = Date()

        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short

        let datetime = formatter.string(from: now)
        return datetime
    }
    
    @State var newsDate = ""
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text("Title:")
                    .font(.custom("Georgia-Boldltalic", size: 23))
                    .padding(.horizontal)
                    Spacer()
            }
            
            TextField("Title", text: $newsTitle)
                .padding(10)
                .foregroundColor(Color.red)
                .font(.custom("HelveticaNeue", size: 23))
                .frame(maxWidth: .infinity)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                .padding([.leading, .bottom, .trailing])
            
            TextField("Image thumbnail URL", text: $imageURL)
                .padding(10)
                .foregroundColor(Color.red)
                .font(.custom("HelveticaNeue", size: 23))
                .frame(maxWidth: .infinity)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                .padding([.leading, .bottom, .trailing])
            
            HStack {
                Text("Type the news here:")
                    .font(.custom("Georgia-Boldltalic", size: 23))
                    .padding(.horizontal)
                    Spacer()
            }
            
            TextEditor(text: $newsBody)
                .foregroundColor(Color.red)
                .font(.custom("HelveticaNeue", size: 23))
                .lineSpacing(5)
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                .padding([.leading, .bottom, .trailing])
            
            Button {
                self.newsDate = "\(getDate())"
                
                newsViewModel.addData(title: newsTitle, newsBody: newsBody, imageURL: imageURL,likes: 0, date: newsDate)
                
                let content = UNMutableNotificationContent()
                content.title = newsTitle
                content.subtitle = newsBody
                content.sound = UNNotificationSound.default

                // show this notification five seconds from now
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                // choose a random identifier
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                // add our notification request
                UNUserNotificationCenter.current().add(request)
                
                self.newsTitle = ""
                self.newsBody = ""
                self.newsDate = ""
                self.imageURL = ""
                
                
                
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 20)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(50)
                    .hoverEffect(/*@START_MENU_TOKEN@*/.automatic/*@END_MENU_TOKEN@*/)
            }.padding(.horizontal)
            
            HStack {
                Text("Thumbnail preview:")
            }
            
            WebImage(url: URL(string: imageURL))
                .resizable()
                .scaledToFill()
                .frame(width: 125, height: 125)
                .clipped()
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.label), lineWidth: 0.3)
                )
            .padding(.top, 10)
            
            Spacer()
        }
    }
}


struct News_Previews: PreviewProvider {
    static var previews: some View {
        News()
        NewsAdmin()
    }
}
