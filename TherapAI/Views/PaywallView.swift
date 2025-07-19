//
//  PaywallView.swift
//  TherapAI
//
//  Created by Ramneet Bhangoo on 2025-01-07.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var subscriptionViewModel = SubscriptionViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    headerSection
                    
                    // Features
                    featuresSection
                    
                    // Subscription Options
                    subscriptionOptionsSection
                    
                    // Legal Links
                    legalSection
                }
                .padding()
            }
            .navigationTitle("TherapAI Premium")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await subscriptionViewModel.subscriptionService.loadProducts()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.purple, Color.blue]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 10) {
                Text("Unlock Your Full Potential")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Get unlimited access to AI therapy sessions, advanced insights, and premium features")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(spacing: 15) {
            Text("Premium Features")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                FeatureRow(
                    icon: "infinity",
                    title: "Unlimited AI Sessions",
                    description: "No daily limits on AI therapy conversations"
                )
                
                FeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Advanced Analytics",
                    description: "Detailed mood patterns and insights over time"
                )
                
                FeatureRow(
                    icon: "square.and.arrow.up",
                    title: "Export Your Data",
                    description: "Download your journal entries and mood data"
                )
                
                FeatureRow(
                    icon: "bell.badge",
                    title: "Smart Reminders",
                    description: "Personalized notifications for check-ins"
                )
                
                FeatureRow(
                    icon: "shield.checkerboard",
                    title: "Priority Support",
                    description: "Get help faster with premium support"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
    
    // MARK: - Subscription Options
    private var subscriptionOptionsSection: some View {
        VStack(spacing: 15) {
            Text("Choose Your Plan")
                .font(.headline)
                .fontWeight(.semibold)
            
            if subscriptionViewModel.subscriptionService.isLoading {
                ProgressView("Loading subscription options...")
                    .frame(height: 100)
            } else {
                VStack(spacing: 10) {
                    ForEach(subscriptionViewModel.subscriptionService.products, id: \.id) { product in
                        SubscriptionCard(
                            product: product,
                            isSelected: selectedProduct?.id == product.id,
                            onSelect: {
                                selectedProduct = product
                            }
                        )
                    }
                }
            }
            
            // Purchase Button
            if let selectedProduct = selectedProduct {
                Button(action: {
                    Task {
                        await subscriptionViewModel.purchaseProduct(selectedProduct)
                    }
                }) {
                    HStack {
                        if subscriptionViewModel.isPurchasing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text(subscriptionViewModel.isPurchasing ? "Processing..." : "Start Free Trial")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .fontWeight(.semibold)
                }
                .disabled(subscriptionViewModel.isPurchasing)
            }
            
            // Restore Button
            Button("Restore Purchases") {
                Task {
                    await subscriptionViewModel.restorePurchases()
                }
            }
            .foregroundColor(.purple)
            .font(.subheadline)
        }
    }
    
    // MARK: - Legal Section
    private var legalSection: some View {
        VStack(spacing: 10) {
            Text("• Free trial for 1 week, then subscription auto-renews")
            Text("• Cancel anytime in Settings")
            Text("• Payment charged to iTunes Account")
                
            HStack(spacing: 20) {
                Link("Privacy Policy", destination: URL(string: "https://yourwebsite.com/privacy")!)
                Link("Terms of Service", destination: URL(string: "https://yourwebsite.com/terms")!)
            }
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.purple)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Subscription Card
struct SubscriptionCard: View {
    let product: Product
    let isSelected: Bool
    let onSelect: () -> Void
    
    private var isPopular: Bool {
        product.id.contains("monthly")
    }
    
    private var savingsText: String? {
        if product.id.contains("yearly") {
            return "Save 75%"
        } else if product.id.contains("monthly") {
            return "Most Popular"
        }
        return nil
    }
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(product.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(product.displayPrice)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if let period = subscriptionPeriodText {
                            Text(period)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if let savings = savingsText {
                    HStack {
                        Text(savings)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(isPopular ? .orange : .green)
                        Spacer()
                    }
                }
            }
            .padding()
            .background(isSelected ? Color.purple.opacity(0.1) : Color(.systemGray6))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
            )
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var subscriptionPeriodText: String? {
        if product.id.contains("weekly") {
            return "per week"
        } else if product.id.contains("monthly") {
            return "per month"
        } else if product.id.contains("yearly") {
            return "per year"
        }
        return nil
    }
}

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
    }
}