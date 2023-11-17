package com.zplcode;

import android.graphics.Bitmap;
import android.graphics.Color;

import java.io.ByteArrayOutputStream;

public class PixelImage {

  public final Bitmap bitmap;

  public PixelImage(Bitmap bitmap) {
    this.bitmap = bitmap;
  }

  public int getPixel(int x, int y) {
    return bitmap.getPixel(x, y);
  }

  public void setPixel(int x, int y, int rgb) {
    bitmap.setPixel(x, y, rgb);
  }

  public int getHeight() {
    return this.bitmap.getHeight();
  }

  public int getWidth() {
    return this.bitmap.getWidth();
  }

  public PixelImage newScale(int w, int h) {
    if (w > 0 && h > 0) {
      final Bitmap b = Bitmap.createScaledBitmap(
        this.bitmap, w, h, true);
      return new PixelImage(b);
    } else {
      return this;
    }
  }

  /**
   * transform RGB image in raster format.
   * @return raster byte array
   */
  public byte[] getRasterBytes() {
    final ByteArrayOutputStream byteArray = new ByteArrayOutputStream();
    int  Byte;
    int  bits;

    final int width = this.getWidth();
    final int height = this.getHeight();

    for(int y = 0; y < height; y++){
      Byte = 0;
      bits = 0;

      for(int x = 0; x < width; x++){
        // Obtenemos un blanco o un negro del pixel.
        final int pixel = this.getPixel(x, y);
        int zeroOrOne = Pixel.toBit(pixel, 127); // black or White

        Byte = Byte | (zeroOrOne << (7 - bits));
        bits++;

        if(bits == 8){
          byteArray.write(Byte);
          Byte = 0;
          bits = 0;
        }
      }

      if (bits > 0) {
        byteArray.write(Byte);
      }

    }
    return byteArray.toByteArray();
  }

  /* Aplica un dither a la imagen */
  public PixelImage newTransform(Transform transform) {
    return transform.apply(this);
  }

  /* Aplica un filtro a la imagen. */
  public void apply(Filter filter) {
    final int width = getWidth();
    final int height = getHeight();

    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        int pixel = getPixel(col, row);

        // Obtener el canal alfa (transparencia)
        int alpha = Color.alpha(pixel);
        // Si el píxel es transparente, establecerlo como blanco
        if (alpha == 0) {
          setPixel(col, row, Color.WHITE);
        } else {
          setPixel(col, row, filter.pixel(pixel));
        }
      }
    }
  }

  public static int getResizedDimension(int maxPrimary, int maxSecondary, int actualPrimary,
                                        int actualSecondary) {

    // If no dominant value at all, just return the actual.
    if ((maxPrimary == 0) && (maxSecondary == 0)) {
      return actualPrimary;
    }

    // If primary is unspecified, scale primary to match secondary's scaling ratio.
    if (maxPrimary == 0) {
      double ratio = (double) maxSecondary / (double) actualSecondary;
      return (int) (actualPrimary * ratio);
    }

    if (maxSecondary == 0) {
      return maxPrimary;
    }

    double ratio = (double) actualSecondary / (double) actualPrimary;
    int resized = maxPrimary;

    if ((resized * ratio) > maxSecondary) {
      resized = (int) (maxSecondary / ratio);
    }
    return resized;
  }
}
