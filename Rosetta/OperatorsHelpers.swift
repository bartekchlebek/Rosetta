import Foundation

//MARK: Decoding

func decode<T, U, V>(
	value: U?,
	rosetta: Rosetta,
	bridge: _Bridge<T, V>,
	validator: ((T) -> Bool)?,
	optional: Bool) -> T? {

	func addLogWithType(_ type: Log.MapType) {
		let severity: Log.Severity = optional ? .warning : .error
		rosetta.logs.append(.mapping(severity: severity, type: type, keyPath: rosetta.keyPath))
	}

	guard let value = value else {
		if !optional {
			addLogWithType(.valueMissing)
		}
		rosetta.keyPath.removeAll(keepingCapacity: false)
		return nil
	}

	let bridgeResult = bridge.decode(jsonValue: value)
	switch bridgeResult {
	case .null:
		if !optional {
			addLogWithType(.valueMissing)
		}
		rosetta.keyPath.removeAll(keepingCapacity: false)
		return nil
	case .unexpectedValue:
		if !optional {
			addLogWithType(.bridgingFailed)
		}
		rosetta.keyPath.removeAll(keepingCapacity: false)
		return nil
	case .success(let value):
		if validator?(value) == false {
			addLogWithType(.validationFailed)
			rosetta.keyPath.removeAll(keepingCapacity: false)
			return nil
		}

		rosetta.keyPath.removeAll(keepingCapacity: false)
		return value
	}
}

func decodeTo<T, U, V>(
	_ property: inout T,
	value: U?,
	rosetta: Rosetta,
	bridge: _Bridge<T, V>,
	validator: ((T) -> Bool)?,
	optional: Bool) {

		let decoded = decode(value: value, rosetta: rosetta, bridge: bridge, validator: validator, optional: optional)
		if rosetta.testRun == false {
			property = decoded ?? property
		}
}

func decodeTo<T, U, V>(
	_ property: inout T!,
	value: U?,
	rosetta: Rosetta,
	bridge: _Bridge<T, V>,
	validator: ((T) -> Bool)?,
	optional: Bool) {

		let decoded = decode(value: value, rosetta: rosetta, bridge: bridge, validator: validator, optional: optional)
		if rosetta.testRun == false {
			property = decoded ?? property
		}
}

func decodeTo<T, U, V>(
	_ property: inout T?,
	value: U?,
	rosetta: Rosetta,
	bridge: _Bridge<T, V>,
	validator: ((T) -> Bool)?,
	optional: Bool) {

		let decoded = decode(value: value, rosetta: rosetta, bridge: bridge, validator: validator, optional: optional)
		if rosetta.testRun == false {
			property = decoded ?? property
		}
}

//MARK: Encoding

func encodeFrom<T, U>(
	_ property: T?,
	rosetta: Rosetta,
	bridge: _Bridge<T, U>,
	validator: ((T) -> Bool)?,
	optional: Bool) {

	let severity: Log.Severity = optional ? .warning : .error
	if let property = property {
		if validator?(property) ?? true {
			let bridgeResult = bridge.encode(value: property)
			switch bridgeResult {
			case .success(let value): setValue(value, atKeyPath: rosetta.keyPath, inDictionary: &rosetta.dictionary!)
			case .error: rosetta.logs.append(Log.mapping(severity: severity, type: .bridgingFailed, keyPath: rosetta.keyPath))
			}
		}
		else {
			rosetta.logs.append(Log.mapping(severity: severity, type: .validationFailed, keyPath: rosetta.keyPath))
		}
	}
	else {
		rosetta.logs.append(Log.mapping(severity: severity, type: .valueMissing, keyPath: rosetta.keyPath))
	}
	rosetta.keyPath.removeAll(keepingCapacity: false)
}
