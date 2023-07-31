//
//  CardioZonesView.swift
//  Zones
//
//  Created by Grant Isom on 7/30/23.
//

import SwiftUI

struct CardioZonesView: View {
    @ObservedObject var viewModel: CardioZonesViewModel

    init(viewModel: CardioZonesViewModel) {
        self.viewModel = viewModel
        viewModel.loadData()   
    }
    var body: some View {
        ZStack {
            List(CardioZone.allCases, id: \.self) { zone in
                Text("\(String(describing: zone)): \(viewModel.timeInZone(zone))")
            }
        }
    }
}
