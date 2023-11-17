export function formatToHex(ascii: number): string {
  const hexString = ascii.toString(16).toUpperCase(); // Convierte el número a una cadena hexadecimal en mayúsculas
  return hexString.padStart(2, '0'); // Asegura que la cadena tenga al menos dos caracteres, agregando ceros a la izquierda si es necesario
}

export function formatField(text: string): string {
  const sb: any[] = []
  
  for (var i = 0; i < text.length; i++) {
    const character: string = text.charAt(i);
    const ascii: number = text.charCodeAt(i);

    // Expresiones regulares para letra, número y espacio en blanco
    const regexLetra = /^[a-zA-Z]$/;
    const regexNumero = /^[0-9]$/;
    const regexEspacio = /^\s$/;

    // Validar el carácter
    if (regexLetra.test(character)) { // es letra
      sb.push(character)
    } else if (regexNumero.test(character)) { // es numero
      sb.push(character)
    } else if (regexEspacio.test(character)) { // es un espacio en blanco
      sb.push(character)
    } else {
      sb.push('\\')
      sb.push(formatToHex(ascii));
    }
  }
  
  return sb.join("");
}