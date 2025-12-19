//
//  GiftCard.swift
//  GiftcardTracker
//
//  Created by Sebastian Ingebrigtsen on 19/12/2025.
//

import Foundation
import SwiftData

@Model
final class GiftCard {
    var uuid: UUID
    var storeName: String
    var amount: Double
    var expiryDate: Date

    init(storeName: String, amount: Double, expiryDate: Date) {
        self.uuid = UUID()
        self.storeName = storeName
        self.amount = amount
        self.expiryDate = expiryDate
    }
}
