//
//  GetFirebaseVeterinariesTests.swift
//  MDPetTests
//
//  Created by Philippe on 01/08/2020.
//  Copyright © 2020 Philippe. All rights reserved.
//

import XCTest
import FirebaseDatabase
@testable import MDPet

class GetFirebaseVeterinariesTests: XCTestCase {

//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }

    func testGetVeterinaries_ShouldPostSuccessCallback_IfNoError() {
        let client = GetFirebaseVeterinaries(with: MockDatabaseReference())
        let expectation = XCTestExpectation(description: #function)
        
        client.observeVeterinaries { (success, veterinariesItems) in
            print(" \(veterinariesItems)")
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
    }

//    func testReadSample() {
//        let client = FirebaseDatabaseClient(with: MockDatabaseReference())
//        let expectaion = expectation(description: #function)
//
//        client.readSample { sampleList in
//            print("'======= \(sampleList)")
//            XCTAssertTrue(sampleList.contains("something"))
//            expectaion.fulfill()
//        }
//        wait(for: [expectaion], timeout: 0.5)
//    }


//    func testGetVeterinaries_ShouldPostSuccessCallback_IfNoInternetConnection() {
//        let client = GetFirebaseVeterinaries()
//        let expectation = XCTestExpectation(description: #function)
//
//        client.observeVeterinaries { (success, veterinariesItems) in
//            XCTAssertTrue(success)
//            expectation.fulfill()
//        }
//        wait(for: [expectation], timeout: 0.5)
//    }

//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    // MARK: - Override Firebae Realtime Database
    private class MockDatabaseReference: DatabaseReference {

        override func child(_ pathString: String) -> DatabaseReference {
            return self
        }
        
        override func queryOrdered(byChild key: String) -> DatabaseQuery {
            return self
        }

        override func observeSingleEvent(of eventType: DataEventType, with block: @escaping (DataSnapshot) -> Void) {
            let snapshot = MockSnapshot()
            DispatchQueue.global().async {
                block(snapshot)
            }
        }
    }
 
    private class MockSnapshot: DataSnapshot {

        override var value: Any? {
            return ["key_1": "value_1", "key_2": "value_2"]
        }
    }
}
