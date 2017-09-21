//
//  The_SpotTests.swift
//  The SpotTests
//
//  Created by Giorgia Marenda on 9/18/17.
//  Copyright © 2017 Giorgia Marenda. All rights reserved.
//

import XCTest
@testable import The_Spot

class The_SpotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        Store.removeHistory(for: "Test")
    }
    
    func testAddSentMessage() {
        Store.addSentMessage(to: "Test", placeID: "1234")
        Store.addSentMessage(to: "Test", placeID: "5678")

        let list = Store.fetch(key: .contactHistoryKey) as? [ContactHistory]
        XCTAssertNotNil(list)
        let historyItem = list?.filter({ $0.contactFullname == "Test" }).first
        XCTAssertNotNil(historyItem)
        XCTAssertGreaterThan(historyItem!.sentSpots.count, 1)
        XCTAssertEqual(historyItem!.sentSpots.first, "1234")
        XCTAssertEqual(historyItem!.sentSpots.last, "5678")
    }
    
    func testAddReceivedMessage() {
        Store.addReceivedMessage(from: "Test", placeID: "1234")
        Store.addReceivedMessage(from: "Test", placeID: "5678")
        
        let list = Store.fetch(key: .contactHistoryKey) as? [ContactHistory]
        XCTAssertNotNil(list)
        let historyItem = list?.filter({ $0.contactFullname == "Test" }).first
        XCTAssertNotNil(historyItem)
        XCTAssertGreaterThan(historyItem!.receivedSpots.count, 1)
        XCTAssertEqual(historyItem!.receivedSpots.first, "1234")
        XCTAssertEqual(historyItem!.receivedSpots.last, "5678")
    }
    
}

