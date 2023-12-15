//
//  PixelImage.swift
//
//  Created by Jesus on 23/11/22.
//

import Foundation
import UIKit
import Accelerate

public class PixelImage: NSObject
{
  public static let bitsPerComponent = 8
  public static let bytesPerPixel = 4
  
  private let cgImage: CGImage?
  private let width: Int
  private let height: Int
  private let bytesPerRow: Int
  private var pixelData: [UInt8]
  
  init(width: Int, height: Int, argb: Int) {
    self.width = width
    self.height = height
    self.bytesPerRow = PixelImage.bytesPerPixel * width
    
    // Rellenar pixelData con el valor ARGB
    let byteValue = UInt8(argb & 0xFF)

    // Crear un array unidimensional directamente sin pasar por una matriz 2D
    self.pixelData = [UInt8](repeating: byteValue, count: width * height * PixelImage.bytesPerPixel)

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)
    let provider = CGDataProvider(data: NSData(bytes: &self.pixelData, length: self.pixelData.count))
    
    self.cgImage = CGImage(
      width: self.width,
      height: self.height,
      bitsPerComponent: PixelImage.bitsPerComponent,
      bitsPerPixel: PixelImage.bytesPerPixel * 8,
      bytesPerRow: self.bytesPerRow,
      space: colorSpace,
      bitmapInfo: bitmapInfo,
      provider: provider!,
      decode: nil,
      shouldInterpolate: true,
      intent: .defaultIntent
    )
  }
  
  init(cgImage: CGImage) throws {
    self.cgImage = cgImage
    self.width = cgImage.width
    self.height = cgImage.height
    self.bytesPerRow = PixelImage.bytesPerPixel * self.width
    self.pixelData = [UInt8](repeating: 0, count: self.bytesPerRow * self.height)

    let colorSpace = CGColorSpaceCreateDeviceRGB()

    guard let context = CGContext(data: &self.pixelData,
                                  width: self.width,
                                  height: self.height,
                                  bitsPerComponent: PixelImage.bitsPerComponent,
                                  bytesPerRow: self.bytesPerRow,
                                  space: colorSpace,
                                  bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) else {
        
      fatalError("Invalid Context")
    }
                            
    context.draw(cgImage, in: CGRect(
      x: 0, y: 0, width: self.width, height: self.height))
  }
  
  convenience init(uiImage: UIImage) throws {
    guard let cgImage = uiImage.cgImage else {
      fatalError("Image Conversion Error")
    }
    try self.init(cgImage: cgImage)
  }
  
  convenience init(data: Data) throws {
    // Definimos la scale en 1.0 para obtimizar los tiempos de carga
    try self.init(uiImage: UIImage(data: data, scale: 1.0)!)
  }
  
  public override var description: String {
    return "PixelImage(w:\(self.getWidth()) h:\(self.getHeight())"
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
   * Obtiene el valor ARGB de la imagen según las coordenadas.
   */
  public func getArgb(x: Int, y: Int) -> Int {
    let pixelIndex = y * self.bytesPerRow + x * PixelImage.bytesPerPixel
    guard pixelIndex < self.pixelData.count else {
      fatalError("Error: Attempted to access a pixel outside the bounds of the context. Requested position: (\(x), \(y))")
    }

    let red = Int(self.pixelData[pixelIndex])
    let green = Int(self.pixelData[pixelIndex + 1])
    let blue = Int(self.pixelData[pixelIndex + 2])
    let alpha = Int(self.pixelData[pixelIndex + 3])

    return Pixel.toArgb(red: red, green: green, blue: blue, alpha: alpha)
  }

  /**
   * Setea el valor ARGB en la imagen según las coordenadas.
   */
  public func setArgb(x: Int, y: Int, _ argb: Int) {
    let pixelIndex = (self.bytesPerRow * y) + x * PixelImage.bytesPerPixel
    guard pixelIndex < self.pixelData.count else { return }

    self.pixelData[pixelIndex] = UInt8(Pixel.red(argb))       // Rojo
    self.pixelData[pixelIndex + 1] = UInt8(Pixel.green(argb)) // Verde
    self.pixelData[pixelIndex + 2] = UInt8(Pixel.blue(argb))  // Azul
    self.pixelData[pixelIndex + 3] = UInt8(Pixel.alpha(argb)) // Alfa
  }
  
  // Subscript para acceder a un píxel específico
  public subscript(x: Int, y: Int) -> Int {
    get {
      // Obtener el píxel en la posición (x, y)
      return getArgb(x: x, y: y)
    }
    set(newValue) {
      // Asignar un nuevo valor al píxel en la posición (x, y)
      setArgb(x: x, y: y, newValue)
    }
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
        let pixel = self.getArgb(x: col, y: row)
        self.setArgb(x: col, y: row, filter.apply(argb: pixel))
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
  
  public func getCGImage() -> CGImage? {
    return self.cgImage
  }

  /**
   * Escala la imagen
   */
  public func newScale(
    width: Int,
    height: Int,
    interpolationQuality: CGInterpolationQuality = .medium //.high
  ) throws -> PixelImage {
    Utils.log("[PixelImage]", "newScale -> width:\(width) height:\(height)")

    let scale = UIScreen.main.scale  // Puedes ajustar esto según tus necesidades
    let newSize = CGSize(
      width: CGFloat(width) / scale,
      height: CGFloat(height) / scale)

    UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
    defer { UIGraphicsEndImageContext() }

    guard let context = UIGraphicsGetCurrentContext() else {
      fatalError("Invalid Context")
    }
    
    // Apply a horizontal flip transformation to correct the mirroring issue
    context.scaleBy(x: -1.0, y: 1.0)
    context.translateBy(x: -newSize.width, y: 0.0)

    context.interpolationQuality = interpolationQuality

    guard let cgImage = self.getCGImage() else {
      fatalError("Invalid CG Image")
    }
    
    context.draw(cgImage, in: CGRect(origin: .zero, size: newSize))

    guard let scaledImage = UIGraphicsGetImageFromCurrentImageContext() else {
      fatalError("Invalid Image")
    }

    return try PixelImage(uiImage: scaledImage)
  }
  
  /**
   * Obtiene la cantidad de bytes necesarios para almacenar los datos
   * ráster de la imagen en un formato donde cada byte representa
   * 8 píxeles horizontalmente.
   * @return
   */
  public func getHorizontalBytesOfRaster() -> Int {
      return ((self.getWidth() % 8) > 0)
              ? (self.getWidth() / 8) + 1
              : (self.getWidth() / 8);
  }
  
  /**
   * Otsu's Method.
   *
   * Utiliza el método de Otsu, que es un enfoque bien establecido y
   * ampliamente utilizado para determinar el umbral óptimo en imágenes
   * binarias.
   *
   * Calcula el limite para entre los pixeles blanco y negros.
   */
  public func calculeThreshold() -> UInt8 {
    // Get the histogram of pixel intensities
    var histogram = [Int](repeating: 0, count: 256)
    for y in 0..<getHeight() {
      for x in 0..<getWidth() {
        let pixel = getArgb(x: x, y: y)
        let intensity = Pixel.gray(pixel)
        histogram[Int(intensity)] += 1
      }
    }

    // Calculate the total number of pixels
    let totalPixels = getWidth() * getHeight()

    // Calculate the sum of intensities and sum of squared intensities
    var sum = 0
    //var sumOfSquares = 0
    for i in 0..<256 {
      sum += i * histogram[i]
      //sumOfSquares += i * i * histogram[i]
    }

    var maxVariance = 0.0
    var threshold: UInt8 = 0

    var sumForeground = 0
    var sumBackground = 0
    var countForeground = 0
    var countBackground = 0

    // Iterate through intensities to find the optimal threshold
    for i in 0..<256 {
      countBackground += histogram[i]
      if countBackground == 0 {
          continue
      }

      countForeground = totalPixels - countBackground
      if countForeground == 0 {
          break
      }

      sumBackground += i * histogram[i]
      sumForeground = sum - sumBackground

      let meanBackground = Double(sumBackground) / Double(countBackground)
      let meanForeground = Double(sumForeground) / Double(countForeground)

      // Calculate between-class variance
      let betweenVariance = Double(countBackground) * Double(countForeground) *
          pow(meanBackground - meanForeground, 2) / Double(totalPixels * totalPixels)

      // Update if the variance is greater than the current maximum
      if betweenVariance > maxVariance {
          maxVariance = betweenVariance
          threshold = UInt8(i)
      }
    }

    return threshold
  }
  
  /**
   * transform RGB image in raster format.
   * @return raster byte array
   */
  public func getRasterBytes(threshold: UInt8) -> [UInt8] {
    var byteArray = [UInt8]()
    var Byte: UInt8;
    var bits: Int;

    Utils.log("[PixelImage]", "getRasterBytes", "threshold=\(threshold)") // 129
      
    for y in 0 ..< getHeight() {
        Byte = 0;
        bits = 0;
        
      for x in 0 ..< getWidth() {
        // Obtenemos un blanco o un negro del pixel.
        let pixel = self.getArgb(x: x, y: y);
        let zeroOrOne: UInt8 = Pixel.zeroOrOne(
          argb: pixel, threshold: threshold); // black or White
        
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
        return try self.getImageFrom(base64: String(base64))
      }
      throw NSError(domain: "Header not found in base64 string", code: 500);
    }

    if (uri.hasPrefix("http://") || uri.hasPrefix("https://")) {
      guard let url = URL(string: uri) else {
        throw NSError(domain: "URL Not Found " + uri, code: 404);
      }
      let data = try Data(contentsOf: url)
      return try PixelImage(data: data)
    }

    if (uri.hasPrefix("file://")) {
      guard let url = URL(string: uri) else {
        throw NSError(domain: "File Not Found " + uri, code: 404);
      }
      let data = try Data(contentsOf: url)
      return try PixelImage(data: data)
    }

    if !FileManager.default.fileExists(atPath: uri) {
      throw NSError(domain: "File Not Found " + uri, code: 404);
    }
    let data = FileManager.default.contents(atPath: uri)!
    return try PixelImage(data: data)
  }

  public static func getImageFrom(base64: String) throws -> PixelImage {
    guard let base64DecodedData = Data(base64Encoded: base64) else {
      throw Utils.createError(message: "Failed to decode base64 string")
    }
    return try PixelImage(data: base64DecodedData)
  }
}
