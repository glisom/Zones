//
//  CardioZonesView.swift
//  Zones
//
//  Created by Grant Isom on 7/30/23.
//

import Charts
import SwiftUI

struct CardioZonesView: View {
    @ObservedObject var viewModel: CardioZonesViewModel
    @State var showZoneOne: Bool = false
    @State var showZoneListView = false
    @State var showWorkoutListView = false
    @State var zoneGoal = 200

    init(viewModel: CardioZonesViewModel) {
        self.viewModel = viewModel
        viewModel.loadData(from: viewModel.startDate, to: viewModel.endDate)
    }

    var body: some View {
        NavigationView {
            VStack {
                Chart {
                    RuleMark(y: .value("Goal", zoneGoal))
                    if showZoneOne {
                        BarMark(
                            x: .value("Zone", "Zone 1"),
                            y: .value("Minutes in Zone", viewModel.timeInZoneValue(.warmUp))
                        )
                    }
                    BarMark(
                        x: .value("Zone", "Zone 2"),
                        y: .value("Minutes in Zone", viewModel.timeInZoneValue(.fatBurn))
                    )
                    .foregroundStyle(.cyan)
                    BarMark(
                        x: .value("Zone", "Zone 3"),
                        y: .value("Minutes in Zone", viewModel.timeInZoneValue(.aerobic))
                    )
                    .foregroundStyle(.yellow)
                    BarMark(
                        x: .value("Zone", "Zone 4"),
                        y: .value("Minutes in Zone", viewModel.timeInZoneValue(.anaerobic))
                    )
                    .foregroundStyle(.orange)
                    BarMark(
                        x: .value("Zone", "Zone 5"),
                        y: .value("Minutes in Zone", viewModel.timeInZoneValue(.peak))
                    )
                    .foregroundStyle(.red)
                }
                .aspectRatio(contentMode: .fit)
                HStack {
                    DatePicker("Start", selection: $viewModel.startDate, displayedComponents: .date)

                    Spacer()
                    DatePicker("End", selection: $viewModel.endDate, displayedComponents: .date)
                }
                .padding(.horizontal)
                Toggle("Show Zone 1", isOn: $showZoneOne)
                    .padding(.horizontal)
                TextField("Zone Goal", value: $zoneGoal, formatter: NumberFormatter())
                    .padding(.horizontal)
                Divider()
                Button {
                    showZoneListView.toggle()
                } label: {
                    Text("Show Zone Details")
                        .font(.headline)
                }
                .sheet(isPresented: $showZoneListView) {
                    ZoneListView(viewModel: self.viewModel)
                }
                .padding()
                Button {
                    showWorkoutListView.toggle()
                } label: {
                    Text("Show Workouts")
                        .font(.headline)
                }
                .sheet(isPresented: $showWorkoutListView) {
                    WorkoutListView(viewModel: self.viewModel) { workouts in
                        self.viewModel.filterOnWorkouts(workouts)
                    }
                }
                .padding()
            }.navigationTitle("Zones")
        }
    }
}
