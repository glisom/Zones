//
//  ZoneListView.swift
//  Zones
//
//  Created by Grant Isom on 10/19/23.
//

import SwiftUI

struct ZoneListView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: CardioZonesViewModel
    var body: some View {
        VStack {
            List(CardioZone.allCases, id: \.self) { zone in
                Text("\(String(describing: zone)): \(viewModel.timeInZone(zone))")
            }
        }
    }
}
