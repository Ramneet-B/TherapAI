//
//  TherapAIApp.swift
//  TherapAI
//
//  Created by Ramneet Bhangoo on 2025-05-13.
//

import SwiftUI
import Firebase

@main
struct TherapAIApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var authViewModel = AuthViewModel()

    init() {
        // Configure Firebase
        FirebaseApp.configure()
        #if DEBUG
        print("🔥 Firebase initialized successfully")
        #endif
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch authViewModel.authState {
                case .loading:
                    SplashScreen()
                        .onAppear {
                            print("🔄 App State: Loading")
                        }
                case .signedOut, .error:
                    AuthenticationView()
                        .environmentObject(authViewModel)
                        .onAppear {
                            print("🔒 App State: Signed Out")
                        }
                case .signedIn(let user):
                    ContentView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .onAppear {
                            print("✅ App State: Signed In - \(user.email)")
                        }
                }
            }
            .environmentObject(authViewModel)
        }
    }
}

// MARK: - Splash Screen
struct SplashScreen: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text("TherapAI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
            }
        }
    }
}
