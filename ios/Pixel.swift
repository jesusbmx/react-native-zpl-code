//
//  Color.swift
//
//  Created by jbmx on 27/12/22.
//

import Foundation


class Pixel
{
  public static let white = Pixel(red:255, green: 255, blue: 255)
  public static let black = Pixel(red:  0, green:   0, blue:   0)
  
  public static let palette: [Pixel] =  [
    Pixel(red:  0, green:   0, blue:   0), // black
    Pixel(red:  0, green:   0, blue: 255), // green
    Pixel(red:  0, green: 255, blue:   0), // blue
    Pixel(red:  0, green: 255, blue: 255), // cyan
    Pixel(red:255, green:   0, blue:   0), // red
    Pixel(red:255, green:   0, blue: 255), // purple
    Pixel(red:255, green: 255, blue:   0), // yellow
    Pixel(red:255, green: 255, blue: 255)  // white
  ];
  
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
  
  public init(pixel: Pixel) {
    self.red = Int(pixel.red);
    self.green = Int(pixel.green);
    self.blue = Int(pixel.blue);
    self.alpha = Int(pixel.alpha)
  }
  
  public init(argb: Int) {
    self.red = Pixel.red(argb);
    self.green = Pixel.green(argb);
    self.blue = Pixel.blue(argb);
    self.alpha = Pixel.alpha(argb);
  }
  
  // Calcula la intensidad de gris basada en las componentes RGB
  public var gray: Int {
    return (red + green + blue) / 3
  }

  public func sum(_ o: Pixel) -> Pixel {
    return Pixel(
      red: red + o.red,
      green: green + o.green,
      blue: blue + o.blue,
      alpha: alpha + o.alpha
    );
  }

  public func sub(_ o: Pixel) -> Pixel {
      return Pixel(
        red: red - o.red,
        green: green - o.green,
        blue: blue - o.blue,
        alpha: alpha - o.alpha
      );
  }
  
  public func clamp(_ c: Int) -> Int {
      return max(0, min(255, c));
  }

  public func diff(_ o: Pixel) -> Int {
    let Rdiff = o.red - red;
    let Gdiff = o.green - green;
    let Bdiff = o.blue - blue;
    let Adiff = o.alpha - alpha;
    let distanceSquared = Rdiff * Rdiff + Gdiff * Gdiff + Bdiff * Bdiff + Adiff * Adiff;
    return distanceSquared;
  }

  public func mul(_ d: Double) -> Pixel {
      return Pixel(
        red: Int(d * Double(red)),
        green: Int(d * Double(green)),
        blue: Int(d * Double(blue)),
        alpha: Int(d * Double(alpha))
      );
  }
  
  public func toArgb() -> Int {
    return (alpha << 24) | (red << 16) | (green << 8) | blue
  }
  
  public static func findClosestPaletteColor(_ value: Pixel) -> Pixel {
    var closest: Pixel = Pixel.palette[0];
    
    for n: Pixel in Pixel.palette {
      if (n.diff(value) < closest.diff(value)) {
        closest = n;
      }
    }

    return closest;
  }
  
  /**
   * zeroOrOne
   *
   * Convierte el pixel de la imagen a blanco o negro
   * @param argb
   * @return Blanco(1) or Negro(0)
   */
  public static func zeroOrOneAsChar(
    pixel: Pixel,
    threshold: UInt8 = 128
  ) -> Character
  {
    if (pixel.gray >= threshold) {
        return "0"; // Negro
    }
    return "1"; // Blanco*/
  }
  
  public static func zeroOrOneAsChar(
    argb: Int,
    threshold: UInt8 = 128
  ) -> Character
  {
    if (Pixel.gray(argb) >= threshold) {
        return "0"; // Negro
    }
    return "1"; // Blanco*/
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
    threshold: UInt8 = 128
  ) -> UInt8 {
    return (pixel.gray < threshold) ? 1 : 0
  }
  
  public static func zeroOrOne(
    argb: Int,
    threshold: UInt8 = 128
  ) -> UInt8 {
    return (Pixel.gray(argb) < threshold) ? 1 : 0
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
  
  // Método de luminosidad:
  public static func gray(_ argb: Int) -> Int {
    /*
     let redValue = red(argb)
     let greenValue = green(argb)
     let blueValue = blue(argb)
     return (redValue + greenValue + blueValue) / 3
    */
    let redValue = red(argb)
    let greenValue = green(argb)
    let blueValue = blue(argb)
    return Int(0.299 * Double(redValue) + 0.587 * Double(greenValue) + 0.114 * Double(blueValue))
  }
  
  public static func toArgb(
    red: Int, green: Int, blue: Int, alpha: Int
  ) -> Int {
    return (alpha << 24) | (red << 16) | (green << 8) | blue
  }
}
