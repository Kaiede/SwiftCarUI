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

final class TabBarTests: XCTestCase {
    func testEmptyTabBar() throws {
        let tabBar = TabBar {}

        let _ = try distillTemplate(CPTemplate.self, for: tabBar)
        let template = try distillTemplate(CPTabBarTemplate.self, for: tabBar)
        XCTAssertEqual(template.templates.count, 0)
    }

    func testSimpleTabBar() throws {
        let tabBar = TabBar {
            List {}
            List {}
            List {}
        }

        let _ = try distillTemplate(CPTemplate.self, for: tabBar)
        let template = try distillTemplate(CPTabBarTemplate.self, for: tabBar)
        XCTAssertEqual(template.templates.count, 3)
    }

    func testComplexTabBar() throws {
        let tabBar = TabBar {
            FirstTab()
            SecondTab()
            List {}
        }

        let _ = try distillTemplate(CPTemplate.self, for: tabBar)
        let template = try distillTemplate(CPTabBarTemplate.self, for: tabBar)
        XCTAssertEqual(template.templates.count, 3)
    }

    func testTabDetails() throws {
        let tabBar = TabBar {
            FirstTab()
                .tabDetails(title: "Library", systemName: "books.vertical")

            SecondTab()
                .tabDetails(title: "Playlists", image: UIImage(systemName: "music.note.list")!)

            ThirdTab()
                .tabDetails(systemItem: .favorites)
        }

        let _ = try distillTemplate(CPTemplate.self, for: tabBar)

        let environmentValues = EnvironmentValues()
        environmentValues.makeActive()
        let template = try distillTemplate(CPTabBarTemplate.self, for: tabBar)
        environmentValues.resignActive()

        XCTAssertEqual(template.templates.count, 3)
        XCTAssertEqual(template.templates[0].tabTitle, "Library")
        XCTAssertEqual(template.templates[0].tabImage?.isSymbolImage, true)
        XCTAssertEqual(template.templates[1].tabTitle, "Playlists")
        XCTAssertEqual(template.templates[1].tabImage?.isSymbolImage, true)
        XCTAssertEqual(template.templates[2].tabSystemItem, .favorites)
        XCTAssertEqual(template.templates[2].tabTitle, nil)
        XCTAssertEqual(template.templates[2].tabImage, nil)
    }

    struct FirstTab: CarView {
        var body: some CarView {
            List {
                Button(action: {}, label: { Text("FirstItem") })
                Button(action: {}, label: { Text("SecondItem") })
            }
        }
    }

    struct SecondTab: CarView {
        var body: some CarView {
            List {
                Button(action: {}, label: { Text("FirstItem") })
                Button(action: {}, label: { Text("SecondItem") })
            }
        }
    }

    struct ThirdTab: CarView {
        var body: some CarView {
            List {
                Button(action: {}, label: { Text("FirstItem") })
                Button(action: {}, label: { Text("SecondItem") })
            }
        }
    }
}
