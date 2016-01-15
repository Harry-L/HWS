//: Playground - noun: a place where people can play

import UIKit

var myInt = 0

extension Int {
    mutating func plusOne() {
        self++
    }
    
    static func random(min min: Int, max: Int) -> Int {
        return min
    }
}

extension String {
    mutating func trim() {
        self = stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}


myInt.plusOne()