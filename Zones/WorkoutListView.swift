//
//  WorkoutListView.swift
//  Zones
//
//  Created by Grant Isom on 10/19/23.
//

import HealthKit
import SwiftUI

struct WorkoutListItem: Identifiable {
    let name: String
    var isSelected: Bool
    var id: UUID
}

struct WorkoutListView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: CardioZonesViewModel
    @State private var workouts = [WorkoutListItem]()
    @State private var multiSelection = Set<UUID>()
    var onFilter: (([HKWorkout]) -> Void)?

    var body: some View {
        NavigationView {
            VStack {
                List(workouts, selection: $multiSelection) { workout in
                    Text(workout.name)
                }
            }
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if self.multiSelection.isEmpty {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    } else {
                        Button("Filter") {
                            if let onFilter {
                                onFilter($viewModel.workouts.wrappedValue.filter { multiSelection.contains($0.uuid) })
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
        .onAppear {
            self.workouts = viewModel.workouts.map { hkWorkout in
                WorkoutListItem(name: hkWorkout.workoutActivityType.name, isSelected: false, id: hkWorkout.uuid)
            }
        }
    }
}
