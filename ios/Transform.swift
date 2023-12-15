//
//  Transform.swift
//
//  Created by Jesus on 22/11/22.
//
import Foundation
import UIKit

public protocol Transform
{
  func apply(_ image: PixelImage) -> PixelImage
}

/*
 Floyd-Steinberg Dithering:
 
    Ventajas:
        Produce imágenes de alta calidad con transiciones suaves entre colores.
        Relativamente fácil de entender e implementar.

    Desventajas:
        Puede ser computacionalmente costoso.
 
 "Floyd-Steinberg Dithering" y los algoritmos de "Error Diffusion Dithering" tienden
 a producir resultados más satisfactorios en términos de calidad de imagen.
 */
public class FloydSteinbergDithering: NSObject, Transform
{
  public override var description: String {
    return "FloydSteinbergDithering()"
  }
  
  /*
   * False Floyd-Steinberg Dithering
   *
   * X 3
   * 3 2
   *
   * (1/8)
   */
  public func apply(_ img: PixelImage) -> PixelImage
  {
    var image = img
    let width = image.getWidth()
    let height = image.getHeight()
    
    let factor1 = 7 / 16.0;
    let factor2 = 3 / 16.0;
    let factor3 = 5 / 16.0;
    let factor4 = 1 / 16.0;

    for y in 0 ..< height {
        for x in 0 ..< width {
          let oldColor = image.getArgb(x: x, y: y)

          let oldRed = Pixel.red(oldColor)
          let oldGreen = Pixel.green(oldColor)
          let oldBlue = Pixel.blue(oldColor)
          let oldAlpha = Pixel.alpha(oldColor)

          let newRed = (oldRed < 128) ? 0 : 255
          let newGreen = (oldGreen < 128) ? 0 : 255
          let newBlue = (oldBlue < 128) ? 0 : 255
          let newAlpha = (oldAlpha < 128) ? 0 : 255

          let newColor = Pixel.toArgb(red: newRed, green: newGreen, blue: newBlue, alpha: newAlpha)
          image.setArgb(x: x, y: y, newColor)

          let errorRed = oldRed - newRed
          let errorGreen = oldGreen - newGreen
          let errorBlue = oldBlue - newBlue
          let errorAlpha = oldAlpha - newAlpha

          if x < width - 1 {
              distributeError(&image, x + 1, y, errorRed, errorGreen, errorBlue, errorAlpha, factor1)
          }

          if x > 0 && y < height - 1 {
              distributeError(&image, x - 1, y + 1, errorRed, errorGreen, errorBlue, errorAlpha, factor2)
          }

          if y < height - 1 {
              distributeError(&image, x, y + 1, errorRed, errorGreen, errorBlue, errorAlpha, factor3)
          }

          if x < width - 1 && y < height - 1 {
              distributeError(&image, x + 1, y + 1, errorRed, errorGreen, errorBlue, errorAlpha, factor4)
          }
        }
    }

    return image
  }
  
  private func distributeError(
    _ image: inout PixelImage,
    _ x: Int,
    _ y: Int,
    _ errorRed: Int,
    _ errorGreen: Int,
    _ errorBlue: Int,
    _ errorAlpha: Int,
    _ factor: Double
  ) {
    let currentColor = image.getArgb(x: x, y: y)
    var newRed = Int(Double(Pixel.red(currentColor)) + Double(errorRed) * factor)
    var newGreen = Int(Double(Pixel.green(currentColor)) + Double(errorGreen) * factor)
    var newBlue = Int(Double(Pixel.blue(currentColor)) + Double(errorBlue) * factor)
    var newAlpha = Int(Double(Pixel.alpha(currentColor)) + Double(errorAlpha) * factor)

    newRed = min(255, max(0, newRed))
    newGreen = min(255, max(0, newGreen))
    newBlue = min(255, max(0, newBlue))
    newAlpha = min(255, max(0, newAlpha))

    image.setArgb(x: x, y: y, Pixel.toArgb(
        red: newRed, green: newGreen, blue: newBlue, alpha: newAlpha))
  }

}

/*
 El "Sierra Dithering" pertenece a la categoría de algoritmos de difusión de errores,
 al igual que el "Floyd-Steinberg Dithering" y otros. Especificamente, "Sierra Dithering"
 es un tipo de algoritmo de difusión de errores utilizado para el dithering de imágenes.
 */
public class SierraDithering: NSObject, Transform
{
  public override var description: String {
    return "SierraDithering()"
  }
  
  /*
   * Sierra Dithering
   *
   *     X 5 3
   * 2 4 5 4 2
   *   2 3 2
   *
   * (1/32)
   */
  public func apply(_ img: PixelImage) -> PixelImage
  {
    var alpha: Int
    var red: Int
    var gray: Int
    var pixel: Int

    let width: Int = img.getWidth();
    let height: Int = img.getHeight();
    
    var error: Int = 0;
    var errors = Array(repeating: Array(repeating: 0, count: width), count: height)
    
    for y in 0 ..< height
    {
      for x in 0 ..< width
      {
        pixel = img.getArgb(x: x, y: y)

        alpha = Pixel.alpha(pixel);
        red = Pixel.red(pixel);

        gray = red;
        if (gray + errors[x][y] < 127) {
          error = gray + errors[x][y];
          gray = 0;
        } else {
          error = gray + errors[x][y] - 255;
          gray = 255;
        }

        errors[x + 1][y] += (5 * error) / 32;
        errors[x + 2][y] += (3 * error) / 32;

        errors[x - 2][y + 1] += (2 * error) / 32;
        errors[x - 1][y + 1] += (4 * error) / 32;
        errors[x][y + 1] += (5 * error) / 32;
        errors[x + 1][y + 1] += (4 * error) / 32;
        errors[x + 2][y + 1] += (2 * error) / 32;

        errors[x - 1][y + 2] += (2 * error) / 32;
        errors[x][y + 2] += (3 * error) / 32;
        errors[x + 1][y + 2] += (2 * error) / 32;

        img[x, y] = Pixel.toArgb(
          red: gray, green: gray, blue: gray, alpha: alpha
        )
      }
    }

    return img
  }
}

/*
 Ordered Dithering:

     Ventajas:
         Relativamente rápido y eficiente.
         Proporciona resultados predecibles y repetibles.
         Menos complejo que algunos algoritmos de difusión de errores.

     Desventajas:
         Puede introducir patrones perceptibles, especialmente en áreas homogéneas.
 */
public class OrderedDithering: NSObject, Transform {
        
    /*se utiliza una matriz de dithering simple de 2x2*/
    public static let ditherMatrix_2x2: [[Double]] = [
        [1.0 / 5.0, 3.0 / 5.0],
        [4.0 / 5.0, 2.0 / 5.0]
    ]
  
    /*se utiliza una matriz de dithering simple de 4x4*/
    public static  let ditherMatrix_4x4: [[Double]] = [
        [1.0 / 17.0, 9.0 / 17.0, 3.0 / 17.0, 11.0 / 17.0],
        [13.0 / 17.0, 5.0 / 17.0, 15.0 / 17.0, 7.0 / 17.0],
        [4.0 / 17.0, 12.0 / 17.0, 2.0 / 17.0, 10.0 / 17.0],
        [16.0 / 17.0, 8.0 / 17.0, 14.0 / 17.0, 6.0 / 17.0]
    ]
  
    /*se utiliza una matriz de dithering simple de 8x8*/
    public static  let ditherMatrix_8x8: [[Double]] = [
          [1.0 / 65.0, 49.0 / 65.0, 13.0 / 65.0, 61.0 / 65.0, 4.0 / 65.0, 52.0 / 65.0, 16.0 / 65.0, 64.0 / 65.0],
          [33.0 / 65.0, 17.0 / 65.0, 45.0 / 65.0, 29.0 / 65.0, 36.0 / 65.0, 20.0 / 65.0, 48.0 / 65.0, 32.0 / 65.0],
          [9.0 / 65.0, 57.0 / 65.0, 5.0 / 65.0, 53.0 / 65.0, 12.0 / 65.0, 60.0 / 65.0, 8.0 / 65.0, 56.0 / 65.0],
          [41.0 / 65.0, 25.0 / 65.0, 37.0 / 65.0, 21.0 / 65.0, 44.0 / 65.0, 28.0 / 65.0, 40.0 / 65.0, 24.0 / 65.0],
          [3.0 / 65.0, 51.0 / 65.0, 15.0 / 65.0, 63.0 / 65.0, 2.0 / 65.0, 50.0 / 65.0, 14.0 / 65.0, 62.0 / 65.0],
          [35.0 / 65.0, 19.0 / 65.0, 47.0 / 65.0, 31.0 / 65.0, 34.0 / 65.0, 18.0 / 65.0, 46.0 / 65.0, 30.0 / 65.0],
          [11.0 / 65.0, 59.0 / 65.0, 7.0 / 65.0, 55.0 / 65.0, 10.0 / 65.0, 58.0 / 65.0, 6.0 / 65.0, 54.0 / 65.0],
          [43.0 / 65.0, 27.0 / 65.0, 39.0 / 65.0, 23.0 / 65.0, 42.0 / 65.0, 26.0 / 65.0, 38.0 / 65.0, 22.0 / 65.0]
    ]
  
    private let ditherMatrix: [[Double]]

    init(_ ditherMatrix: [[Double]]) {
      self.ditherMatrix = ditherMatrix
    }

    public override var description: String {
        return "OrderedDithering()"
    }
    
    public func apply(_ img: PixelImage) -> PixelImage {
        var image = img
        let width = image.getWidth()
        let height = image.getHeight()
        
        for y in 0..<height {
            for x in 0..<width {
                let oldColor = image.getArgb(x: x, y: y)
                let oldRed = Pixel.red(oldColor)
                let oldGreen = Pixel.green(oldColor)
                let oldBlue = Pixel.blue(oldColor)
                let oldAlpha = Pixel.alpha(oldColor)

                let threshold = ditherMatrix[x % 2][y % 2]

                let newRed = (Double(oldRed) / 255.0 < threshold) ? 0 : 255
                let newGreen = (Double(oldGreen) / 255.0 < threshold) ? 0 : 255
                let newBlue = (Double(oldBlue) / 255.0 < threshold) ? 0 : 255
                let newAlpha = (Double(oldAlpha) / 255.0 < threshold) ? 0 : 255

                let newColor = Pixel.toArgb(red: Int(newRed), green: Int(newGreen), blue: Int(newBlue), alpha: Int(newAlpha))
                image.setArgb(x: x, y: y, newColor)
            }
        }
        
        return image
    }
}


/*
 Halftone Dithering:

     Utilizado en impresión para simular niveles de gris.
 
     Ventajas:
        Efectivo en el contexto de la impresión en blanco y negro.
 
     Desventajas:
        Puede no ser tan efectivo para imágenes que se visualizarán principalmente en pantalla.
 */
public class HalftoneDitheringNoSirve: NSObject, Transform {
    public override var description: String {
        return "HalftoneDithering()"
    }
    
    private let halftoneMatrix: [[Double]] = [
        [1, 9, 3, 11],
        [13, 5, 15, 7],
        [4, 12, 2, 10],
        [16, 8, 14, 6]
    ]
    
    public func apply(_ img: PixelImage) -> PixelImage {
        var image = img
        let width = image.getWidth()
        let height = image.getHeight()
        
        for y in 0..<height {
            for x in 0..<width {
                let oldColor = image.getArgb(x: x, y: y)
                let oldRed = Pixel.red(oldColor)
                let oldGreen = Pixel.green(oldColor)
                let oldBlue = Pixel.blue(oldColor)
                let oldAlpha = Pixel.alpha(oldColor)

                let threshold = halftoneMatrix[x % 4][y % 4]

                let newRed = (Double(oldRed) / 255.0 < threshold) ? 0 : 255
                let newGreen = (Double(oldGreen) / 255.0 < threshold) ? 0 : 255
                let newBlue = (Double(oldBlue) / 255.0 < threshold) ? 0 : 255
                let newAlpha = (Double(oldAlpha) / 255.0 < threshold) ? 0 : 255

                let newColor = Pixel.toArgb(red: Int(newRed), green: Int(newGreen), blue: Int(newBlue), alpha: Int(newAlpha))
                image.setArgb(x: x, y: y, newColor)
            }
        }
        
        return image
    }
}

public class HalftoneDithering: NSObject, Transform {
  
    private let threshold: UInt8
  
    public init(threshold: UInt8)
    {
      self.threshold = threshold
    }
    
    public override var description: String {
        return "HalftoneDithering()"
    }

    public func apply(_ image: PixelImage) -> PixelImage {
        let width = image.getWidth()
        let height = image.getHeight()

        for y in 0 ..< height {
            for x in 0 ..< width {
                let oldColor = image.getArgb(x: x, y: y)
                let grayLevel = computeGrayLevel(oldColor)

                // Aplica lógica de Halftone Dithering según el nivel de gris
              
                //Pixel.white : Pixel.black
                //0xffffffff : 0xff000000
                let newColor = (grayLevel < threshold) ? 0xff000000 : 0xffffffff
              
                image.setArgb(x: x, y: y, newColor)
            }
        }
      
        return image
    }

    private func computeGrayLevel(_ color: Int) -> Int {
        // Calcula el nivel de gris basado en el color (puede variar según tu implementación)
        let red = Pixel.red(color)
        let green = Pixel.green(color)
        let blue = Pixel.blue(color)
        return (red + green + blue) / 3
    }
}
