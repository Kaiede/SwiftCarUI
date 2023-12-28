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
import Foundation

fileprivate struct NavigatorKey: EnvironmentKey {
    static var defaultValue: Navigator = Navigator()
}

internal extension EnvironmentValues {
    var navigator: Navigator {
        get { self[NavigatorKey.self] }
        set { self[NavigatorKey.self] = newValue }
    }
}

internal protocol CarInterfaceController {
    func pushTemplate(_ templateToPush: CPTemplate, animated: Bool) async throws -> Bool
    func popTemplate(animated: Bool) async throws -> Bool
    func presentTemplate(_ templateToPresent: CPTemplate, animated: Bool) async throws -> Bool
    func setRootTemplate(_ rootTemplate: CPTemplate, animated: Bool) async throws -> Bool
}

extension CPInterfaceController: CarInterfaceController {}

internal struct Navigator {
    let controller: CarInterfaceController?

    internal init() {
        self.controller = nil
    }

    internal init(controller: CarInterfaceController) {
        self.controller = controller
    }

    public func setRoot<V>(_ view: V, animated: Bool) async throws -> Bool
    where V: CarView {
        guard let controller = controller else { return false }
        let template = try distillTemplate(CPTemplate.self, for: view)
        await template.willDisplayTemplate()
        return try await controller.setRootTemplate(template, animated: animated)
    }

    public func navigateTo<V>(_ view: V, animated: Bool) async throws -> Bool
    where V: CarView {
        guard let controller = controller else { return false }
        let template = try distillTemplate(CPTemplate.self, for: view)
        await template.willDisplayTemplate()
        return try await controller.pushTemplate(template, animated: animated)
    }

    public func navigateBack(animated: Bool) async throws -> Bool {
        guard let controller = controller else { return false }
        return try await controller.popTemplate(animated: animated)
    }

    public func present<V>(_ view: V, animated: Bool) async throws -> Bool 
    where V: CarView {
        guard let controller = controller else { return false }
        let template = try distillTemplate(CPTemplate.self, for: view)
        await template.willDisplayTemplate()
        return try await controller.presentTemplate(template, animated: animated)
    }

//    private func getDelegate() -> CarHostControllerDelegate {
//        guard let delegate = controller?.delegate as? CarHostControllerDelegate else {
//            fatalError("Must create scene using CarHost")
//        }
//
//        return delegate
//    }
}

#endif
