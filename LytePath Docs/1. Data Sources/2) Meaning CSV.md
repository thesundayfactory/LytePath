# Meaning CSV

**Original Notion Database:** https://www.notion.so/LytePath_Database-22cd4a211bd680abbd49d6d49af0b9fc?source=copy_link

This CSV file was originally exported from a **Notion database**.  
Each row corresponds to the `Meaning` struct used in logic interpretation.

**cf) Notice: the rules for the Meaning database (A forest of trees)**
- Each node has exactly one parent (except root nodes, which have none)
- No cycles (the structure is acyclic)
- There exists a unique path from a root to every node
- Even if two nodes represent the same clinical concept, they are treated as distinct if their upstream paths differ (e.g., Aldosterone ↑)

## Source Format
- **Original platform**: Notion database  
- **Export format**: CSV  

## Columns
- **ID**
	- Purpose:  Export only
	- Export: Yes
	- Notion property type: ID
	- Description: Unique number for identification
- **Order**
	- Purpose: Both
	- Export: Yes
	- Notion property type: Number
	- Description:
		- Double
		- Unique number in each Electrolyte type
		-  CCriteria-linked entries use integers (others use floats).
		- Written for logical orders in the Notion database
		- Exported for sorting in the views
- **Electrolyte**
	- Purpose: Both
	- Export: Yes
	- Notion property type: Selection
	- Description: Matches the `Electrolyte` enum.
- **Category**
	- Purpose: Both
	- Export: Yes
	- Notion property type: Selection
	- Description: 
		- Options are "CCriteria", "Mechanism" or "Divider"
		- CCriteria: Meanings directly linked to one or more CCriteria. Rough clinical meanings.
		- Mechanism: Detailed clinical meanings
		- Divider: A structural element used to organize or group related Diseases. For visual grouping only.
- **CCriteria**
	- Purpose: Reading only
	- Export: No
	- Notion property type: Relation (Related to the LabCriteria table)
	- Description: 
		- Connected to the related criteria.
		- Two-way relation with the Meaning property of the LabCriteria table.
		- Only CCriteria category items have one or more associated CCriterias.
- **Name**
	- Purpose: Both
	- Export: Yes
	- Notion property type: Title
	- Description: 
		- Title of the contents.
		- Should not use ',' (due to parsing problem)
- **HeadM**
	- Purpose: Writing only
	- Export: No
	- Notion property type: Relation (Related to this database)
	- Description
		- Directly connected head items
		- Two-way relation with the TailM property of this database
- **TailM**
	- Purpose: Reading only
	- Export: No
	- Notion property type: Relation (Related to this database)
	- Description:
		- Directly connected tail items
		- Two-way relation with the HeadM property of this database
- **Disease**
	- Purpose: Writing only
	- Export: No
	- Notion property type: Relation (Related to the Disease table)
	- Description:
		-  Connected to the related disease.
		- Two-way relation with the Meaning property of the Disease table.
		- All category items can have one or more associated Diseases.
- **Arrow**
	- Purpose: Both
	- Export: Yes
	- Notion property type: Selection
	- Description: 
		- Selection options are "↑", "↓", or "-".
		- Only potential root Meanings have a value in this field.
- **CCriteriaID**
	- Purpose: None
	- Export: No
	- Notion property type: Formula
	- Description: link the CCriteria items' ID with ', '
- **HeadMID**
	- Purpose: None
	- Export: No
	- Notion property type: Formula
	- Description: link the HeadM items' ID with ', '
- **TailMID**
	- Purpose: Export only
	- Export: Yes
	- Notion property type: Formula
	- Description: link the TailM items' ID with ';'
- **DiseaseID**
	- Purpose: Export only
	- Export: Yes
	- Notion property type: Formula
	- Description: link the Disease items' ID with ';'

## Column Order (on export)
1. ID
2. Electrolyte
3. Category
4. Name
5. TailMID
6. DiseaseID
7. Order
8. Arrow
