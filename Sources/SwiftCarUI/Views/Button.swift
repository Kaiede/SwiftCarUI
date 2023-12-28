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

public struct Button<Label>: CarView where Label: CarView  {
    private let action: Action
    private let label: Label

    @Environment(\.navigator) private var navigator

    public init(action: @escaping () -> Void, label: () -> Label) {
        self.action = .action(action)
        self.label = label()
    }

    public init<Destination>(@ViewBuilder destination: () -> Destination, label: () -> Label)
    where Destination: CarView {
        self.action = .destination(destination())
        self.label = label()
    }

    public var body: Never { fatalError() }

    enum Action {
        case action(() -> Void)
        case destination(any CarView)
    }
}

public extension Button where Label == Text {
    init(action: @escaping () -> Void, title: String) {
        self.action = .action(action)
        self.label = Text(title)
    }

    init<Destination>(@ViewBuilder destination: () -> Destination, title: String)
    where Destination: CarView {
        self.action = .destination(destination())
        self.label = Text(title)
    }
}

public extension Button where Label == Image {
    init(action: @escaping () -> Void, image: Image) {
        self.action = .action(action)
        self.label = image
    }

    init(action: @escaping () -> Void, systemName: String) {
        self.action = .action(action)
        self.label = Image(systemName: systemName)
    }


    init(action: @escaping () -> Void, nowPlaying: Image.NowPlayingImage) {
        self.action = .action(action)
        self.label = Image(nowPlaying: nowPlaying)
    }
}

extension Button: CPTemplateRepresentable {
    func makeTemplate<T>(_ type: T.Type) throws -> T {
        let label = distillLabelRepresentable(for: label)
        if T.self == CPAlertAction.self {
            return makeAlertAction(label) as! T
        } else if T.self == CPTextButton.self {
            return makeTextButton(label) as! T
        } else if T.self == CPListItem.self || T.self == CPListTemplateItem.self  {
            return makeListItem(label) as! T
        } else if T.self == CPGridButton.self {
            return makeGridButton(label) as! T
        } else if T.self == CPNowPlayingButton.self {
            return makeNowPlayingButton(label) as! T
        } else {
            throw SwiftCarUIError()
        }
    }

    private func makeAlertAction(_ label: LabelRepresentable) -> CPAlertAction {
        CPAlertAction(title: label.labelTitle, style: .default, handler: { [action, navigator] _ in
            Task { try await callAction(action, navigator: navigator) }
        })
    }

    private func makeTextButton(_ label: LabelRepresentable) -> CPTextButton {
        CPTextButton(title: label.labelTitle, textStyle: .normal, handler: { [action, navigator] _ in
            Task { try await callAction(action, navigator: navigator) }
        })
    }

    private func makeListItem(_ label: LabelRepresentable) -> CPListItem {
        let item = CPListItem(text: label.labelTitle, detailText: nil, image: label.labelImage)
        item.handler = { [action, navigator] (_, completion) in
            Task {
                try await callAction(action, navigator: navigator)
                completion()
            }
        }
        return item
    }

    private func makeGridButton(_ label: LabelRepresentable) -> CPGridButton {
        CPGridButton(titleVariants: [label.labelTitle], image: label.labelImage ?? UIImage(), handler: { [action, navigator] _ in
            Task { try await callAction(action, navigator: navigator) }
        })
    }

    private func makeNowPlayingButton(_ label: LabelRepresentable) -> CPNowPlayingButton {
        let handler: ((CPNowPlayingButton) -> Void) = { [action, navigator] _ in
            Task { try await callAction(action, navigator: navigator) }
        }

        // Allow builtins
        if let builtin = label.labelImageBuiltin {
            switch builtin {
            case .addToLibrary: return CPNowPlayingAddToLibraryButton(handler: handler)
            case .more: return CPNowPlayingMoreButton(handler: handler)
            case .playbackRate: return CPNowPlayingPlaybackRateButton(handler: handler)
            case .repeat: return CPNowPlayingRepeatButton(handler: handler)
            case .shuffle: return CPNowPlayingShuffleButton(handler: handler)
            }
        } else if let image = label.labelImage {
            return CPNowPlayingImageButton(image: image, handler: handler)
        } else {
            // If the label has no image, resort to simply using the more button as a fallback
            return CPNowPlayingMoreButton(handler: handler)
        }
    }

    private func callAction(_ action: Action, navigator: Navigator) async throws {
        switch action {
        case .action(let handler): handler()
        case .destination(let destination): let _ = try await navigator.navigateTo(destination, animated: true)
        }
    }
}

#endif
