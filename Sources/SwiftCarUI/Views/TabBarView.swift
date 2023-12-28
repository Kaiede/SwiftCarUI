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

public struct TabBar<Content>: CarView
where Content: CarView {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError() }
}

extension TabBar: CPTemplateRepresentable {
    func makeTemplate<T>(_ type: T.Type) throws -> T {
        if T.self == CPTabBarTemplate.self || T.self == CPTemplate.self {
            return try makeTabBarTemplate() as! T
        } else {
            throw SwiftCarUIError()
        }
    }

    private func makeTabBarTemplate() throws -> CPTabBarTemplate {
        let children = try content.makeCollection().map({
            try distillTemplate(CPTemplate.self, for: $0)
        })
        return CPTabBarTemplate(templates: children)
    }
}

#endif
