import Foundation

extension String {
	func toData() -> NSData? {
		return dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
	}
}
