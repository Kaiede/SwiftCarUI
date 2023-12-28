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

struct NowPlayingButtonModifier<Content>: TemplateModifier
where Content: CarView {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func mutate(template: CPNowPlayingTemplate) throws {
        let buttons = try content.makeCollection().map({ try distillTemplate(CPNowPlayingButton.self, for: $0) })
        template.updateNowPlayingButtons(buttons)
    }
}

struct NowPlayingUpNextModifier: TemplateModifier {
    private let title: String?
    private let handler: () -> Void

    init(title: String? = nil, handler: @escaping () -> Void) {
        self.title = title
        self.handler = handler
    }

    func mutate(template: CPNowPlayingTemplate) throws {
        template.isUpNextButtonEnabled = true
        if let title = title {
            template.upNextTitle = title
        }
        template.templateObserver.upNextHandler = handler
    }
}

struct NowPlayingAlbumArtistModifier: TemplateModifier {
    private let handler: () -> Void

    init(handler: @escaping () -> Void) {
        self.handler = handler
    }

    func mutate(template: CPNowPlayingTemplate) throws {
        template.isAlbumArtistButtonEnabled = true
        template.templateObserver.albumArtistHandler = handler
    }
}

final class NowPlayingObserver: NSObject, CPNowPlayingTemplateObserver, DefaultInitializable {
    var upNextHandler: (() -> Void)?
    var albumArtistHandler: (() -> Void)?

    deinit {
        CPNowPlayingTemplate.shared.remove(self)
    }

    func nowPlayingTemplateUpNextButtonTapped(_ nowPlayingTemplate: CPNowPlayingTemplate) {
        upNextHandler?()
    }

    func nowPlayingTemplateAlbumArtistButtonTapped(_ nowPlayingTemplate: CPNowPlayingTemplate) {
        albumArtistHandler?()
    }
}

extension CarView {
    func nowPlayingButtons<Content>(@ViewBuilder content: () -> Content) -> some CarView
    where Content: CarView {
        ModifiedCarView(
            content: self,
            modifier: NowPlayingButtonModifier(content: content)
        )
    }

    func upNextButton(action: @escaping () -> Void, title: String? = nil) -> some CarView {
        ModifiedCarView(
            content: self,
            modifier: NowPlayingUpNextModifier(title: title, handler: action)
        )
    }

    func albumArtistButton(action: @escaping () -> Void) -> some CarView {
        ModifiedCarView(
            content: self,
            modifier: NowPlayingAlbumArtistModifier(handler: action)
        )
    }
}

#endif
