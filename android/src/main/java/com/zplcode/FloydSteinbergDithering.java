package com.zplcode;

public final class FloydSteinbergDithering implements Transform {

  @Override
  public PixelImage apply(PixelImage image) {
    final int width = image.getWidth();
    final int height = image.getHeight();

    final double factor1 = 7 / 16.0;
    final double factor2 = 3 / 16.0;
    final double factor3 = 5 / 16.0;
    final double factor4 = 1 / 16.0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int oldColor = image.getArgb(x, y);

        final int oldRed = Pixel.red(oldColor);
        final int oldGreen = Pixel.green(oldColor);
        final int oldBlue = Pixel.blue(oldColor);
        final int oldAlpha = Pixel.alpha(oldColor);

        final int newRed = (oldRed < 128) ? 0 : 255;
        final int newGreen = (oldGreen < 128) ? 0 : 255;
        final int newBlue = (oldBlue < 128) ? 0 : 255;
        final int newAlpha = (oldAlpha < 128) ? 0 : 255;

        final int newColor = Pixel.toRGB(newRed, newGreen, newBlue, newAlpha);
        image.setArgb(x, y, newColor);

        final int errorRed = oldRed - newRed;
        final int errorGreen = oldGreen - newGreen;
        final int errorBlue = oldBlue - newBlue;
        final int errorAlpha = oldAlpha - newAlpha;

        if (x < width - 1) {
          distributeError(image, x + 1, y, errorRed, errorGreen, errorBlue, errorAlpha, factor1);
        }

        if (x > 0 && y < height - 1) {
          distributeError(image, x - 1, y + 1, errorRed, errorGreen, errorBlue, errorAlpha, factor2);
        }

        if (y < height - 1) {
          distributeError(image, x, y + 1, errorRed, errorGreen, errorBlue, errorAlpha, factor3);
        }

        if (x < width - 1 && y < height - 1) {
          distributeError(image, x + 1, y + 1, errorRed, errorGreen, errorBlue, errorAlpha, factor4);
        }
      }
    }

    return image;
  }

  private static void distributeError(
    PixelImage image,
    int x,
    int y,
    int errorRed,
    int errorGreen,
    int errorBlue,
    int errorAlpha,
    double factor
  ) {
    final int currentColor = image.getArgb(x, y);

    int newRed = (int) (Pixel.red(currentColor) + errorRed * factor);
    int newGreen = (int) (Pixel.green(currentColor) + errorGreen * factor);
    int newBlue = (int) (Pixel.blue(currentColor) + errorBlue * factor);
    int newAlpha = (int) (Pixel.alpha(currentColor) + errorAlpha * factor);

    newRed = Math.min(255, Math.max(0, newRed));
    newGreen = Math.min(255, Math.max(0, newGreen));
    newBlue = Math.min(255, Math.max(0, newBlue));
    newAlpha = Math.min(255, Math.max(0, newAlpha));

    image.setArgb(x, y, Pixel.toRGB(newRed, newGreen, newBlue, newAlpha));
  }

}
