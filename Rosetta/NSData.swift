import Foundation

extension Data {
	func toString() -> String? {
		return NSString(data: self, encoding: String.Encoding.utf8.rawValue) as? String
	}
}
