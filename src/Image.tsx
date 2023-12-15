import { NativeModules, Platform } from 'react-native';
import Element from './Element';

const LINKING_ERROR =
  `The package 'react-native-zpl-code' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const ZplCode = NativeModules.ZplCode
  ? NativeModules.ZplCode
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export interface ImageProps {
  /**
   * file://var/..
   * https://...
   */
  uri?: string 
  base64?: string,
  x?: number
  y?: number
  width: number
  height?: number
  dither?: boolean
}

export default class Image extends Element {
  public props: ImageProps

  constructor(props: ImageProps) {
    super()
    this.props = props
  }

  toZpl(): string {
    return ZplCode.imageToZpl(this.props);
  }
}