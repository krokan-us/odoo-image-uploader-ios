//
//  String+Slugify.swift
//  Odoo-iOS
//
//  Created by Asım Altınışık on 7.06.2023.
//

import Foundation

extension String {
    func slugify() -> String {
        let turkishCharacters = "çğıöşüÇĞİÖŞÜ"
        let englishReplacements = "cgiosuCGIOSU"
        
        var converted = self.folding(options: .diacriticInsensitive, locale: Locale(identifier: "tr"))
        for (turkishCharacter, englishReplacement) in zip(turkishCharacters, englishReplacements) {
            converted = converted.replacingOccurrences(of: String(turkishCharacter), with: String(englishReplacement))
        }
        
        let withoutSpaces = converted.replacingOccurrences(of: "\\s+", with: "-", options: .regularExpression, range: nil)
        return withoutSpaces
    }
}
