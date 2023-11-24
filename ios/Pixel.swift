//
//  Color.swift
//  Text2Barcode
//
//  Created by Sistemas on 27/12/22.
//

import Foundation
import SwiftImage


class Pixel
{
  public static let palette: [Pixel] =  [
    Pixel(  0,   0,   0), // black
    Pixel(  0,   0, 255), // green
    Pixel(  0, 255,   0), // blue
    Pixel(  0, 255, 255), // cyan
    Pixel(255,   0,   0), // red
    Pixel(255,   0, 255), // purple
    Pixel(255, 255,   0), // yellow
    Pixel(255, 255, 255)  // white
  ];
  
  public let r: Int;
  public let g: Int;
  public let b: Int;
  public let a: Int;

  public init(_ r: Int, _ g: Int, _ b: Int, _ a: Int = 255) {
    self.r = r;
    self.g = g;
    self.b = b;
    self.a = a;
  }
  
  public init(_ rgb: UIColor) {
    self.r = Int(rgb.red);
    self.g = Int(rgb.green);
    self.b = Int(rgb.blue);
    self.a = Int(rgb.alpha)
  }

  public func sum(_ o: Pixel) -> Pixel {
    return Pixel(
      r + o.r,
      g + o.g,
      b + o.b,
      a + o.a
    );
  }

  public func sub(_ o: Pixel) -> Pixel {
      return Pixel(
        r - o.r,
        g - o.g,
        b - o.b,
        a - o.a
      );
  }
  
  public func clamp(_ c: Int) -> Int {
      return max(0, min(255, c));
  }

  public func diff(_ o: Pixel) -> Int {
    let Rdiff = o.r - r;
    let Gdiff = o.g - g;
    let Bdiff = o.b - b;
    let Adiff = o.a - a;
    let distanceSquared = Rdiff * Rdiff + Gdiff * Gdiff + Bdiff * Bdiff + Adiff * Adiff;
    return distanceSquared;
  }

  public func mul(_ d: Double) -> Pixel {
      return Pixel(
        Int(d * Double(r)),
        Int(d * Double(g)),
        Int(d * Double(b)),
        Int(d * Double(a))
      );
  }

  public func toRgb() -> UIColor {
      return UIColor(
        red: UInt8(clamp(r)),
        green: UInt8(clamp(g)),
        blue: UInt8(clamp(b)),
        alpha: UInt8(clamp(a))
      );
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
  public static func toBitChar(
    _ pixel: UIColor,
    threshold: UInt8 = 128
  ) -> Character
  {
    if (pixel.gray >= threshold) {
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
  public static func toBit(
    _ pixel: UIColor,
    threshold: UInt8 = 128
  ) -> UInt8 {
    return (pixel.gray < threshold) ? 1 : 0
  }
  
}
