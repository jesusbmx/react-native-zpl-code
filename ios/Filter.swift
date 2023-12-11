//
//  Filter.swift
//
//  Created by jbmx on 23/12/22.
//

import Foundation

/*
  Filtro para PixelImage
 */
protocol Filter
{
  func apply(argb: Int) -> Int
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
class GrayScale: NSObject, Filter
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
  
  public func apply(argb: Int) -> Int {
    // Obtener el canal alfa (transparencia)
    let alpha = Pixel.alpha(argb)
    
    // Si el píxel es transparente, establecerlo como blanco
    if (alpha == 0) {
      return Pixel.white.toArgb()
    }

    let rg = Int(Pixel.red(argb) * self.r);
    let gg = Int(Pixel.green(argb) * self.g);
    let bg = Int(Pixel.blue(argb) * self.b);
    
    var totalColor: Int = (rg + gg + bg) / 100;
    if (totalColor > 255) {
        totalColor = 255;
    } else if (totalColor < 0) {
        totalColor = 0;
    }
    
    let gray = totalColor
        
    return Pixel.toArgb(
      red: gray, green: gray, blue: gray, alpha: alpha)
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
  
  public func apply(argb: Int) -> Int {
    // Obtener el canal alfa (transparencia)
    let a = Pixel.alpha(argb)
    
    // Si el píxel es transparente, establecerlo como blanco
    if (a == 0) {
      return Pixel.white.toArgb()
    }
    
    var r = Pixel.red(argb)
    var g = Pixel.green(argb)
    var b = Pixel.blue(argb)
    
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
    
    return Pixel.toArgb(red: r, green: g, blue: b, alpha: a)
  }
}
