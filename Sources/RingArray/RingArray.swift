public final class RingArray<Element>: Collection {
	private var internalBuffer: UnsafeMutableBufferPointer<Element?> { didSet { oldValue.deallocate() } }
	public private(set) var capacity: Int
	public private(set) var count: Int = 0
	private(set) var bufferStartOffset: Int = 0 {
		didSet {
			if self.bufferStartOffset >= self.capacity {
				// If our offset is the whole buffer, wrap the offset back to the beginning
				self.bufferStartOffset = 0
			}
		}
	}
	
	public let startIndex: Int = 0
	public var endIndex: Int { count }
	
	public init(startingSize: Int = 64) {
		self.capacity = startingSize
		self.internalBuffer = type(of: self).callocBuffer(capacity: self.capacity)
	}
	
	deinit {
		self.internalBuffer.deallocate()
	}
	
	public subscript(index: Int) -> Element {
		get {
			ensureWithinCount(index)
			return self.pointer(for: index).pointee!
		}
		set {
			ensureWithinCount(index, gte: true)
			self.ensureCapacity(for: index)
			
			self.pointer(for: index).pointee = newValue
			
			if index == self.count {
				self.count += 1
			}
		}
	}
	
	public func append(_ element: Element) {
		self[self.count] = element
	}
	
	@discardableResult
	public func remove(at index: Int) -> Element {
		ensureWithinCount(index)
		
		let ptr = self.pointer(for: index)
		let outValue = ptr.move(replacingWith: .value(nil))!
		
		if index == 0 {
			self.bufferStartOffset += 1
		} else {
			let shiftRange = self.index(after: index)..<self.endIndex
			for src in shiftRange {
				let dest = self.index(before: src)
				self.internalBuffer.move(self.bufferIndex(for: src),
										 to: self.bufferIndex(for: dest),
										 srcPostState: .uninitialized)
			}
			
			if let i = shiftRange.last {
				self.internalBuffer[self.bufferIndex(for: i)] = nil
			}
		}
		
		self.count -= 1
		return outValue
	}
	
	public func index(before i: Int) -> Int { i - 1 }
	public func index(after i: Int) -> Int { i + 1 }
}

extension RingArray {
	convenience public init<S: Sequence>(_ seq: S) where S.Element == Element {
		self.init()
		seq.forEach(self.append)
	}
	
	@discardableResult
	public func popFirst() -> Element? {
		guard !self.isEmpty else { return nil }
		
		return self.remove(at: 0)
	}
	
	@discardableResult
	public func popLast() -> Element? {
		guard !self.isEmpty else { return nil }
		
		return self.remove(at: self.lastValidIndex)
	}
}

extension RingArray {
	@inline(__always)
	private func ensureWithinCount(_ index: Int, gte: Bool = false) {
		precondition(gte ? (index <= self.count) : (index < self.count), "Index \(index) out of bounds: \(self.count)")
	}
	
	private var lastValidIndex: Int { self.count - 1 }
	
	private func bufferIndex(for index: Int) -> Int {
		var outInd = self.bufferStartOffset + index
		if outInd >= self.capacity {
			outInd -= self.capacity
		}
		
		assert(outInd >= 0, "Buffer index \(outInd) out of bounds: \(self.capacity)")
		assert(outInd < capacity, "Buffer index \(outInd) out of bounds: \(self.capacity)")
		
		return outInd
	}
	
	private func pointer(for index: Int) -> UnsafeMutablePointer<Element?> {
		self.internalBuffer.baseAddress!.advanced(by: self.bufferIndex(for: index))
	}
}

extension RingArray {
	private static func callocBuffer(capacity: Int) -> UnsafeMutableBufferPointer<Element?> {
		let outBuf = UnsafeMutableBufferPointer<Element?>.allocate(capacity: capacity)
		outBuf.initialize(repeating: nil)
		return outBuf
	}
	
	private func ensureCapacity(for index: Int) {
		guard index >= self.capacity else { return }
		
		let newCapacity = self.capacity * 2
		let newBuffer = type(of: self).callocBuffer(capacity: newCapacity)
		
		let (firstChunk, secondChunk) = self.chunksToMove()
		
		newBuffer.baseAddress!.moveAssign(from: firstChunk.first!, count: firstChunk.count)
		
		if let secondChunk = secondChunk {
			newBuffer.baseAddress!.advanced(by: firstChunk.count).moveAssign(from: secondChunk.first!, count: secondChunk.count)
		}
		
		self.internalBuffer = newBuffer
		self.bufferStartOffset = 0
		self.capacity = newCapacity
	}
	
	private func chunksToMove() -> (Range<UnsafeMutablePointer<Element?>>, Range<UnsafeMutablePointer<Element?>>?) {
		let firstChunkStartPtr = self.internalBuffer.baseAddress!.advanced(by: self.bufferStartOffset)
		let firstChunkEndPtr = Swift.min(firstChunkStartPtr.advanced(by: self.count), self.internalBuffer.endAddress!)
		let firstChunk = firstChunkStartPtr..<firstChunkEndPtr
		
		let remainingItems = self.count - firstChunk.count
		guard remainingItems > 0 else { return (firstChunk, nil) }
		
		let secondChunkStartPtr = self.internalBuffer.baseAddress!
		let secondChunkEndPtr = secondChunkStartPtr.advanced(by: remainingItems)
		let secondChunk = secondChunkStartPtr..<secondChunkEndPtr
		
		return (firstChunk, secondChunk)
	}
}
