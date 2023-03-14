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
    let location: Location
    let onCompletion: (Location?) -> Void
    
    var body: some View {
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        let map = Map(coordinateRegion: .constant(region),
                      annotationItems: [location.coordinate]) { MapMarker(coordinate: $0) }
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
                    onCompletion(location)
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
