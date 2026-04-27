// import 'package:flutter_test/flutter_test.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';
// import 'dart:io';
//
// void main() {
//   test('extract image', () async {
//     PdfDocument document = PdfDocument(inputBytes: File('pdf/Apt 1904 Sobha Crest Grande.pdf').readAsBytesSync());
//     PdfImageExtractor extractor = PdfImageExtractor(document);
//     var images = extractor.extract(startPageIndex: 0, endPageIndex: 0);
//     print('Found ' + images.length.toString() + ' images on first page.');
//
//     // Also try counting blue text or snags
//     int count = 0;
//     for(int i = 1; i < document.pages.count; i++) {
//         var txt = PdfTextExtractor(document).extractText(startPageIndex: i, endPageIndex: i);
//         // Do we see snag or "blue heading"?
//         if(txt.contains("Snag")) count++;
//     }
//     print("Found snag texts on " + count.toString() + " pages.");
//   });
// }
