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

struct List<Content>: CarView
where Content: CarView {
    let title: String?
    let content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: Never { fatalError() }
}

struct Section<Content>: CarView 
where Content: CarView {
    let title: String?
    let content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: Never { fatalError() }
}

extension List: CPTemplateRepresentable {
    func makeTemplate<T>(_ type: T.Type) throws -> T {
        if T.self == CPListTemplate.self || T.self == CPTemplate.self {
            return try makeListTemplate() as! T
        } else {
            throw SwiftCarUIError()
        }
    }

    private func makeListTemplate() throws -> CPListTemplate {
        let children = try makeChildren()
        let template = CPListTemplate(title: title, sections: children)
        return template
    }

    private func makeChildren() throws -> [CPListSection] {
        var result: [CPListSection] = []
        var implicitSection: [CPListTemplateItem] = []
        let children = content.makeCollection()

        for child in children {
            if let section = try? distillTemplate(CPListSection.self, for: child) {
                if implicitSection.count > 0 {
                    result.append(CPListSection(items: implicitSection))
                    implicitSection = []
                }
                
                result.append(section)
            } else if let item = try? distillTemplate(CPListTemplateItem.self, for: child) {
                implicitSection.append(item)
            } else {
                throw SwiftCarUIError()
            }
        }

        if implicitSection.count > 0 {
            result.append(CPListSection(items: implicitSection))
        }

        return result
    }
}

extension Section: CPTemplateRepresentable {
    func makeTemplate<T>(_ type: T.Type) throws -> T {
        if T.self == CPListSection.self {
            return try makeSectionTemplate() as! T
        } else {
            throw SwiftCarUIError()
        }
    }

    private func makeSectionTemplate() throws -> CPListSection {
        let children = try content.makeCollection().map({ try distillTemplate(CPListTemplateItem.self, for: $0) })
        return CPListSection(items: children, header: title, sectionIndexTitle: nil)
    }
}

#endif
