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

final class NowPlayingTests: XCTestCase {
    func testBasicNowPlaying() throws {
        let nowPlaying = NowPlaying()

        let template = try distillTemplate(CPNowPlayingTemplate.self, for: nowPlaying)
        XCTAssertEqual(template.isUpNextButtonEnabled, false)
        XCTAssertEqual(template.upNextTitle, "")
        XCTAssertEqual(template.isAlbumArtistButtonEnabled, false)
        XCTAssertEqual(template.nowPlayingButtons.count, 0)
    }

    func testNowPlayingButtons() throws {
        let nowPlaying = NowPlaying()
            .nowPlayingButtons(content: {
                Button(action: { /* Can't test Button Actions */ }, nowPlaying: .shuffle)
                Button(action: { /* Can't test Button Actions */ }, nowPlaying: .repeat)
            })

        let template = try distillTemplate(CPNowPlayingTemplate.self, for: nowPlaying)
        XCTAssertEqual(template.isUpNextButtonEnabled, false)
        XCTAssertEqual(template.upNextTitle, "")
        XCTAssertEqual(template.isAlbumArtistButtonEnabled, false)
        XCTAssertEqual(template.nowPlayingButtons.count, 2)
        XCTAssert(template.nowPlayingButtons[0] is CPNowPlayingShuffleButton)
        XCTAssert(template.nowPlayingButtons[1] is CPNowPlayingRepeatButton)
    }

    func testNowPlayingUpNext() throws {
        let upNextExpectation = expectation(description: "Up Next Handler should be called")
        let nowPlaying =
            NowPlaying()
            .upNextButton(action: { upNextExpectation.fulfill() }, title: "Custom Title")

        let template = try distillTemplate(CPNowPlayingTemplate.self, for: nowPlaying)
        XCTAssertEqual(template.isUpNextButtonEnabled, true)
        XCTAssertEqual(template.upNextTitle, "Custom Title")
        XCTAssertEqual(template.isAlbumArtistButtonEnabled, false)
        XCTAssertEqual(template.nowPlayingButtons.count, 0)

        template.templateObserver.nowPlayingTemplateUpNextButtonTapped(template)

        wait(for: [upNextExpectation], timeout: 0.1)
    }

    func testNowPlayingAlbumArtist() throws {
        let albumArtistExpectation = expectation(description: "Album Artist Handler should be called")
        let nowPlaying =
            NowPlaying()
            .albumArtistButton(action: { albumArtistExpectation.fulfill() })

        let template = try distillTemplate(CPNowPlayingTemplate.self, for: nowPlaying)
        XCTAssertEqual(template.isUpNextButtonEnabled, false)
        XCTAssertEqual(template.upNextTitle, "")
        XCTAssertEqual(template.isAlbumArtistButtonEnabled, true)
        XCTAssertEqual(template.nowPlayingButtons.count, 0)

        template.templateObserver.nowPlayingTemplateAlbumArtistButtonTapped(template)

        wait(for: [albumArtistExpectation], timeout: 0.1)
    }

    func testNowPlayingComplex() throws {
        let upNextExpectation = expectation(description: "Up Next Handler should be called")
        let albumArtistExpectation = expectation(description: "Album Artist Handler should be called")

        let nowPlaying =
        NowPlaying()
            .nowPlayingButtons(content: {
                Button(action: { /* Can't test Button Actions */ }, nowPlaying: .shuffle)
                Button(action: { /* Can't test Button Actions */ }, nowPlaying: .repeat)
            })
            .upNextButton(action: { upNextExpectation.fulfill() })
            .albumArtistButton(action: { albumArtistExpectation.fulfill() })

        let template = try distillTemplate(CPNowPlayingTemplate.self, for: nowPlaying)
        XCTAssertEqual(template.isUpNextButtonEnabled, true)
        XCTAssertEqual(template.upNextTitle, "")
        XCTAssertEqual(template.isAlbumArtistButtonEnabled, true)
        XCTAssertEqual(template.nowPlayingButtons.count, 2)

        template.templateObserver.nowPlayingTemplateUpNextButtonTapped(template)
        template.templateObserver.nowPlayingTemplateAlbumArtistButtonTapped(template)

        wait(for: [upNextExpectation, albumArtistExpectation], timeout: 0.1)
    }
}
