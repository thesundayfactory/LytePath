# App Architecture

This document outlines the architectural structure of the LytePath app.

---

## 🧠 Core Concept

The app is organized around **three main layers**:

1. **Input Layer** – Accepts and manages user lab data
2. **Logic Layer** – Performs algorithmic interpretation
3. **Presentation Layer** – Displays interpreted results and educational content

---

## 📥 1. Input Layer

### `ContentView.swift`
- Displays lab input fields based on selected electrolytes
- Manages input states for Na, K, pH, and related lab values
- Performs live validation and auto-calculation
- Saves and loads session data with `LabData`

---

## ⚙️ 2. Logic Layer

### `CalculationManager.swift`
- Contains:
  - `DisplayLabItem`: Chooses which lab items to show based on selected electrolytes
  - `LabValueCalculator`: Computes derived values (AG, TTKG, Delta Ratio, etc.)
  - `CMDUtils`: Utility functions for criteria, meanings, and diseases
	  -  Mapping between criteria, meanings, and diseases
	  - Building full disease routes
	  - Converting logic paths to human-readable strings

### `ResultModel.swift`
- Core algorithmic logic
  - `buildCStructures()`: Finds matched criteria via DFS
  - `buildMStructures()`: Converts criteria into meaningful interpretations
  - `multiPathSelection()`: Infers diseases from meaning paths

---

## 🧱 3. Data Layer

### `DataImport.swift`
- Loads CCriteria, Meaning, and Disease data from CSV files

### `Enums+Structs.swift`
- Defines:
  - `Electrolyte`, `VolumeStatusOption`, `AcuteChronicOption`
  - `LabItem`, `CCriteria`, `Meaning`, `Disease`

### `LabData+Persistence.swift`
- Saves and retrieves `LabData` using `UserDefaults`

---

## 🎨 4. Presentation Layer

### `ResultView.swift`
- Displays:
  - Matching logic paths
  - Selected interpretations
  - Top causes based on matching depth

### `MoreView.swift`
- Tree view of all matched and unmatched logic branches
- Navigation to `LogicView` for full algorithm graph

### `HelpView.swift`
- Static educational instructions and user guide

---

## 🧩 Other Supporting Files

### `View+Extensions.swift`
- UI helper components like:
  - `DotGroupView`, `ArrowCircleView`, `LabCell`, etc.
- Keyboard hiding extension