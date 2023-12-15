import * as React from 'react';
import { StyleSheet, View, Text, Button } from 'react-native';
import DocumentPicker from 'react-native-document-picker';

import { Zpl } from 'react-native-zpl-code';

export default function App() {
  const [result, setResult] = React.useState<string | undefined>();

  const generateWithImage = async (uri: string) => {
    console.debug("generateWithImage", uri)
    // Create a ZPL builder instance
    const zplBuilder = new Zpl.Builder();

    // Setup label configuration
    zplBuilder.setup({
      size: {
        heightDots: 609,
        widthDots: 609,
      },
      labelHome: {
        x: 0,
        y: 0,
      },
      labelTop: 0,
      labeShift: 0,
      orientation: 'NORMAL',
      media: {
        type: 'MARK_SENSING',
        dots: 24,
      },
    });

    // Add text
    zplBuilder.text({
      x: 50,
      y: 50,
      font: {
        type: 'A',
        h: 20,
        w: 10,
      },
      text: 'Hello, ZPL!',
      justification: 0,
    });

    // Add barcode 128
    zplBuilder.barcode128({
      x: 50,
      y: 100,
      height: 50,
      barcodeTxt: 'YES',
      rotation: 'NORMAL',
      width: 2,
      text: '123456',
    });

    // Add QR code
    zplBuilder.qrcode({
      x: 50,
      y: 200,
      model: '2',
      size: 5,
      errorLevel: 'M',
      text: 'https://example.com',
    });

    // Add rectangle
    zplBuilder.rectangle({
      x: 50,
      y: 400,
      w: 200,
      h: 100,
      line: 2,
    });

    // Add image
    zplBuilder.image({
      uri: uri,
      x: 330,
      y: 350,
      width: 192,
      height: 192,
      dither: true,
    });

    // Generate ZPL code
    const zplCode = await zplBuilder.build();
    console.log(zplCode);
    return zplCode;
  }

  const pickImageFile = async () => {
    try {
      const uri = "https://s-media-cache-ak0.pinimg.com/236x/ac/bb/d4/acbbd49b22b8c556979418f6618a35fd.jpg"
      /*const { uri } = await DocumentPicker.pickSingle({
        type: [DocumentPicker.types.images],
      });*/
      
      generateWithImage(uri)
        .then(setResult)  
        .catch(error => console.error(error))

    } catch (err) {
      if (DocumentPicker.isCancel(err)) {
        // User cancelled the picker, exit any dialogs or menus and move on
      } else {
        console.error(err)
      }
    }
  }

  return (
    <View style={styles.container}>
      <Button onPress={pickImageFile} title='Select Image' />
      <Text selectable={true}>Zpl: {result}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
