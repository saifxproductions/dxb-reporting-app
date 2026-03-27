import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() async {
  final file = File('pdf/Apt 1904 Sobha Crest Grande.pdf');
  final document = PdfDocument(inputBytes: await file.readAsBytes());
  final text = PdfTextExtractor(document).extractText(startPageIndex: 0, endPageIndex: 0);
  print('--- EXTRACTED TEXT ---');
  print(text);
  print('----------------------');
  document.dispose();
}
