package com.zplcode;

public class Pixel {
  public static final Pixel[] palette = new Pixel[] {
    new Pixel(  0,   0,   0), // black
    new Pixel(  0,   0, 255), // green
    new Pixel(  0, 255,   0), // blue
    new Pixel(  0, 255, 255), // cyan
    new Pixel(255,   0,   0), // red
    new Pixel(255,   0, 255), // purple
    new Pixel(255, 255,   0), // yellow
    new Pixel(255, 255, 255)  // white
  };

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

  public Pixel add(Pixel o) {
    return new Pixel(
      r + o.r,
      g + o.g,
      b + o.b,
      a + o.a
    );
  }

  public int clamp(int c) {
    return Math.max(0, Math.min(255, c));
  }

  public int diff(Pixel o) {
    int Rdiff = o.r - r;
    int Gdiff = o.g - g;
    int Bdiff = o.b - b;
    int Adiff = o.a - a;
    int distanceSquared = Rdiff * Rdiff + Gdiff * Gdiff + Bdiff * Bdiff + Adiff * Adiff;
    return distanceSquared;
  }

  public Pixel mul(double d) {
    return new Pixel(
      (int) (d * r),
      (int) (d * g),
      (int) (d * b),
      (int) (d * a)
    );
  }

  public Pixel sub(Pixel o) {
    return new Pixel(
      r - o.r,
      g - o.g,
      b - o.b,
      a - o.a
    );
  }

  public int toRGB() {
    int alpha = clamp(a);
    int red = clamp(r);
    int green = clamp(g);
    int blue = clamp(b);
    return toRGB(red, green, blue, alpha);
  }


  public static Pixel findClosestPaletteColor(Pixel c, Pixel[] palette) {
    Pixel closest = palette[0];

    for (Pixel n : palette) {
      if (n.diff(c) < closest.diff(c)) {
        closest = n;
      }
    }

    return closest;
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
   * Conviert un pixel rgb a un gray
   * @param argb
   * @return
   */
  public static int gray(int argb) {
    //int alpha = (argb >> 24) & 0xFF;
    final int red = (argb >> 16) & 0xFF;
    final int green = (argb >> 8) & 0xFF;
    final int blue = (argb) & 0xFF;
    return red + green + blue / 3;
    //return (int) (0.2989 * red + 0.5870 * green + 0.1140 * blue);
  }

  /**
   * zeroOrOne
   *
   * Convierte el pixel de la imagen a blanco o negro
   * @param argb
   * @param threshold 127
   * @return Blanco(1) or Negro(0)
   */
  public static int toBit(int argb, int threshold) {
    final int gray = Pixel.gray(argb);
    return (gray < threshold) ? 1 : 0;
  }

  /**
   * zeroOrOne
   *
   * Convierte un rgb a un binario blanco o negro.
   * @param argb
   * @param threshold 127
   * @return Blanco(1) or Negro(0)
   */
  public static char toBitChar(int argb, int threshold) {
    final int gray = Pixel.gray(argb);
    return (gray < threshold) ? '1' : '0';
  }

  /**
   * zeroOrOne
   *
   * Convierte el pixel de la imagen a blanco o negro
   * @param argb
   * @return Blanco(1) or Negro(0)
   */
  public static char toBitChar(int argb) {
    return toBitChar(argb, 127);
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
