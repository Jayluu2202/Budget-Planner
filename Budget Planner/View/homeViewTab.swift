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
                Image("WaveHand")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                Spacer()
                Button(action: {
                    print("Money button Tapped")
                }){
                    Image("Wealth")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                }
            }
            
            HStack(spacing: 110){
                Image(systemName: "chevron.left")
                Text("Month YYYY")
                Image(systemName: "chevron.right")
            }
            Spacer()
            
        }.padding()
        
    }
}

struct HomeViewTab_Previews: PreviewProvider {
    static var previews: some View {
        homeViewTab()
    }
}
