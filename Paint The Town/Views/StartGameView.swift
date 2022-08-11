//
//  StartGameView.swift
//  Paint The Town
//
//  Created by Lewis Valaitis on 06/08/2022.
//

import SwiftUI

struct StartGameView: View {
    
    @State var paintCompletion: CGFloat = 0.0
    
    var body: some View {
        VStack {
            PaintButton(text: "Start Game", color: .red, completion: paintCompletion, direction: .right, action: {})
                .frame(height: 55)
                .padding()
            
            PaintButton(text: "Invite Only", color: .blue, completion: paintCompletion, direction: .left, action: {})
                .frame(height: 55)
                .padding()
        }
        .onAppear {
            withAnimation(.easeIn(duration: 2.0)) {
                paintCompletion = 1
            }
        }
    }
}




struct StartGameView_Previews: PreviewProvider {
    static var previews: some View {
        StartGameView()
    }
}
