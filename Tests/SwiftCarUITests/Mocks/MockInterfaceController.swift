/*
SwiftCarUI

Copyright (c) 2023 Adam Thayer
Licensed under the MIT license, as follows:

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.)
*/

import CarPlay
import XCTest
@testable import SwiftCarUI

class MockInterfaceController: CarInterfaceController {
    var setRootExpectation: XCTestExpectation?
    var pushTemplateExpectation: XCTestExpectation?
    var popTemplateExpectation: XCTestExpectation?
    var presentTemplateExpectation: XCTestExpectation?

    var currentRoot: CPTemplate? = nil
    var pushedTemplates: [CPTemplate] = []
    var presentedTemplates: [CPTemplate] = []

    func setRootTemplate(_ rootTemplate: CPTemplate, animated: Bool) async throws -> Bool {
        currentRoot = rootTemplate
        if let expectation = setRootExpectation {
            expectation.fulfill()
            return true
        }

        XCTFail("No expectation for setRoot")
        return false
    }

    func pushTemplate(_ templateToPush: CPTemplate, animated: Bool) async throws -> Bool {
        pushedTemplates.append(templateToPush)
        if let expectation = pushTemplateExpectation {
            expectation.fulfill()
            return true
        }

        XCTFail("No expectation for popTemplate")
        return false
    }
    
    func popTemplate(animated: Bool) async throws -> Bool {
        if let expectation = popTemplateExpectation {
            expectation.fulfill()
            return true
        }

        XCTFail("No expectation for popTemplate")
        return false
    }

    func presentTemplate(_ templateToPresent: CPTemplate, animated: Bool) async throws -> Bool {
        presentedTemplates.append(templateToPresent)
        if let expectation = presentTemplateExpectation {
            expectation.fulfill()
            return true
        }

        XCTFail("No expectation for presentTemplate")
        return false
    }
}
