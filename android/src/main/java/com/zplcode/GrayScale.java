package com.zplcode;

/*
 Filtro: Escala de grises
 -  50    50    50   dark gray
 - 120   120   120   medium gray
 - 200   200   200   light gray
 - 250   200   200   not gray, reddish
 -   0     0     0   black (a sort of gray)
 - 255   255   255   white (ditto)
*/
public class GrayScale implements Filter {

  public final int r;
  public final int g;
  public final int b;

  public static final GrayScale DEFAULT = new GrayScale(30, 59, 11);
  public static final GrayScale DARK_GRAY = new GrayScale(50, 50, 50);
  public static final GrayScale MEDIUM_GRAY = new GrayScale(120, 120, 120);
  public static final GrayScale LIGHT_GRAY = new GrayScale(200, 200, 200);

  public GrayScale(int r, int g, int b) {
    this.r = r;
    this.g = g;
    this.b = b;
  }

  @Override
  public String toString() {
    return "GrayScale(r:"+r+" g:"+g+" b:"+b+")";
  }

  @Override
  public int pixel(int argb){
    final int a = Pixel.alpha(argb);

    final int rg = (int) (Pixel.red(argb) * this.r);
    final int gg = (int) (Pixel.green(argb) * this.g);
    final int bg = (int) (Pixel.blue(argb) * this.b);
    int totalColor = (rg + gg + bg) / 100;

    if (totalColor > 255) {
      totalColor = 255;
    } else if (totalColor < 0) {
      totalColor = 0;
    }

    int gray = totalColor;

    return Pixel.toRGB(gray, gray, gray, a);
  }

}
