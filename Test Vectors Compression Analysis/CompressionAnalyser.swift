//
//  CompressionAnalyser.swift
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


class CompressionAnalyserResult {
    let testVectors: [String]
    let compression: Double

    init(withTestVectors testVectors: [String], compression: Double) {
        self.testVectors = testVectors
        self.compression = compression
    }
}


protocol CompressionAnalyserDelegate {
    func compressionAnalyserUpdatedProgress(currentProgress: Double)
}


public class CompressionAnalyser {
    let numberOfTestVectors: Int
    let lenghtOfTestVectors: Int
    let numberOfGenerations: Int
    var delegate: CompressionAnalyserDelegate?

    private var currentGeneration = 0

    init(withNumberOfTestVectors numberOfTestVectors: Int, lenghtOfTestVectors: Int, numberOfGenerations: Int) {
        self.numberOfTestVectors = numberOfTestVectors
        self.lenghtOfTestVectors = lenghtOfTestVectors
        self.numberOfGenerations = numberOfGenerations
    }

    func analysePossibleCompression() -> (averageCompression: Double,  results: [CompressionAnalyserResult]) {
        updateDelegateWithTestVectorIndex(-1)

        var results = [CompressionAnalyserResult]()

        for index in 1...numberOfGenerations {
            currentGeneration = index

            let testVectors = TestVectorsGenerator.generateTestVectors(withLength: lenghtOfTestVectors, quantity: numberOfTestVectors)
            let analysisResult = analyseCompression(forTestVectors: testVectors);

            results.append(CompressionAnalyserResult(withTestVectors: testVectors, compression: analysisResult.0))
        }

        return (averageCompression(forResults: results), results)
    }

    func analyseCompression(forTestVectors testVectors: [String]) -> (Double, String) {
        let compressedInput = compressTestVectors(testVectors)

        let compression = Double(compressedInput.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)) / Double(testVectors.count * lenghtOfTestVectors)

        return (compression, compressedInput)
    }

    private func compressTestVectors(testVectors: [String]) -> String {
        guard testVectors.count >= 1 else {
            return ""
        }

        if testVectors.count == 1 {
            return testVectors.first!
        }

        var bestCompressedInput: String?

        for index in 0 ..< testVectors.count - 1 {
            for internalIndex in (index + 1) ..< testVectors.count {
                let testVector = testVectors[index]
                let anotherTestVector = testVectors[internalIndex]

                let resultTestVector = concatinateWithCompression(testVector, withTestVector: anotherTestVector)

                if resultTestVector.compressedLength == 0 && internalIndex < testVectors.count - 1 {
                    continue
                }

                var unusedTestVectors = testVectors
                unusedTestVectors.removeAtIndex(internalIndex)
                unusedTestVectors.removeAtIndex(index)
                unusedTestVectors.append(resultTestVector.result)

                let compressedInput = compressTestVectors(unusedTestVectors)
                if let challengedCompressedInput = bestCompressedInput {
                    if challengedCompressedInput.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > compressedInput.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) {
                        bestCompressedInput = compressedInput
                    }
                } else {
                    bestCompressedInput = compressedInput
                }
            }
            if testVectors.count == numberOfTestVectors {
                updateDelegateWithTestVectorIndex(index)
            }
        }

        return bestCompressedInput!
    }

    private func averageCompression(forResults results: [CompressionAnalyserResult]) -> Double {
        var compressionSum = 0.0
        for result in results {
            compressionSum += result.compression
        }

        return compressionSum / Double(results.count)
    }

    private func concatinateWithCompression(testVector: String, withTestVector anotherTestVector: String) -> (result: String, compressedLength: Int) {
        let numberOfOverlappingBitsOneDirection = countNumberOfOverlappingBits(forTestVector: testVector, withTestVector: anotherTestVector)
        let numberOfOverlappingBitsAnotherDirection = countNumberOfOverlappingBits(forTestVector: anotherTestVector, withTestVector: testVector)

        let compoundTestVector: String
        let compressedLength: Int
        if numberOfOverlappingBitsOneDirection > numberOfOverlappingBitsAnotherDirection {
            compoundTestVector = makeCompoundTestVector(fromTestVector: testVector, andTestVector: anotherTestVector, withOverlapping: numberOfOverlappingBitsOneDirection)
            compressedLength = numberOfOverlappingBitsOneDirection
        }
        else {
            compoundTestVector = makeCompoundTestVector(fromTestVector: anotherTestVector, andTestVector: testVector, withOverlapping: numberOfOverlappingBitsOneDirection)
            compressedLength = numberOfOverlappingBitsAnotherDirection
        }

        return (compoundTestVector, compressedLength)
    }

    private func countNumberOfOverlappingBits(forTestVector testVector: String, withTestVector anotherTestVector:String) -> Int {
        var index = 0
        var charactar: String.CharacterView.Index
        var anotherCharacter: String.CharacterView.Index
        let testVectorLength = testVector.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        repeat {
            charactar = testVector.startIndex.advancedBy((testVectorLength - 1) - index)
            anotherCharacter = anotherTestVector.startIndex.advancedBy(index)
            index += 1

        } while testVector[charactar] == anotherTestVector[anotherCharacter] && index < lenghtOfTestVectors

        return index - 1
    }

    private func makeCompoundTestVector(fromTestVector testVector: String, andTestVector anotherTestVector: String, withOverlapping overlappingLength: Int) -> String {
        let index = anotherTestVector.startIndex.advancedBy(overlappingLength)
        let difference = anotherTestVector.substringFromIndex(index)
        return testVector.stringByAppendingString(difference)
    }

    private func updateDelegateWithTestVectorIndex(index: Int) {
        let allNumberOfIterations = lenghtOfTestVectors * numberOfGenerations
        let currentNumberOfIterations = (index + 1) + (currentGeneration - 1) * (numberOfTestVectors - 1)
        if let delegate = delegate {
            delegate.compressionAnalyserUpdatedProgress(Double(currentNumberOfIterations) / Double(allNumberOfIterations))
        }
    }
}
