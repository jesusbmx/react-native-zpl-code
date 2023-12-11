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

      var xOffset: Int = Utils.getValue(props, key: "x") ?? 0
      var yOffset: Int = Utils.getValue(props, key: "y") ?? 0
        
      let width: Int = Utils.getValue(props, key: "width")!
      let height: Int = Utils.getValue(props, key: "height")!
            
      let maxWidth: Int   = width   <= 0 ?  image.getWidth()  : width
      let maxHeight: Int  = height  <= 0 ?  image.getHeight() : height
        
      var desiredWidth: Int = maxWidth
      var desiredHeight: Int = maxHeight

      // Resize
      let actualWidth: Int = image.getWidth();
      let actualHeight: Int = image.getHeight();

      // Then compute the dimensions we would ideally like to decode to.
      desiredWidth = PixelImage.getResizedDimension(maxWidth, maxHeight, actualWidth, actualHeight);

      desiredHeight = PixelImage.getResizedDimension(maxHeight, maxWidth, actualHeight, actualWidth);


      if (Utils.getValue(props, key: "center") ?? false) {
        xOffset = (maxWidth - desiredWidth) / 2;
        yOffset = (maxHeight - desiredHeight) / 2;
      }

      let newImage = try image.newScale(width: desiredWidth, height: desiredHeight)
      
      if (Utils.getValue(props, key: "dither") ?? true) {
        newImage.apply(transform: Dither(type: .floydSteinberg))
      }

      let graphics = ZplLibGraphics(pixels: newImage)
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
