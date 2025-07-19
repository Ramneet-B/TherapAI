//
//  SubscriptionManagementView.swift
//  TherapAI
//
//  Created by Ramneet Bhangoo on 2025-01-07.
//

import SwiftUI

struct SubscriptionManagementView: View {
    @StateObject private var subscriptionViewModel = SubscriptionViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Current Status Section
                    currentStatusSection
                    
                    // Features Section
                    featuresSection
                    
                    // Management Actions
                    managementActionsSection
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Subscription")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $subscriptionViewModel.showingPaywall) {
            PaywallView()
        }
    }
    
    // MARK: - Current Status Section
    private var currentStatusSection: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(subscriptionViewModel.subscriptionStatusColor.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: subscriptionViewModel.isPremiumUser ? "crown.fill" : "crown")
                    .font(.system(size: 40))
                    .foregroundColor(subscriptionViewModel.subscriptionStatusColor)
            }
            
            VStack(spacing: 5) {
                Text(subscriptionViewModel.isPremiumUser ? "Premium Member" : "Free Plan")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(subscriptionViewModel.subscriptionStatusText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(spacing: 15) {
            Text("Premium Features")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                FeatureStatusRow(
                    icon: "infinity",
                    title: "Unlimited AI Sessions",
                    isUnlocked: subscriptionViewModel.canAccessUnlimitedAI
                )
                
                FeatureStatusRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Advanced Insights",
                    isUnlocked: subscriptionViewModel.canAccessAdvancedInsights
                )
                
                FeatureStatusRow(
                    icon: "square.and.arrow.up",
                    title: "Export Journal Data",
                    isUnlocked: subscriptionViewModel.canExportJournal
                )
                
                FeatureStatusRow(
                    icon: "bell.badge",
                    title: "Smart Reminders",
                    isUnlocked: subscriptionViewModel.isPremiumUser
                )
                
                FeatureStatusRow(
                    icon: "shield.checkerboard",
                    title: "Priority Support",
                    isUnlocked: subscriptionViewModel.isPremiumUser
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
    
    // MARK: - Management Actions
    private var managementActionsSection: some View {
        VStack(spacing: 15) {
            if subscriptionViewModel.isPremiumUser {
                // Manage Subscription Button
                Button(action: {
                    subscriptionViewModel.manageSubscriptions()
                }) {
                    HStack {
                        Image(systemName: "gearshape.fill")
                        Text("Manage Subscription")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .fontWeight(.semibold)
                }
                
                // Restore Purchases Button
                Button(action: {
                    Task {
                        await subscriptionViewModel.restorePurchases()
                    }
                }) {
                    Text("Restore Purchases")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                        .fontWeight(.medium)
                }
            } else {
                // Upgrade to Premium Button
                Button(action: {
                    subscriptionViewModel.showingPaywall = true
                }) {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text("Upgrade to Premium")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .fontWeight(.semibold)
                }
                
                // Restore Purchases Button
                Button(action: {
                    Task {
                        await subscriptionViewModel.restorePurchases()
                    }
                }) {
                    Text("Restore Purchases")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                        .fontWeight(.medium)
                }
            }
        }
    }
}

// MARK: - Feature Status Row
struct FeatureStatusRow: View {
    let icon: String
    let title: String
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isUnlocked ? .green : .gray)
                .frame(width: 30)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isUnlocked ? .primary : .secondary)
            
            Spacer()
            
            Image(systemName: isUnlocked ? "checkmark.circle.fill" : "lock.circle.fill")
                .foregroundColor(isUnlocked ? .green : .gray)
        }
    }
}

struct SubscriptionManagementView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionManagementView()
    }
}