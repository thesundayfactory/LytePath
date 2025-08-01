//
//  LabData+Persistence.swift
//  AAE8
//
//  Created by 이지선 on 7/31/25.
//

import Foundation

extension LabData {
    static let storageKey = "SavedLabData"

    func save() {
        do {
            let data = try JSONEncoder().encode(self)
            UserDefaults.standard.set(data, forKey: LabData.storageKey)
        } catch {
            print("❌ Failed to encode LabData: \(error)")
        }
    }

    static func load() -> LabData? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return nil
        }
        do {
            let decoded = try JSONDecoder().decode(LabData.self, from: data)
            return decoded
        } catch {
            print("❌ Failed to decode LabData: \(error)")
            return nil
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
