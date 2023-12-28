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

final class ImageButtonsTests: XCTestCase {
    func testImageButtonsRowHandler() throws {
        let rowExpectation = expectation(description: "Row expectation should be fired when handler is")
        let rowCompletionExpectation = expectation(description: "Row completion should be fired after action")

        let buttonsRow = ImageButtons(title: "Hello World", action: { item in
            switch item {
            case .row: rowExpectation.fulfill()
            case .item(_): XCTFail("Item handler should not be called here")
            }
        }) {
            Image(systemName: "cloud")
            Image(systemName: "figure.walk")
            Image(systemName: "house")
        }

        let template = try distillTemplate(CPListImageRowItem.self, for: buttonsRow)
        XCTAssertEqual(template.gridImages.count, 3)

        template.handler?(template, { rowCompletionExpectation.fulfill() })
        wait(for: [rowExpectation, rowCompletionExpectation], timeout: 0.01)
    }

    func testImageButtonsItemHandler() throws {
        let itemExpectation = expectation(description: "Item expectation should be fired when handler is")
        let itemCompletionExpectation = expectation(description: "Item completion should be fired after action")

        let buttonsRow = ImageButtons(title: "Hello World", action: { item in
            switch item {
            case .row: XCTFail("Row handler should not be called here")
            case .item(_): itemExpectation.fulfill()
            }
        }) {
            Image(systemName: "cloud")
            Image(systemName: "figure.walk")
            Image(systemName: "house")
        }

        let template = try distillTemplate(CPListImageRowItem.self, for: buttonsRow)
        XCTAssertEqual(template.gridImages.count, 3)

        template.listImageRowHandler?(template, 0, { itemCompletionExpectation.fulfill() })
        wait(for: [itemExpectation, itemCompletionExpectation], timeout: 0.01)
    }

    func testImageButtonsDestination() throws {
        let buttonsRow = ImageButtons(title: "Hello World", destination: { _ in NowPlaying() }) {
            Image(systemName: "cloud")
            Image(systemName: "figure.walk")
            Image(systemName: "house")
        }

        let pushExpectation = expectation(description: "Should push template when navigating")
        let completionExpectation = expectation(description: "Should call completion after navigating")

        let interfaceController = MockInterfaceController()
        interfaceController.pushTemplateExpectation = pushExpectation

        var environmentValues = EnvironmentValues()
        environmentValues.navigator = Navigator(controller: interfaceController)

        environmentValues.makeActive()
        let template = try distillTemplate(CPSelectableListItem.self, for: buttonsRow)
        environmentValues.resignActive()

        template.handler?(template, { completionExpectation.fulfill() })
        wait(for: [pushExpectation, completionExpectation], timeout: 0.1)
        XCTAssertEqual(interfaceController.pushedTemplates[0] is CPNowPlayingTemplate, true)
    }
}
