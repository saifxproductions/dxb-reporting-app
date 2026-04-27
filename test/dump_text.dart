import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  PdfDocument document = PdfDocument(inputBytes: File('pdf/Apt 1904 Sobha Crest Grande.pdf').readAsBytesSync());
  if (document.pages.count > 1) {
    String text1 = PdfTextExtractor(document).extractText(startPageIndex: 1, endPageIndex: 1);
    print("PAGE 2 TEXT:");
    print(text1.substring(0, text1.length > 1000 ? 1000 : text1.length));
  }
}
