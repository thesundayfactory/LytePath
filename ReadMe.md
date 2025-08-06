# LytePath

**LytePath** is an iOS educational tool designed for medical students, residents, and healthcare professionals. It provides a structured, algorithm-based approach to interpreting electrolyte abnormalities and identifying possible underlying causes.

---

## 🔍 Features

- Select target electrolytes: **Na**, **K**, **pH**
- Enter relevant lab values — both plasma and urine
- Automatically calculates derived values:
  - **TTKG**, **Anion gap (AG)**, **Osmolar gap (OG)**
  - **Expected/Actual HCO₃ / CO₂**, **Δ ratio**, etc.
- Suggests mechanisms explaining the abnormality
- Infers potential **diagnoses** based on selected logic paths
- Tree-based visualization of interpretation routes
- Fully offline: No data collection or external storage

---

## 🧠 Logic Overview

The app is built on a three-tiered logic system:

1. **Lab Criteria (CCriteria)**  
   Threshold-based conditions (e.g., `pNa < 135`, `UOsm > 100`)

2. **Mechanisms (Meaning)**  
   Clinical interpretations like "High anion gap metabolic acidosis"

3. **Diseases**  
   Final diagnostic entities (e.g., SIADH, Diuretics use)

Each logic unit is structured in a **tree**, and users can trace the logic path from lab criteria to disease.

---

## 📱 How to Use

1. **Select Electrolytes**  
   Tap Na, K, or pH to begin.

2. **Enter Lab Values**  
   Required and recommended fields appear dynamically.

3. **Tap 'Done'**  
   The app analyzes available data and shows:
   - Matched interpretation chains
   - Possible diseases

4. **Explore Details**  
   Tap `>` to expand paths, or `More` to view the full logic tree.

5. **Warnings**  
   - Invalid (physiologically implausible) values are blocked.
   - Auto-calculated fields are read-only.

---

## 🔒 Privacy

- All input is stored **only** on the device
- No internet connection required
- No analytics or data collection

---

## 📁 Data Files

**Original Notion Database:** https://www.notion.so/LytePath_Database-22cd4a211bd680abbd49d6d49af0b9fc?source=copy_link

- `LabCriteria_ver 4_new12_edited.csv`
- `Meaning_ver 4_new12_edited.csv`
- `Disease_ver 4_new12_edited.csv`

> These files define the logic tree and diagnostic mapping.

---

## ⚠️ Disclaimer

LytePath is intended for **educational use only** by medical professionals.  
It does **not** provide medical diagnoses and should not replace clinical judgment.

---

## 📌 App Info

- Version: 1.0.0
- License: MIT
- GitHub: [https://github.com/thesundayfactory/LytePath](https://github.com/thesundayfactory/LytePath)
- Contact: thesundayfactory01@gmail.com