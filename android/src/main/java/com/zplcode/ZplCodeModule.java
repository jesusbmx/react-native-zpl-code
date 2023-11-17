package com.zplcode;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.module.annotations.ReactModule;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

@ReactModule(name = ZplCodeModule.NAME)
public class ZplCodeModule extends ReactContextBaseJavaModule {
  public static final String NAME = "ZplCode";

  public ZplCodeModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  @ReactMethod
  public void imageToZpl(
    ReadableMap props,
    Promise promise
  ) {
    try {
      // Obtener propiedades de la ReadableMap
      final Bitmap bitmap = getBitmap(props);
      if (bitmap == null) {
        throw new IOException("Image not found");
      }

      Integer xOffset = props.hasKey("x") ? props.getInt("x") : null;
      Integer yOffset = props.hasKey("y") ? props.getInt("y") : null;
      int width = props.getInt("width");
      int height = props.getInt("height");
      boolean center = props.hasKey("center") && props.getBoolean("center");
      boolean dither = props.hasKey("dither") && props.getBoolean("dither");

      PixelImage image = new PixelImage(bitmap);

      int maxWidth   = width   <= 0 ?  image.getWidth()  : width;
      int maxHeight  = height  <= 0 ?  image.getHeight() : height;

      int desiredWidth = maxWidth;
      int desiredHeight = maxHeight;

      // Resize
      int actualWidth = image.getWidth();
      int actualHeight = image.getHeight();

      // Then compute the dimensions we would ideally like to decode to.
      desiredWidth = PixelImage.getResizedDimension(maxWidth, maxHeight, actualWidth, actualHeight);

      desiredHeight = PixelImage.getResizedDimension(maxHeight, maxWidth, actualHeight, actualWidth);


      if (center) {
        xOffset = (maxWidth - desiredWidth) / 2;
        yOffset = (maxHeight - desiredHeight) / 2;
      }

      PixelImage newImage = image.newScale(desiredWidth, desiredHeight);
      newImage.apply(GrayScale.DARK_GRAY);

      if (dither) {
        newImage = newImage.newTransform(new Dither());
      }

      final ZplLibGraphics graphics = new ZplLibGraphics(newImage);
      graphics.setPoint(xOffset, yOffset);
      String zpl = graphics.getZplCode(true);

      promise.resolve(zpl);

    } catch (Exception e) {
      promise.reject(e.getMessage(), e);
    }
  }


  public static Bitmap getBitmap(ReadableMap props) throws IOException {
    String uri = props.hasKey("uri") ? props.getString("uri") : null;
    if (uri != null) {
      return getBitmapFormUri(uri);
    }

    String base64 = props.hasKey("base64") ? props.getString("base64") : null;
    if (base64 != null) {
      return getBitmapFromBase64(base64);
    }

    throw new IOException("Image path not specified");
  }

  public static Bitmap getBitmapFormUri(String uri) throws IOException {
    if (uri.startsWith("https://") || uri.startsWith("http://")) {
      // Si es una URL
      URL src = new URL(uri);
      HttpURLConnection connection = null;

      try {
        connection = (HttpURLConnection) src.openConnection();
        connection.setDoInput(true);
        connection.connect();

        try (InputStream input = connection.getInputStream()) {
          return BitmapFactory.decodeStream(input);
        }

      } finally {
        if (connection != null)
          connection.disconnect();
      }
    }

    // "data:image/jpeg;base64,...............";
    if (uri.startsWith("data:")) {
      // Obtener la parte de los datos base64 después de la coma
      String imageDataBytes = uri.substring(uri.indexOf(",") + 1);
      return getBitmapFromBase64(imageDataBytes);
    }

    // Si es una ruta de archivo local
    return BitmapFactory.decodeFile(uri);
  }

  // Método para convertir una cadena Base64 a un objeto Bitmap
  public static Bitmap getBitmapFromBase64(String base64String) {
    // Decodificar los datos base64 a un array de bytes
    byte[] decodedBytes = Base64.decode(base64String, Base64.DEFAULT);
    // Convertir el array de bytes a un objeto Bitmap
    return BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.length);
  }

}
