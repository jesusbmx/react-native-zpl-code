//
//  PixelImage.swift
//  Text2Barcode
//
//  Created by Sistemas on 23/11/22.
//

import Foundation
import UIKit
import Accelerate

class PixelImage: NSObject
{
  /* Imagen en pixeles */
  private let cgImage: CGImage;
  private let width: Int
  private let height: Int
  private let bitsPerComponent = 8
  private let bytesPerPixel = 4
  private let bytesPerRow: Int
  public var pixelData: [UInt8]
  
  init(cgImage: CGImage) throws 
  {
    self.cgImage = cgImage;
    self.width = cgImage.width
    self.height = cgImage.height

    self.bytesPerRow = self.bytesPerPixel * self.width
    let colorSpace = CGColorSpaceCreateDeviceRGB()

    self.pixelData = [UInt8](repeating: 0, count: self.bytesPerRow * self.height)

    guard let context = CGContext(data: &self.pixelData,
                                      width: self.width,
                                      height: self.height,
                                      bitsPerComponent: self.bitsPerComponent,
                                      bytesPerRow: self.bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) else {
        
        throw NSError(domain: "PixelImageErrorDomain", code: 1, userInfo: nil)
    }
                            
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.width, height: self.height))
  }
  
  convenience init(uiImage: UIImage) throws
  {
    guard let cgImage = uiImage.cgImage else {
      fatalError("Image Conversion Error")
    }
    self.init(image: uiImage.cgImage)
  }
  
  convenience init(data: Data) throws
  {
    // Definimos la scale en 1.0 para obtimizar los tiempos de carga
    self.init(uiImage: UIImage(data: data, scale: 1.0)!)
  }
  
  public override var description: String {
    return "PixelImage(w:\(width()) h:\(height())"
  }
  
  /**
   * Ancho de la imagen
   */
  public func getWidth() -> Int {
    return self.width
  }
  
  /**
   * Largo de la imagen
   */
  public func getHeight() -> Int {
    return self.height
  }
  
  /**
   * Obtiene el pixel de la imagen segun la cordenada
   */
  public func getPixel(x: Int, y: Int) -> UIColor {
    let pixelIndex = y * self.bytesPerRow + x * self.bytesPerPixel

    let red = CGFloat(self.pixelData[pixelIndex]) / 255.0
    let green = CGFloat(self.pixelData[pixelIndex + 1]) / 255.0
    let blue = CGFloat(self.pixelData[pixelIndex + 2]) / 255.0
    let alpha = CGFloat(self.pixelData[pixelIndex + 3]) / 255.0

    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }
  
  /**
   * Setea el pixel en la imagen segun la cordenada
   */
  public func setPixel(x: Int, y: Int, pixel: UIColor) {
    let byteIndex = (self.bytesPerRow * y) + x * self.bytesPerPixel
    guard byteIndex < self.pixelData.count else { return }

    self.pixelData[byteIndex] = UInt8(pixel.red * 255.0)
    self.pixelData[byteIndex + 1] = UInt8(pixel.green * 255.0)
    self.pixelData[byteIndex + 2] = UInt8(pixel.blue * 255.0)
    self.pixelData[byteIndex + 3] = UInt8(pixel.alpha * 255.0)
  }
  
  /**
   * Calcula el limite para entre los pixeles blanco y negros.
   */
  public func threshold() -> UInt8 {
    let totalPixels = self.width * self.height
    var totalGray: Int = 0

    for y in 0..<self.height {
      for x in 0..<self.width {
        let pixel = self.getPixel(x: x, y: y)
        totalGray += Int(pixel.gray * 255.0)
      }
    }

    return UInt8(totalGray / totalPixels)
  }
    
  /**
   * Aplica un filtro a la imagen.
   */
  public func apply(filter: Filter) {
    Utils.log("[PixelImage]", "apply -> filter:\(filter)")
    let width = self.width
    let height = self.height

    for row in 0..<height {
      for col in 0..<width {
        let pixel = self.getPixel(x: col, y: row)

        // Obtener el canal alfa (transparencia)
        let alpha = pixel.alpha
        // Si el píxel es transparente, establecerlo como blanco
        if alpha == 0 {
          self.setPixel(x: col, y: row, pixel: UIColor.white)
        } else {
          self.setPixel(x: col, y: row, pixel: filter.pixel(pixel))
        }
      }
    }
  }
  
  /**
   * Aplica un dither a la imagen
   */
  public func apply(transform: Transform) {
    Utils.log("[PixelImage]", "apply -> transform:\(transform)")
    self.pixelData = transform.apply(self).pixelData
  }

  public func uiImage() -> UIImage {
    return UIImage(cgImage: self.cgImage)
  }
  
  /**
   * Escala la imagen
   */
  public func newScale(width: Int, height: Int) -> PixelImage {
    guard width > 0 && height > 0 else {
      return self  // Retorna self si las dimensiones no son válidas
    }

    Utils.log("[PixelImage]", "newScale -> width:\(width) height:\(height)")

    let scale = UIScreen.main.scale  // Puedes ajustar esto según tus necesidades
    let newSize = CGSize(width: CGFloat(width) / scale, height: CGFloat(height) / scale)

    UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
    defer { UIGraphicsEndImageContext() }

    guard let context = UIGraphicsGetCurrentContext() else {
      return nil  // Retorna nil si no se puede obtener el contexto gráfico
    }

    context.interpolationQuality = .high
    self.uiImage().draw(in: CGRect(origin: .zero, size: newSize))

    guard let scaledImage = UIGraphicsGetImageFromCurrentImageContext() else {
      return nil  // Retorna nil si no se puede obtener la imagen escalada
    }

    return PixelImage(uiImage: scaledImage)
  }
  
  /**
   * Obtiene la cantidad de bytes necesarios para almacenar los datos
   * ráster de la imagen en un formato donde cada byte representa
   * 8 píxeles horizontalmente.
   * @return
   */
  public func getHorizontalBytesOfRaster() -> Int {
      return ((self.width() % 8) > 0)
              ? (self.width() / 8) + 1
              : (self.width() / 8);
  }
  
  /**
   * transform RGB image in raster format.
   * @return raster byte array
   */
  public func getRasterBytes() -> [UInt8] {
    var byteArray = [UInt8]()
    var Byte: UInt8;
    var bits: Int;
      
    for y in 0 ..< image.height {
        Byte = 0;
        bits = 0;
        
      for x in 0 ..< image.width {
        // Obtenemos un blanco o un negro del pixel.
        let pixel = self.getPixel(x: x, y: y);
        let zeroOrOne: UInt8 = Pixel.toBit(pixel); // black or White
        
        Byte = Byte | (zeroOrOne << (7 - bits));
        bits = bits + 1;
        
        if(bits == 8){
            byteArray.append(Byte);
            Byte = 0;
            bits = 0;
        }
      }
        
      if (bits > 0) {
          byteArray.append(Byte);
      }
    }
    
    return byteArray;
  }
  
  public static func getResizedDimension(
    _ maxPrimary: Int,
    _ maxSecondary: Int,
    _ actualPrimary: Int,
    _ actualSecondary: Int
  ) -> Int {

     // If no dominant value at all, just return the actual.
     if ((maxPrimary == 0) && (maxSecondary == 0)) {
         return actualPrimary;
     }

     // If primary is unspecified, scale primary to match secondary's scaling ratio.
     if (maxPrimary == 0) {
        let ratio: Double = Double(maxSecondary) / Double(actualSecondary);
        return Int(Double(actualPrimary) * ratio);
     }

     if (maxSecondary == 0) {
        return maxPrimary;
     }

     let ratio: Double = Double(actualSecondary) / Double( actualPrimary);
     var resized: Int = maxPrimary;

     if ((Double(resized) * ratio) > Double(maxSecondary)) {
        resized = Int(Double(maxSecondary) / ratio);
     }
    
     return resized;
  }

  public static func getImageFrom(uri: String) throws -> PixelImage {
    if (uri.hasPrefix("data:")) {
      if let commaIndex = uri.firstIndex(of: ",") {
        let base64 = uri.suffix(from: uri.index(after: commaIndex))
        return try self.getImageFrom(base64: base64)
      }
      throw NSError(domain: "Header not found in base64 string", code: 500);
    }

    if (uri.hasPrefix("http://") || uri.hasPrefix("https://")) {
      guard let url = URL(string: uri) else {
        throw NSError(domain: "URL Not Found " + uri, code: 404);
      }
      let data = try Data(contentsOf: url)
      return PixelImage(data: data)
    }

    if (uri.hasPrefix("file://")) {
      guard let url = URL(string: uri) else {
        throw NSError(domain: "File Not Found " + uri, code: 404);
      }
      let data = try Data(contentsOf: url)
      return PixelImage(data: data)
    }

    if !FileManager.default.fileExists(atPath: uri) {
      throw NSError(domain: "File Not Found " + uri, code: 404);
    }
    let data = FileManager.default.contents(atPath: uri)!
    return PixelImage(data: data)
  }

  public static func getImageFrom(base64: String) throws -> PixelImage {
    guard let base64DecodedData = Data(base64Encoded: base64) else {
      throw Utils.createError(message: "Failed to decode base64 string")
    }
    return PixelImage(data: base64DecodedData)
  }
}
