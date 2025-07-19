# TherapAI - Mental Wellness Companion

## Overview

TherapAI is an iOS mental wellness application that provides AI-powered conversational support, mood tracking, journaling, and wellness resources. The app is designed to complement professional mental health care, not replace it.

## ⚠️ App Store Compliance Status

### ✅ COMPLETED - Ready for Submission

#### Privacy & Legal Compliance
- **Privacy Policy**: Complete privacy policy created (`PrivacyPolicy.md`)
- **Medical Disclaimers**: Comprehensive disclaimers throughout the app
- **Crisis Resources**: Emergency hotlines and resources prominently displayed
- **Info.plist**: Complete with privacy descriptions and security settings
- **Age Rating**: Appropriate for 17+ with mental health content

#### Core Features
- **AI Chat**: Therapeutic AI assistant with safety guardrails
- **Mood Tracking**: Daily mood check-ins and tracking
- **Journaling**: Private journaling with secure storage
- **User Authentication**: Secure Firebase authentication
- **Data Security**: End-to-end encryption and secure storage

#### Safety Features
- **Crisis Detection**: AI trained to recognize crisis situations
- **Emergency Resources**: Direct access to 988 and crisis text line
- **Professional Referrals**: Encourages professional therapy
- **Data Protection**: HIPAA-level security measures

## Features

### 🤖 AI Therapist Assistant
- Empathetic conversational AI trained for mental wellness support
- Context-aware responses based on conversation history
- Safety guardrails for crisis situations
- Rate limiting to prevent overuse

### 📊 Mood Tracking
- Daily mood check-ins with emotional scale
- Visual mood trends and insights
- Mood history and pattern recognition

### 📝 Private Journaling
- Secure, encrypted journal entries
- Reflection prompts and guided exercises
- Search and categorization features

### 🔐 Security & Privacy
- Firebase Authentication for secure login
- Encrypted data storage with Core Data
- No data sharing without explicit consent
- User data deletion capabilities

### 🆘 Crisis Support
- 24/7 crisis hotline integration (988)
- Crisis text line access (741741)
- Emergency contact information
- Professional therapy referrals

## Technical Implementation

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **Core Data**: Local data persistence with encryption
- **Firebase**: Authentication and cloud sync
- **OpenRouter**: AI conversation processing
- **MVVM Pattern**: Clean architecture with ViewModels

### Third-Party Services
- **OpenRouter AI**: Therapeutic conversation processing
- **Firebase Auth**: Secure user authentication
- **Firebase Firestore**: Cloud data synchronization

### Security Measures
- TLS 1.2+ for all network communications
- AES encryption for local data storage
- Secure keychain storage for sensitive data
- No data collection without explicit consent

## App Store Guidelines Compliance

### 1.4.1 Medical Apps ✅
- Clear medical disclaimers throughout the app
- Prominent "not a substitute for professional care" messaging
- Crisis resources readily available
- Professional therapy recommendations

### 5.1 Privacy ✅
- Comprehensive privacy policy
- Clear data collection disclosure
- User consent for all data usage
- Data deletion capabilities

### 3.1.1 In-App Purchases ✅
- No monetization currently implemented
- Designed for future subscription model if needed
- No incomplete payment systems

### 4.8 Login Services ✅
- Custom authentication system
- No dependency on third-party social logins
- Secure credential management

## Pre-Submission Checklist

### ✅ Completed Items
- [x] Privacy policy created and accessible
- [x] Medical disclaimers added throughout app
- [x] Crisis resources prominently displayed
- [x] App icon properly configured
- [x] Info.plist complete with privacy descriptions
- [x] AI safety guardrails implemented
- [x] Professional therapy recommendations included
- [x] Data encryption and security measures
- [x] Age-appropriate content rating
- [x] No incomplete subscription systems

### 📋 App Store Connect Setup Required
- [ ] App description emphasizing wellness support (not therapy)
- [ ] Screenshots showing disclaimers and safety features
- [ ] Age rating: 17+ for mental health content
- [ ] Privacy labels configured
- [ ] Contact information for support

## App Store Description Template

```
TherapAI - Your Mental Wellness Companion

IMPORTANT: TherapAI is not a substitute for professional mental health care. It's designed to complement therapy and provide wellness support.

Features:
• AI-powered wellness conversations with safety guardrails
• Daily mood tracking and insights
• Private, encrypted journaling
• Crisis resources and emergency support
• Professional therapy referrals

Safety First:
• Built-in crisis detection and support
• Direct access to 988 Suicide & Crisis Lifeline
• Medical disclaimers throughout the app
• Encourages professional mental health care

Privacy & Security:
• End-to-end encryption
• No data sharing without consent
• Complete data deletion options
• HIPAA-level security measures

If you're experiencing a mental health crisis, please contact:
• 988 - Suicide & Crisis Lifeline
• 911 - Emergency services
• Crisis Text Line: Text HOME to 741741
```

## Support Information

### Crisis Resources
- **National Suicide Prevention Lifeline**: 988
- **Crisis Text Line**: Text HOME to 741741
- **Emergency Services**: 911

### App Support
- **Privacy Questions**: privacy@therapai.com
- **Technical Support**: support@therapai.com
- **General Inquiries**: info@therapai.com

## Development Team Notes

### Code Quality
- Comprehensive error handling
- Proper memory management
- Accessibility support
- Clean code architecture

### Testing
- Unit tests for critical functions
- UI testing for user flows
- Security testing for data handling
- Accessibility testing

### Future Enhancements
- Professional therapist directory
- Group support features
- Advanced analytics
- Wearable device integration

---

**Version**: 1.0  
**Last Updated**: December 2024  
**Compliance Review**: Complete ✅  
**Ready for App Store Submission**: Yes ✅