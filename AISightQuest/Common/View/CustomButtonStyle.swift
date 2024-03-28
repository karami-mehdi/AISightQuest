//
//  CustomButtonStyle.swift
//  AISightQuest
//
//  Created by Mehdi Karami on 3/29/24.
//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .bold()
            .frame(height: 40)
            .frame(minWidth: 40)
            .background {
                Capsule()
                    .fill(LinearGradient(colors: configuration.isPressed ? [Color.lilac500]
                                         : [Color.darkBlue500, .darkBlue900],
                                         startPoint: .top,
                                         endPoint: .bottom))
            }
    }
}

#Preview {
    Button { 
        print("Pressed")
    } label: {
        HStack {
            Image(systemName: "plus")
                .foregroundStyle(.lilac200)
            Text("new session")
                .foregroundStyle(.lilac100)
        }
    }
    .buttonStyle(CustomButtonStyle())
}
