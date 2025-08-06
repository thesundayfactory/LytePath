
## 📂 Data Structure Overview

LytePath’s algorithmic engine is powered by a carefully structured hierarchy of three data layers: **CCriteria**, **Meaning**, and **Disease**. Each layer builds upon the last to convert raw lab data into clinically relevant disease suggestions.

---

## 1. **CCriteria Layer**

**CSV:** `LabCriteria_ver 4_new12_edited.csv`  
**Swift Struct:** `CCriteria` (in `Enums+Structs.swift`)

### ✅ Role

CCriteria defines threshold-based lab conditions such as “pNa < 135” or “pHCO3 > 26”.  
Each node can:

- Point to other CCriteria (`tailCID`) → builds tree logic.
- Be associated with one or more Meanings (`meaningID`).

---

## 2. **Meaning Layer**

**CSV:** `Meaning_ver 4_new12_edited.csv`  
**Swift Struct:** `Meaning`

### ✅ Role

Meanings represent _clinical mechanisms_ like “Renal Na loss” or “Volume depletion”.  
They form a **directed acyclic graph (DAG)** by linking to:

- Other Meanings via `tailMID`
- Diseases via `diseaseID`

---
## 3. **Disease Layer**

**CSV:** `Disease_ver 4_new12_edited.csv`  
**Swift Struct:** `Disease`

### ✅ Role

Diseases are the final diagnostic endpoints, connected to the lowest-level Meanings.

---
## 📌 Integration Flow

From input lab data to disease suggestions:

1. **CCriteria matching** (`ResultLogic.buildCStructures`)  
    → selects all criteria satisfied by lab values
    
2. **Meaning path building** (`ResultLogic.buildMStructures`)  
    → maps CCriteria sequences to Meaning chains
    
3. **Disease mapping** (`ResultLogic.multiPathSelection`)  
    → collects diseases connected to the meanings
    
4. **Visualization**
    
    - **ResultView**: summarizes meanings and matches
        
    - **MoreView / LogicView**: reveals full Meaning and Disease graph
        
    - **DotGroupView**: shows path matching depth

---

## 🛠 LabItem Layer (Supportive)

**Defined in:** `LabItem` (in `Enums+Structs.swift`)

- Represents all measurable labs.
- Used by CCriteria to follow the algorithms.

---
## 📐 Data Diagram Notes
**1) LabCriteria structures** ![[LabCriteria Structures.png]]
**2) LabCriteria example - pH** ![[LabCriteria example- LabCriteria (pH).png]]
**3) Data structures overview - LabItem & CCriteria & Meaning & Disease** ![[Data Structures overview.png]]
**4) Data Structures example - CCriteria & Meaning & Disease** ![[Data Structures example- Criteria & Meaning & Disease.png]]