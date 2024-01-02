package com.zplcode;

import android.graphics.Bitmap;

import java.io.ByteArrayOutputStream;

public class PixelImage {

  public final Bitmap bitmap;

  public PixelImage(Bitmap b) {
    if (null == b) {
      throw new IllegalArgumentException("bitmap arg cannot be null");
    } else {
      this.bitmap = b;
    }
  }

  public int getArgb(int x, int y) {
    return bitmap.getPixel(x, y);
  }

  public void setArgb(int x, int y, int argb) {
    bitmap.setPixel(x, y, argb);
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
        int pixel = getArgb(col, row);
        setArgb(col, row, filter.pixel(pixel));
      }
    }
  }

  /**
   * Otsu's Method.Utiliza el método de Otsu, que es un enfoque bien establecido y
   ampliamente utilizado para determinar el umbral óptimo en imágenes
   binarias.
   *
   * Calcula el limite para entre los pixeles blanco y negros.
   * @return
   */
  public int calculeThreshold() {
    // Get the histogram of pixel intensities
    int[] histogram = new int[256];
    for (int y = 0; y < getHeight(); y++) {
      for (int x = 0; x < getWidth(); x++) {
        int pixel = getArgb(x, y);
        int intensity = Pixel.gray(pixel);
        histogram[intensity]++;
      }
    }

    // Calculate the total number of pixels
    final int totalPixels = getWidth() * getHeight();

    // Calculate the sum of intensities and sum of squared intensities
    int sum = 0;
    //int sumOfSquares = 0;
    for (int i = 0; i < 256; i++) {
      sum += i * histogram[i];
      //sumOfSquares += i * i * histogram[i];
    }

    double maxVariance = 0.0;
    byte threshold = 0;

    int sumForeground = 0;
    int sumBackground = 0;
    int countForeground = 0;
    int countBackground = 0;

    // Iterate through intensities to find the optimal threshold
    for (int i = 0; i < 256; i++) {
      countBackground += histogram[i];
      if (countBackground == 0) {
        continue;
      }

      countForeground = totalPixels - countBackground;
      if (countForeground == 0) {
        break;
      }

      sumBackground += i * histogram[i];
      sumForeground = sum - sumBackground;

      final double meanBackground = (double) sumBackground / countBackground;
      final double meanForeground = (double) sumForeground / countForeground;

      // Calculate between-class variance
      final double betweenVariance = countBackground * countForeground *
        Math.pow(meanBackground - meanForeground, 2) / (totalPixels * totalPixels);

      // Update if the variance is greater than the current maximum
      if (betweenVariance > maxVariance) {
        maxVariance = betweenVariance;
        threshold = (byte) i;
      }
    }

    return threshold;
  }

  /**
   * transform RGB image in raster format.
   * @param threshold 127
   * @return raster byte array
   */
  public byte[] getRasterBytes(int threshold) {
    final ByteArrayOutputStream byteArray = new ByteArrayOutputStream();
    int  Byte;
    int  bits;

    for(int y = 0; y < this.getHeight(); y++){
      Byte = 0;
      bits = 0;

      for(int x = 0; x < this.getWidth(); x++){
        // Obtenemos un blanco o un negro del pixel.
        final int pixel = this.getArgb(x, y);
        int zeroOrOne = Pixel.zeroOrOne(pixel, threshold); // black or White

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
