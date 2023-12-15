package com.zplcode;

import android.util.Base64;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.zip.DeflaterOutputStream;

public class ZplLibGraphics {

  public final PixelImage pixels;

  public final int threshold;
  protected Integer x;
  protected Integer y;

  public ZplLibGraphics(PixelImage pixels, int threshold) {
    this.pixels = pixels;
    this.threshold = threshold;
  }

  public void setPoint(Integer x, Integer y) {
    this.x = x;
    this.y = y;
  }

  public String getBodyHeader(boolean insideFormat, int bytesPerRow, int binaryByteCount) {
    StringBuilder result = new StringBuilder();

    if (!insideFormat) result.append("^XA");

    if (x != null && y != null) {
      result.append("^FO").append(x).append(",").append(y);
    }

    result.append("^GFA").append(",");
    result.append(binaryByteCount).append(",");
    result.append(binaryByteCount).append(",");
    result.append(bytesPerRow).append(",");

    return result.toString();
  }

  /**
   *  Reads in a sequence of bytes and prints out its 16 bit
   *  Cylcic Redundancy Check (CRC-CCIIT 0xFFFF).
   *
   *  1 + x + x^5 + x^12 + x^16 is irreducible polynomial.
   *
   */
  public static String getCRCHexString(String bytes)
  {
    int crc = 0x0000;           // initial value
    final int polynomial = 0x1021;    // 0001 0000 0010 0001  (0, 5, 12)
    for (int c = 0; c < bytes.length() ; c++)
    {
      final byte b = (byte) bytes.charAt(c);
      for (int i = 0; i < 8; i++)
      {
        boolean bit = ((b >> (7 - i) & 1) == 1);
        boolean c15 = ((crc >> 15 & 1) == 1);
        crc <<= 1;

        if (c15 ^ bit)
        {
          crc ^= polynomial;
        }
      }
    }

    crc &= 0xffff;
    return Integer.toHexString(crc);
  }


  /**
   * Comprime con el algoritmo zlib que es una abstracción
   * del algoritmo DEFLATE.
   *
   * @param data datos a comprimir
   * @return datos comprimidos
   *
   * @throws java.io.IOException
   */
  public byte[] deflate(byte[] data) throws IOException {
    DeflaterOutputStream deflaterOutputStream = null;
    try {
      final ByteArrayOutputStream compressedImage = new ByteArrayOutputStream(data.length);

      deflaterOutputStream = new DeflaterOutputStream(compressedImage);
      deflaterOutputStream.write(data, 0, data.length);
      deflaterOutputStream.finish();

      return compressedImage.toByteArray();

    } finally {
      if (deflaterOutputStream != null) {
        deflaterOutputStream.close();
      }
    }
  }

  public String getZplCode(boolean insideFormat) throws IOException {
    final int width = pixels.getWidth();
    final int height = pixels.getHeight();
    final byte[] rasterBytes = pixels.getRasterBytes(threshold);

    // LZ77 compression
    final byte[] deflate = deflate(rasterBytes);

    // without compression
    final String z64 = Base64.encodeToString(deflate, Base64.DEFAULT);
    final String crcString = getCRCHexString(z64);

    final int bytesPerRow = rasterBytes.length / height;
    final int binaryByteCount = (width * height) / 8;

    final StringBuilder zpl = new StringBuilder();
    zpl.append(getBodyHeader(insideFormat, bytesPerRow, binaryByteCount));
    zpl.append(":Z64:");
    zpl.append(z64);
    zpl.append(":");
    zpl.append(crcString);
    if (!insideFormat) zpl.append("^XZ");
    return zpl.toString();
  }


}
