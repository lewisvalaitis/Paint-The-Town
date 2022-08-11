//
//  GameView.swift
//  Paint The Town
//
//  Created by Lewis Valaitis on 06/08/2022.
//

import SwiftUI
import MapKit

struct GameView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        MapView(userMapData: viewModel.mapUserData)
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
