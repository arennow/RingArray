import XCTest
import RingArray

final class RingArrayTests: XCTestCase {
	static var allTests = [
		("testAppend", testAppend),
		("testAddViaSubscript", testAddViaSubscript),
		("testRemoveFirst", testRemoveFirst),
		("testRemoveMiddle", testRemoveMiddle),
		("testRemoveLast", testRemoveLast),
		("testRemoveFirstThenMiddle", testRemoveFirstThenMiddle)
	]
	
	func testAppend() {
		let ra = RingArray<Int>()
		for i in 0..<10 {
			ra.append(i)
		}
		
		XCTAssertEqual(Array(ra), Array(0..<10))
	}
	
	func testAddViaSubscript() {
		let ra = RingArray<Int>()
		for i in 0..<10 {
			ra[ra.count] = i
		}
		
		XCTAssertEqual(Array(ra), Array(0..<10))
	}
	
	func testRemoveFirst() {
		let ra = RingArray(0..<10)
		
		ra.remove(at: 0)
		XCTAssertEqual(Array(ra), Array(1..<10))
	}
	
	func testRemoveMiddle() {
		let ra = RingArray(0..<10)
		
		ra.remove(at: 5)
		XCTAssertEqual(Array(ra), [0, 1, 2, 3, 4, 6, 7, 8, 9])
	}
	
	func testRemoveLast() {
		let ra = RingArray(0..<10)
		
		ra.remove(at: 9)
		XCTAssertEqual(Array(ra), Array(0..<9))
	}
	
	func testRemoveFirstThenMiddle() {
		let ra = RingArray(0..<10)
		
		ra.remove(at: 0)
		ra.remove(at: 4)
		XCTAssertEqual(Array(ra), [1, 2, 3, 4, 6, 7, 8, 9])
	}
}
