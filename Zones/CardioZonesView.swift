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

    init(viewModel: CardioZonesViewModel) {
        self.viewModel = viewModel
        viewModel.loadData(from: viewModel.startDate, to: viewModel.endDate)
    }

    var body: some View {
        NavigationView {
            VStack {
                Chart {
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
                HStack {
                    DatePicker("Start", selection: $viewModel.startDate, displayedComponents: .date)

                    Spacer()
                    DatePicker("End", selection: $viewModel.endDate, displayedComponents: .date)
                }
                .padding(.horizontal)
                Toggle("Show Zone 1", isOn: $showZoneOne)
                    .padding(.horizontal)
                List(CardioZone.allCases, id: \.self) { zone in
                    Text("\(String(describing: zone)): \(viewModel.timeInZone(zone))")
                }
                List(viewModel.workouts, id: \.uuid) { workout in
                    Text("\(workout.workoutActivityType.name)")
                }
            }.navigationTitle("Zones")
        }
    }
}
