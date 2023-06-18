import 'package:encrypt/encrypt.dart' as encrypt;

// Fungsi untuk enkripsi
String encryptAES(String plainText, String keyString) {
  final key = encrypt.Key.fromUtf8(keyString);
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  final encrypted = encrypter.encrypt(plainText, iv: iv);
  return encrypted.base64;
}

// Fungsi untuk dekripsi
String decryptAES(String encryptedText, String keyString) {
  final key = encrypt.Key.fromUtf8(keyString);
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  final decrypted =
      encrypter.decrypt(encrypt.Encrypted.from64(encryptedText), iv: iv);
  return decrypted;
}

class key {
  static final String Crypto = 'dwskajfhsnshwjfnsthaksysndhstsnv';
}
