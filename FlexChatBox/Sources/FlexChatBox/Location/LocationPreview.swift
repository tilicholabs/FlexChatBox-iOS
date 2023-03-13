//
//  LocationPreview.swift
//
//
//  Created by Aditya Kumar Bodapati on 10/03/23.
//

import SwiftUI
import CoreLocation
import MapKit

struct LocationPreview: View {
    
    @Environment(\.presentationMode) private var presentationMode
    let coordinates: CLLocationCoordinate2D
    let onCompletion: (URL?) -> Void
    
    var body: some View {
        let region = MKCoordinateRegion(center: coordinates,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        let map = Map(coordinateRegion: .constant(region),
                      annotationItems: [Location(coordinates: coordinates)]) { MapMarker(coordinate: $0.coordinates) }
        VStack {
            HStack {
                Button(action: {
                    onCompletion(nil)
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                })
                
                Spacer()
                
                Text("Current location")
                    .font(Font.title)
                
                Spacer()
                
                Button(action: {
                    if let url = URL(string: "https://www.google.com/maps/?q=\(coordinates.latitude),\(coordinates.longitude)") {
                        onCompletion(url)
                    }
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "checkmark.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                })
            }
            .padding(.leading)
            .padding(.trailing)
            .padding(.top)

            map
        }
    }
}
