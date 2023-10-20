//
//  WorkoutListView.swift
//  Zones
//
//  Created by Grant Isom on 10/19/23.
//

import SwiftUI

struct WorkoutListView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: CardioZonesViewModel
    var body: some View {
        VStack {
            List(viewModel.workouts, id: \.uuid) { workout in
                Text("\(workout.workoutActivityType.name)")
            }
        }
    }
}
