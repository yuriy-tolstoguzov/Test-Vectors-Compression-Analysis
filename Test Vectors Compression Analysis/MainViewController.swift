//
//  MainViewController.swift
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

import Cocoa


class MainViewController: NSViewController, CompressionAnalyserDelegate {

    @IBOutlet weak var numberOfTestVectorsTextField: NSTextField!
    @IBOutlet weak var lenghtOfTestVectorsTextField: NSTextField!
    @IBOutlet weak var numberOfGenerationsTextField: NSTextField!
    @IBOutlet weak var progressLabel: NSTextField!
    @IBOutlet weak var analyseCompressionButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()


    }

    @IBAction func calculateCompression(sender: AnyObject) {
        self.analyseCompressionButton.enabled = false

        let compressionAnalyser = CompressionAnalyser(withNumberOfTestVectors: numberOfTestVectorsTextField.integerValue, lenghtOfTestVectors: lenghtOfTestVectorsTextField.integerValue, numberOfGenerations: numberOfGenerationsTextField.integerValue)
        compressionAnalyser.delegate = self
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            let result = compressionAnalyser.analysePossibleCompression()

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.analyseCompressionButton.enabled = true
                self.progressLabel.stringValue = "Done!"
                let alert = NSAlert()
                let percentCompression = (1 - result.averageCompression) * 100
                alert.messageText = "compression: \(percentCompression)%"
                alert.runModal()
            })
        }
    }


    // MARK: CompressionAnalyserDelegate

    func compressionAnalyserUpdatedProgress(currentProgress: Double) {
         dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let formattedProgress = String(format: "%.2f", currentProgress * 100)
            self.progressLabel.stringValue = "Current progress: \(formattedProgress)"
        }
    }
}

