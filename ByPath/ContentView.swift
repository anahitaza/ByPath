//
//  ContentView.swift
//  ByPath
//
//  Created by Duke Holsing on 11/18/22.
//
import MapKit
import SwiftUI
import WeatherKit
import CoreLocation


struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
     
    @State private var region = MKCoordinateRegion (center:  CLLocationCoordinate2D(latitude: 42.33105, longitude: -83.04571 ),
        span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.002  ))
    
    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true)
            .ignoresSafeArea()
        
    }
}
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}

final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager?
    
    func checkIfLocationServiceIsEnabled () {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        } else {
            print("Your location service is off, please turn it on in settings")
        }
    }
    func checkLocationAuthorization () {
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
        
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Your location is restricted")
        case .denied:
            print("You have denied this app location permissions, go into settings to fix this")
        case .authorizedAlways, .authorizedWhenInUse:
            break
        @unknown default:
            break
            
        }
        func locationManagerDidChangeAuthorization(manager: CLLocationManager){
            checkLocationAuthorization()
            
        }
    }
}


///import WeatherKit
///import CoreLocation
public class WeatherViewModel: ObservableObject {
    let service = WeatherService()
    
    let currentLocation = CLLocation(latitude: 37.7749, longitude: 122.4194)
    var currentWeather: CurrentWeather?
    func getWeather() async {
        
        do {
            
            let weather = try await service.weather(for: currentLocation)
            
            self.currentWeather = CurrentWeather(
                temperature: weather.currentWeather.temperature.value,
                condition: weather.currentWeather.condition.rawValue,
                symbolName: weather.currentWeather.symbolName
            )
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
    
}
struct CurrentWeather {
    
    let temperature: Double
    let condition: String
    let symbolName: String
    
}

