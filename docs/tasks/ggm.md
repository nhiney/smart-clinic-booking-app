You are a Senior Flutter + Firebase Engineer with strong experience in Clean Architecture, scalable mobile apps, and production-level code quality.

Your task is to implement a Doctor Search, Doctor Detail, Hospital Selection, and Map Feature inside an existing Flutter project WITHOUT breaking any existing code.

---

# 🔥 CORE REQUIREMENTS

## 1. Architecture (MANDATORY)
Follow Clean Architecture strictly:

- Presentation Layer:
  - Screens
  - Controllers (Riverpod or Bloc – choose one and be consistent)

- Domain Layer:
  - Entities
  - UseCases

- Data Layer:
  - Models
  - Repositories
  - Firebase (Firestore) data sources

Flow:
UI → Controller → UseCase → Repository → Firestore

DO NOT mix layers.

---

# 🧑‍⚕️ FEATURE 1: DOCTOR SEARCH

## Requirements

User can:
- Search doctors by:
  - Specialty (exact match)
  - Rating (>= value)
  - Location (city string)
  - Optional: name keyword

## Firestore Collection: doctors

Fields:
- doctorId
- name
- avatarUrl
- specialty
- rating (double)
- experienceYears (int)
- description
- clinicName
- location (string)
- schedule (map)

Example schedule:
{
  "monday": ["08:00-11:00", "14:00-18:00"],
  "tuesday": ["..."]
}

---

## Query Rules (IMPORTANT)

- Combine filters using AND
- rating uses >=
- specialty & location use equality
- Implement REAL Firestore queries (no mock data)

Handle:
- loading state
- error state
- empty result state

---

## UI: Doctor List Item

Each item must show:
- Avatar
- Name
- Specialty
- Rating
- Clinic Name

---

# 🧑‍⚕️ FEATURE 2: DOCTOR DETAIL

On tap doctor → open detail screen

Display:
- Avatar
- Name
- Specialty
- Rating
- Experience (years)
- Description
- Clinic Name
- Location
- Working Schedule (days + time slots)

Handle null or missing data safely.

---

# 🏥 FEATURE 3: HOSPITAL SELECTION

## Firestore Collection: hospitals

Fields:
- hospitalId
- name
- rating
- address
- location
- latitude
- longitude
- specialties (array)

---

## Features

Display:
- Name
- Rating
- Address

Support:
- Suggest nearest hospitals
- Filter by specialty (based on user need)

---

# 🗺️ FEATURE 4: GOOGLE MAP

## Requirements

Integrate Google Maps Flutter plugin.

Display:
- User location (patient)
- Hospital markers

---

## User Location

- Use FREE solution (geolocator)
- Request permission properly
- Handle:
  - अनुमति denied
  - GPS off
  - loading state

---

## Hospital Markers

Each marker:
- Show hospital name
- Show rating
- Show distance (km)

---

## Distance Calculation

- Calculate distance between user and hospital (Haversine formula)
- Do calculation on client side

---

## Map Behavior

- Auto focus on user location
- Show nearby hospitals
- Highlight nearest hospital
- Click marker → show bottom sheet with:
  - Name
  - Rating
  - Distance
  - Button: View Detail

---

# ⚠️ IMPORTANT CONSTRAINTS

## ❗ VERY IMPORTANT (DO NOT IGNORE)

- The entire feature MUST use FREE solutions only
- DO NOT use any paid APIs or paid services
- DO NOT implement anything that requires billing
- Optimize for zero-cost usage

---

## Additional Constraints

- DO NOT break existing project structure
- DO NOT remove existing code
- Only ADD new modules
- Write clean, readable, maintainable code
- Use null safety
- Follow best practices

---

# 🧠 EDGE CASES (MUST HANDLE)

- No doctors found → show empty UI
- Firestore error → show error UI
- No hospitals nearby → show message
- Location permission denied
- GPS disabled
- Missing schedule data

---

# 🚀 OUTPUT REQUIREMENTS

Generate:

1. Folder structure (Clean Architecture)
2. Entities
3. Models
4. Firestore data source
5. Repository implementation
6. UseCases
7. Controllers (state management)
8. UI Screens:
   - Doctor Search Screen
   - Doctor Detail Screen
   - Hospital List Screen
   - Map Screen
9. Google Maps integration
10. Distance calculation logic

---

# 🎯 GOAL

The final result must be:
- Production-ready
- Scalable
- Clean Architecture compliant
- Fully working with Firestore
- Smooth UX (loading, error, empty states)

---

Take your time, think deeply, and implement step-by-step like a real senior