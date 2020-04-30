extension UnsafeMutableBufferPointer {
	enum PostState {
		case uninitialized
		case value(Element)
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
