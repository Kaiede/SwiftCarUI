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

final class ButtonTests: XCTestCase {
    func testProduceInvalid() throws {
        let button = Button(action: { }, label: { Text("Hello") })
        do {
            _ = try button.makeTemplate(CPTemplate.self)
            XCTFail("Invalid template should fail")
        } catch is SwiftCarUIError {
        } catch {
            XCTFail("Unexpected error thrown")
        }
    }

    func testProduceAlertAction() throws {
        let actionExpect = expectation(description: "Action should be fired")
        let button = Button(action: { actionExpect.fulfill() }, label: { Text("Hello") })

        let template = try button.makeTemplate(CPAlertAction.self)
        template.handler(template)

        XCTAssertEqual(template.title, "Hello")
        wait(for: [actionExpect], timeout: 0.1)
    }

    func testProduceTextButton() throws {
        // Unfortunately, CPTextButton doesn't let us access the handler.
        let button = Button(action: { }, title: "Hello")

        let template = try button.makeTemplate(CPTextButton.self)

        XCTAssertEqual(template.title, "Hello")
        XCTAssertEqual(template.textStyle, .normal)
    }

    func testProduceListItem() throws {
        let actionExpectation = expectation(description: "Action should be fired")
        let button = Button(action: { actionExpectation.fulfill() }, label: { Text("Hello") })

        let template = try button.makeTemplate(CPListTemplateItem.self)

        XCTAssertEqual(template.text, "Hello")
        if let item = template as? CPListItem {
            XCTAssertEqual(item.detailText, nil)

            let completionExpectation = expectation(description: "Completion should be called")
            item.handler?(item, { completionExpectation.fulfill() } )

            wait(for: [actionExpectation, completionExpectation], timeout: 0.1)
        } else {
            XCTFail("makeTemplate should be returning a CPListItem")
        }
    }

    func testProduceGridItem() throws {
        // Can't access the handler for CPGridButton
        let button = Button(action: { }, label: { Label(text: "Hello", systemName: "cloud") })

        let template = try button.makeTemplate(CPGridButton.self)
        XCTAssertEqual(template.titleVariants, ["Hello"])
        XCTAssertEqual(template.image.isSymbolImage, true)
    }

    func testDestination() throws {
        let button = Button(destination: { DestinationView() }, title: "Hello")

        let pushExpectation = expectation(description: "Should push template when navigating")
        let completionExpectation = expectation(description: "Should call completion after navigating")

        let interfaceController = MockInterfaceController()
        interfaceController.pushTemplateExpectation = pushExpectation

        var environmentValues = EnvironmentValues()
        environmentValues.navigator = Navigator(controller: interfaceController)

        environmentValues.makeActive()
        let template = try button.makeTemplate(CPListItem.self)
        environmentValues.resignActive()
        
        XCTAssertEqual(template.text, "Hello")

        template.handler?(template, { completionExpectation.fulfill() })

        wait(for: [pushExpectation, completionExpectation], timeout: 0.1)

        XCTAssertEqual(interfaceController.pushedTemplates[0] is CPListTemplate, true)
    }

    func testNowPlayingDestination() throws {
        let button = Button(destination: { NowPlaying() }, title: "Hello")

        let pushExpectation = expectation(description: "Should push template when navigating")
        let completionExpectation = expectation(description: "Should call completion after navigating")

        let interfaceController = MockInterfaceController()
        interfaceController.pushTemplateExpectation = pushExpectation

        var environmentValues = EnvironmentValues()
        environmentValues.navigator = Navigator(controller: interfaceController)

        environmentValues.makeActive()
        let template = try button.makeTemplate(CPListItem.self)
        environmentValues.resignActive()

        XCTAssertEqual(template.text, "Hello")

        template.handler?(template, { completionExpectation.fulfill() })

        wait(for: [pushExpectation, completionExpectation], timeout: 0.1)

        XCTAssertEqual(interfaceController.pushedTemplates[0] is CPNowPlayingTemplate, true)
    }

    struct DestinationView: CarView {
        var body: some CarView {
            List {
                Button(action: {}, title: "First Item")
                Button(action: {}, title: "Second Item")
            }
        }
    }
}

