@objc(ZplCode)
class ZplCode: NSObject {

  @objc
  func imageToZpl(_ props: NSDictionary,
    resolve: RCTPromiseResolveBlock,
    reject: RCTPromiseRejectBlock
  ) -> Void {

    do {
      // Obtener propiedades de la ReadableMap
      var image: PixelImage = try ZplCode.getImageFrom(props: props);
      var xOffset: Int? = props.hasKey("x") ? props.getInt("x") : nil;
      var yOffset: Int? = props.hasKey("y") ? props.getInt("y") : nil;
      var width: Int = props.getInt("width");
      var height: Int = props.getInt("height");
      var center: Bool = props.hasKey("center") && props.getBoolean("center");
      var dither: Bool = props.hasKey("dither") && props.getBoolean("dither");

      var maxWidth: Int   = width   <= 0 ?  image.getWidth()  : width;
      var maxHeight: Int  = height  <= 0 ?  image.getHeight() : height;

      var desiredWidth: Int = maxWidth;
      var desiredHeight: Int = maxHeight;

      // Resize
      var actualWidth: Int = image.getWidth();
      var actualHeight: Int = image.getHeight();

      // Then compute the dimensions we would ideally like to decode to.
      desiredWidth = PixelImage.getResizedDimension(maxWidth, maxHeight, actualWidth, actualHeight);

      desiredHeight = PixelImage.getResizedDimension(maxHeight, maxWidth, actualHeight, actualWidth);


      if (center) {
        xOffset = (maxWidth - desiredWidth) / 2;
        yOffset = (maxHeight - desiredHeight) / 2;
      }

      var newImage: PixelImage = image.newScale(desiredWidth, desiredHeight);
      //newImage.apply(filter: Sepia())
      newImage.apply(filter: GrayScale.DARK_GRAY) // 25 secs    28960
      //newImage.apply(filter: GrayScale(57, 57, 57)) // 23 secs    26996
      //newImage.apply(filter: GrayScale(65, 65, 65)) // 19s secs 23632

      if (dither) {
        newImage.apply(transform: Dither(type: .floydSteinberg));
      }

      let graphics = ZplLibGraphics(newImage);
      graphics.setPoint(xOffset, yOffset);
      let zpl = graphics.getZplCode(true);

      promise.resolve(zpl);

    } catch let error {
      reject("0", error.localizedDescription, nil)
    }
  }

  static func getImageFrom(props: NSDictionary) throws -> PixelImage {
    Utils.log("[ZplCode]", "getImageFromProps -> props:\(props)")

    var uri: String? = props.hasKey("uri") ? props.getString("uri") : nil;
    var base64: String? = props.hasKey("base64") ? props.getString("base64") : nil;
    
    if (uri != nil) {
      return try PixelImage.getImageFrom(uri: uri)
    }

    if (uri != nil) {
      return try PixelImage.getImageFrom(base64: base64)
    }

    throw NSError(domain: "Image path not specified", code: 404);
  }
}
