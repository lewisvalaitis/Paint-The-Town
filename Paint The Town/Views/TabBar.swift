//
//  SwiftUIView.swift
//  Paint The Town
//
//  Created by Lewis Valaitis on 07/08/2022.
//

import SwiftUI

// MARK: - Tab Item
struct TabItem: Identifiable {
    var id: String
    var imageName: String
}

// MARK: - Tab Bar
struct TabBar<Content: View>: View {
    @State private(set) var currentTabId: String
    var tabItems: [TabItem]
    /// Takes `Tab Id` and returns content view
    @ViewBuilder var getCurrentContent: (String) -> Content
    
    var body: some View {
        GeometryReader { proxy in
            
            ZStack(alignment: .bottom) {
                
                getCurrentContent(currentTabId)
                    .ignoresSafeArea()
                
                tabButtons
                    .frame(height: 60)
                    .frame(width: proxy.size.width - 24)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.black, lineWidth: 4)
                            .background(RoundedRectangle(cornerRadius: 10).fill(.white))
                    )
                
            }
        }
    }
    
    var tabButtons: some View {
        HStack {
            Spacer ()
            ForEach(tabItems, id: \.id) { tab in
                
                TabButton(tabItem: tab, selected: tab.id == currentTabId) {
                    self.currentTabId = tab.id
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: Tab Button
    private struct TabButton: View {
        let tabItem: TabItem
        let selected: Bool
        let action: () -> ()
        
        var body: some View {
            Button(action: action,
                   label: {
                Image(systemName: tabItem.imageName)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundColor(selected ? .black : .gray.opacity(0.8))
                
            })
            .foregroundColor(.white)
            .padding()
        }
    }
}

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBar(currentTabId: "0",
               tabItems: [
                           TabItem(id: "0", imageName: "paintpalette.fill"),
                           TabItem(id: "1", imageName: "person.circle.fill"),
                           TabItem(id: "2", imageName: "gearshape.circle.fill")
                            
               ]) { id in
                   
                   switch id {
                   case "0": Rectangle().fill(.red)
                   case "1": Rectangle().fill(.blue)
                   case "2": Rectangle().fill(.green)
                   default: EmptyView()
                   }
                   
               }
    }
}
