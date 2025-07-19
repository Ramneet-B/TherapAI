import SwiftUI

// MARK: - App Icon Generator
// Use this view to create your app icon by taking screenshots at different sizes

struct AppIconGenerator: View {
    let size: CGFloat
    
    init(size: CGFloat = 1024) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Same gradient as splash screen
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.purple.opacity(0.8),
                    Color.blue.opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Brain icon - same as splash screen
            Image(systemName: "brain.head.profile")
                .font(.system(size: size * 0.4, weight: .medium, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
        .clipped()
    }
}

// MARK: - Preview for Testing
struct AppIconGenerator_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Large version for App Store (1024x1024)
            AppIconGenerator(size: 200)
                .overlay(
                    Text("1024×1024")
                        .font(.caption)
                        .foregroundColor(.black)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(4),
                    alignment: .bottomTrailing
                )
            
            HStack(spacing: 20) {
                // Medium version
                AppIconGenerator(size: 120)
                    .overlay(
                        Text("120×120")
                            .font(.caption2)
                            .foregroundColor(.black)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(4),
                        alignment: .bottomTrailing
                    )
                
                // Small version
                AppIconGenerator(size: 60)
                    .overlay(
                        Text("60×60")
                            .font(.caption2)
                            .foregroundColor(.black)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(4),
                        alignment: .bottomTrailing
                    )
                
                // Tiny version
                AppIconGenerator(size: 30)
                    .overlay(
                        Text("30×30")
                            .font(.caption2)
                            .foregroundColor(.black)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(4),
                        alignment: .bottomTrailing
                    )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}

// MARK: - How to Use This
/*
INSTRUCTIONS TO CREATE YOUR APP ICONS:

1. ADD TO YOUR APP:
   - Add this file to your Xcode project
   - Add AppIconGenerator to any view temporarily

2. CAPTURE ICONS:
   Method A - iOS Simulator:
   - Run app in iOS Simulator
   - Navigate to view showing AppIconGenerator(size: 1024)
   - Cmd+S to save screenshot
   - Crop to just the icon square
   
   Method B - SwiftUI Preview:
   - Use Xcode's SwiftUI preview
   - Right-click on AppIconGenerator preview
   - "Copy" or screenshot
   
   Method C - Mac Playground:
   - Create macOS playground
   - Copy this code
   - Export as high-resolution image

3. RESIZE FOR ALL SIZES:
   - Use online tool like "Image Resizer" or "AppIcon.co"
   - Upload your 1024×1024 version
   - Generate all required iOS icon sizes
   
4. SAVE TO PROJECT:
   - Save all 18 PNG files to: TherapAI/Assets.xcassets/AppIcon.appiconset/
   - Use exact filenames from APP_ICON_GUIDE.md

5. REMOVE THIS FILE:
   - Delete IconGenerator.swift after creating icons
   - It's only needed for generating the icon images
*/