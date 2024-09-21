import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';

void main() {
  runApp(TextEncryptionApp());
}

class TextEncryptionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Encryption',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: EncryptionScreen(),
    );
  }
}

class EncryptionScreen extends StatefulWidget {
  @override
  _EncryptionScreenState createState() => _EncryptionScreenState();
}

class _EncryptionScreenState extends State<EncryptionScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _keyController =
      TextEditingController(text: 'my32lengthsupersecretnooneknows1');
  String _encryptedText = '';
  String _decryptedText = '';
  String _selectedAlgorithm = 'AES';
  final iv = encrypt.IV.fromLength(16);

  void _encryptText() {
    final key =
        encrypt.Key.fromUtf8(_keyController.text.padRight(32).substring(0, 32));
    final encrypter = _selectedAlgorithm == 'AES'
        ? encrypt.Encrypter(encrypt.AES(key))
        : encrypt.Encrypter(encrypt.Salsa20(key));

    final encrypted = encrypter.encrypt(_textController.text, iv: iv);
    setState(() {
      _encryptedText = encrypted.base64;
    });
  }

  void _decryptText() {
    final key =
        encrypt.Key.fromUtf8(_keyController.text.padRight(32).substring(0, 32));
    final encrypter = _selectedAlgorithm == 'AES'
        ? encrypt.Encrypter(encrypt.AES(key))
        : encrypt.Encrypter(encrypt.Salsa20(key));

    final decrypted = encrypter.decrypt64(_encryptedText, iv: iv);
    setState(() {
      _decryptedText = decrypted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text Encryption'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: 'Enter text to encrypt',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _keyController,
                decoration: InputDecoration(
                  labelText: 'Enter encryption key',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: _selectedAlgorithm,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAlgorithm = newValue!;
                  });
                },
                items: <String>['AES', 'Salsa20']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _encryptText,
                child: Text('Encrypt'),
              ),
              SizedBox(height: 20),
              if (_encryptedText.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Encrypted Text:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SelectableText(_encryptedText),
                  ],
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _decryptText,
                child: Text('Decrypt'),
              ),
              SizedBox(height: 20),
              if (_decryptedText.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Decrypted Text:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SelectableText(_decryptedText),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
