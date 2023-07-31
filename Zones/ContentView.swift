//
//  ContentView.swift
//  Zones
//
//  Created by Grant Isom on 7/30/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CardioZonesView(viewModel: CardioZonesViewModel())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
