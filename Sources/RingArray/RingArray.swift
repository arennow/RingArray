public class RingArray<Element>: Collection {
	private var internalBuffer: UnsafeMutableBufferPointer<Element?>
	public private(set) var capacity: Int
	public private(set) var count: Int = 0
	private(set) var bufferStartOffset: Int = 0
	
	public let startIndex: Int = 0
	public var endIndex: Int { count }
	
	public init(startingSize: Int = 64) {
		self.capacity = startingSize
		self.internalBuffer = .allocate(capacity: self.capacity)
		self.internalBuffer.initialize(repeating: nil)
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
			self.pointer(for: index).pointee = newValue
			
			if index == self.count {
				self.count += 1
			}
		}
	}
	
	public func append(_ element: Element) {
		self[self.count] = element
	}
	
	public func remove(at index: Int) {
		ensureWithinCount(index)
		
		self.pointer(for: index).pointee = nil
		
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
	}
	
	public func index(before i: Int) -> Int { i - 1 }
	public func index(after i: Int) -> Int { i + 1 }
}

extension RingArray {
	convenience public init<S: Sequence>(_ seq: S) where S.Element == Element {
		self.init()
		seq.forEach(self.append)
	}
}

extension RingArray {
	@inline(__always)
	private func ensureWithinCount(_ index: Int, gte: Bool = false) {
		precondition(gte ? (index <= self.count) : (index < self.count), "Index \(index) out of bounds: \(self.count)")
	}
	
	private var lastValidIndex: Int { self.count - 1 }
	
	private func bufferIndex(for index: Int) -> Int {
		self.bufferStartOffset + index
	}
	
	private func pointer(for index: Int) -> UnsafeMutablePointer<Element?> {
		self.internalBuffer.baseAddress!.advanced(by: self.bufferIndex(for: index))
	}
}
