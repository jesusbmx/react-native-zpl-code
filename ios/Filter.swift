//
//  Filter.swift
//  Text2Barcode
//
//  Created by Sistemas on 23/12/22.
//

import Foundation
import SwiftImage

/*
  Filtro para PixelImage
 */
protocol Filter
{
  func pixel(_ argb: UIColor) -> UIColor
}


/*
 Filtro: Escala de grises
 -  50    50    50   dark gray
 - 120   120   120   medium gray
 - 200   200   200   light gray
 - 250   200   200   not gray, reddish
 -   0     0     0   black (a sort of gray)
 - 255   255   255   white (ditto)
*/
public class GrayScale: NSObject, Filter
{
  public let r: Int
  public let g: Int
  public let b: Int
  
  public static let DEFAULT = GrayScale(30, 59, 11)
  public static let DARK_GRAY = GrayScale(50, 50, 50)
  public static let MEDIUM_GRAY = GrayScale(120, 120, 120)
  public static let LIGHT_GRAY = GrayScale(200, 200, 200)
  public static let NOT_GRAY = GrayScale(250, 200, 200)
  public static let BLACK = GrayScale(0, 0, 0)
  public static let WHITE = GrayScale(255, 255, 255)
  
  public init(_ r: Int, _ g: Int, _ b: Int) {
    self.r = r
    self.g = g
    self.b = b
  }
  
  public override var description: String {
    return "GrayScale(r:\(r) g:\(g) b:\(b))"
  }
  
  public func pixel(_ argb: UIColor) -> UIColor {
    let rg = Int(Int(argb.red) * self.r);
    let gg = Int(Int(argb.green) * self.g);
    let bg = Int(Int(argb.blue) * self.b);
    var totalColor: Int = (rg + gg + bg) / 100;
    
    if (totalColor > 255) {
        totalColor = 255;
    } else if (totalColor < 0) {
        totalColor = 0;
    }
    
    let gray = UInt8(totalColor)
    
    return UIColor(red: gray, green: gray, blue: gray, alpha: argb.alpha)
  }
}

/*
  Filtro Sepia
 */
public class Sepia: NSObject, Filter
{
  
  public override var description: String {
    return "Sepia()"
  }
  
  public func pixel(_ argb: UIColor) -> UIColor {
    var a = Int(argb.alpha)
    var r = Int(argb.red)
    var g = Int(argb.green)
    var b = Int(argb.blue)
    
    // calculate
    let newRed = Int(0.393 * Float(r) + 0.769 * Float(g) + 0.189 * Float(b))
    let newGreen = Int(0.349 * Float(r) + 0.686 * Float(g) + 0.168 * Float(b))
    let newBlue = Int(0.272 * Float(r) + 0.534 * Float(g) + 0.131 * Float(b))

    // check condition
    if (newRed > 255) {
      r = 255
    } else {
      r = newRed
    }

    if (newGreen > 255) {
      g = 255
    } else {
      g = newGreen
    }
    
    if (newBlue > 255) {
      b = 255
    } else {
      b = newBlue
    }
    
    return UIColor(red: UInt8(r), green: UInt8(g), blue: UInt8(b), alpha: UInt8(a))
  }
}
