extension UnsafeMutableBufferPointer {
	enum PostState {
		case uninitialized
		case value(Element)
	}
	
	var endAddress: UnsafeMutablePointer<Element>? {
		guard let baseAddress = self.baseAddress else { return nil }
		return baseAddress.advanced(by: self.count)
	}
	
	func move(_ src: Index, to dest: Index, srcPostState: PostState) {
		let srcPtr = self.baseAddress!.advanced(by: src)
		let dstPtr = self.baseAddress!.advanced(by: dest)
		
		dstPtr.moveAssign(from: srcPtr, count: 1)
		
		switch srcPostState {
			case .value(let val): srcPtr.initialize(to: val)
			case .uninitialized: break
		}
	}
}
