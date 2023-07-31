//
//  CardioZonesViewModel.swift
//  Zones
//
//  Created by Grant Isom on 7/30/23.
//

import Foundation

class CardioZonesViewModel: ObservableObject {
    private let healthManager = HealthManager()
    
    @Published var zones: [CardioZone: TimeInterval] = [:]
    
    let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()
    
    func timeInZone(_ zone: CardioZone) -> String {
        let timeInterval = zones[zone, default: 0]
        return timeFormatter.string(from: timeInterval) ?? "0"
    }
    
    func loadData() {
        // Request authorization and query heart rate data, then update `zones`
        let healthManager = HealthManager()
        healthManager.requestAuthorization { success in
            if success {
                // Define the time range you want to query, for example, the last week
                let endDate = Date()
                let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)!

                // Query heart rate data during workouts in the given time range
                healthManager.queryHeartRateData(from: startDate, to: endDate) { samples in
                    // Parse the heart rate data into cardio zones
                    let zones = healthManager.parseHeartRateIntoZones(samples: samples)
                    print(zones)
                    // Update the published zones property on the main thread
                    DispatchQueue.main.async {
                        self.zones = zones
                    }
                }
            }
        }
    }
}
