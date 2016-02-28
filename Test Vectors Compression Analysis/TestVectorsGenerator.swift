//
//  TestVectorsGenerator.swift
//  Test Vectors Compression Analysis
//
//  Created by Yuriy Tolstoguzov on 2/20/16.
//  Copyright © 2016 Yuriy Tolstoguzov. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import GameplayKit


class TestVectorsGenerator {
    class func generateTestVectors(withLength length: Int, quantity: Int) -> [String] {
        var testVectors = Set<String>(minimumCapacity: quantity)

        while testVectors.count < quantity {
            let upperBound = Int(pow(Double(2), Double(length)))
            let diceRoll = GKLinearCongruentialRandomSource.sharedRandom().nextIntWithUpperBound(upperBound)
            var testVector = String(diceRoll, radix: 2)
            let testVectorLength = testVector.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
            if testVectorLength < length {
                let prefixLength = length - testVectorLength
                let prefixString = String(count: prefixLength, repeatedValue: Character("0"))
                testVector = prefixString.stringByAppendingString(testVector)
            }

            testVectors.insert(testVector)
        }

        return Array(testVectors)
    }
}