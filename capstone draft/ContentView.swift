//
//  ContentView.swift
//  capstone draft
//
//  Created by Xiaojing Meng on 1/5/26.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            LogView()
                .tabItem { Label("Log", systemImage: "list.bullet") }

        }
    }
}


/*
import SwiftUI

struct ContentView: View {
    @StateObject var store = SymptomStore()
    
    var body: some View {
        
        TabView{
            LogView(store: store)
                .tabItem { Label("Log", systemImage: "list.bullet") }
        }
         //   Tab(Constants.homeString, systemImage: "house"){
           //     Text(Constants.homeString)
            //}
            //Tab(Constants.logString, systemImage: "rectangle.and.pencil.and.ellipsis"){
              //  Text(Constants.logString)
            //}
           // Tab("Schedule", systemImage: "calendar"){
             //   Text("schedule")
            //}
            //Tab("News", systemImage: "newspaper"){
               // Text("news")
          //  }
        //}
    }
}

#Preview {
    ContentView()
}
*/
