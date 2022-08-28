//
//  RecentreButton.swift
//  Paint The Town
//
//  Created by Lewis Valaitis on 28/08/2022.
//

import SwiftUI

struct RecentreButton: View {
    var action: () -> ()
    
    var body: some View {
        Button(action: action, label: {
            buttonContent
        })
    }
    
    var buttonContent: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 15)
                .stroke(.black, lineWidth: 2)
            
            HStack(alignment: .center) {
                Image(systemName: "location.north.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                
                Text("Re-centre")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.001)
                    
            }
            .padding(.horizontal, 8)
        }
        .foregroundColor(.black)
        .background(RoundedRectangle(cornerRadius: 15).fill(.white))
    }
}

struct RecentreButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            
            RecentreButton { }
                .frame(width: 100, height: 40)
        }
        
    }
}
