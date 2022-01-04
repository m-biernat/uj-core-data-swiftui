//
//  MapView.swift
//  sklep-rest
//
//  Created by user209006 on 1/3/22.
//

import SwiftUI
import MapKit

struct MapView: View {
    private static let coords = CLLocationCoordinate2D(
        latitude: 50.02985,
        longitude: 19.90491
    )
    
    @State private var locations: [Location] = [
        Location(coordinate: coords)
    ]
    
    @State private var region = MKCoordinateRegion(
            center: coords,
            span: MKCoordinateSpan(
                latitudeDelta: 1,
                longitudeDelta: 1
            )
        )
    
    @State private var zoom = 1
    private let delta = [10, 1.0, 0.1, 0.01, 0.001]
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: locations) { location in
                    MapPin(coordinate: location.coordinate, tint: Color.red)
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(
                            action: {
                                zoomIn()
                                animateMap()
                            },
                            label: {
                                Image(systemName: "plus.magnifyingglass")
                                    .font(.title2)
                            })
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(5)
                            .shadow(radius: 1)
                        
                        Button(
                            action: {
                                zoomOut()
                                animateMap()
                            },
                            label: {
                                Image(systemName: "minus.magnifyingglass")
                                    .font(.title2)
                            })
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(5)
                            .shadow(radius: 1)
                        Spacer()
                    }
                    .padding(.bottom, 6)
                }
            }
            Divider()
        }
    }
    
    func animateMap() {
        withAnimation {
            region.center = Self.coords
            region.span = MKCoordinateSpan(
                latitudeDelta: delta[zoom],
                longitudeDelta: delta[zoom]
            )
        }
    }
    
    func zoomIn() {
        if zoom + 1 < delta.count {
            zoom += 1
        }
    }
    
    func zoomOut() {
        if zoom - 1 >= 0 {
            zoom -= 1
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}

struct Location: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
