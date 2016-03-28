import Foundation

//MARK: Decoding

func decode<T, U, V>(
	value value: U?,
	rosetta: Rosetta,
	bridge: Bridge<T, V>,
	validator: (T -> Bool)?,
	optional: Bool) -> T? {

		func addLogWithType(type: Log.MapType) {
			let severity: Log.Severity = optional ? .Warning : .Error
			rosetta.logs.append(.Mapping(severity: severity, type: type, keyPath: rosetta.keyPath))
		}

		guard let value = value else {
			if !optional {
				addLogWithType(.ValueMissing)
			}
			rosetta.keyPath.removeAll(keepCapacity: false)
			return nil
		}

		guard let castedValue = value as? V else {
			if !optional {
				addLogWithType(.WrongType)
			}
			rosetta.keyPath.removeAll(keepCapacity: false)
			return nil
		}

		guard let decodedValue = bridge.decoder(castedValue) else {
			if !optional {
				addLogWithType(.BridgingFailed)
			}
			rosetta.keyPath.removeAll(keepCapacity: false)
			return nil
		}

		if validator?(decodedValue) == false {
			addLogWithType(.ValidationFailed)
			rosetta.keyPath.removeAll(keepCapacity: false)
			return nil
		}

		rosetta.keyPath.removeAll(keepCapacity: false)
		return decodedValue
}

func decodeTo<T, U, V>(
	inout property: T,
	value: U?,
	rosetta: Rosetta,
	bridge: Bridge<T, V>,
	validator: (T -> Bool)?,
	optional: Bool) {

		let decoded = decode(value: value, rosetta: rosetta, bridge: bridge, validator: validator, optional: optional)
		if rosetta.testRun == false {
			property = decoded ?? property
		}
}

func decodeTo<T, U, V>(
	inout property: T!,
	value: U?,
	rosetta: Rosetta,
	bridge: Bridge<T, V>,
	validator: (T -> Bool)?,
	optional: Bool) {

		let decoded = decode(value: value, rosetta: rosetta, bridge: bridge, validator: validator, optional: optional)
		if rosetta.testRun == false {
			property = decoded ?? property
		}
}

func decodeTo<T, U, V>(
	inout property: T?,
	value: U?,
	rosetta: Rosetta,
	bridge: Bridge<T, V>,
	validator: (T -> Bool)?,
	optional: Bool) {

		let decoded = decode(value: value, rosetta: rosetta, bridge: bridge, validator: validator, optional: optional)
		if rosetta.testRun == false {
			property = decoded ?? property
		}
}

//MARK: Encoding

func encodeFrom<T, U>(
	property: T?,
	rosetta: Rosetta,
	bridge: Bridge<T, U>,
	validator: (T -> Bool)?,
	optional: Bool) {

		let severity: Log.Severity = optional ? .Warning : .Error
		if let property = property {
			if validator?(property) ?? true {
				if let encodedValue = bridge.encoder(property) {
					setValue(encodedValue, atKeyPath: rosetta.keyPath, inDictionary: &rosetta.dictionary!)
				}
				else {
					rosetta.logs.append(Log.Mapping(severity: severity, type: .BridgingFailed, keyPath: rosetta.keyPath))
				}
			}
			else {
				rosetta.logs.append(Log.Mapping(severity: severity, type: .ValidationFailed, keyPath: rosetta.keyPath))
			}
		}
		else {
			rosetta.logs.append(Log.Mapping(severity: severity, type: .ValueMissing, keyPath: rosetta.keyPath))
		}
		rosetta.keyPath.removeAll(keepCapacity: false)
}
