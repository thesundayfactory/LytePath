# Disease CSV

**Original Notion Database:** https://www.notion.so/LytePath_Database-22cd4a211bd680abbd49d6d49af0b9fc?source=copy_link

This CSV file was originally exported from a **Notion database**.  
Each row corresponds to the `Disease` struct used in logic interpretation.

**cf) Notice: the rule for the Disease database**
- The depth of Disease-to-Disease links must not exceed 1.
	(e.g., Ketonuria > DKA ⇒ O / Ketonuria > DKA > DM ⇒ X)


## Source Format
- **Original platform**: Notion database  
- **Export format**: CSV  

## Columns
- **ID**
	- Purpose:  Export only
	- Export: Yes
	- Notion property type: ID
	- Description: Unique number for identification
- **Type**
	- Purpose: Both
	- Export: Yes
	- Notion property type: Selection
	- Description: 
		- Options are "Finding" or "Diagnosis"
		- 'Finding' type may need to find underlying diseases.
			- e.g., Ketonuria
		- 'Diagnosis' type generally does not need to find further underlying diseases.
			- e.g., DKA
- **Typical**
	- Purpose: Both
	- Export: Yes
	- Notion property type: Checkbox
	- Description:
		- Boolean value
		- Marks diseases with high prevalence or those representing core mechanisms behind electrolyte abnormalities
		- Used to reduce unnecessary complexity in the “Possible Causes” section of the result view
- **Name**
	- Purpose: Both
	- Export: Yes
	- Notion property type: Title
	- Description: 
		- Name of the disease.
		- Should not use ',' (due to parsing problem)
- **ResultDisease**
	- Purpose: Writing only
	- Export: No
	- Notion property type: Relation (Related to this database)
	- Description: 
		- Connected to the head item.
		- Two-way relation with the CauseDisease property of this database.  
- **CauseDisease**
	- Purpose: Writing only
	- Export: No
	- Notion property type: Relation (Related to this database)
	- Description: 
		- Connected to the tail items.
		- Two-way relation with the ResultDisease property of this database.  
- **RelatedDisease**
	- Purpose: Writing only
	- Export: No
	- Notion property type: Relation (Related to this database)
	- Description: 
		- Non-directional links: the two-way relation is disabled.
		- Mutual connections are presented.
		- Related diseases share underlying mechanisms that contribute to electrolyte abnormalities.
- **Meaning**
	- Purpose: Reading only
	- Export: No
	- Notion property type: Relation (Related to the Meaning table)
	- Description
		- Connected to the related meanings.
		- Two-way relation with the Disease property of the Meaning table.
- **Description**
	- Purpose: Both
	- Export: Yes
	- Notion property type: Text
	- Description:
		- Explanation of the disease
		- Should not use ',' (due to parsing problem)
- **ResultDiseaseID**
	- Purpose: Export only
	- Export: Yes
	- Notion property type: Formula
	- Description: link the ResultDisease items' ID with '; '
- **CauseDiseaseID**
	- Purpose: Export only
	- Export: Yes
	- Notion property type: Formula
	- Description: link the CauseDisease items' ID with '; '
- **RelatedDiseaseID**
	- Purpose: Export only
	- Export: Yes
	- Notion property type: Formula
	- Description: link the RelatedDisease items' ID with '; '
- **MeaningID**
	- Purpose: None
	- Export: No
	- Notion property type: Formula
	- Description: link the Meaning items' ID with ', '

## Column Order (on export)
1. ID
2. Type
3. Typical
4. Name
5. ResultDiseaseID
6. CauseDiseaseID
7. RelatedDiseaseID
8. Description

### cf) DiseaseCards
A separate `DiseaseCards` database exists in Notion (not exported),  
which helps prevent duplicate or inconsistent disease entries under different names.  
It serves as a reference to ensure standardization across all related data sources.