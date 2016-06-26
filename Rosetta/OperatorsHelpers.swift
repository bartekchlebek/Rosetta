import Foundation

//MARK: Decoding

func decode<T, U, V>(
	value: U?,
	rosetta: Rosetta,
	bridge: Bridge<T, V>,
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

		guard let castedValue = value as? V else {
			if !optional {
				addLogWithType(.wrongType)
			}
			rosetta.keyPath.removeAll(keepingCapacity: false)
			return nil
		}

		guard let decodedValue = bridge.decoder(castedValue) else {
			if !optional {
				addLogWithType(.bridgingFailed)
			}
			rosetta.keyPath.removeAll(keepingCapacity: false)
			return nil
		}

		if validator?(decodedValue) == false {
			addLogWithType(.validationFailed)
			rosetta.keyPath.removeAll(keepingCapacity: false)
			return nil
		}

		rosetta.keyPath.removeAll(keepingCapacity: false)
		return decodedValue
}

func decodeTo<T, U, V>(
	_ property: inout T,
	value: U?,
	rosetta: Rosetta,
	bridge: Bridge<T, V>,
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
	bridge: Bridge<T, V>,
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
	bridge: Bridge<T, V>,
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
	bridge: Bridge<T, U>,
	validator: ((T) -> Bool)?,
	optional: Bool) {

		let severity: Log.Severity = optional ? .warning : .error
		if let property = property {
			if validator?(property) ?? true {
				if let encodedValue = bridge.encoder(property) {
					setValue(encodedValue, atKeyPath: rosetta.keyPath, inDictionary: &rosetta.dictionary!)
				}
				else {
					rosetta.logs.append(Log.mapping(severity: severity, type: .bridgingFailed, keyPath: rosetta.keyPath))
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
