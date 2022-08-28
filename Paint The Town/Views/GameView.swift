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
    @State var trackUser: Bool = true
    
    var body: some View {
        ZStack (alignment: .bottomLeading){
            MapView(data: viewModel.mapUserData, trackUser: $trackUser)
            
            if !trackUser {
                RecentreButton {
                    trackUser = true
                }
                .frame(width: 100, height: 40)
                .padding()                
            }
        }
        .onAppear {
            trackUser = viewModel.mapUserData.isTracking
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
