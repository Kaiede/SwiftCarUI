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

struct ActionSheet<Label, Actions>: CarView
where Label: CarView, Actions: CarView {
    let label: Label
    let actions: Actions

    init(@ViewBuilder label: () -> Label, @ViewBuilder actions: () -> Actions) {
        self.label = label()
        self.actions = actions()
    }

    var body: Never { fatalError() }
}

extension ActionSheet: CPTemplateRepresentable {
    func makeTemplate<T>(_ type: T.Type) throws -> T {
        let label = distillLabelRepresentable(for: label)
        if T.self == CPTemplate.self || T.self == CPActionSheetTemplate.self {
            return try makeActionSheetTemplate(label) as! T
        } else {
            throw SwiftCarUIError()
        }
    }

    private func makeActionSheetTemplate(_ label: LabelRepresentable) throws -> CPActionSheetTemplate {
        let actions = try actions.makeCollection().map({ try distillTemplate(CPAlertAction.self, for: $0) })
        return CPActionSheetTemplate(title: label.labelTitle, message: nil, actions: actions)
    }
}

#endif
