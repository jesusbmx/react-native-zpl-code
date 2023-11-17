import Element from "./Element";
import Image, { type ImageProps } from "./Image";
import { formatField } from "./Utils";

module Zpl {

  export type FontType = 'ZERO' | 'A' | 'B' | 'C' | 'D' | 'F' | 'G';
  export type RotationType = 'NORMAL' | 'ROTATE_90' | 'INVERTED' | 'READ_FROM_BOTTOM';
  export type AlignmentType = 'LEFT' | 'CENTER' | 'RIGHT' | 'JUSTIFIED';
  export type JustificationType = 0 | 1 | 2;
  export type MediaTrackingType = 'CONTINUOUS' | 'NO_CONTINUOUS' | 'WEB_SENSING' | 'MARK_SENSING';
  export type PrintOrientationType = 'NORMAL' | 'INVERT';
  export type BarcodeTxtType = 'NOT' | 'YES';
  export type QRCodeModelType = '1' | '2';
  export type QRErrorCorrectionLevelType = 'H' | 'Q' | 'M' | 'L';

  const fontValues: Record<FontType, string> = {
    'ZERO': '0',
    'A': 'A',
    'B': 'B',
    'C': 'C',
    'D': 'D',
    'F': 'F',
    'G': 'G',
  };

  const rotationValues: Record<RotationType, string> = {
    'NORMAL': 'N',
    'ROTATE_90': 'R',
    'INVERTED': 'I',
    'READ_FROM_BOTTOM': 'B',
  };

  const alignmentValues: Record<AlignmentType, string> = {
    'LEFT': 'L',
    'CENTER': 'C',
    'RIGHT': 'R',
    'JUSTIFIED': 'J',
  };

  const justificationValues: Record<JustificationType, string> = {
    0: 'LEFT',
    1: 'RIGHT',
    2: 'AUTO',
  };

  const mediaTrackingValues: Record<MediaTrackingType, string> = {
    'CONTINUOUS': 'N',
    'NO_CONTINUOUS': 'Y',
    'WEB_SENSING': 'W',
    'MARK_SENSING': 'M',
  };

  const printOrientationValues: Record<PrintOrientationType, string> = {
    'NORMAL': 'N',
    'INVERT': 'I',
  };

  const barcodeTxtValues: Record<BarcodeTxtType, string> = {
    'NOT': 'N',
    'YES': 'Y',
  };

  const qrCodeModelValues: Record<QRCodeModelType, number> = {
    '1': 49,
    '2': 50,
  };

  const qrErrorCorrectionLevelValues: Record<QRErrorCorrectionLevelType, string> = {
    'H': 'H',
    'Q': 'Q',
    'M': 'M',
    'L': 'L',
  };

  export class Builder {
    
    private elements: any[] = []

    push(command: any): this {
      this.elements.push(command)
      return this
    }

    /**
     * Configuración para la etiqueta
     * @param props 
     * @returns 
     */
    setup(props: {
      size?: {
        heightDots: number,
        widthDots: number,
      },
      labelHome?: {
        x: number, 
        y: number
      },
      labelTop?: number,
      labeShift?: number,
      orientation?: PrintOrientationType,
      media?: {
        type: MediaTrackingType,
        dots?: number
      },
    }): this {

      const { size, labelHome, media } = props

      if (size) {
        this.push(`^LL${size.heightDots}`);
        this.push(`^PW${size.widthDots}`);
      }

      if (labelHome) {
        this.push(`^LH${labelHome.x},${labelHome.y}`);
      }

      if (props.labelTop) {
        this.push(`^LT${props.labelTop}`);
      }

      if (props.labeShift) {
        this.push(`^LS${props.labeShift}`);
      }

      if (media) {
        var cmd = `^MN${mediaTrackingValues[media.type]}`
    
        if (media.dots != null && media.type != 'CONTINUOUS') {
          cmd = cmd + "," + media.dots;
        }

        this.push(cmd);
      }
      
      if (props.orientation) {
        this.push(`^PO${printOrientationValues[props.orientation]}`);
      }

      return this;
    }

    /**
     * Fuente
     */  
    font(props: {
      type: FontType;
      w: number;
      h: number;
    }): this {
      return this.push(`^CF${fontValues[props.type]},${props.h},${props.w}`);
    }

    /**
     * Cordenada
     */
    point(props: {
      x: number;
      y: number;
      justification?: JustificationType;
    }): this {
      let command = `^FO${props.x},${props.y}`
      
      if (props.justification) {
        command = command + `,${justificationValues[props.justification]}`
      }

      return this.push(command)
    }

    /**
     * Agrega un texto 
     */
    text(props: {
      x: number;
      y: number;
      font?: {
        type: FontType;
        h: number; 
        w: number;
      },
      text: string;
      justification?: JustificationType;
    }): this {

      const { font } = props

      this.point({
        x: props.x,
        y: props.y,
        justification: props.justification
      })

      if (font) {
        this.push(`^A${fontValues[font.type]}N,${font.h},${font.w}`);
      }

      this.push(`^FH\\^FD${formatField(props.text)}^FS`);
      return this
    }

    /**
     * Agrega un texto en formato block
     */
    textBlock(
      props: {
        x: number;
        y: number;
        font?: {
          type: FontType;
          h: number; 
          w: number;
        },
        text: string;
        width: number;
        numLines: number;
        textJustification?: AlignmentType; 
      }
    ): this {

      const { font } = props
      const textJustification: AlignmentType = props.textJustification ?? 'LEFT'

      this.push(`^FO${props.x},${props.y}`)

      if (font) {
        this.push(`^A${fontValues[font.type]}N,${font.h},${font.w}`);
      }

      this.push(`^FB${props.width},${props.numLines},1,${alignmentValues[textJustification]},0`);
      this.push(`^FH\\^FD${formatField(props.text)}^FS`);
      return this
    }

    /**
     * Agrega un codigo de barra 128
     * @param props 
     * @returns 
     */
    barcode128(props: {
      x: number;
      y: number;
      height: number;
      barcodeTxt: BarcodeTxtType; 
      rotation: RotationType;
      width: number;
      text: string;
    }): this {

      this.push(`^FO${props.x},${props.y}`)
      this.push(`^BY${props.width}`)
      this.push(`^BC${rotationValues[props.rotation]},${props.height},${barcodeTxtValues[props.barcodeTxt]},N,N`)
      this.push(`^FH\\^FD${formatField(props.text)}^FS`);
      return this;
    }

    /**
     * Agrega un codigo QR
     * @param props 
     * @returns 
     */
    qrcode(props: {
      x: number;
      y: number;
      model?: QRCodeModelType; 
      size: number;
      errorLevel?: QRErrorCorrectionLevelType; 
      text: string;
      characterMode?: string;
    }): this {

      const model: QRCodeModelType = props.model ?? '2'
      const errorLevel: QRErrorCorrectionLevelType = props.errorLevel ??'M'
      const characterMode = props.characterMode ?? "A"

      this.push(`^FO${props.x},${props.y}^BQN,${qrCodeModelValues[model]},${props.size}`);
      this.push(`^FH\\^FD${qrErrorCorrectionLevelValues[errorLevel]}${characterMode},${formatField(props.text)}^FS`);
      return this;
    }

    /**
     * Dibuja un rectangulo.
     *
     * ^FO500,300^GB170,170,1^FS
     */
    rectangle(props: {
      x: number;
      y: number;
      w: number;
      h: number;
      line: number;
    }): this {
      this.push(`^FO${props.x},${props.y}`)
      this.push(`^GB${props.w},${props.h},${props.line}^FS`)
      return this
    }

    /**
     * Agrega una linea
     * 
     * ^FO50,500^GB700,1,3^FS
     * 
     * @param x
     * @param y
     * @param w
     * @param line
     */
    bar(props: {
      x: number;
      y: number;
      w: number;
      h: number;
      line: number;
    }): this {
      return this.rectangle({
        x: props.x, 
        y: props.y, 
        w: props.w, 
        h: 1, 
        line: props.line
      });
    }

    /**
     * Agrega una imagen
     * @param props 
     * @returns 
     */
    image(props: ImageProps): this {
      return this.push(new Image(props));
    }

    /**
     * Genera el codigo zpl
     * 
     * @param prefixAndSufix 
     * @returns 
     */
    async build(prefixAndSufix = true): Promise<string> {
      const result: any[] = [];

      for (const element of this.elements) {
        const zpl = element instanceof Element ? await element.toZpl() : element;
        result.push(zpl);
      }

      const zplString = result.join("\n");

      return prefixAndSufix ? `^XA\n${zplString}\n^XZ` : zplString;
    }
  }

}


export default Zpl