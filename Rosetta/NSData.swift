import Foundation

extension NSData {
	func toDictionary() -> [String: AnyObject]? {
		return (try? NSJSONSerialization.JSONObjectWithData(self, options: [])) as? [String: AnyObject]
	}

	func toString() -> String? {
		return NSString(data: self, encoding: NSUTF8StringEncoding) as? String
	}
}
