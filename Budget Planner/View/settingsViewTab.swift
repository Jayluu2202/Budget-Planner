//
//  settingsViewTab.swift
//  Budget Planner
//
//  Created by mac on 03/09/25.
//

import SwiftUI

struct settingsViewTab: View {
    var body: some View {
        VStack{
            Text("Setting")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity,minHeight: 40, alignment: .leading)
                
            List{
                Section {
                    HStack{
                        hStackFunc(image: "arrow.up.doc", title: "Export Data",subtitle: true)
                    }
                }header: {
                    Text("General")
                }
                
                Section {
                    hStackFunc(image: "creditcard", title: "Accounts")
                    hStackFunc(image: "dollarsign.circle", title: "Currency")
                    hStackFunc(image: "square.grid.2x2", title: "Categories")
                    hStackFunc(image: "circle.lefthalf.filled", title: "Theme")
                    hStackFunc(image: "checkmark.shield", title: "App Lock")
                } header: {
                    Text("Account")
                }
                
                Section {
                    hStackFunc(image: "headphones", title: "Help & Support", subtitle: true)
                    hStackFunc(image: "info.circle", title: "Privacy Policy", subtitle: true)
                } header: {
                    Text("Support")
                }
            }
        }
        .padding()
    }
    func hStackFunc(image: String, title: String, subtitle: Bool = false) -> some View{
        HStack(spacing: 15){
            Image(systemName: "\(image)")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                
            VStack(spacing: 2){
                Text("\(title)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if subtitle == false{
                    Text("USD")
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            Spacer()
            Image(systemName: "chevron.right")
        }.frame(height: 50)
    }
}


struct settingsViewTab_preview: PreviewProvider {
    static var previews: some View {
        settingsViewTab()
        
    }
}
