import 'package:diagnosa/config/crypto.dart';

import 'service/excellent.dart';

class Config {
  static final String apiUrl =
      'https://api.sistempakarlambung.masuk.web.id/apiv3/index.php';
  // Anda bisa menambahkan variabel konfigurasi lainnya di sini.
}

class name {
  static final String body =
      "FOtBDubh430gDBhEGyQXAPZSghI2evUqaTRCzpI0Nv1JEAwUUowLtv/RxIcAEZd5iBmlwokcJR7hEjtYgJ1vXA==";

  static final String title = "FOtBDubh430gORNSEXENBu02+HNaHNYFC1QlrvMbSpc=";
}

class link {
  static final String to = decryptAES(Address.footer, key.Crypto);
}
