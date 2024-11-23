//
//  Information.swift
//  GHS App
//
//  Created by Syed Bukhari on 04/12/2022.
//

import SwiftUI
import CoreLocation
import CoreLocationUI

extension Double {
    func roundDouble() -> String {
        return String(format: "%.0f", self)
    }
}

class LocationManagerR: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var lastKnownLocation: CLLocation?

    func startUpdating() {
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        lastKnownLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
}

struct Information: View {
    
    @State var defaultLatitude: CLLocationDegrees
    @State var defaultLongitude: CLLocationDegrees
    
    @StateObject var locationManager2 = LocationManager()
    @EnvironmentObject var locationManager: LocationManager
    
    var weatherManager = WeatherManager()
    @State var weather: ResponseBody?
    
    var body: some View {
        
        VStack {
            Weather(defaultLatitude: defaultLatitude, defaultLongitude: defaultLongitude)
        }
    }
}

class LocationViewModellll: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastSeenLocation: CLLocation?
    @Published var currentPlacemark: CLPlacemark?
    
    private let locationManager: CLLocationManager
    
    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 0.4
        locationManager.startUpdatingLocation()
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastSeenLocation = locations.first
        fetchCountryAndCity(for: locations.first)
    }
    
    func fetchCountryAndCity(for location: CLLocation?) {
        guard let location = location else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            self.currentPlacemark = placemarks?.first
        }
    }
}

struct Weather: View {
    
    @State var defaultLatitude: CLLocationDegrees
    @State var defaultLongitude: CLLocationDegrees
    
    @StateObject var locationViewModel = LocationViewModellll()
    @State var accessToLocation: Bool = true
    
    var weatherManager = WeatherManager()
    @State var weather: ResponseBody?
    
    var coordinate: CLLocationCoordinate2D? {
        locationViewModel.lastSeenLocation?.coordinate
    }
    
    var body: some View {
        VStack {
            if let weather = weather {
                
                VStack {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("\(weather.name)")
                    }.padding(.top, 20)
                    
                    HStack {
                        // Image
                        Image(systemName: "cloud.sun.fill")
                            .renderingMode(.original)
                            .font(.system(size: 65))
                            .padding(.leading,20)
                        Spacer()
                        HStack {
                            VStack {
                                HStack {
                                    Text("\(weather.main.temp.roundDouble())").font(.system(size: 50)).fontWeight(.bold)
                                }
                                Text("Cloudy")
                            }
                            Text("/\(weather.main.feelsLike.roundDouble()) ℃").fontWeight(.bold).opacity(0.7).padding(.bottom,20)
                        }
                        Spacer()
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        VStack {
                            Image(systemName: "wind").opacity(0.75)
                            Text("\(weather.wind.speed.roundDouble()) mph").fontWeight(.bold)
                            Text("Wind").font(.system(size: 12)).opacity(0.75)
                        }
                        Spacer()
                        VStack {
                            Image(systemName: "barometer").opacity(0.75)
                            Text("\(weather.main.pressure.roundDouble()) hPa").fontWeight(.bold)
                            Text("Visibility").font(.system(size: 12)).opacity(0.75)
                        }
                        Spacer()
                        VStack {
                            Image(systemName: "humidity.fill").opacity(0.75)
                            Text("\(weather.main.humidity.roundDouble()) %")
                                .fontWeight(.bold)
                            Text("Humidity").font(.system(size: 12)).opacity(0.75)
                        }
                        Spacer()
                    }.padding(.vertical, 20)
                }.frame(maxWidth: .infinity, maxHeight: 205)
                    .background(
                        LinearGradient(gradient:
                                  Gradient(colors:
                                     [Color(red: 0.203, green: 0.819, blue: 0.864), Color(red: -0.002, green: 0.51, blue: 0.998)]),
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .foregroundColor(.white)
                if weather.main.temp < 10.1 {
                    Text("It is pretty cold today. Sending a coat is recommended.")
                        .padding(2)
                }
            }
            else {
                ZStack {
                    ProgressView()
                        .task {
                            do {
                                weather = try await weatherManager.getCurrentWeather(latitude: coordinate?.latitude ?? defaultLatitude, longitude: coordinate?.longitude ?? defaultLongitude)
                            } catch {
                                print("Error getting weather: \(error)")
                            }
                        }
                }.frame(maxWidth: .infinity, maxHeight: 130)
                    .background(Color(hue: 0.584, saturation: 0.116, brightness: 0.936))
                    .cornerRadius(20)
                    .padding(.horizontal)
            }
            if accessToLocation == false {
                Button {
                    locationViewModel.requestPermission()
                    print("Requestion user's location")
                } label: {
                    Text("Share location")
                }
            }
        }.onAppear{
            if locationViewModel.authorizationStatus == .authorizedAlways || locationViewModel.authorizationStatus == .authorizedWhenInUse {
                self.accessToLocation = true
            } else {
                self.accessToLocation = false
            }
        }
    }
}
