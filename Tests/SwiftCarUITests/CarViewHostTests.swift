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

final class CarViewHostTests: XCTestCase {
    func testBasicHostingEnvironment() async throws {
        let mockScene = MockTemplateScene()
        let mockController = MockInterfaceController()

        let setRootExpectation = expectation(description: "setRoot should be called")

        mockController.setRootExpectation = setRootExpectation

        var host: CarPlayHost? = nil
        XCTAssertEqual(EnvironmentValues.activeList.count, 1)

        // Initialize the Host
        host = await CarPlayHost(scene: mockScene, controller: mockController) {
            ComplexRootView()
        }

        // Once initialized, the host should push the root view for us...
        XCTAssertNotNil(mockController.currentRoot)
        XCTAssertEqual(EnvironmentValues.activeList.count, 2)

        await fulfillment(of: [setRootExpectation], timeout: 0.1)
        withExtendedLifetime(host) {}
        host = nil

        // After host is discarded, then we should have no active host environment anymore
        XCTAssertEqual(EnvironmentValues.activeList.count, 1)

        // At this point, there is still technically a root template...
        // However, that's Apple's problem.
    }

    struct ComplexRootView: CarView {
        var body: some CarView {
            TabBar {
                FirstTab()
                SecondTab()
                ThirdTab()
            }
        }
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
