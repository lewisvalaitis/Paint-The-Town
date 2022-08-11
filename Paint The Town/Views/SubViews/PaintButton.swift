//
//  PaintButtonView.swift
//  Paint The Town
//
//  Created by Lewis Valaitis on 07/08/2022.
//

import SwiftUI

struct PaintButton: View, Animatable {
    var text: String
    var color: Color
    var completion: CGFloat
    var direction: Direction
    var action: () -> ()
    
    enum Direction {
        case left, right
    }
    
    var animatableData: CGFloat {
        get {
            completion
        }
        set {
            completion = newValue
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack (alignment: .leading) {
                
                Path { path in
                    
                    let y = proxy.size.height / 2
                    
                    switch direction {
                    case .left:
                        path.move(to: CGPoint(x: proxy.size.width, y: y))
                        path.addLine(to: CGPoint(x: 0, y: y))
                    case .right:
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: proxy.size.width, y: y))
                    }
                }
                .trimmedPath(from: 0, to: completion)
                .stroke(color, lineWidth: proxy.size.height)
                
                Button(action: action, label: {
                    HStack(alignment: .center) {
                        
                        Spacer()
                        
                        Text(text)
                            .font(.system(size: proxy.size.height * 0.8, weight: .heavy, design: .default))
                            .foregroundColor(.white)
                            .padding(.leading)
                        
                        Spacer()
                    }
                })
                .disabled(completion != 1)
                
                Image("PaintBrush")
                    .resizable()
                    .rotationEffect(Angle(degrees: direction == .right ? 90 : -90))
                    .frame(width: proxy.size.height, height: proxy.size.height)
                    .offset(x: get_brush_x_offset(in: proxy.size),
                            y: 0)
            }
        }
    }
    
    func get_brush_x_offset(in size: CGSize) -> CGFloat {
        let brushSize = size.height
        let relative_completion = size.width * completion
        
        switch direction {
        case .left:
            return size.width - relative_completion - brushSize + 3/5 * size.height
        case .right:
            return relative_completion - brushSize + 2/5 * size.height
        }
    }
}

struct PaintButton_Previews: PreviewProvider {
    @State static var completion: CGFloat = 0
    
    static var previews: some View {
        PaintButton(text: "StartGame", color: .red, completion: completion, direction: .right, action: {})
            .onAppear {
                Self.completion = 1
            }
    }
}
