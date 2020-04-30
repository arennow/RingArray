extension UnsafeMutableBufferPointer {
	var endAddress: UnsafeMutablePointer<Element>? {
		guard let baseAddress = self.baseAddress else { return nil }
		return baseAddress.advanced(by: self.count)
	}
	
	func move(_ src: Index, to dest: Index, srcPostState: UnsafeMutablePointer<Element>.PostState) {
		let srcPtr = self.baseAddress!.advanced(by: src)
		let dstPtr = self.baseAddress!.advanced(by: dest)
		
		dstPtr.moveAssign(from: srcPtr, count: 1)
		
		srcPtr.apply(postState: srcPostState)
	}
}
