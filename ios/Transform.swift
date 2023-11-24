//
//  Transform.swift
//  Text2Barcode
//
//  Created by Sistemas on 22/11/22.
//
import Foundation
import UIKit

protocol Transform
{
  func apply(_ image: PixelImage) -> PixelImage
}

/*
 * Dithering Type : Error Diffusion Dithering
 * Dithering Map  : Floyd Steinberg
 */
class Dither: NSObject, Transform
{
  enum DitheringType: String {
      case floydSteinberg = "floydSteinberg"
      case sierra = "sierra"
  }
  
  public let type: DitheringType;
  
  public init(type: DitheringType = DitheringType.floydSteinberg) {
    self.type = type
  }
  
  public override var description: String {
    return "Dither(type:\(type))"
  }
  
  public func apply(_ image: PixelImage) -> PixelImage {
    switch(type) {
      case .sierra:
        return sierra(image)
      case .floydSteinberg:
        return floydSteinberg(image)
    }
  }
  
  public func errors(_ image: PixelImage) -> [[Pixel]] {
    var errors = [[Pixel]]()

    for y in 0 ..< image.height {
      var row = [Pixel]()
      
      for x in 0 ..< image.width {
        let pixel = image.getPixel(x: x, y: y)!
        row.append(Pixel(pixel));
      }
      
      errors.append(row)
    }
    
    return errors
  }
  
  /*
   * False Floyd-Steinberg Dithering
   *
   * X 3
   * 3 2
   *
   * (1/8)
   */
  public func floydSteinberg(_ image: PixelImage) -> PixelImage
  {
    var r = image.pixelData
    let w: Int = r.width;
    let h: Int = r.height;
    
    var errors = self.errors(image)

    for y in 0 ..< h
    {
      for x in 0 ..< w
      {
        let oldColor: Pixel = errors[y][x];
        let newColor: Pixel = Pixel.findClosestPaletteColor(oldColor);
        
        r[x, y] = newColor.toRgb();

        let err: Pixel = oldColor.sub(newColor);

        if (x + 1 < w) {
          let mul = err.mul(7.0 / 16)
          errors[y][x + 1] = errors[y][x + 1].sum(mul);
        }
        
        if (x - 1 >= 0 && y + 1 < h) {
          let mul = err.mul(3.0 / 16)
          errors[y + 1][x - 1] = errors[y + 1][x - 1].sum(mul);
        }
        
        if (y + 1 < h) {
          let mul = err.mul(5.0 / 16)
          errors[y + 1][x] = errors[y + 1][x].sum(mul);
        }
        
        if (x + 1 < w && y + 1 < h) {
          let mul = err.mul(1.0 / 16)
          errors[y + 1][x + 1] = errors[y + 1][x + 1].sum(mul);
        }
      }
    }
    
    return r
  }
  
  /*
   * Sierra Dithering
   *
   *     X 5 3
   * 2 4 5 4 2
   *   2 3 2
   *
   * (1/32)
   */
  public func sierra(_ src: PixelImage) -> PixelImage
  {
    var r = src
    
    var alpha: Int
    var red: Int
    var gray: Int
    var pixel: UIColor

    let width: Int = r.width;
    let height: Int = r.height;
    
    var error: Int = 0;
    var errors = Array(repeating: Array(repeating: 0, count: width), count: height)
    
    for y in 0 ..< height
    {
      for x in 0 ..< width
      {
        pixel = src.pixelAt(x: x, y: y)!

        alpha = Int(pixel.alpha);
        red = Int(pixel.red);

        gray = red;
        if (gray + errors[x][y] < 127) {
          error = gray + errors[x][y];
          gray = 0;
        } else {
          error = gray + errors[x][y] - 255;
          gray = 255;
        }

        errors[x + 1][y] += (5 * error) / 32;
        errors[x + 2][y] += (3 * error) / 32;

        errors[x - 2][y + 1] += (2 * error) / 32;
        errors[x - 1][y + 1] += (4 * error) / 32;
        errors[x][y + 1] += (5 * error) / 32;
        errors[x + 1][y + 1] += (4 * error) / 32;
        errors[x + 2][y + 1] += (2 * error) / 32;

        errors[x - 1][y + 2] += (2 * error) / 32;
        errors[x][y + 2] += (3 * error) / 32;
        errors[x + 1][y + 2] += (2 * error) / 32;

        r[x, y] = UIColor(
          red: UInt8(gray), green: UInt8(gray), blue: UInt8(gray), alpha: UInt8(alpha)
        )
      }
    }

    return r
  }
}
