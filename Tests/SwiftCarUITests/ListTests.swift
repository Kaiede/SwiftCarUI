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
import Combine
import XCTest
@testable import SwiftCarUI

final class ListTests: XCTestCase {
    func testEmptyList() throws {
        let list = List {}

        let _ = try distillTemplate(CPTemplate.self, for: list)
        let template = try distillTemplate(CPListTemplate.self, for: list)
        XCTAssertEqual(template.title, nil)
        XCTAssertEqual(template.sectionCount, 0)
    }

    func testListWithSingleSection() throws {
        let list = List {
            Section {
                Button(action: {}, label: { Text("First Item") })
                Button(action: {}, label: { Text("Second Item") })
            }
        }

        let _ = try distillTemplate(CPTemplate.self, for: list)
        let template = try distillTemplate(CPListTemplate.self, for: list)
        XCTAssertEqual(template.title, nil)
        XCTAssertEqual(template.sectionCount, 1)
    }

    func testListWithSingleImplicitSection() throws {
        let list = List {
            Button(action: {}, label: { Text("First Item") })
            Button(action: {}, label: { Text("Second Item") })
        }

        let _ = try distillTemplate(CPTemplate.self, for: list)
        let template = try distillTemplate(CPListTemplate.self, for: list)
        XCTAssertEqual(template.title, nil)
        XCTAssertEqual(template.sectionCount, 1)
    }

    func testListWithMultipleSections() throws {
        let list = List {
            Section {
                Button(action: {}, label: { Text("First Item") })
                Button(action: {}, label: { Text("Second Item") })
            }
            Section {
                Button(action: {}, label: { Text("First Item") })
                Button(action: {}, label: { Text("Second Item") })
            }
        }

        let _ = try distillTemplate(CPTemplate.self, for: list)
        let template = try distillTemplate(CPListTemplate.self, for: list)
        XCTAssertEqual(template.title, nil)
        XCTAssertEqual(template.sectionCount, 2)
    }

    func testListWithMultipleSectionsAndImplicitTrailingItems() throws {
        let list = List {
            Section {
                Button(action: {}, label: { Text("First Item") })
                Button(action: {}, label: { Text("Second Item") })
            }

            Button(action: {}, label: { Text("First Item") })
            Button(action: {}, label: { Text("Second Item") })
        }

        let _ = try distillTemplate(CPTemplate.self, for: list)
        let template = try distillTemplate(CPListTemplate.self, for: list)
        XCTAssertEqual(template.title, nil)
        XCTAssertEqual(template.sectionCount, 2)
    }

    func testListWithImplicitAndExplicitSections() throws {
        let list = List {
            Button(action: {}, title: "First Section, First Item")

            Section {
                Button(action: {}, label: { Text("First Item") })
                Button(action: {}, label: { Text("Second Item") })
            }

            Button(action: {}, title: "Third Section, First Item")
        }

        let _ = try distillTemplate(CPTemplate.self, for: list)
        let template = try distillTemplate(CPListTemplate.self, for: list)
        XCTAssertEqual(template.title, nil)
        XCTAssertEqual(template.sectionCount, 3)
        XCTAssertEqual(template.sections[0].items.count, 1)
        XCTAssertEqual(template.sections[1].items.count, 2)
        XCTAssertEqual(template.sections[2].items.count, 1)
    }

    func testListWithLeadingImplicitSections() throws {
        let list = List {
            Button(action: {}, title: "First Section, First Item")
            Button(action: {}, title: "First Section, First Item")

            SecondSection()
        }

        let _ = try distillTemplate(CPTemplate.self, for: list)
        let template = try distillTemplate(CPListTemplate.self, for: list)
        XCTAssertEqual(template.title, nil)
        XCTAssertEqual(template.sectionCount, 2)
        XCTAssertEqual(template.sections[0].items.count, 2)
        XCTAssertEqual(template.sections[1].items.count, 3)
    }

    func testComplexList() throws {
        let list = List {
            FirstSection()
            SecondSection()
        }

        let _ = try distillTemplate(CPTemplate.self, for: list)
        let template = try distillTemplate(CPListTemplate.self, for: list)
        XCTAssertEqual(template.title, nil)
        XCTAssertEqual(template.sectionCount, 2)
        XCTAssertEqual(template.sections[0].items.count, 2)
        XCTAssertEqual(template.sections[1].items.count, 3)
    }

    func testEmptySection() throws {
        let section = Section {}

        let template = try distillTemplate(CPListSection.self, for: section)
        XCTAssertEqual(template.header, nil)
        XCTAssertEqual(template.items.count, 0)
    }

    func testSectionWithSingle() throws {
        let section = Section {
            Button(action: {}, label: { Text("First Item") })
        }

        let template = try distillTemplate(CPListSection.self, for: section)
        XCTAssertEqual(template.header, nil)
        XCTAssertEqual(template.items.count, 1)
    }

    func testSectionWithMultiple() throws {
        let section = Section(title: "Disc 1") {
            Button(action: {}, label: { Text("First Item") })
            Button(action: {}, label: { Text("Second Item") })
        }

        let template = try distillTemplate(CPListSection.self, for: section)
        XCTAssertEqual(template.header, "Disc 1")
        //XCTAssertEqual(template.headerSubtitle, nil)
        XCTAssertEqual(template.items.count, 2)
        XCTAssertEqual(template.items[0].text, "First Item")
        XCTAssertEqual(template.items[1].text, "Second Item")
    }

    func testListItemUpdating() throws {
        let titlePublisher = PassthroughSubject<String,Never>()
        let detailPublisher = PassthroughSubject<String?,Never>()
        let imagePublisher = PassthroughSubject<UIImage?,Never>()
        let accessoryImagePublisher = PassthroughSubject<UIImage?,Never>()
        let accessoryPublisher = PassthroughSubject<Bool,Never>()
        let listItem = Button(action: {}, title: "Hello World")
            .updateListItem(on: titlePublisher, perform: { (element, listItem) in
                listItem.setText(element)
            })
            .updateListItem(on: detailPublisher, perform: { (element, listItem) in
                listItem.setDetailText(element)
            })
            .updateListItem(on: imagePublisher, perform: { (element, listItem) in
                listItem.setImage(element)
            })
            .updateListItem(on: accessoryPublisher, perform: { (element, listItem) in
                listItem.setAccessoryType(element ? .cloud : .none)
            })
            .updateListItem(on: accessoryImagePublisher, perform: { (element, listItem) in
                listItem.setAccessoryImage(element)
            })

        let template = try distillTemplate(CPListItem.self, for: listItem)
        XCTAssertEqual(template.text, "Hello World")
        XCTAssertEqual(template.detailText, nil)
        XCTAssertEqual(template.accessoryType, .none)
        XCTAssertEqual(template.image, nil)
        XCTAssertEqual(template.accessoryImage, nil)

        titlePublisher.send("Good Morning Sun")
        XCTAssertEqual(template.text, "Good Morning Sun")
        XCTAssertEqual(template.detailText, nil)
        XCTAssertEqual(template.accessoryType, .none)
        XCTAssertEqual(template.image, nil)
        XCTAssertEqual(template.accessoryImage, nil)

        accessoryPublisher.send(true)
        XCTAssertEqual(template.text, "Good Morning Sun")
        XCTAssertEqual(template.detailText, nil)
        XCTAssertEqual(template.accessoryType, .cloud)
        XCTAssertEqual(template.image, nil)
        XCTAssertEqual(template.accessoryImage, nil)

        detailPublisher.send("Some Artist Here")
        XCTAssertEqual(template.text, "Good Morning Sun")
        XCTAssertEqual(template.detailText, "Some Artist Here")
        XCTAssertEqual(template.accessoryType, .cloud)
        XCTAssertEqual(template.image, nil)
        XCTAssertEqual(template.accessoryImage, nil)

        let image = UIImage(systemName: "cloud")!
        imagePublisher.send(image)
        XCTAssertEqual(template.text, "Good Morning Sun")
        XCTAssertEqual(template.detailText, "Some Artist Here")
        XCTAssertEqual(template.accessoryType, .cloud)
        XCTAssertEqual(template.image?.isSymbolImage, true)
        XCTAssertEqual(template.accessoryImage, nil)

        let accessoryImage = UIImage(systemName: "cloud")!
        accessoryImagePublisher.send(accessoryImage)
        XCTAssertEqual(template.text, "Good Morning Sun")
        XCTAssertEqual(template.detailText, "Some Artist Here")
        XCTAssertEqual(template.accessoryType, .none) // This gets reset when accessory image is set
        XCTAssertEqual(template.image?.isSymbolImage, true)
        XCTAssertEqual(template.accessoryImage?.isSymbolImage, true)
    }

    func testListItemTask() async throws {
        let expectation = expectation(description: "Should call into the task when about to display...")
        let listItem = Button(action: {}, title: "Hello World")
            .listItemTask(perform: { listItem in
                do {
                    try await Task.sleep(for: .milliseconds(10))
                    listItem.setDetailText("Finished Loading")
                    expectation.fulfill()
                } catch {
                    XCTFail("Exception thrown during sleep")
                }
            })

        let template = try distillTemplate(CPListItem.self, for: listItem)
        try await Task.sleep(for: .milliseconds(20))
        XCTAssertEqual(template.detailText, nil)
        
        /// We should only get the task fired after we call willDisplayTemplate
        template.willDisplayTemplate()
        XCTAssertEqual(template.detailText, nil)

        await fulfillment(of: [expectation], timeout: 0.02)
        XCTAssertEqual(template.detailText, "Finished Loading")
    }

    func testListItemTaskEmbedded() async throws {
        let expectation = expectation(description: "Should call into the task when about to display...")
        let list = List {
            Button(action: {}, title: "Hello World")
                .listItemTask(perform: { listItem in
                    do {
                        try await Task.sleep(for: .milliseconds(10))
                        listItem.setDetailText("Finished Loading")
                        expectation.fulfill()
                    } catch {
                        XCTFail("Exception thrown during sleep")
                    }
                })
        }

        let template = try distillTemplate(CPListTemplate.self, for: list)
        guard let firstItem = template.sections[0].items[0] as? CPListItem else {
            XCTFail("List Item is Missing")
            return
        }

        try await Task.sleep(for: .milliseconds(20))
        XCTAssertEqual(firstItem.detailText, nil)

        /// We should only get the task fired after we call willDisplayTemplate
        template.willDisplayTemplate()
        XCTAssertEqual(firstItem.detailText, nil)

        await fulfillment(of: [expectation], timeout: 0.02)
        XCTAssertEqual(firstItem.detailText, "Finished Loading")
    }

    struct FirstSection: CarView {
        var body: some CarView {
            Section {
                Button(action: {}, title: "First Item")
                Button(action: {}, title: "Second Item")
            }
        }
    }

    struct SecondSection: CarView {
        var body: some CarView {
            Section {
                Button(action: {}, title: "First Item")
                Button(action: {}, title: "Second Item")
                Button(action: {}, title: "Third Item")
            }
        }
    }
}
