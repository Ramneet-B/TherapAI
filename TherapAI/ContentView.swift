//
//  ContentView.swift
//  TherapAI
//
//  Created by Ramneet Bhangoo on 2025-05-13.
//

import SwiftUI

enum MainTab: Hashable {
    case home, mood, journal, chat
}

struct ContentView: View {
    @State private var selectedTab: MainTab = .home
    @StateObject private var dataService = DataService.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeScreen(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(MainTab.home)
            MoodCheckInScreen()
                .environmentObject(dataService.moodViewModel)
                .tabItem {
                    Image(systemName: "face.smiling")
                    Text("Mood")
                }
                .tag(MainTab.mood)
            JournalScreen()
                .environmentObject(dataService.journalViewModel)
                .tabItem {
                    Image(systemName: "book.closed")
                    Text("Journal")
                }
                .tag(MainTab.journal)
            ChatScreen()
                .environmentObject(dataService.chatViewModel)
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right")
                    Text("Chat")
                }
                .tag(MainTab.chat)
        }
        .accentColor(.purple)
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
