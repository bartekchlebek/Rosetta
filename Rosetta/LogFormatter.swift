import Foundation

public typealias LogFormatter = (json: JSON?, logs: [Log], file: StaticString, line: UInt, function: StaticString) -> String
let defaultLogFormatter: LogFormatter = { json, logs, file, line, function in
	var string = "Rosetta"

	// "\(file)" is used instead of file.stringValue, because it causes compiler warning:
	// integer overflows when converted from 'Builtin.Int32' to 'Builtin.Int8'
	let fileString = "\(file)".componentsSeparatedByString("/").last ?? "\(file)"
	string += "\n"
	string += "\(fileString):\(line) \(function)"

	if let jsonString = json?.stringValue {
		string += "\n"
		string += "JSON String: \(jsonString)"
	}
	else if let jsonData = json?.dataValue {
		string += "\n"
		string += "JSON Data: \(jsonData)"
	}

	string += "\n"
	string += logs.map { $0.description }.joinWithSeparator("\n")
	return string
}
