//
//  String+Extension.swift
//  BookIt
//
//  Created by Alice’z Poy on 2023-03-24.
//

import Foundation

extension String {
    func masked(_ n: Int = 4, reversed: Bool = false) -> String {
        let mask = String(repeating: "•", count: Swift.max(0, count-n))
        return reversed ? mask + suffix(n) : prefix(n) + mask
    }
}
