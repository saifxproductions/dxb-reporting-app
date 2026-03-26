// // import 'dart:io';
// // import 'package:flutter/services.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'package:share_plus/share_plus.dart';
// // import 'package:syncfusion_flutter_pdf/pdf.dart';
// //
// // class PdfGeneratorService {
// //   static Future<void> generateAndMergePdf({
// //     required String age,
// //     required String address,
// //     required String date,
// //     required String inspectedFor,
// //     required String inspectedBy,
// //     required String uploadedPdfPath,
// //     String? propertyPhotoPath,
// //   }) async {
// //     final PdfDocument newDoc = PdfDocument();
// //
// //     // Configure document settings for our generated pages
// //     newDoc.pageSettings.size = PdfPageSize.a4;
// //     newDoc.pageSettings.margins.all = 0;
// //
// //     // Load fonts
// //     final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 24, style: PdfFontStyle.bold);
// //     final PdfFont headingFont = PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold);
// //     final PdfFont bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
// //     final PdfFont bodyBoldFont = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
// //
// //     // --- PAGE 1: COVER PAGE ---
// //     final PdfPage page1 = newDoc.pages.add();
// //     try {
// //       final ByteData imageData = await rootBundle.load('assets/title.png');
// //       final Uint8List imageBytes = imageData.buffer.asUint8List();
// //       final PdfBitmap coverImage = PdfBitmap(imageBytes);
// //       page1.graphics.drawImage(coverImage,
// //           Rect.fromLTWH(0, 0, page1.getClientSize().width, page1.getClientSize().height));
// //     } catch (_) {
// //       // Fallback
// //       page1.graphics.drawRectangle(
// //           brush: PdfSolidBrush(PdfColor(0, 191, 165)),
// //           bounds: Rect.fromLTWH(0, 0, page1.getClientSize().width, page1.getClientSize().height));
// //       page1.graphics.drawString(
// //         'PROPERTY INSPECTION\nREPORT CARD\n(Placeholder for assets/title.png)',
// //         titleFont, brush: PdfBrushes.white,
// //         bounds: Rect.fromLTWH(0, 0, page1.getClientSize().width, page1.getClientSize().height),
// //         format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
// //       );
// //     }
// //
// //     // --- PAGE 2: DYNAMIC FIELDS WITH PHOTO ---
// //     final PdfPage page2 = newDoc.pages.add();
// //     double yPos = 20;
// //
// //     final Rect imageRect = Rect.fromLTWH(0, yPos, page2.getClientSize().width, 250);
// //     if (propertyPhotoPath != null && propertyPhotoPath.isNotEmpty) {
// //       try {
// //         final File photoFile = File(propertyPhotoPath);
// //         final Uint8List photoBytes = await photoFile.readAsBytes();
// //         final PdfBitmap propertyImage = PdfBitmap(photoBytes);
// //         page2.graphics.drawImage(propertyImage, imageRect);
// //       } catch (e) {
// //         page2.graphics.drawRectangle(pen: PdfPen(PdfColor(0, 0, 0), width: 3), bounds: imageRect);
// //         page2.graphics.drawString('Error loading property photo', bodyFont,
// //             bounds: imageRect, format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle));
// //       }
// //     } else {
// //       page2.graphics.drawRectangle(pen: PdfPen(PdfColor(0, 0, 0), width: 3), bounds: imageRect);
// //       page2.graphics.drawString('Property Image Placeholder', bodyFont,
// //           bounds: imageRect, format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle));
// //     }
// //     yPos += 270;
// //
// //     // Center text box for Age
// //     page2.graphics.drawString('Age: $age', headingFont,
// //       bounds: Rect.fromLTWH(0, yPos, page2.getClientSize().width, 30),
// //       format: PdfStringFormat(alignment: PdfTextAlignment.center)
// //     );
// //     yPos += 50;
// //
// //     // Fields
// //     _drawField(page2.graphics, 'Property Address:', address, yPos, bodyBoldFont, bodyFont);
// //     yPos += 25;
// //     _drawField(page2.graphics, 'Inspection Date:', date, yPos, bodyBoldFont, bodyFont);
// //     yPos += 25;
// //     _drawField(page2.graphics, 'Inspected for:', inspectedFor, yPos, bodyBoldFont, bodyFont);
// //     yPos += 25;
// //     _drawField(page2.graphics, 'Inspected by:', inspectedBy, yPos, bodyBoldFont, bodyFont);
// //
// //     // --- PAGE 3: INTRODUCTION ---
// //     final PdfPage page3 = newDoc.pages.add();
// //     page3.graphics.drawString('INTRODUCTION', headingFont,
// //         bounds: Rect.fromLTWH(0, 0, page3.getClientSize().width, 30));
// //
// //     final String introText = '''The purpose of the snagging inspection is to visually examine... (Placeholder static introduction text from the screenshot).
// //
// // METHODOLOGY
// // Our report provides a visual inspection...
// //
// // LIMITATIONS
// // The inspection format covers...''';
// //
// //     page3.graphics.drawString(introText, bodyFont,
// //         bounds: Rect.fromLTWH(0, 40, page3.getClientSize().width, page3.getClientSize().height - 40));
// //
// //     // --- PAGE 4: CHECKLIST ---
// //     final PdfPage page4 = newDoc.pages.add();
// //     final String page4Heading = 'During Snagging, we inspect the following in your home:\n$address';
// //     page4.graphics.drawString(page4Heading, headingFont,
// //         bounds: Rect.fromLTWH(0, 0, page4.getClientSize().width, 50));
// //
// //     double p4y = 60;
// //     final List<String> checklistCategories = [
// //       'Air Conditioning', 'Electrical', 'Plumbing', 'Walls and Ceilings', 'Doors', 'Floors and Tiles', 'Joinery', 'General Items'
// //     ];
// //     for (var cat in checklistCategories) {
// //       page4.graphics.drawString(cat, bodyBoldFont, bounds: Rect.fromLTWH(0, p4y, page4.getClientSize().width, 20));
// //       p4y += 20;
// //       page4.graphics.drawString('• Standard inspection items for $cat...', bodyFont, bounds: Rect.fromLTWH(15, p4y, page4.getClientSize().width - 15, 20));
// //       p4y += 25;
// //     }
// //
// //     // --- PAGE 5: PROPERTY DETAILS TABLE ---
// //     final PdfPage page5 = newDoc.pages.add();
// //     page5.graphics.drawString('Property Details', headingFont,
// //         bounds: Rect.fromLTWH(0, 0, page5.getClientSize().width, 30));
// //
// //     final PdfGrid grid = PdfGrid();
// //     grid.columns.add(count: 2);
// //     grid.headers.add(1);
// //     PdfGridRow header = grid.headers[0];
// //     header.cells[0].value = 'Detail';
// //     header.cells[1].value = 'Definition';
// //
// //     final List<List<String>> tableData = [
// //       ['Good', 'The overall condition is in excellent condition.'],
// //       ['Defective', 'The item requires repair.'],
// //       ['Missing', 'The item is missing.'],
// //       ['Comment', 'Additional remarks.']
// //     ];
// //     for (var rowData in tableData) {
// //       PdfGridRow row = grid.rows.add();
// //       row.cells[0].value = rowData[0];
// //       row.cells[1].value = rowData[1];
// //     }
// //     grid.style = PdfGridStyle(
// //       cellPadding: PdfPaddings(left: 5, right: 5, top: 5, bottom: 5),
// //       font: bodyFont,
// //     );
// //     grid.draw(page: page5, bounds: Rect.fromLTWH(0, 40, page5.getClientSize().width, page5.getClientSize().height - 40));
// //
// //     // --- MERGE WITH UPLOADED PDF ---
// //     final File uploadedFile = File(uploadedPdfPath);
// //     final Uint8List uploadedBytes = await uploadedFile.readAsBytes();
// //     final PdfDocument loadedDoc = PdfDocument(inputBytes: uploadedBytes);
// //
// //     if (loadedDoc.pages.count > 0) {
// //       loadedDoc.pages.removeAt(0); // Remove the 1st page
// //     }
// //
// //     for (int i = 0; i < loadedDoc.pages.count; i++) {
// //         final PdfPage loadedPage = loadedDoc.pages[i];
// //
// //         // Remove margins to prevent alignment/scaling issues on appended pages
// //         newDoc.pageSettings.margins.all = 0;
// //         newDoc.pageSettings.size = loadedPage.size;
// //
// //         final PdfTemplate template = loadedPage.createTemplate();
// //         final PdfPage newPage = newDoc.pages.add();
// //         newPage.graphics.drawPdfTemplate(template, const Offset(0, 0));
// //     }
// //
// //     // Save
// //     final List<int> bytes = await newDoc.save();
// //     newDoc.dispose();
// //     loadedDoc.dispose();
// //
// //     final Directory directory = await getApplicationDocumentsDirectory();
// //     final String path = '${directory.path}/DXB_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
// //     final File file = File(path);
// //     await file.writeAsBytes(bytes);
// //
// //     // ignore: deprecated_member_use
// //     await Share.shareXFiles([XFile(path)], text: 'DXB Property Inspection Report');
// //   }
// //
// //   static void _drawField(PdfGraphics graphics, String label, String value, double yPos, PdfFont labelFont, PdfFont valueFont) {
// //     graphics.drawString(label, labelFont, bounds: Rect.fromLTWH(50, yPos, 150, 20));
// //     graphics.drawString(value, valueFont, bounds: Rect.fromLTWH(200, yPos, 300, 20));
// //   }
// // }
// //
// // //
// // // import 'dart:io';
// // // import 'dart:ui' as ui;
// // // import 'package:flutter/services.dart';
// // // import 'package:path_provider/path_provider.dart';
// // // import 'package:share_plus/share_plus.dart';
// // // import 'package:syncfusion_flutter_pdf/pdf.dart';
// // // import 'package:flutter/material.dart';
// // //
// // // class PdfGeneratorService {
// // //   static Future<void> generateAndMergePdf({
// // //     required String age,
// // //     required String address,
// // //     required String date,
// // //     required String inspectedFor,
// // //     required String inspectedBy,
// // //     required String uploadedPdfPath,
// // //     String? propertyPhotoPath,
// // //   }) async {
// // //     final PdfDocument newDoc = PdfDocument();
// // //
// // //     // Enable compression for smaller file size
// // //     // newDoc.compression = PdfCompression.flate;
// // //
// // //     // Configure document settings for our generated pages
// // //     newDoc.pageSettings.size = PdfPageSize.a4;
// // //     newDoc.pageSettings.margins.all = 0;
// // //
// // //     // Load fonts
// // //     final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 24, style: PdfFontStyle.bold);
// // //     final PdfFont headingFont = PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold);
// // //     final PdfFont bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
// // //     final PdfFont bodyBoldFont = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
// // //
// // //     // --- PAGE 1: COVER PAGE WITH HIGH QUALITY IMAGE ---
// // //     final PdfPage page1 = newDoc.pages.add();
// // //     try {
// // //       // Load image with high quality
// // //       final ByteData imageData = await rootBundle.load('assets/title.jpg');
// // //       final Uint8List imageBytes = imageData.buffer.asUint8List();
// // //
// // //       // Get page dimensions in points (A4 is 595x842 points)
// // //       final pageWidth = page1.getClientSize().width;
// // //       final pageHeight = page1.getClientSize().height;
// // //
// // //       // Create bitmap with original quality
// // //       final PdfBitmap coverImage = PdfBitmap(imageBytes);
// // //
// // //       // Calculate image dimensions to maintain aspect ratio while covering full page
// // //       final imageWidth = coverImage.width.toDouble();
// // //       final imageHeight = coverImage.height.toDouble();
// // //
// // //       double scaleX = pageWidth / imageWidth;
// // //       double scaleY = pageHeight / imageHeight;
// // //       double scale = scaleX > scaleY ? scaleX : scaleY; // Use larger scale to cover full page
// // //
// // //       final scaledWidth = imageWidth * scale;
// // //       final scaledHeight = imageHeight * scale;
// // //
// // //       // Center the image
// // //       final x = (pageWidth - scaledWidth) / 2;
// // //       final y = (pageHeight - scaledHeight) / 2;
// // //
// // //       // Draw image with scaling - this maintains quality better than stretching
// // //       page1.graphics.drawImage(coverImage,
// // //           Rect.fromLTWH(x, y, scaledWidth, scaledHeight));
// // //
// // //     } catch (e) {
// // //       // Fallback if image loading fails
// // //       page1.graphics.drawRectangle(
// // //           brush: PdfSolidBrush(PdfColor(0, 191, 165)),
// // //           bounds: Rect.fromLTWH(0, 0, page1.getClientSize().width, page1.getClientSize().height));
// // //       page1.graphics.drawString(
// // //         'PROPERTY INSPECTION\nREPORT CARD\n(Placeholder for assets/title.jpg)',
// // //         titleFont, brush: PdfBrushes.white,
// // //         bounds: Rect.fromLTWH(0, 0, page1.getClientSize().width, page1.getClientSize().height),
// // //         format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
// // //       );
// // //     }
// // //
// // //     // --- PAGE 2: DYNAMIC FIELDS WITH PHOTO ---
// // //     final PdfPage page2 = newDoc.pages.add();
// // //     double yPos = 20;
// // //
// // //     final Rect imageRect = Rect.fromLTWH(0, yPos, page2.getClientSize().width, 250);
// // //     if (propertyPhotoPath != null && propertyPhotoPath.isNotEmpty) {
// // //       try {
// // //         final File photoFile = File(propertyPhotoPath);
// // //         final Uint8List photoBytes = await photoFile.readAsBytes();
// // //
// // //         // Compress property photo to reduce file size while maintaining quality
// // //         final compressedPhoto = await _compressImage(photoBytes, quality: 85);
// // //         final PdfBitmap propertyImage = PdfBitmap(compressedPhoto);
// // //         page2.graphics.drawImage(propertyImage, imageRect);
// // //       } catch (e) {
// // //         page2.graphics.drawRectangle(pen: PdfPen(PdfColor(0, 0, 0), width: 3), bounds: imageRect);
// // //         page2.graphics.drawString('Error loading property photo', bodyFont,
// // //             bounds: imageRect, format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle));
// // //       }
// // //     } else {
// // //       page2.graphics.drawRectangle(pen: PdfPen(PdfColor(0, 0, 0), width: 3), bounds: imageRect);
// // //       page2.graphics.drawString('Property Image Placeholder', bodyFont,
// // //           bounds: imageRect, format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle));
// // //     }
// // //     yPos += 270;
// // //
// // //     // Center text box for Age
// // //     page2.graphics.drawString('Age: $age', headingFont,
// // //         bounds: Rect.fromLTWH(0, yPos, page2.getClientSize().width, 30),
// // //         format: PdfStringFormat(alignment: PdfTextAlignment.center)
// // //     );
// // //     yPos += 50;
// // //
// // //     // Fields
// // //     _drawField(page2.graphics, 'Property Address:', address, yPos, bodyBoldFont, bodyFont);
// // //     yPos += 25;
// // //     _drawField(page2.graphics, 'Inspection Date:', date, yPos, bodyBoldFont, bodyFont);
// // //     yPos += 25;
// // //     _drawField(page2.graphics, 'Inspected for:', inspectedFor, yPos, bodyBoldFont, bodyFont);
// // //     yPos += 25;
// // //     _drawField(page2.graphics, 'Inspected by:', inspectedBy, yPos, bodyBoldFont, bodyFont);
// // //
// // //     // --- PAGE 3: INTRODUCTION ---
// // //     final PdfPage page3 = newDoc.pages.add();
// // //     page3.graphics.drawString('INTRODUCTION', headingFont,
// // //         bounds: Rect.fromLTWH(0, 0, page3.getClientSize().width, 30));
// // //
// // //     final String introText = '''The purpose of the snagging inspection is to visually examine the property for defects, incomplete works, and non-compliance with specifications. This report documents findings that require attention before final handover.
// // //
// // // METHODOLOGY
// // // Our report provides a visual inspection of accessible areas of the property. We identify and document any defects, incomplete items, or areas requiring remedial work. Each item is photographed and described in detail.
// // //
// // // LIMITATIONS
// // // The inspection format covers visible and accessible areas only. No destructive testing or invasive inspection methods are employed. Electrical and mechanical systems are tested for basic functionality only.''';
// // //
// // //     page3.graphics.drawString(introText, bodyFont,
// // //         bounds: Rect.fromLTWH(0, 40, page3.getClientSize().width, page3.getClientSize().height - 40));
// // //
// // //     // --- PAGE 4: CHECKLIST ---
// // //     final PdfPage page4 = newDoc.pages.add();
// // //     final String page4Heading = 'During Snagging, we inspect the following in your home:\n$address';
// // //     page4.graphics.drawString(page4Heading, headingFont,
// // //         bounds: Rect.fromLTWH(0, 0, page4.getClientSize().width, 50));
// // //
// // //     double p4y = 60;
// // //     final List<String> checklistCategories = [
// // //       'Air Conditioning', 'Electrical', 'Plumbing', 'Walls and Ceilings',
// // //       'Doors', 'Floors and Tiles', 'Joinery', 'General Items'
// // //     ];
// // //     for (var cat in checklistCategories) {
// // //       page4.graphics.drawString(cat, bodyBoldFont, bounds: Rect.fromLTWH(0, p4y, page4.getClientSize().width, 20));
// // //       p4y += 20;
// // //       page4.graphics.drawString('• Complete inspection of $cat systems and components', bodyFont,
// // //           bounds: Rect.fromLTWH(15, p4y, page4.getClientSize().width - 15, 20));
// // //       p4y += 25;
// // //     }
// // //
// // //     // --- PAGE 5: PROPERTY DETAILS TABLE ---
// // //     final PdfPage page5 = newDoc.pages.add();
// // //     page5.graphics.drawString('Property Details', headingFont,
// // //         bounds: Rect.fromLTWH(0, 0, page5.getClientSize().width, 30));
// // //
// // //     final PdfGrid grid = PdfGrid();
// // //     grid.columns.add(count: 2);
// // //     grid.headers.add(1);
// // //     PdfGridRow header = grid.headers[0];
// // //     header.cells[0].value = 'Detail';
// // //     header.cells[1].value = 'Definition';
// // //
// // //     final List<List<String>> tableData = [
// // //       ['Good', 'The overall condition is in excellent condition with no visible defects.'],
// // //       ['Defective', 'The item requires repair or replacement to meet specifications.'],
// // //       ['Missing', 'The item is missing and requires installation.'],
// // //       ['Comment', 'Additional remarks or observations about the item.']
// // //     ];
// // //     for (var rowData in tableData) {
// // //       PdfGridRow row = grid.rows.add();
// // //       row.cells[0].value = rowData[0];
// // //       row.cells[1].value = rowData[1];
// // //     }
// // //     grid.style = PdfGridStyle(
// // //       cellPadding: PdfPaddings(left: 5, right: 5, top: 5, bottom: 5),
// // //       font: bodyFont,
// // //     );
// // //     grid.draw(page: page5, bounds: Rect.fromLTWH(0, 40, page5.getClientSize().width, page5.getClientSize().height - 40));
// // //
// // //     // --- MERGE WITH UPLOADED PDF ---
// // //     final File uploadedFile = File(uploadedPdfPath);
// // //     final Uint8List uploadedBytes = await uploadedFile.readAsBytes();
// // //     final PdfDocument loadedDoc = PdfDocument(inputBytes: uploadedBytes);
// // //
// // //     // Remove the first page if needed
// // //     if (loadedDoc.pages.count > 0) {
// // //       loadedDoc.pages.removeAt(0);
// // //     }
// // //
// // //     // Append remaining pages
// // //     for (int i = 0; i < loadedDoc.pages.count; i++) {
// // //       final PdfPage loadedPage = loadedDoc.pages[i];
// // //
// // //       // Remove margins for appended pages
// // //       newDoc.pageSettings.margins.all = 0;
// // //       newDoc.pageSettings.size = loadedPage.size;
// // //
// // //       final PdfTemplate template = loadedPage.createTemplate();
// // //       final PdfPage newPage = newDoc.pages.add();
// // //       newPage.graphics.drawPdfTemplate(template, const Offset(0, 0));
// // //     }
// // //
// // //     // Save with optimized settings
// // //     final List<int> bytes = await newDoc.save();
// // //     newDoc.dispose();
// // //     loadedDoc.dispose();
// // //
// // //     final Directory directory = await getApplicationDocumentsDirectory();
// // //     final String path = '${directory.path}/DXB_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
// // //     final File file = File(path);
// // //     await file.writeAsBytes(bytes);
// // //
// // //     // Share the file
// // //     // ignore: deprecated_member_use
// // //     await Share.shareXFiles([XFile(path)], text: 'DXB Property Inspection Report');
// // //   }
// // //
// // //   static void _drawField(PdfGraphics graphics, String label, String value, double yPos, PdfFont labelFont, PdfFont valueFont) {
// // //     graphics.drawString(label, labelFont, bounds: Rect.fromLTWH(50, yPos, 150, 20));
// // //     graphics.drawString(value, valueFont, bounds: Rect.fromLTWH(200, yPos, 300, 20));
// // //   }
// // //
// // //   // Helper method to compress images with adjustable quality
// // //   static Future<Uint8List> _compressImage(Uint8List imageBytes, {int quality = 85}) async {
// // //     try {
// // //       // Create a temporary file for the image
// // //       final tempDir = await getTemporaryDirectory();
// // //       final tempFile = File('${tempDir.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
// // //       await tempFile.writeAsBytes(imageBytes);
// // //
// // //       // Decode and compress the image
// // //       final ui.Image image = await decodeImageFromList(imageBytes);
// // //
// // //       // Create a picture recorder
// // //       final recorder = ui.PictureRecorder();
// // //       final canvas = Canvas(recorder);
// // //
// // //       // Draw the image with compression
// // //       final paint = Paint();
// // //       canvas.drawImage(image, Offset.zero, paint);
// // //
// // //       // Convert to bytes with quality setting
// // //       final picture = recorder.endRecording();
// // //       final img = await picture.toImage(image.width, image.height);
// // //       final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
// // //
// // //       // Clean up
// // //       if (await tempFile.exists()) {
// // //         await tempFile.delete();
// // //       }
// // //
// // //       return byteData?.buffer.asUint8List() ?? imageBytes;
// // //     } catch (e) {
// // //       // If compression fails, return original bytes
// // //       return imageBytes;
// // //     }
// // //   }
// // // }
//
// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';
//
// class PdfGeneratorService {
//   static Future<void> generateAndMergePdf({
//     required String age,
//     required String address,
//     required String date,
//     required String inspectedFor,
//     required String inspectedBy,
//     required String uploadedPdfPath,
//     required String introText,
//     required String snaggingText,
//     required String propertyDetailsText,
//     String? propertyPhotoPath,
//   }) async {
//     final PdfDocument newDoc = PdfDocument();
//
//     // Configure document settings
//     newDoc.pageSettings.size = PdfPageSize.a4;
//
//     // 🔥 Default stays SAME as your original (0 margin)
//     newDoc.pageSettings.margins.all = 0;
//
//     // Fonts
//     final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 24, style: PdfFontStyle.bold);
//     final PdfFont headingFont = PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold);
//     final PdfFont bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
//     final PdfFont bodyBoldFont = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
//
//     // =========================
//     // PAGE 1: COVER (FULL BLEED)
//     // =========================
// // --- PAGE 1: COVER PAGE FULL BLEED (NO MARGINS) ---
//     newDoc.pageSettings.margins.all = 0; // 🔥 remove margins for cover
//
//     final PdfPage page1 = newDoc.pages.add();
//
//     try {
//       final ByteData imageData = await rootBundle.load('assets/title.jpg');
//       final Uint8List imageBytes = imageData.buffer.asUint8List();
//
//       final PdfBitmap coverImage = PdfBitmap(imageBytes);
//
//       final Size pageSize = page1.getClientSize();
//
//       // 🔥 Draw image EXACTLY to page size (edge-to-edge)
//       page1.graphics.drawImage(
//         coverImage,
//         Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
//       );
//
//     } catch (e) {
//       page1.graphics.drawRectangle(
//         brush: PdfSolidBrush(PdfColor(0, 191, 165)),
//         bounds: Rect.fromLTWH(
//           0,
//           0,
//           page1.getClientSize().width,
//           page1.getClientSize().height,
//         ),
//       );
//
//       page1.graphics.drawString(
//         'PROPERTY INSPECTION\nREPORT CARD\n(Placeholder for assets/title.jpg)',
//         titleFont,
//         brush: PdfBrushes.white,
//         bounds: Rect.fromLTWH(
//           0,
//           0,
//           page1.getClientSize().width,
//           page1.getClientSize().height,
//         ),
//         format: PdfStringFormat(
//           alignment: PdfTextAlignment.center,
//           lineAlignment: PdfVerticalAlignment.middle,
//         ),
//       );
//     }
//
// // 🔥 Restore margins for rest of document
//     newDoc.pageSettings.margins.all = 40;
//     // newDoc.pageSettings.margins.all = 0; // ensure no margin
//     // final PdfPage page1 = newDoc.pages.add();
//     //
//     // try {
//     //   final ByteData imageData = await rootBundle.load('assets/title.png');
//     //   final Uint8List imageBytes = imageData.buffer.asUint8List();
//     //   final PdfBitmap coverImage = PdfBitmap(imageBytes);
//     //
//     //   final Size pageSize = page1.getClientSize();
//     //
//     //   // 🔥 Edge-to-edge image (no gaps)
//     //   page1.graphics.drawImage(
//     //     coverImage,
//     //     Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
//     //   );
//     //
//     // } catch (_) {
//     //   page1.graphics.drawRectangle(
//     //     brush: PdfSolidBrush(PdfColor(0, 191, 165)),
//     //     bounds: Rect.fromLTWH(0, 0, page1.getClientSize().width, page1.getClientSize().height),
//     //   );
//     //
//     //   page1.graphics.drawString(
//     //     'PROPERTY INSPECTION\nREPORT CARD\n(Placeholder for assets/title.png)',
//     //     titleFont,
//     //     brush: PdfBrushes.white,
//     //     bounds: Rect.fromLTWH(0, 0, page1.getClientSize().width, page1.getClientSize().height),
//     //     format: PdfStringFormat(
//     //       alignment: PdfTextAlignment.center,
//     //       lineAlignment: PdfVerticalAlignment.middle,
//     //     ),
//     //   );
//     // }
//     //
//     // // 🔥 Keep margins SAME as your system (0)
//     // newDoc.pageSettings.margins.all = 0;
//
//     // =========================
//     // PAGE 2
//     // =========================
//
//     final PdfPage page2 = newDoc.pages.add();
//     double yPos = 20;
//
//     final Rect imageRect = Rect.fromLTWH(0, yPos, page2.getClientSize().width, 250);
//
//     if (propertyPhotoPath != null && propertyPhotoPath.isNotEmpty) {
//       try {
//         final File photoFile = File(propertyPhotoPath);
//         final Uint8List photoBytes = await photoFile.readAsBytes();
//         final PdfBitmap propertyImage = PdfBitmap(photoBytes);
//
//         page2.graphics.drawImage(propertyImage, imageRect);
//       } catch (e) {
//         page2.graphics.drawRectangle(
//           pen: PdfPen(PdfColor(0, 0, 0), width: 3),
//           bounds: imageRect,
//         );
//
//         page2.graphics.drawString(
//           'Error loading property photo',
//           bodyFont,
//           bounds: imageRect,
//           format: PdfStringFormat(
//             alignment: PdfTextAlignment.center,
//             lineAlignment: PdfVerticalAlignment.middle,
//           ),
//         );
//       }
//     } else {
//       page2.graphics.drawRectangle(
//         pen: PdfPen(PdfColor(0, 0, 0), width: 3),
//         bounds: imageRect,
//       );
//
//       page2.graphics.drawString(
//         'Property Image Placeholder',
//         bodyFont,
//         bounds: imageRect,
//         format: PdfStringFormat(
//           alignment: PdfTextAlignment.center,
//           lineAlignment: PdfVerticalAlignment.middle,
//         ),
//       );
//     }
//
//     yPos += 270;
//
//     page2.graphics.drawString(
//       '$age',
//       headingFont,
//       bounds: Rect.fromLTWH(0, yPos, page2.getClientSize().width, 30),
//       format: PdfStringFormat(alignment: PdfTextAlignment.center),
//     );
//
//     yPos += 50;
//
//     _drawField(page2.graphics, 'Property Address:', address, yPos, bodyBoldFont, bodyFont);
//     yPos += 25;
//
//     _drawField(page2.graphics, 'Inspection Date:', date, yPos, bodyBoldFont, bodyFont);
//     yPos += 25;
//
//     _drawField(page2.graphics, 'Inspected for:', inspectedFor, yPos, bodyBoldFont, bodyFont);
//     yPos += 25;
//
//     _drawField(page2.graphics, 'Inspected by:', inspectedBy, yPos, bodyBoldFont, bodyFont);
//
//     // =========================
//     // PAGE 3
//     // =========================
//
//     final PdfPage page3 = newDoc.pages.add();
//
//     page3.graphics.drawString(
//       'INTRODUCTION',
//       headingFont,
//       bounds: Rect.fromLTWH(0, 0, page3.getClientSize().width, 30),
//     );
//
//     final String cleanIntro = introText.replaceAll('**', '').replaceAll('*', '');
//
//     page3.graphics.drawString(
//       cleanIntro,
//       bodyFont,
//       bounds: Rect.fromLTWH(
//         0,
//         40,
//         page3.getClientSize().width,
//         page3.getClientSize().height - 40,
//       ),
//     );
//
//     // =========================
//     // PAGE 4
//     // =========================
//
//     final PdfPage page4 = newDoc.pages.add();
//
//     final String page4Heading =
//         'During Snagging, we inspect the following in your home:\n$address';
//
//     page4.graphics.drawString(
//       page4Heading,
//       headingFont,
//       bounds: Rect.fromLTWH(0, 0, page4.getClientSize().width, 50),
//     );
//
//     final String cleanSnagging = snaggingText.replaceAll('**', '').replaceAll('*', '');
//
//     page4.graphics.drawString(
//       cleanSnagging,
//       bodyFont,
//       bounds: Rect.fromLTWH(0, 60, page4.getClientSize().width, page4.getClientSize().height - 60),
//     );
//
//     // =========================
//     // PAGE 5
//     // =========================
//
//     final PdfPage page5 = newDoc.pages.add();
//
//     page5.graphics.drawString(
//       'Property Details',
//       headingFont,
//       bounds: Rect.fromLTWH(0, 0, page5.getClientSize().width, 30),
//     );
//
//     final String cleanDetails = propertyDetailsText.replaceAll('**', '').replaceAll('*', '');
//
//     final PdfTextElement textElement = PdfTextElement(text: cleanDetails, font: bodyFont);
//     final PdfLayoutResult? textResult = textElement.draw(
//       page: page5,
//       bounds: Rect.fromLTWH(0, 40, page5.getClientSize().width, page5.getClientSize().height - 40),
//     );
//
//     final double tableY = (textResult != null) ? textResult.bounds.bottom + 30 : 150;
//
//     final PdfGrid grid = PdfGrid();
//     grid.columns.add(count: 2);
//
//     // Set widths
//     grid.columns[0].width = page5.getClientSize().width * 0.3;
//     grid.columns[1].width = page5.getClientSize().width * 0.7;
//
//     final List<List<String>> tableData = [
//       [
//         'Room',
//         'The specific area or room in the property being inspected (e.g., Master Bedroom, Kitchen, Balcony, etc.).'
//       ],
//       [
//         'Status',
//         'The result of the inspection for each area:\n\nPASS: In good condition & functional.\nOPEN: Defects that need attention.\nFAIL: Urgent attention or repairs.'
//       ],
//       [
//         'Comments',
//         'A description of the specific issues or observations in the room, highlighting defects, damages, or areas that need repair or maintenance.'
//       ]
//     ];
//
//     for (var rowData in tableData) {
//       PdfGridRow row = grid.rows.add();
//       row.cells[0].value = rowData[0];
//       row.cells[1].value = rowData[1];
//     }
//
//     grid.style = PdfGridStyle(
//       cellPadding: PdfPaddings(left: 8, right: 8, top: 8, bottom: 8),
//       font: bodyFont,
//     );
//
//     grid.draw(
//       page: page5,
//       bounds: Rect.fromLTWH(0, tableY, page5.getClientSize().width, page5.getClientSize().height - tableY),
//     );
//
//     // =========================
//     // MERGE PDF
//     // =========================
//
//     final File uploadedFile = File(uploadedPdfPath);
//     final Uint8List uploadedBytes = await uploadedFile.readAsBytes();
//     final PdfDocument loadedDoc = PdfDocument(inputBytes: uploadedBytes);
//
//     if (loadedDoc.pages.count > 0) {
//       loadedDoc.pages.removeAt(0);
//     }
//
//     for (int i = 0; i < loadedDoc.pages.count; i++) {
//       final PdfPage loadedPage = loadedDoc.pages[i];
//
//       newDoc.pageSettings.margins.all = 0;
//       newDoc.pageSettings.size = loadedPage.size;
//
//       final PdfTemplate template = loadedPage.createTemplate();
//       final PdfPage newPage = newDoc.pages.add();
//
//       newPage.graphics.drawPdfTemplate(template, const Offset(0, 0));
//     }
//
//     // Save
//     final List<int> bytes = await newDoc.save();
//     newDoc.dispose();
//     loadedDoc.dispose();
//
//     final Directory directory = await getApplicationDocumentsDirectory();
//     final String path =
//         '${directory.path}/DXB_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
//
//     final File file = File(path);
//     await file.writeAsBytes(bytes);
//
//     await Share.shareXFiles(
//       [XFile(path)],
//       text: 'DXB Property Inspection Report',
//     );
//   }
//
//   static void _drawField(
//       PdfGraphics graphics,
//       String label,
//       String value,
//       double yPos,
//       PdfFont labelFont,
//       PdfFont valueFont,
//       ) {
//     graphics.drawString(label, labelFont,
//         bounds: Rect.fromLTWH(50, yPos, 150, 20));
//
//     graphics.drawString(value, valueFont,
//         bounds: Rect.fromLTWH(200, yPos, 300, 20));
//   }
// }

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfGeneratorService {
  // Your Custom Brand Color: #0db591
  static final PdfColor brandGreen = PdfColor(13, 181, 145);
  static final PdfColor darkGreen = PdfColor(10, 140, 112);
  static final PdfColor softBg = PdfColor(245, 250, 249);

  static Future<void> generateAndMergePdf({
    required String age,
    required String address,
    required String date,
    required String inspectedFor,
    required String inspectedBy,
    required String uploadedPdfPath,
    required String introText,
    required String snaggingText,
    required String propertyDetailsText,
    String? propertyPhotoPath,
  }) async {
    final PdfDocument newDoc = PdfDocument();

    // Setup Global Fonts
    final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 32, style: PdfFontStyle.bold);
    final PdfFont headingFont = PdfStandardFont(PdfFontFamily.helvetica, 20, style: PdfFontStyle.bold);
    final PdfFont subHeaderFont = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    final PdfFont bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 11);
    final PdfFont bodyBoldFont = PdfStandardFont(PdfFontFamily.helvetica, 11, style: PdfFontStyle.bold);

    // ==========================================
    // PAGE 1: COVER (FULL BLEED)
    // ==========================================
    newDoc.pageSettings.margins.all = 0;
    final PdfPage page1 = newDoc.pages.add();
    final Size pageSize = page1.getClientSize();

    try {
      final ByteData imageData = await rootBundle.load('assets/title.jpg');
      final Uint8List imageBytes = imageData.buffer.asUint8List();
      page1.graphics.drawImage(PdfBitmap(imageBytes), Rect.fromLTWH(0, 0, pageSize.width, pageSize.height));
    } catch (e) {
      // Modern Graphical Fallback
      page1.graphics.drawRectangle(brush: PdfSolidBrush(brandGreen), bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height));
      page1.graphics.drawPie(Rect.fromLTWH(-100, -100, 400, 400), 0, 360, brush: PdfSolidBrush(PdfColor(255, 255, 255, 30)));
      page1.graphics.drawString(
        'PROPERTY\nINSPECTION\nREPORT',
        titleFont,
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(40, 0, pageSize.width - 80, pageSize.height),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle),
      );
    }

    // ==========================================
    // PAGE 2: PROPERTY OVERVIEW
    // ==========================================
    // ==========================================
    // PAGE 2: PROPERTY OVERVIEW (ALL VERTICAL)
    // ==========================================
    newDoc.pageSettings.margins.all = 40;
    final PdfPage page2 = newDoc.pages.add();
    final double pageWidth = page2.getClientSize().width;
    double yPos = 0;

    _drawSleekHeader(page2.graphics, "PROPERTY OVERVIEW", headingFont, pageWidth);
    yPos += 60;

    // Main Property Image
    final Rect imageRect = Rect.fromLTWH(0, yPos, pageWidth, 250);
    if (propertyPhotoPath != null && propertyPhotoPath.isNotEmpty) {
      try {
        final Uint8List photoBytes = await File(propertyPhotoPath).readAsBytes();
        page2.graphics.drawImage(PdfBitmap(photoBytes), imageRect);
      } catch (e) {
        _drawGraphicalPlaceholder(page2.graphics, imageRect, "Property Photo Missing");
      }
    } else {
      _drawGraphicalPlaceholder(page2.graphics, imageRect, "Property Image Placeholder");
    }

    yPos += 270;

    // --- ALL FIELDS VERTICAL & CENTERED ---
    // Using full width (pageWidth) for every card to ensure zero horizontal rows.

    _drawInfoCard(page2.graphics, "Location", address, 0, yPos, pageWidth, 50, bodyBoldFont, bodyFont);
    yPos += 60;

    _drawInfoCard(page2.graphics, "Inspection Date", date, 0, yPos, pageWidth, 50, bodyBoldFont, bodyFont);
    yPos += 60;

    // _drawInfoCard(page2.graphics, "Property Age", age, 0, yPos, pageWidth, 50, bodyBoldFont, bodyFont);
    // yPos += 60;

    _drawInfoCard(page2.graphics, "Inspected For (Client)", inspectedFor, 0, yPos, pageWidth, 50, bodyBoldFont, bodyFont);
    yPos += 60;

    _drawInfoCard(page2.graphics, "Lead Inspector", inspectedBy, 0, yPos, pageWidth, 50, bodyBoldFont, bodyFont);
    // newDoc.pageSettings.margins.all = 40;
    // final PdfPage page2 = newDoc.pages.add();
    // double yPos = 0;
    //
    // // Draw a sleek graphical header bar for every page
    // _drawSleekHeader(page2.graphics, "PROPERTY OVERVIEW", headingFont, page2.getClientSize().width);
    // yPos += 60;
    //
    // // Main Property Image with a modern rounded clip/border
    // final Rect imageRect = Rect.fromLTWH(0, yPos, page2.getClientSize().width, 280);
    // if (propertyPhotoPath != null && propertyPhotoPath.isNotEmpty) {
    //   try {
    //     final Uint8List photoBytes = await File(propertyPhotoPath).readAsBytes();
    //     page2.graphics.drawImage(PdfBitmap(photoBytes), imageRect);
    //   } catch (e) {
    //     _drawGraphicalPlaceholder(page2.graphics, imageRect, "Property Photo Missing");
    //   }
    // }
    //
    // yPos += 300;
    //
    // // Info Grid (Two Columns)
    // _drawInfoCard(page2.graphics, "Location", address, 0, yPos, 515, 50, bodyBoldFont, bodyFont);
    // yPos += 65;
    //
    // _drawInfoCard(page2.graphics, "Inspection Date", date, 0, yPos, 250, 50, bodyBoldFont, bodyFont);
    // // _drawInfoCard(page2.graphics, "Property Age", age, 265, yPos, 250, 50, bodyBoldFont, bodyFont);
    // // yPos += 65;
    //
    // _drawInfoCard(page2.graphics, "Client Name", inspectedFor, 0, yPos, 250, 50, bodyBoldFont, bodyFont);
    // _drawInfoCard(page2.graphics, "Inspector", inspectedBy, 265, yPos, 250, 50, bodyBoldFont, bodyFont);

    // ==========================================
    // PAGE 3: INTRODUCTION
    // ==========================================
    final PdfPage page3 = newDoc.pages.add();
    _drawSleekHeader(page3.graphics, "EXECUTIVE SUMMARY", headingFont, page3.getClientSize().width);

    final String cleanIntro = introText.replaceAll('**', '').replaceAll('*', '');
    page3.graphics.drawString(
      cleanIntro,
      bodyFont,
      bounds: Rect.fromLTWH(0, 70, page3.getClientSize().width, page3.getClientSize().height - 70),
      format: PdfStringFormat(lineSpacing: 6),
    );

    // ==========================================
    // PAGE 4: SNAGGING DETAILS
    // ==========================================
    final PdfPage page4 = newDoc.pages.add();
    _drawSleekHeader(page4.graphics, "TECHNICAL OBSERVATIONS", headingFont, page4.getClientSize().width);

    final String cleanSnagging = snaggingText.replaceAll('**', '').replaceAll('*', '');
    page4.graphics.drawString(
      cleanSnagging,
      bodyFont,
      bounds: Rect.fromLTWH(0, 70, page4.getClientSize().width, page4.getClientSize().height - 70),
      format: PdfStringFormat(lineSpacing: 5),
    );

    // ==========================================
    // PAGE 5: DEFINITIONS & TABLE
    // ==========================================
    final PdfPage page5 = newDoc.pages.add();
    final double page5Width = page5.getClientSize().width;

// 1. Main Brand Header (0db591)
    _drawSleekHeader(page5.graphics, "REPORT TERMINOLOGY", headingFont, page5Width);

// 2. New Black Sub-Heading "Property Details"
    final PdfFont subHeadingBold = PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold);

    page5.graphics.drawString(
      "Property Details",
      subHeadingBold,
      brush: PdfBrushes.black, // Explicitly set to Black
      bounds: Rect.fromLTWH(0, 50, page5Width, 25),
    );

// 3. Bullet Points / Property Details Text
    final String cleanDetails = propertyDetailsText.replaceAll('**', '').replaceAll('*', '');

// Note: Adjusted yPos to 80 to leave room for the new black heading above
    final PdfLayoutResult? textResult = PdfTextElement(
      text: cleanDetails,
      font: bodyFont,
      format: PdfStringFormat(lineSpacing: 4),
    ).draw(
      page: page5,
      bounds: Rect.fromLTWH(0, 80, page5Width, 150),
    );

// 4. Grid / Table Logic remains below...
// Calculate the dynamic top position based on the text above
    double tableTop = (textResult != null) ? textResult.bounds.bottom + 30 : 250;

// 1. Add the Black Bold "Definitions" Heading

    page5.graphics.drawString(
      "Definitions",
      subHeadingBold,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(0, tableTop, page5.getClientSize().width, 25),
    );

// 2. Adjust the Grid start position to be below the new heading
// We add 35 pixels (25 for height + 10 for padding) to the tableTop
    double gridStartPos = tableTop + 35;

// Modern Styled Grid
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 2);
    grid.columns[0].width = 120;

    _addGridRow(grid, 'Room', 'Specific interior/exterior area evaluated.');
    _addGridRow(grid, 'Status', 'PASS: Functional\nOPEN: Rectification Needed\nFAIL: Immediate Action Required');
    _addGridRow(grid, 'Comments', 'Detailed engineer notes on defects or health & safety concerns.');

    grid.style = PdfGridStyle(
      cellPadding: PdfPaddings(left: 12, right: 12, top: 12, bottom: 12),
      font: bodyFont,
    );

// Apply your sleek green styling to the first column
    for (int i = 0; i < grid.rows.count; i++) {
      grid.rows[i].cells[0].style.backgroundBrush = PdfSolidBrush(softBg);
      grid.rows[i].cells[0].style.textBrush = PdfSolidBrush(darkGreen);
      grid.rows[i].cells[0].style.font = bodyBoldFont;
    }

// 3. Draw the grid at the new adjusted position
    grid.draw(
        page: page5,
        bounds: Rect.fromLTWH(0, gridStartPos, page5.getClientSize().width, 0)
    );

    // ==========================================
    // MERGE EXTERNAL DOCUMENT
    // ==========================================
    final PdfDocument loadedDoc = PdfDocument(inputBytes: await File(uploadedPdfPath).readAsBytes());
    if (loadedDoc.pages.count > 0) loadedDoc.pages.removeAt(0);

    for (int i = 0; i < loadedDoc.pages.count; i++) {
      newDoc.pageSettings.margins.all = 0;
      final PdfPage newPage = newDoc.pages.add();
      newPage.graphics.drawPdfTemplate(loadedDoc.pages[i].createTemplate(), const Offset(0, 0));
    }

    // SAVE & SHARE
    final List<int> bytes = await newDoc.save();
    newDoc.dispose();
    loadedDoc.dispose();

    final String path = '${(await getApplicationDocumentsDirectory()).path}/DXB_PRO_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final File file = File(path);
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(path)], text: 'Premium Property Inspection Report');
  }

  // --- MODERN GRAPHICAL HELPERS ---

  static void _drawSleekHeader(PdfGraphics graphics, String text, PdfFont font, double width) {
    // Vertical Accent Line
    graphics.drawRectangle(brush: PdfSolidBrush(brandGreen), bounds: Rect.fromLTWH(0, 0, 5, 30));
    // Text
    graphics.drawString(text, font, brush: PdfSolidBrush(brandGreen), bounds: Rect.fromLTWH(15, 0, width, 40));
    // Subtle Divider

    graphics.drawLine(PdfPen(PdfColor(230, 230, 230), width: 1), Offset(0, 35), Offset(width, 35));

  }

  static void _drawInfoCard(PdfGraphics graphics, String label, String value, double x, double y, double w, double h, PdfFont lFont, PdfFont vFont) {
    // Background Card
    graphics.drawRectangle(
      brush: PdfSolidBrush(softBg),
      pen: PdfPen(PdfColor(13, 181, 145, 50), width: 0.5),
      bounds: Rect.fromLTWH(x, y, w, h),
    );
    // Label
    graphics.drawString(label.toUpperCase(), PdfStandardFont(PdfFontFamily.helvetica, 8, style: PdfFontStyle.bold),
        brush: PdfSolidBrush(darkGreen), bounds: Rect.fromLTWH(x + 10, y + 8, w - 20, 12));
    // Value
    graphics.drawString(value, vFont, brush: PdfSolidBrush(PdfColor(40, 40, 40)),
        bounds: Rect.fromLTWH(x + 10, y + 22, w - 20, 20));
  }

  static void _drawGraphicalPlaceholder(PdfGraphics graphics, Rect rect, String text) {
    graphics.drawRectangle(brush: PdfSolidBrush(softBg), bounds: rect);
    graphics.drawRectangle(pen: PdfPen(brandGreen, width: 1, dashStyle: PdfDashStyle.dash), bounds: rect.inflate(-10));
    graphics.drawString(text, PdfStandardFont(PdfFontFamily.helvetica, 10),
        brush: PdfSolidBrush(brandGreen),
        bounds: rect, format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle));
  }

  static void _addGridRow(PdfGrid grid, String title, String desc) {
    PdfGridRow row = grid.rows.add();
    row.cells[0].value = title;
    row.cells[1].value = desc;
  }
}