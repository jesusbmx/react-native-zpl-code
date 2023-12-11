//
//  Transform.swift
//
//  Created by jbmx on 22/11/22.
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
  public enum DitheringType: String {
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
    var errors = [[Pixel]](
      repeating: [Pixel](repeating: Pixel.white, count: image.getWidth()),
      count: image.getHeight())

    for y in 0 ..< image.getHeight() {
      for x in 0 ..< image.getWidth() {
        let pixel = image.getArgb(x: x, y: y)
        errors[y][x] = Pixel(argb: pixel)
      }
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
  public func floydSteinberg(_ img: PixelImage) -> PixelImage
  {
    let w = img.getWidth()
    let h = img.getHeight()

    var errors = self.errors(img)

    for y in 0 ..< h {
      for x in 0 ..< w {
        let oldColor = errors[y][x]
        let newColor = Pixel.findClosestPaletteColor(oldColor)
        img[x, y] = newColor.toArgb()

        let err = oldColor.sub(newColor)

        let x1 = x + 1
        let x2 = x + 2
        let y1 = y + 1

        if x1 < w {
          errors[y][x1] = errors[y][x1].sum(err.mul(7.0 / 16))
        }

        if x2 < w {
          errors[y][x2] = errors[y][x2].sum(err.mul(1.0 / 16))
        }

        if x1 < w && y1 < h {
          errors[y1][x1] = errors[y1][x1].sum(err.mul(3.0 / 16))
        }

        if y1 < h {
          errors[y1][x] = errors[y1][x].sum(err.mul(5.0 / 16))
        }
      }
    }

    return img
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
  public func sierra(_ img: PixelImage) -> PixelImage
  {
    var alpha: Int
    var red: Int
    var gray: Int
    var pixel: Int

    let width: Int = img.getWidth();
    let height: Int = img.getHeight();
    
    var error: Int = 0;
    var errors = Array(repeating: Array(repeating: 0, count: width), count: height)
    
    for y in 0 ..< height
    {
      for x in 0 ..< width
      {
        pixel = img.getArgb(x: x, y: y)

        alpha = Pixel.alpha(pixel);
        red = Pixel.red(pixel);

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

        img[x, y] = Pixel.toArgb(
          red: gray, green: gray, blue: gray, alpha: alpha
        )
      }
    }

    return img
  }
}
