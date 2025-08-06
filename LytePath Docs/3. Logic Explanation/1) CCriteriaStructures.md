# CCriteria Evaluation Logic

This document explains how `buildCStructures()` works using DFS traversal over CCriteria paths.

## Key Function
- `buildCStructures(data: LabData, rootCriteriaList, cCriteriaDict)`
- Uses DFS to find valid logic paths based on user's lab values
- Only terminal nodes with MeaningID are added to final path list

## Diagram
![[1) cStructures diagram.png]]
