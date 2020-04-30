import XCTest
import RingArray

final class RingArrayTests: XCTestCase {
	static var allTests = [
		("testAppend", testAppend),
		("testAddViaSubscript", testAddViaSubscript),
		("testRemoveFirst", testRemoveFirst),
		("testRemoveMiddle", testRemoveMiddle),
		("testRemoveLast", testRemoveLast),
		("testRemoveFirstThenMiddle", testRemoveFirstThenMiddle),
		("testWrapNoRealloc", testWrapNoRealloc),
		("testWrapWholeBuffer", testWrapWholeBuffer)
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
	
	func testWrapNoRealloc() {
		let capacity = 10
		let ra = RingArray<Int>(startingSize: capacity)
		
		for i in 0..<10 { ra.append(i) }
		for _ in 0..<5 { ra.remove(at: 0) }
		
		XCTAssertEqual(Array(ra), Array(5..<10))
		
		for i in 100..<102 {
			ra.append(i)
		}
		
		XCTAssertEqual(ra[6], 101)
		XCTAssertEqual(Array(ra), [5, 6, 7, 8, 9, 100, 101])
		XCTAssertEqual(ra.capacity, capacity)
	}
	
	func testWrapWholeBuffer() {
		let capacity = 10
		let ra = RingArray<Int>(startingSize: capacity)
		
		for i in 0..<capacity { ra.append(i) }
		while !ra.isEmpty { ra.remove(at: 0) }
		
		for i in 100..<(100+capacity) { ra.append(i) }
		
		XCTAssertEqual(ra[6], 106)
		XCTAssertEqual(Array(ra), Array(100..<(100+capacity)))
		XCTAssertEqual(ra.capacity, capacity)
	}
}
