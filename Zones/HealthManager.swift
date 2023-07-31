//
//  HealthManager.swift
//  Zones
//
//  Created by Grant Isom on 7/30/23.
//

import HealthKit

enum CardioZone: CaseIterable {
    case warmUp, fatBurn, aerobic, anaerobic, peak
}

class HealthManager {
    private let healthStore = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }

        let readData: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .heartRate)!]

        healthStore.requestAuthorization(toShare: nil, read: readData) { success, _ in
            completion(success)
        }
    }

    func queryHeartRateData(from startDate: Date, to endDate: Date, completion: @escaping ([HKQuantitySample]) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        let query = HKSampleQuery(sampleType: HKQuantityType.quantityType(forIdentifier: .heartRate)!,
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: [sortDescriptor])
        { _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                completion([])
                return
            }

            completion(samples)
        }

        healthStore.execute(query)
    }

    func parseHeartRateIntoZones(samples: [HKQuantitySample]) -> [CardioZone: TimeInterval] {
        var zones: [CardioZone: TimeInterval] = [:]

        for i in 1..<samples.count {
            let sample = samples[i]
            let previousSample = samples[i - 1]
            let timeInterval = sample.startDate.timeIntervalSince(previousSample.startDate)

            let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))

            let zone: CardioZone
            switch heartRate {
            case 0..<100: zone = .warmUp
            case 100..<120: zone = .fatBurn
            case 120..<140: zone = .aerobic
            case 140..<160: zone = .anaerobic
            default: zone = .peak
            }

            zones[zone, default: 0] += timeInterval
        }

        return zones
    }
}
