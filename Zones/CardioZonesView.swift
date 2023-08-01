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

    init(viewModel: CardioZonesViewModel) {
        self.viewModel = viewModel
        viewModel.loadData(from: viewModel.startDate, to: viewModel.endDate)
    }

    var body: some View {
        VStack {
            HStack {
                Text("Start Date")
                    .bold()
                Spacer()
                Text("End Date")
                    .bold()
            }
            .padding(.horizontal)
            HStack {
                DatePicker("", selection: $viewModel.startDate, displayedComponents: .date)
                    .labelsHidden()
                Spacer()
                DatePicker("", selection: $viewModel.endDate, displayedComponents: .date)
                    .labelsHidden()
            }
            .padding(.horizontal)
            Chart {
//                BarMark(
//                    x: .value("Zone", "Zone 1"),
//                    y: .value("Minutes in Zone", viewModel.timeInZoneValue(.warmUp))
//                )
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
            List(CardioZone.allCases, id: \.self) { zone in
                Text("\(String(describing: zone)): \(viewModel.timeInZone(zone))")
            }
        }
    }
}
