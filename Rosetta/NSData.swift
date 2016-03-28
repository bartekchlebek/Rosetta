import Foundation

extension NSData {
	func toString() -> String? {
		return NSString(data: self, encoding: NSUTF8StringEncoding) as? String
	}
}
