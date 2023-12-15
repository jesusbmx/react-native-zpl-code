package com.zplcode;

public class Pixel {

  int r, g, b, a;

  public Pixel(int argb) {
    this.a = alpha(argb);
    this.r = red(argb);
    this.g = green(argb);
    this.b = blue(argb);
  }

  public Pixel(int r, int g, int b, int a) {
    this.r = r;
    this.g = g;
    this.b = b;
    this.a = a;
  }

  public Pixel(int r, int g, int b) {
    this(r, g, b, 255);
  }

  public static int alpha(int argb) {
    return (argb >> 24) & 0xFF;
  }

  public static int red(int argb) {
    return (argb >> 16) & 0x000000FF;
  }

  public static int green(int argb) {
    return (argb >> 8) & 0x000000FF;
  }

  public static int blue(int argb) {
    return (argb) & 0x000000FF;
  }

  public static int toRGB(int r, int g, int b, int a) {
    return ((a & 0xFF) << 24) |
      ((r & 0xFF) << 16) |
      ((g & 0xFF) << 8)  |
      ((b & 0xFF) << 0);
  }

  /**
   * Método de luminosidad.
   * Calcula la intensidad de gris de un píxel basándose en sus componentes RGB y alfa
   * @param argb pixel
   * @return rango de 0 a 255
   */
  public static int gray(int argb) {
    int red = red(argb);
    int green = green(argb);
    int blue = blue(argb);
    int alpha = alpha(argb);

    // Si el canal alfa es bajo, se considera blanco
    boolean isTransparent = alpha < 128;

    if (isTransparent) {
      return 255;

    } else {
      int result = (int) (0.2989 * red + 0.5870 * green + 0.1140 * blue);

      return clamp(result);
    }
  }

  /**
   * zeroOrOne
   *
   * Convierte el pixel de la imagen a blanco o negro
   * @param argb
   * @param threshold 127
   * @return Blanco(1) or Negro(0)
   */
  public static int zeroOrOne(int argb, int threshold) {
    final int gray = Pixel.gray(argb);
    // Negro(1) o blanco(0)
    return (gray <= threshold) ? 1 : 0;
  }

  public static int clamp(int c) {
    return Math.max(0, Math.min(255, c));
  }

  public int toRGB() {
    int alpha = clamp(a);
    int red = clamp(r);
    int green = clamp(g);
    int blue = clamp(b);
    return toRGB(red, green, blue, alpha);
  }


//    public static boolean shouldPrintColor(int pixel) {
//      final int a = (pixel >> 24) & 0xFF;
//      if (a != 0xFF) { // Ignore transparencies
//         return false;
//      }
//      final int r = (pixel >> 16) & 0xFF;
//      final int g = (pixel >> 8) & 0xFF;
//      final int b = pixel & 0xFF;
//
//      final int threshold = 127;
//      final int luminance = (int) (0.299 * r + 0.587 * g + 0.114 * b);
//      return luminance < threshold;
//    }

}
