//
//  ZplLibGraphics.swift
//
//  Created by jbmx on 29/11/22.
//

import Foundation
import Compression

class ZplLibGraphics
{
  /* Imagen a convertir */
  private let pixels: PixelImage
  private let threshold: UInt8
  
  public init(pixels: PixelImage, threshold: UInt8)
  {
    self.pixels = pixels
    self.threshold = threshold
  }
  
  /**
   *  Reads in a sequence of bytes and prints out its 16 bit
   *  Cylcic Redundancy Check (CRC-CCIIT 0xFFFF).
   *
   *  1 + x + x^5 + x^12 + x^16 is irreducible polynomial.
   *
   */
  private static func getCRCHexString(_ bytes: [Character]) -> String
  {
    var crc: Int = 0x0000;           // initial value
    let polynomial: Int = 0x1021;    // 0001 0000 0010 0001  (0, 5, 12)
    
    for c in 0 ..< bytes.count
    {
      let character: Character = bytes[c];
      let b: UInt8 = character.asciiValue!
      
      for i in 0 ..< 8
      {
        let bit: Bool = ((b >> (7 - i) & 1) == 1);
        let c15: Bool = ((crc >> 15 & 1) == 1);
        crc <<= 1;

        if (c15 != bit)
        {
            crc ^= polynomial;
        }
      }
    }

    crc &= 0xffff;
    return String(format:"%2X", crc)
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
  func deflate(_ data: inout [UInt8]) -> Data
  {
    Utils.log("[ZplLibGraphics]", "deflate: \(data.count)")
    
    let deflater = DeflateStream()
    let (deflated, _) = deflater.write(&data, flush: true)
    return Data(bytes: deflated, count: deflated.count)
    
    // // Crear el búfer de destino
    // let dst_buffer = UnsafeMutablePointer<UInt8>.allocate(
    //  capacity: src_buffer.count)

    // // Comprimir los datos
    // let compressedSize = compression_encode_buffer(
    //  dst_buffer,
    //  src_buffer.count,
    //  &src_buffer,
    //  src_buffer.count,
    //  nil,
    //  COMPRESSION_LZ4  // Seleccione un algoritmo de compresión
    // )

    // return NSData(bytesNoCopy: dst_buffer, length: compressedSize)
  }
  
  /**
   * Obtiene el codigo zpl
   * - Parameter prefixAndSuffix ^XA...^XZ
   * - Returns cadena con el codigo zpl
   */
  public func getZplCode(x: Int, y: Int, prefixAndSuffix: Bool) -> String
  {
    Utils.log("[ZplLibGraphics]", "getZplCode -> x:\(x) y:\(y) prefixAndSuffix:\(prefixAndSuffix)")
    
    let width: Int = pixels.getWidth();
    let height: Int = pixels.getHeight();
    
    var data: [UInt8] = pixels.getRasterBytes(threshold: threshold);
    let bytesPerRow: Int = data.count / height;
    let binaryByteCount: Int = (width * height) / 8;
    
    // LZ77 compression
    //data = dataStatic()
    let deflate: Data = deflate(&data)
    
    // without compression
    let z64: String = (deflate.base64EncodedString())
    let crcString: String = ZplLibGraphics.getCRCHexString([Character](z64));
    
    
    // Label
    var zpl = String()
    
    // Start
    if (prefixAndSuffix) { zpl.append("^XA") }
    
    // Cordenadas
    zpl.append("^FO\(x),\(y)")
    
    zpl.append(
      "^GFA,\(binaryByteCount),\(binaryByteCount),\(bytesPerRow),"
    );
    zpl.append(":Z64:");
    zpl.append(z64);
    zpl.append(":");
    zpl.append(crcString);
    
    // End
    if (prefixAndSuffix) { zpl.append("^XZ"); }
    
    return zpl + "\n"
  }
  
}
