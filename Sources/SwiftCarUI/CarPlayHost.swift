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

#if canImport(UIKit) && canImport(CarPlay)

import CarPlay
import CoreData
import Foundation

public final class CarPlayHost {
    private var baseEnvironment: EnvironmentValues

    public init(
        scene: CarTemplateApplicationScene,
        controller: CarInterfaceController,
        managedObjectContext: NSManagedObjectContext? = nil,
        @ViewBuilder rootView: @escaping () -> some CarView
    ) async {
        self.baseEnvironment = EnvironmentValues(scene: scene)
        self.baseEnvironment.navigator = Navigator(controller: controller)
        self.baseEnvironment.makeActive()

        do {
            _ = try await self.baseEnvironment.navigator.setRoot(rootView(), animated: false)
        } catch {
            // TODO: runtime error here.
        }
    }

    deinit {
        self.baseEnvironment.resignActive()
    }
}

#endif
