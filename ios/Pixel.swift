//
//  Color.swift
//
//  Created by Jesus on 27/12/22.
//

import Foundation


public class Pixel
{
  public let red: Int;
  public let green: Int;
  public let blue: Int;
  public let alpha: Int;

  public init(red: Int, green: Int, blue: Int, alpha: Int = 255) {
    self.red = red;
    self.green = green;
    self.blue = blue;
    self.alpha = alpha;
  }
  
  public init(argb: Int) {
    self.red = Pixel.red(argb);
    self.green = Pixel.green(argb);
    self.blue = Pixel.blue(argb);
    self.alpha = Pixel.alpha(argb);
  }
  
  // Calcula la intensidad de gris basada en las componentes RGB
  public var gray: Int {
    return Pixel.gray(red: red, green: green, blue: blue, alpha: alpha)
  }

  public static func alpha(_ argb: Int) -> Int {
    return (argb >> 24) & 0xFF
  }
  
  public static func red(_ argb: Int) -> Int {
    return (argb >> 16) & 0xFF
  }
  
  public static func green(_ argb: Int) -> Int {
    return (argb >> 8) & 0xFF
  }
  
  public static func blue(_ argb: Int) -> Int {
    return argb & 0xFF
  }
  
  public static func gray(_ argb: Int) -> Int {
    let red = red(argb)
    let green = green(argb)
    let blue = blue(argb)
    let alpha = alpha(argb)
    return gray(red: red, green: green, blue: blue, alpha: alpha)
  }
  
  /**
   * Método de luminosidad.
   * Calcula la intensidad de gris de un píxel basándose en sus componentes RGB y alfa
   * - Returns rango de 0 a 255
   */
  public static func gray(red: Int, green: Int, blue: Int, alpha: Int) -> Int {
    /*return (red + green + blue) / 3*/
    
    // Si el canal alfa es bajo, se considera blanco
    let isTransparent = alpha < 128
    
    if isTransparent {
        return 255
      
    } else {
      let result: Int = Int(
        0.299 * Double(red) + 0.587 * Double(green) + 0.114 * Double(blue))
      
      return Pixel.clamp(result)
    }
  }
  
  /**
   * zeroOrOne
   *
   * Convierte el pixel de la imagen a blanco o negro
   * @param argb
   * @return Blanco(1) or Negro(0)
   */
  public static func zeroOrOne(
    pixel: Pixel,
    threshold: UInt8
  ) -> UInt8 {
    // Negro(1) o blanco(0)
    return (pixel.gray <= threshold) ? 1 : 0
  }
  
  public static func zeroOrOne(
    argb: Int,
    threshold: UInt8
  ) -> UInt8 {
    // Negro(1) o blanco(0)
    return (Pixel.gray(argb) <= threshold) ? 1 : 0
  }
  
  public static func clamp(_ c: Int) -> Int {
      return max(0, min(255, c));
  }

  public func toArgb() -> Int {
    return (alpha << 24) | (red << 16) | (green << 8) | blue
  }
  
  public static func toArgb(
    red: Int, green: Int, blue: Int, alpha: Int
  ) -> Int {
    return (alpha << 24) | (red << 16) | (green << 8) | blue
  }
}
