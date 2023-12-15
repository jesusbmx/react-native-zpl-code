import Foundation

@objc(ZplCode)
class ZplCode: NSObject {

  @objc
  func imageToZpl(_ props: NSDictionary,
    resolve: RCTPromiseResolveBlock,
    reject: RCTPromiseRejectBlock
  ) -> Void {

    do {
      // Obtener propiedades de la ReadableMap
      var image: PixelImage = try getImageFrom(props: props);

       //Extrae las propiedades de ancho y alto, con valores predeterminados basados en las dimensiones de la imagen.
      let maxWidth: Int = props["width"] as? Int ?? image.getWidth()
      
      let maxHeight: Int = props["height"] as? Int
        ?? (image.getHeight() * maxWidth) / image.getWidth()
          
      let actualWidth: Int = image.getWidth();
      let actualHeight: Int = image.getHeight();
      
      // Then compute the dimensions we would ideally like to decode to.
      let desiredWidth = PixelImage.getResizedDimension(maxWidth, maxHeight, actualWidth, actualHeight);
      
      let desiredHeight = PixelImage.getResizedDimension(maxHeight, maxWidth, actualHeight, actualWidth);

      let newImage = try image.newScale(width: desiredWidth, height: desiredHeight, interpolationQuality: .medium)
      
      let threshold = newImage.calculeThreshold()

      let isDither = props["dither"] as? Bool ?? true
            
      if (isDither) {
        newImage.apply(filter: GrayScale.DEFAULT) // Prototipo aun se esta evaluando
        newImage.apply(transform: FloydSteinbergDithering())
      }

      let graphics = ZplLibGraphics(pixels: newImage, threshold: threshold)

      // Calculate offsets
      let xOffset: Int = props["x"] as? Int ?? (maxWidth - desiredWidth) / 2
      let yOffset: Int = props["y"] as? Int ?? (maxHeight - desiredHeight) / 2

      let zpl = graphics.getZplCode(x: xOffset, y: yOffset, prefixAndSuffix: false)

      resolve(zpl);

    } catch let error {
      reject("0", error.localizedDescription, nil)
    }
  }

  func getImageFrom(props: NSDictionary) throws -> PixelImage {
    Utils.log("[RNZpl]", "getImageFromProps -> props:\(props)")

    if let uri = props["uri"] as? String {
      return try PixelImage.getImageFrom(uri: uri)
    }
    
    if let base64 = props["base64"] as? String {
      return try PixelImage.getImageFrom(base64: base64)
    }

    throw NSError(domain: "Image path not specified", code: 404);
  }
}
