//
//  Documentation.swift
//  AAE8
//
//  Created by 이지선 on 7/31/25.
//

//1. csv 파일에 관해
///  1) 새 파일을 import 했으면,
///     LabCriteria : DataImport.swift > class CCriteriaStore > func loadFile() 항수 내 파일명 바꾸기
///     Meaning : DataImport.swift > class MeaningStore > func loadFile() 내 파일명 바꾸기
///     Disease : DataImport.swift > class DiseaseStore > func  loadFile() 항수 내 파일명 바꾸기
///  2) Parameter 를 추가했으면 LabItem 항목에도 추가하기
///  3) column 순서 맞추기
///  4) Disease 간의 위계는 한 층이 최대이어야만 함
///  5) Meaning내 Head-Tail 관계는 반드시 1:다 관계(다:1 X), Head는 반드시 하나만 갖는다. 단방향 흐름. 트리의 정의를 만족.
