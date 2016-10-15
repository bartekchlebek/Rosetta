import Foundation

extension String {
	func toData() -> Data? {
		return data(using: String.Encoding.utf8, allowLossyConversion: false)
	}
}
