//
//  ContentView.swift
//  capstone draft
//
//  Created by Xiaojing Meng on 1/5/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView{
            Tab("Home", systemImage: "house"){
                Text("home... for now :)")
            }
            Tab("Log", systemImage: "rectangle.and.pencil.and.ellipsis"){
                Text("log")
            }
            Tab("Schedule", systemImage: "calendar"){
                Text("sched")
            }
            Tab("News", systemImage: "newspaper"){
                Text("news")
            }
        }
    }
}

#Preview {
    ContentView()
}
