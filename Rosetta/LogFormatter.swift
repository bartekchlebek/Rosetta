import Foundation

public typealias LogFormatter = (json: CustomStringConvertible?, logs: [Log]) -> String
let defaultLogFormatter: LogFormatter = { json, logs in
	var string = "Rosetta"
	string += "JSON : \(json)"
	string += "\n"
	string += logs.map { $0.description }.joined(separator: "\n")
	return string
}
