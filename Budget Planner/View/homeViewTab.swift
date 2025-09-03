//
//  homeViewTab.swift
//  Budget Planner
//
//  Created by mac on 03/09/25.
//

import SwiftUI

struct homeViewTab: View {
    var body: some View {
        VStack{
            HStack{
                Text("Hey! Greetings")
                    .font(.headline)
//                Image("Hand Wave Emoji")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 30, height: 30)
                
                Button(action: {
                    print("Money button Tapped")
                }){
                    Image("Money")
                }
            }
        }.padding()
    }
}

struct HomeViewTab_Previews: PreviewProvider {
    static var previews: some View {
        homeViewTab()
    }
}
