/*
 CoreDataModelConfiguration.swift
 
 IMPORTANT: You need to manually add these entities to your TherapAI.xcdatamodeld file in Xcode.
 
 Instructions:
 1. Open TherapAI.xcdatamodeld in Xcode
 2. Delete the existing "Item" entity if it exists
 3. Add the following three entities with their attributes:
 
 ┌─────────────────────────────────────────────────────────────┐
 │                      MOODENTRY ENTITY                      │
 ├─────────────────────────────────────────────────────────────┤
 │ Attribute Name    │ Type      │ Optional │ Default          │
 ├─────────────────────────────────────────────────────────────┤
 │ id               │ UUID      │ No       │ -                │
 │ date             │ Date      │ No       │ -                │
 │ moodIndex        │ Integer16 │ No       │ 0                │
 │ note             │ String    │ Yes      │ -                │
 │ createdAt        │ Date      │ No       │ -                │
 └─────────────────────────────────────────────────────────────┘
 
 ┌─────────────────────────────────────────────────────────────┐
 │                    JOURNALENTRY ENTITY                     │
 ├─────────────────────────────────────────────────────────────┤
 │ Attribute Name    │ Type      │ Optional │ Default          │
 ├─────────────────────────────────────────────────────────────┤
 │ id               │ UUID      │ No       │ -                │
 │ content          │ String    │ No       │ -                │
 │ aiFeedback       │ String    │ Yes      │ -                │
 │ createdAt        │ Date      │ No       │ -                │
 │ updatedAt        │ Date      │ No       │ -                │
 │ wordCount        │ Integer32 │ No       │ 0                │
 └─────────────────────────────────────────────────────────────┘
 
 ┌─────────────────────────────────────────────────────────────┐
 │                    CHATMESSAGE ENTITY                      │
 ├─────────────────────────────────────────────────────────────┤
 │ Attribute Name    │ Type      │ Optional │ Default          │
 ├─────────────────────────────────────────────────────────────┤
 │ id               │ UUID      │ No       │ -                │
 │ content          │ String    │ No       │ -                │
 │ isFromUser       │ Boolean   │ No       │ NO               │
 │ timestamp        │ Date      │ No       │ -                │
 │ conversationId   │ UUID      │ Yes      │ -                │
 └─────────────────────────────────────────────────────────────┘
 
 Entity Settings:
 - Set "Codegen" to "Manual/None" for all entities
 - Set "Class" to the entity name (MoodEntry, JournalEntry, ChatMessage)
 - All entities should be in the "TherapAI" module
 
 Once completed, your Core Data model will work with the ViewModels created in this Phase 1.
 */

import Foundation

// This file serves as documentation only.
// The actual Core Data entities must be created manually in Xcode. 