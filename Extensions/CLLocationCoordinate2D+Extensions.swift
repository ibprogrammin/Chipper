//
//  CLLocationCoordinate2D+Extensions.swift
//  
//
//  Created by Daniel Sevitti on 2025-10-29.
//

// MARK: - Helper Extensions
extension CLLocationCoordinate2D {
    func distance(to coordinate: CLLocationCoordinate2D) -> Double {
        let location1 = CLLocation(latitude: latitude, longitude: longitude)
        let location2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location1.distance(from: location2)
    }
}


