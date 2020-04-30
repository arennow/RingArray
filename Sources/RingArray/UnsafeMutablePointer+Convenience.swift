extension UnsafeMutablePointer {
	enum PostState {
		case uninitialized
		case value(Pointee)
	}
	
	func apply(postState: PostState) {
		switch postState {
			case .value(let val): self.initialize(to: val)
			case .uninitialized: break
		}
	}
	
	func move(replacingWith postState: PostState) -> Pointee {
		let outVal = self.move()
		
		self.apply(postState: postState)
		
		return outVal
	}
}
