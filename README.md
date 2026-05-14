# Assignment3_smarttrip
submission of trip planning app for 42889 Application Development in iOS Environment

SmartTrip is a collaborative iOS travel-planning application built with SwiftUI and following the MVVM architecture pattern. The app helps users organise trips, manage shared expenses, coordinate itineraries, and collaborate on destination planning with group members.

---

# Overview

SmartTrip was designed to improve the travel planning experience for groups by combining itinerary management, shared budgeting, and collaborative location suggestions into a unified mobile experience.

The application focuses on:
- collaborative trip coordination
- shared expense management
- group-based destination planning
- itinerary organisation
- intuitive user experience

---

# Features

## ✈️ Trip Management
- Create new trips
- Edit existing trip details
- Delete trips
- Multiple active trips supported
- Automatic archive handling for completed trips
- Dynamic dashboard navigation

## 👥 Group Collaboration
- Add participants individually
- Bulk add members using comma-separated input
- Shared group planning workflow
- Dynamic member tracking

## 📍 Suggested Locations
- Suggested places based on:
  - selected trip destination
  - current trip members
- Different suggestions for:
  - Tokyo
  - Fiji
  - Bangkok
- Suggested locations can be directly added into itineraries

## 🗓️ Itinerary Planning
- Create itinerary activities
- Add activities from suggested locations
- Activity categorisation
- Dynamic activity counts
- Trip-specific itinerary tracking

## 💰 Expense Tracking
- Shared expense recording
- Expense splitting calculations
- Budget overview page
- Expense grouping by date
- Trip-linked expense navigation
- Balance settlement calculations

## 📦 Past Trips Archive
- Automatically separates completed trips
- Archived trip dashboard access
- Archived budget tracking
- Historical itinerary viewing

## 🎨 User Experience
- SwiftUI-based interface
- Modern card-based design
- Dashboard-driven workflow
- Context menus for editing/deleting trips
- Navigation-based interaction flow

---

# Screenshots

## Home Page
<img width="259" height="488" alt="Screenshot 2026-05-14 at 3 43 04 PM" src="https://github.com/user-attachments/assets/ef7c8f45-88cf-4655-8a84-8d26c73828bc" />


## Dashboard
<img width="259" height="488" alt="Screenshot 2026-05-14 at 3 44 16 PM" src="https://github.com/user-attachments/assets/c2290f73-66be-4234-8ba5-ad5f8d2b216d" />


## Expense Tracking
<img width="259" height="488" alt="Screenshot 2026-05-14 at 3 43 33 PM" src="https://github.com/user-attachments/assets/ba710e42-dea7-4384-9cb2-aa1c17bfbfbe" />


## Suggested Locations
<img width="259" height="488" alt="Screenshot 2026-05-14 at 3 44 28 PM" src="https://github.com/user-attachments/assets/828fd81a-35d9-46de-be17-40c7410c414e" />


## Itinerary
<img width="259" height="488" alt="Screenshot 2026-05-14 at 3 44 51 PM" src="https://github.com/user-attachments/assets/0f6cdb93-5e3f-41cc-aa3c-8e1b1e2c85a2" />


## Budget Overview
<img width="259" height="488" alt="Screenshot 2026-05-14 at 3 45 48 PM" src="https://github.com/user-attachments/assets/64a8d578-04c7-4eca-94a8-d5fd09686bcf" />
<img width="259" height="488" alt="Screenshot 2026-05-14 at 3 45 33 PM" src="https://github.com/user-attachments/assets/1d76bda4-799a-41a1-a907-20a542a87081" />
<img width="259" height="488" alt="Screenshot 2026-05-14 at 3 45 41 PM" src="https://github.com/user-attachments/assets/de0fb7d6-edf8-4cea-aa6f-e3151f79aeb0" />

---

# Tech Stack

- Swift
- SwiftUI
- MVVM Architecture
- Xcode 16
- iOS 17+

---

# Architecture
The application follows the MVVM (Model-View-ViewModel) architecture pattern.

## Models
Responsible for representing application data structures.

Examples:
- Trip
- Expense
- TripMember
- ItineraryItem
- SuggestedPlace

## Views
SwiftUI user interface components are responsible for rendering screens and handling user interactions.

Examples:
- HomePageView
- DashboardView
- ExpenseView
- LocationView
- ItineraryView

## ViewModels
Responsible for:
- state management
- filtering logic
- expense calculations
- navigation coordination
- CRUD operations
- business logic separation

Examples:
- TripViewModel
- ExpenseViewModel
- ItineraryViewModel

---

# Project Structure

Assignment3_SmartTrip
│
├── Models
│   ├── Trip.swift
│   ├── Expense.swift
│   ├── Flight.swift
│   ├── TripMember.swift
│   ├── TripSample.swift
│   ├── TripStandard.swift
│   ├── WeatherData.swift
│   ├── ItineraryItem.swift
│   ├── SuggestedPlace.swift
│   ├── DemoCardData.swift
│   └── DemoLocationData.swift
│
├── ViewModels
│   ├── TripViewModel.swift
│   ├── FlightSearchViewModel.swift
│   ├── ExpenseViewModel.swift
│   ├── ItineraryViewModel.swift
│   └── WeatherViewModel.swift
│
Views
├── Dashboard
│   ├── DashboardView
│   └── HomePageView
│
├── Expense
│   ├── AddExpenseView
│   ├── ExpenseView
│   └── SplitResultView
│
├── Itinerary
│   ├── AddEditItineraryItemView
│   ├── ItineraryFormView
│   └── ItineraryView
│
└── TripLayout
│   ├── AddFlightView
│   ├── BudgetListView
│   ├── CreateTripView
│   ├── EditTripView
│   ├── FlightView
│   ├── GroupView
│   ├── LocationView
│   ├── PastTripsView
│   └── WeatherCardView
│
├── Assets
│
└── README.md

---

# Demo Data

The application includes built-in demo datasets for testing and demonstration purposes.

## Demo Trips
- Tokyo Friend Trip
- Fiji Staycation
- Sawadika Four Fun

## Included Demo Content
- trip members
- suggested locations
- itinerary activities
- shared expenses
- archived trips

## Loading Demo Data
1. Launch the application
2. Tap the profile/demo icon on the homepage

---

# Installation

## Requirements
- macOS
- Xcode 16+
- iOS 17 Simulator

## Setup

Clone the repository:

bash
git clone https://github.com/yourusername/SmartTrip.git

Open the project:

bash
cd SmartTrip
open Assignment3_SmartTrip.xcodeproj

Run the application:
1. Select an iPhone simulator
2. Press Cmd + R

---

# Key Learning Outcomes

This project demonstrates:
- SwiftUI navigation handling
- MVVM architecture implementation
- shared state management
- CRUD operations
- dynamic filtering logic
- expense splitting calculations
- reusable component design
- collaborative UX workflows
- SwiftUI sheet/navigation coordination

---

# Future Improvements

Potential future enhancements include:

- Firebase cloud sync
- Authentication system
- Real-time collaboration
- AI itinerary recommendations
- MapKit integration
- Currency conversion
- Push notifications
- Receipt OCR scanning
- Collaborative voting system for locations
- Offline mode support

---

# Contributors

- Yen-Chun Liu
- JinHao Feng
- Zekun Liu
- Ziying Zhao

---

# License

This project was developed for educational purposes.
