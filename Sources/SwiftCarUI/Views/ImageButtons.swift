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

struct ImageButtons<Content>: CarView
where Content: CarView {
    enum PressedButton {
        case row
        case item(Int)
    }

    enum Action {
        case action((PressedButton) -> Void)
        case destination((PressedButton) -> any CarView)
    }

    @Environment(\.navigator) private var navigator

    private let title: String
    private let action: Action
    private let content: Content

    public init(title: String, action: @escaping (PressedButton) -> Void, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
        self.action = .action(action)
    }

    public init<Destination>(title: String, @ViewBuilder destination: @escaping (PressedButton) -> Destination, @ViewBuilder content: () -> Content)
    where Destination: CarView {
        self.title = title
        self.content = content()
        self.action = .destination(destination)
    }

    public var body: Never { fatalError() }
}

extension ImageButtons: CPTemplateRepresentable {
    func makeTemplate<T>(_ type: T.Type) throws -> T {
        if T.self == CPListImageRowItem.self || T.self == CPSelectableListItem.self || T.self == CPListTemplateItem.self {
            return try makeImageRowTemplate() as! T
        } else {
            throw SwiftCarUIError()
        }
    }

    private func makeImageRowTemplate() throws  -> CPListImageRowItem {
        // TODO: Needs handlers here...
        let labels = self.content.makeCollection().map({ distillLabelRepresentable(for: $0) }).compactMap(\.labelImage)
        let row = CPListImageRowItem(text: title, images: labels)
        row.handler = { [action, navigator] (_, completion) in
            Task {
                try await callAction(action, item: .row, navigator: navigator)
                completion()
            }
        }
        row.listImageRowHandler = { [action, navigator] (_, index, completion) in
            Task { 
                try await callAction(action, item: .item(index), navigator: navigator)
                completion()
            }
        }

        return row
    }

    private func callAction(_ action: Action, item: PressedButton, navigator: Navigator) async throws {
        switch action {
        case .action(let handler): handler(item)
        case .destination(let destination): let _ = try await navigator.navigateTo(destination(item), animated: true)
        }
    }
}

#endif
