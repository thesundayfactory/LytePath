# LabCriteria CSV

**Original Notion Database:** https://www.notion.so/LytePath_Database-22cd4a211bd680abbd49d6d49af0b9fc?source=copy_link

This CSV file was originally exported from a **Notion database**.  
Each row corresponds to the `CCriteria` struct used in logic interpretation.
(cf) CCriteria means a Complex of criteria.)

## Source Format
- **Original platform**: Notion database  
- **Export format**: CSV  
## Columns
- **ID**
	- Purpose:  Export only
	- Export: Yes
	- Notion property type: ID
	- Description: Unique number for identification
- **Electrolyte**
	- Purpose: Both
	- Export: Yes
	- Notion property type: Selection
	- Description: Matches the `Electrolyte` enum.
- **Order**
	- Purpose: Both
	- Export: Yes
	- Notion property type: Number
	- Description:
		- Int
		- Unique number in each Electrolyte type
		- Written for logical orders in the Notion database
		- Exported for sorting in the views
- **Name**
	- Purpose: Writing only
	- Export: No
	- Notion property type: Title
	- Description: Meaning of the contents. For internal reference.
- **Criteria**
	- Purpose: Writing only
	- Export: No
	- Notion property type: Text
	- Description: Written words of the contents. For internal reference.
- **parameter**
	- Purpose: Both
	- Export: Yes
	- Notion property type: Selection
	- Description: 
		- Matches the raw value of the `LabItem` enum.
		- Options of the parameter should match the cases of the `LabItem` enum.
- **threshold**
	- Purpose: Both
	- Export: Yes
	- Notion property type: Number
	- Description: 
		- Double
		- Be careful with the unit (which must match the `unit` of the `LabItem` enum).
		- Selectable fields(e.g., VolumeStatus, AcuteChronic) use `numeric values`
- **direction**
	- Purpose: Both
	- Export: Yes
	- Notion property type: Selection
	- Description:
		- Options are "High" or "Low"
		- "High" includes the threshold(≧); "Low" does not(<).
- **Point**
	- Purpose: Both
	- Export: Yes
	- Notion property type: Number
	- Description: Created for weighted disease matching, but no longer used
- **Head**
	- Purpose: Writing only
	- Export: No
	- Notion property type: Relation (Related to this database)
	- Description: 
		- Directly connected head item
		- Two-way relation with the Tail property of this database
- **Tail**
	- Purpose: Writing only
	- Export: No
	- Notion property type: Relation (Related to this database)
	- Description: 
		- Directly connected tail item
		- Two-way relation with the Head property of this database
- **Meaning**
	- Purpose: Writing only
	- Export: No
	- Notion property type: Relation (Related to the Meaning table)
	- Description: 
		- Connected to the meaning of the item.
		- Two-way relation with the CCriteria property of the Meaning table
		- Only the last item is linked to a Meaning when multiple items are required together
- **HeadID**
	- Purpose: Export only
	- Export: No
	- Notion property type: Formula
	- Description: link the head items' ID with ';'
- **TailID**
	- Purpose: Export only
	- Export: Yes
	- Notion property type: Formula
	- Description: link the Tail items' ID with ';'
- **MeaningID**
	- Purpose: Export only
	- Export: Yes
	- Notion property type: Formula
	- Description: link the Meaning items' ID with ';'

## Column Order (on export)
Columns must appear in the following order for proper parsing:
1. ID
2. Electrolyte
3. parameter
4. threshold
5. direction
6. TailID
7. MeaningID
8. Order
9. Point


