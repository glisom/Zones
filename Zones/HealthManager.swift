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

        let readData: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.workoutType()
        ]

        healthStore.requestAuthorization(toShare: nil, read: readData) { success, _ in
            completion(success)
        }
    }

    func queryWorkouts(from startDate: Date, to endDate: Date, completion: @escaping ([HKWorkout]) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        let query = HKSampleQuery(sampleType: HKObjectType.workoutType(),
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: [sortDescriptor])
        { _, samples, error in
            guard let samples = samples as? [HKWorkout], error == nil else {
                completion([])
                return
            }

            completion(samples)
        }

        healthStore.execute(query)
    }

    func queryHeartRateDataDuringWorkouts(from startDate: Date, to endDate: Date, completion: @escaping ([HKQuantitySample], [HKWorkout]) -> Void) {
        queryWorkouts(from: startDate, to: endDate) { workouts in
            let group = DispatchGroup()
            var heartRateData: [HKQuantitySample] = []

            workouts.forEach { workout in
                group.enter()

                self.queryHeartRateData(from: workout.startDate, to: workout.endDate) { samples in
                    heartRateData.append(contentsOf: samples)
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion(heartRateData, workouts)
            }
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

extension HKWorkoutActivityType {
    var name: String {
        switch self {
        case .americanFootball: return "American Football"
        case .archery: return "Archery"
        case .australianFootball: return "Australian Football"
        case .badminton: return "Badminton"
        case .baseball: return "Baseball"
        case .basketball: return "Basketball"
        case .bowling: return "Bowling"
        case .boxing: return "Boxing"
        case .climbing: return "Climbing"
        case .cricket: return "Cricket"
        case .crossTraining: return "Cross Training"
        case .curling: return "Curling"
        case .cycling: return "Cycling"
        case .dance: return "Dance"
        case .danceInspiredTraining: return "Dance Inspired Training"
        case .elliptical: return "Elliptical"
        case .equestrianSports: return "Equestrian Sports"
        case .fencing: return "Fencing"
        case .fishing: return "Fishing"
        case .functionalStrengthTraining: return "Functional Strength Training"
        case .golf: return "Golf"
        case .gymnastics: return "Gymnastics"
        case .handball: return "Handball"
        case .hiking: return "Hiking"
        case .hockey: return "Hockey"
        case .hunting: return "Hunting"
        case .lacrosse: return "Lacrosse"
        case .martialArts: return "Martial Arts"
        case .mindAndBody: return "Mind and Body"
        case .mixedMetabolicCardioTraining: return "Mixed Metabolic Cardio Training"
        case .paddleSports: return "Paddle Sports"
        case .play: return "Play"
        case .preparationAndRecovery: return "Preparation and Recovery"
        case .racquetball: return "Racquetball"
        case .rowing: return "Rowing"
        case .rugby: return "Rugby"
        case .running: return "Running"
        case .sailing: return "Sailing"
        case .skatingSports: return "Skating Sports"
        case .snowSports: return "Snow Sports"
        case .soccer: return "Soccer"
        case .softball: return "Softball"
        case .squash: return "Squash"
        case .stairClimbing: return "Stair Climbing"
        case .surfingSports: return "Surfing Sports"
        case .swimming: return "Swimming"
        case .tableTennis: return "Table Tennis"
        case .tennis: return "Tennis"
        case .trackAndField: return "Track and Field"
        case .traditionalStrengthTraining: return "Traditional Strength Training"
        case .volleyball: return "Volleyball"
        case .walking: return "Walking"
        case .waterFitness: return "Water Fitness"
        case .waterPolo: return "Water Polo"
        case .waterSports: return "Water Sports"
        case .wrestling: return "Wrestling"
        case .yoga: return "Yoga"

        // - iOS 10

        case .barre: return "Barre"
        case .coreTraining: return "Core Training"
        case .crossCountrySkiing: return "Cross Country Skiing"
        case .downhillSkiing: return "Downhill Skiing"
        case .flexibility: return "Flexibility"
        case .highIntensityIntervalTraining: return "High Intensity Interval Training"
        case .jumpRope: return "Jump Rope"
        case .kickboxing: return "Kickboxing"
        case .pilates: return "Pilates"
        case .snowboarding: return "Snowboarding"
        case .stairs: return "Stairs"
        case .stepTraining: return "Step Training"
        case .wheelchairWalkPace: return "Wheelchair Walk Pace"
        case .wheelchairRunPace: return "Wheelchair Run Pace"

        // - iOS 11

        case .taiChi: return "Tai Chi"
        case .mixedCardio: return "Mixed Cardio"
        case .handCycling: return "Hand Cycling"

        // - iOS 13

        case .discSports: return "Disc Sports"
        case .fitnessGaming: return "Fitness Gaming"

        // - iOS 14
        case .cardioDance: return "Cardio Dance"
        case .socialDance: return "Social Dance"
        case .pickleball: return "Pickleball"
        case .cooldown: return "Cooldown"

        // - Other
        case .other: return "Other"
        case .swimBikeRun:
            return "Swim Bike Run"
        case .transition:
            return "Transition"
        @unknown default: return "Other"
        }
    }
}
