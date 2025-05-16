//
//  ContentView.swift
//  TherapAI
//
//  Created by Ramneet Bhangoo on 2025-05-13.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeScreen()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            MoodCheckInScreen()
                .tabItem {
                    Image(systemName: "face.smiling")
                    Text("Mood")
                }
            JournalScreen()
                .tabItem {
                    Image(systemName: "book.closed")
                    Text("Journal")
                }
            ChatScreen()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right")
                    Text("Chat")
                }
        }
        .accentColor(.purple)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
