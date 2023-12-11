//
//  Utils.swift
//
//  Created by Sistemas on 24/11/22.
//

import Foundation

class Utils {
  
  static let formatter = DateFormatter()
  
  public static func now() -> String {
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter.string(from: Date())
  }
  
  public static func log(_ items: Any...) {
    var sb = [Any]()
    sb.append("[d] [\(Utils.now())] ")
    for it in items {
      sb.append(" ")
      sb.append(it)
    }
    print(toString(sb))
  }
  
  public static func cleanParam(_ str: String) -> String {
    var trim = str.trimmingCharacters(in: .whitespacesAndNewlines)
    return trim.replacingOccurrences(of: " ", with: "")
              .replacingOccurrences(of: "\n", with: "")
              .replacingOccurrences(of: "\r", with: "");
  }
  
  public static func crlf(_ str: String) -> String {
      return str.replacingOccurrences(of: "\r", with: "")
              .replacingOccurrences(of: "\n", with: "\r\n");
  }
  
  public static func toString(_ array: [Any]) -> String {
    return array.map { ( it: Any) in
      String(describing: it)
    }.joined()
  }
  
  public static func roundAvoid(_ value: Float, _ places: Int) -> Float {
    let scale: Float = powf(10, Float(places));
    return round(value * scale) / scale;
  }
  
  public static func getValue<T>(_ dict: NSDictionary, key: String) -> T? {
    let value: Any? = dict.value(forKey: key)
    if let v = value {
      return v as? T
    }
    return nil
  }
  
  public static func getValue<T>(_ dict: [AnyHashable: Any], key: String) -> T? {
    let value: Any? = dict[key]
    if let v = value {
      return v as? T
    }
    return nil
  }
  
  public static func split(str: String, regex pattern: String) -> [String] {
    let regex = try! NSRegularExpression(pattern: pattern)
    let matches = regex.matches(in: str, range: NSRange(str.startIndex..., in: str))
    let splits = [str.startIndex]
        + matches.map { Range($0.range, in: str)! }
        .flatMap { [ $0.lowerBound, $0.upperBound ] }
        + [str.endIndex]

    return zip(splits, splits.dropFirst())
      .map { String(str[$0 ..< $1])}
  }
  
  public static func split(str: String, separator: String) -> [String] {
    return str.components(separatedBy: separator);
  }
  
  /**
   * Obtiene una subcadena
   * - Parameter str "Hello, playground",
   * - Parameter to 5
   * - Returns "Hello"
   */
  public static func substring(str: String, to: Int) -> String {
    let toIndex = str.index(str.startIndex, offsetBy: to)
    return String(str[..<toIndex])
  }
  
  /**
   * Obtiene una subcadena
   * - Parameter str "Hello, playground"
   * - Parameter from 7
   * - Returns "playground"
   */
  public static func substring(str: String, from: Int) -> String {
    let fromIndex = str.index(str.startIndex, offsetBy: from)
    return String(str[fromIndex...])
  }

  /**
   * Obtiene una subcadena
   * - Parameter str "Hello, playground"
   * - Parameter with: 7..<11
   * - Returns "play"
   */
  public static func substring(str: String, with r: Range<Int>) -> String {
    let startIndex = str.index(str.startIndex, offsetBy: r.lowerBound)
    let endIndex = str.index(str.startIndex, offsetBy: r.upperBound)
    return String(str[startIndex..<endIndex])
  }
  
  /**
   * Obtiene una subcadena
   * - Parameter str "Hello, playground"
   * - Parameter indexStart 7
   * - Parameter indexEnd 11
   * - Returns "play"
   */
  public static func substring(str: String, fromIndex: Int, toIndex: Int) -> String {
    let startIndex = str.index(str.startIndex, offsetBy: fromIndex)
    let endIndex = str.index(str.startIndex, offsetBy: toIndex)
    return String(str[startIndex..<endIndex])
  }
  
  /**
   * Replaza un string por medio de una expression regular
   * - Parameter str "data:application/zpl;base64,E839dy"
   * - Parameter pattern "data:(.+);base64,"
   * - Parameter replaceWith ""
   * - Returns "E839dy"
   */
  public static func replaceString(
    _ str: String,
    pattern: String,
    replaceWith: String = ""
  ) -> String {
    do {
      let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
      let range = NSRange(location: 0, length: str.count)
      return regex.stringByReplacingMatches(in: str, options: [], range: range, withTemplate: replaceWith)
    } catch {
      return str
    }
  }
  
  /**
   * Replaza un string por medio de una expression regular
   * - Parameter str "data:application/zpl;base64,E839dy"
   * - Parameter target "data:"
   * - Parameter withString ""
   * - Returns "application/zpl;base64,E839dy"
   */
  public static func replaceString(
    _ str: String,
    target: String,
    withString: String = ""
  ) -> String
  {
     return str.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
  }
  
  /**
   * Decodifica una cadena encriptada en base64
   * - Parameter base64: cadena encriptada
   * - Returns cadena desencriptada
   */
  public static func decodeBase64(
    base64: String,
    defValue: String? = ""
  ) -> String? {
    // Set response
    if let decodeBase64 = Data(base64Encoded: base64) {
      return String(data: decodeBase64, encoding: .utf8)!
    }
    return defValue
  }
  
  
  /**
   * Creates an NSError with a given message.
   *
   * - Parameter message: The error message.
   * - Returns: An error including a domain, error code, and error      message.
   */
  public static func createError(message: String)-> NSError
  {
     let error = NSError(domain: "app.domain", code: 0,userInfo: [NSLocalizedDescriptionKey: message])
     return error
  }

}
