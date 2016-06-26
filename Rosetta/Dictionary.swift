import Foundation

func valueForKeyPath(_ keyPath: [String], inDictionary dictionary: [String: AnyObject]) -> AnyObject? {
	if keyPath.count == 0 {
		return dictionary
	}
	else {
		var branch = dictionary
		for index in 0..<keyPath.count - 1 {
			if let subdict = branch[keyPath[index]] as? [String: AnyObject] {
				branch = subdict
			}
			else {
				return nil
			}
		}
		return branch[keyPath.last!]
	}
}

func dictionaryBySettingValue(
	_ value: AnyObject,
	forKeyPath keyPath: [String],
	inDictionary dictionary: [String: AnyObject]
	) -> [String: AnyObject] {

		if keyPath.count == 0 {
			NSException(name: NSExceptionName.internalInconsistencyException, reason: "ketPath must not be empty", userInfo: nil).raise()
			abort()
		}
		else if keyPath.count == 1 {
			var dictionary = dictionary
			dictionary[keyPath.first!] = value
			return dictionary
		}
		else {
			var dictionary = dictionary
			let firstKey = keyPath[0]
			var keyPath = keyPath
			keyPath.remove(at: 0)
			if let subdict = dictionary[firstKey] as? [String: AnyObject] {
				dictionary[firstKey] = dictionaryBySettingValue(value, forKeyPath: keyPath, inDictionary: subdict)
			}
			else {
				dictionary[firstKey] = dictionaryBySettingValue(value, forKeyPath: keyPath, inDictionary: [:])
			}
			return dictionary
		}
}

func setValue(_ value: AnyObject, atKeyPath keyPath: [String], inDictionary dictionary: inout [String: AnyObject]) {
	dictionary = dictionaryBySettingValue(value, forKeyPath: keyPath, inDictionary: dictionary)
}
