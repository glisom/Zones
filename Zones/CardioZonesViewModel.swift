//
//  CardioZonesViewModel.swift
//  Zones
//
//  Created by Grant Isom on 7/30/23.
//

import Combine
import HealthKit

class CardioZonesViewModel: ObservableObject {
    private let healthManager = HealthManager()

    @Published var startDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    @Published var endDate: Date = .init()

    @Published var zones: [CardioZone: TimeInterval] = [:]
    @Published var workouts: [HKWorkout] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        $startDate
            .combineLatest($endDate)
            .debounce(for: 0.3, scheduler: DispatchQueue.main) // Optional debounce to prevent rapid updates
            .sink { [weak self] startDate, endDate in
                self?.loadData(from: startDate, to: endDate)
            }
            .store(in: &cancellables)
    }

    let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()

    func timeInZone(_ zone: CardioZone) -> String {
        let timeInterval = zones[zone, default: 0]
        return timeFormatter.string(from: timeInterval) ?? "0"
    }

    func timeIntervalInMinutes(_ timeInterval: TimeInterval) -> Int {
        return Int(timeInterval / 60)
    }

    func timeInZoneInMinutes(_ zone: CardioZone) -> String {
        let timeInterval = zones[zone, default: 0]
        let minutes = timeIntervalInMinutes(timeInterval)
        return "\(minutes) minutes"
    }

    func timeInZoneValue(_ zone: CardioZone) -> Int {
        return Int(zones[zone, default: 0] / 60)
    }

    func loadData(from startDate: Date, to endDate: Date) {
        let healthManager = HealthManager()
        healthManager.requestAuthorization { success in
            if success {
                healthManager.queryHeartRateDataDuringWorkouts(from: startDate, to: endDate) { heartRateSamples, workouts in
                    let zones = healthManager.parseHeartRateIntoZones(samples: heartRateSamples)
                    print(zones)
                    DispatchQueue.main.async {
                        self.zones = zones
                        self.workouts = workouts
                    }
                }
            }
        }
    }
}
