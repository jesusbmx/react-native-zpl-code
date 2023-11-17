package com.zplcode;

public final class Dither implements Transform {

  @Override
  public PixelImage apply(PixelImage img) {
    int w = img.getWidth();
    int h = img.getHeight();

    Pixel[][] d = new Pixel[h][w];

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        d[y][x] = new Pixel(img.getPixel(x, y));
      }
    }

    for (int y = 0; y < img.getHeight(); y++) {
      for (int x = 0; x < img.getWidth(); x++) {

        Pixel oldColor = d[y][x];
        Pixel newColor = Pixel.findClosestPaletteColor(oldColor, Pixel.palette);
        img.setPixel(x, y, newColor.toRGB());

        Pixel err = oldColor.sub(newColor);

        if (x + 1 < w) {
          d[y][x + 1] = d[y][x + 1].add(err.mul(7. / 16));
        }

        if (x - 1 >= 0 && y + 1 < h) {
          d[y + 1][x - 1] = d[y + 1][x - 1].add(err.mul(3. / 16));
        }

        if (y + 1 < h) {
          d[y + 1][x] = d[y + 1][x].add(err.mul(5. / 16));
        }

        if (x + 1 < w && y + 1 < h) {
          d[y + 1][x + 1] = d[y + 1][x + 1].add(err.mul(1. / 16));
        }
      }
    }

    return img;
  }

}
