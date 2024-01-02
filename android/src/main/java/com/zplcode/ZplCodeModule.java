package com.zplcode;

import android.content.ContentResolver;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.ImageDecoder;
import android.net.Uri;
import android.os.Build;
import android.provider.MediaStore;
import android.util.Base64;
import android.util.Log;

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
      final Bitmap bitmap = getBitmapFromProps(getReactApplicationContext(), props);
      final PixelImage image = new PixelImage(bitmap);

      //Extrae las propiedades de ancho y alto, con valores predeterminados basados en las dimensiones de la imagen.
      final int maxWidth = props.hasKey("width")
        ? props.getInt("width")
        : image.getWidth();

      final int maxHeight = props.hasKey("height")
        ? props.getInt("height")
        : (image.getHeight() * maxWidth) / image.getWidth();

      final int actualWidth = image.getWidth();
      final int actualHeight = image.getHeight();

      // # Resize
      // Then compute the dimensions we would ideally like to decode to.
      final int desiredWidth = PixelImage.getResizedDimension(maxWidth, maxHeight, actualWidth, actualHeight);

      final int desiredHeight = PixelImage.getResizedDimension(maxHeight, maxWidth, actualHeight, actualWidth);

      PixelImage newImage = image.newScale(desiredWidth, desiredHeight);

      // # Filter
      final boolean isDither = props.hasKey("dither") && props.getBoolean("dither");
      if (isDither) {
        newImage.apply(GrayScale.DEFAULT);
        newImage = newImage.newTransform(new FloydSteinbergDithering());
      }

      // # Zpl
      final ZplLibGraphics graphics = new ZplLibGraphics(newImage, 127);

      // Calculate offsets
      final int xOffset = props.hasKey("x") ? props.getInt("x") : (maxWidth - desiredWidth) / 2;
      final int yOffset = props.hasKey("y") ? props.getInt("y") : (maxHeight - desiredHeight) / 2;

      graphics.setPoint(xOffset, yOffset);

      final String zpl = graphics.getZplCode(true);

      promise.resolve(zpl);

    } catch (Exception e) {
      promise.reject(e.getMessage(), e);
    }
  }


  @NonNull
  public static Bitmap getBitmapFromProps(Context context, ReadableMap props) throws IOException {
    String uri = props.hasKey("uri") ? props.getString("uri") : null;
    if (uri != null) {
      Bitmap bitmap = getBitmapFromUri(context, uri);
      if (bitmap == null) {
        throw new IOException("Image '" + uri + "' not found");
      }
      return  bitmap;
    }

    String base64 = props.hasKey("base64") ? props.getString("base64") : null;
    if (base64 != null) {
      Bitmap bitmap = getBitmapFromBase64(base64);
      if (bitmap == null) {
        throw new IOException("Could not decode the image");
      }
      return  bitmap;
    }

    throw new IOException("Image path not specified");
  }

  public static Bitmap getBitmapFromUri(Context context, String uri) throws IOException {
    Log.d("ZplCodeModule", "getBitmapFromUri: " + uri);

    // "data:image/jpeg;base64,...............";
    if (uri.startsWith("data:")) {
      // Obtener la parte de los datos base64 después de la coma
      String imageDataBytes = uri.substring(uri.indexOf(",") + 1);
      return getBitmapFromBase64(imageDataBytes);
    }

    // Si es una URL
    if (uri.startsWith("https://") || uri.startsWith("http://")) {
      return getBitmapFromUrl(uri);
    }

    // Si es una ruta de archivo es un contenedor
    if (uri.startsWith("content://")) {
      return getBitmapFromHardware(context, Uri.parse(uri));
    }

    // Si es una ruta de archivo local
    if (uri.startsWith("file://")) {
      return getBitmapFromHardware(context, Uri.parse(uri));
    }

    // Si es una ruta de archivo local
    //return BitmapFactory.decodeFile(uri);
    return getBitmapFromHardware(context, Uri.parse("file://" + uri));
  }

  public static Bitmap getBitmapFromHardware(Context context, Uri uri) throws IOException {
    Log.d("ZplCodeModule", "getBitmapFromHardware: " + uri);

    Bitmap originalBitmap;
    ContentResolver resolver = context.getContentResolver();
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
      originalBitmap = ImageDecoder.decodeBitmap(ImageDecoder.createSource(resolver, uri));
    } else {
      originalBitmap = MediaStore.Images.Media.getBitmap(resolver, uri);
    }

    // Verifica si el Bitmap es mutable
    if (!originalBitmap.isMutable()) {
      // Create a mutable copy with the same width, height, and ARGB_8888 configuration
      Bitmap mutableBitmap = originalBitmap.copy(Bitmap.Config.ARGB_8888, true);
      // Make sure to recycle the original bitmap if you no longer need it
      originalBitmap.recycle();

      return mutableBitmap;
    }

    return originalBitmap;
  }

  // Método para obtener un Bitmap de una url
  public static Bitmap getBitmapFromUrl(String url) throws IOException {
    Log.d("ZplCodeModule", "getBitmapFromUrl: " + url);
    // Si es una URL
    URL src = new URL(url);
    HttpURLConnection connection = null;

    try {
      connection = (HttpURLConnection) src.openConnection();
      connection.setDoInput(true);
      connection.connect();

      try (InputStream input = connection.getInputStream()) {
        return BitmapFactory.decodeStream(input);
      }

    } finally {
      if (connection != null) {
        connection.disconnect();
      }
    }
  }

  // Método para convertir una cadena Base64 a un objeto Bitmap
  public static Bitmap getBitmapFromBase64(String base64String) {
    Log.d("ZplCodeModule", "getBitmapFromBase64");
    // Decodificar los datos base64 a un array de bytes
    byte[] decodedBytes = Base64.decode(base64String, Base64.DEFAULT);
    // Convertir el array de bytes a un objeto Bitmap
    return BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.length);
  }

}
