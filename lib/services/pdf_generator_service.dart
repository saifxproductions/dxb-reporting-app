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
//     String? propertyPhotoPath,
//   }) async {
//     final PdfDocument newDoc = PdfDocument();
//
//     // Configure document settings for our generated pages
//     newDoc.pageSettings.size = PdfPageSize.a4;
//     newDoc.pageSettings.margins.all = 0;
//
//     // Load fonts
//     final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 24, style: PdfFontStyle.bold);
//     final PdfFont headingFont = PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold);
//     final PdfFont bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
//     final PdfFont bodyBoldFont = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
//
//     // --- PAGE 1: COVER PAGE ---
//     final PdfPage page1 = newDoc.pages.add();
//     try {
//       final ByteData imageData = await rootBundle.load('assets/title.png');
//       final Uint8List imageBytes = imageData.buffer.asUint8List();
//       final PdfBitmap coverImage = PdfBitmap(imageBytes);
//       page1.graphics.drawImage(coverImage,
//           Rect.fromLTWH(0, 0, page1.getClientSize().width, page1.getClientSize().height));
//     } catch (_) {
//       // Fallback
//       page1.graphics.drawRectangle(
//           brush: PdfSolidBrush(PdfColor(0, 191, 165)),
//           bounds: Rect.fromLTWH(0, 0, page1.getClientSize().width, page1.getClientSize().height));
//       page1.graphics.drawString(
//         'PROPERTY INSPECTION\nREPORT CARD\n(Placeholder for assets/title.png)',
//         titleFont, brush: PdfBrushes.white,
//         bounds: Rect.fromLTWH(0, 0, page1.getClientSize().width, page1.getClientSize().height),
//         format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle),
//       );
//     }
//
//     // --- PAGE 2: DYNAMIC FIELDS WITH PHOTO ---
//     final PdfPage page2 = newDoc.pages.add();
//     double yPos = 20;
//
//     final Rect imageRect = Rect.fromLTWH(0, yPos, page2.getClientSize().width, 250);
//     if (propertyPhotoPath != null && propertyPhotoPath.isNotEmpty) {
//       try {
//         final File photoFile = File(propertyPhotoPath);
//         final Uint8List photoBytes = await photoFile.readAsBytes();
//         final PdfBitmap propertyImage = PdfBitmap(photoBytes);
//         page2.graphics.drawImage(propertyImage, imageRect);
//       } catch (e) {
//         page2.graphics.drawRectangle(pen: PdfPen(PdfColor(0, 0, 0), width: 3), bounds: imageRect);
//         page2.graphics.drawString('Error loading property photo', bodyFont,
//             bounds: imageRect, format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle));
//       }
//     } else {
//       page2.graphics.drawRectangle(pen: PdfPen(PdfColor(0, 0, 0), width: 3), bounds: imageRect);
//       page2.graphics.drawString('Property Image Placeholder', bodyFont,
//           bounds: imageRect, format: PdfStringFormat(alignment: PdfTextAlignment.center, lineAlignment: PdfVerticalAlignment.middle));
//     }
//     yPos += 270;
//
//     // Center text box for Age
//     page2.graphics.drawString('Age: $age', headingFont,
//       bounds: Rect.fromLTWH(0, yPos, page2.getClientSize().width, 30),
//       format: PdfStringFormat(alignment: PdfTextAlignment.center)
//     );
//     yPos += 50;
//
//     // Fields
//     _drawField(page2.graphics, 'Property Address:', address, yPos, bodyBoldFont, bodyFont);
//     yPos += 25;
//     _drawField(page2.graphics, 'Inspection Date:', date, yPos, bodyBoldFont, bodyFont);
//     yPos += 25;
//     _drawField(page2.graphics, 'Inspected for:', inspectedFor, yPos, bodyBoldFont, bodyFont);
//     yPos += 25;
//     _drawField(page2.graphics, 'Inspected by:', inspectedBy, yPos, bodyBoldFont, bodyFont);
//
//     // --- PAGE 3: INTRODUCTION ---
//     final PdfPage page3 = newDoc.pages.add();
//     page3.graphics.drawString('INTRODUCTION', headingFont,
//         bounds: Rect.fromLTWH(0, 0, page3.getClientSize().width, 30));
//
//     final String introText = '''The purpose of the snagging inspection is to visually examine... (Placeholder static introduction text from the screenshot).
//
// METHODOLOGY
// Our report provides a visual inspection...
//
// LIMITATIONS
// The inspection format covers...''';
//
//     page3.graphics.drawString(introText, bodyFont,
//         bounds: Rect.fromLTWH(0, 40, page3.getClientSize().width, page3.getClientSize().height - 40));
//
//     // --- PAGE 4: CHECKLIST ---
//     final PdfPage page4 = newDoc.pages.add();
//     final String page4Heading = 'During Snagging, we inspect the following in your home:\n$address';
//     page4.graphics.drawString(page4Heading, headingFont,
//         bounds: Rect.fromLTWH(0, 0, page4.getClientSize().width, 50));
//
//     double p4y = 60;
//     final List<String> checklistCategories = [
//       'Air Conditioning', 'Electrical', 'Plumbing', 'Walls and Ceilings', 'Doors', 'Floors and Tiles', 'Joinery', 'General Items'
//     ];
//     for (var cat in checklistCategories) {
//       page4.graphics.drawString(cat, bodyBoldFont, bounds: Rect.fromLTWH(0, p4y, page4.getClientSize().width, 20));
//       p4y += 20;
//       page4.graphics.drawString('• Standard inspection items for $cat...', bodyFont, bounds: Rect.fromLTWH(15, p4y, page4.getClientSize().width - 15, 20));
//       p4y += 25;
//     }
//
//     // --- PAGE 5: PROPERTY DETAILS TABLE ---
//     final PdfPage page5 = newDoc.pages.add();
//     page5.graphics.drawString('Property Details', headingFont,
//         bounds: Rect.fromLTWH(0, 0, page5.getClientSize().width, 30));
//
//     final PdfGrid grid = PdfGrid();
//     grid.columns.add(count: 2);
//     grid.headers.add(1);
//     PdfGridRow header = grid.headers[0];
//     header.cells[0].value = 'Detail';
//     header.cells[1].value = 'Definition';
//
//     final List<List<String>> tableData = [
//       ['Good', 'The overall condition is in excellent condition.'],
//       ['Defective', 'The item requires repair.'],
//       ['Missing', 'The item is missing.'],
//       ['Comment', 'Additional remarks.']
//     ];
//     for (var rowData in tableData) {
//       PdfGridRow row = grid.rows.add();
//       row.cells[0].value = rowData[0];
//       row.cells[1].value = rowData[1];
//     }
//     grid.style = PdfGridStyle(
//       cellPadding: PdfPaddings(left: 5, right: 5, top: 5, bottom: 5),
//       font: bodyFont,
//     );
//     grid.draw(page: page5, bounds: Rect.fromLTWH(0, 40, page5.getClientSize().width, page5.getClientSize().height - 40));
//
//     // --- MERGE WITH UPLOADED PDF ---
//     final File uploadedFile = File(uploadedPdfPath);
//     final Uint8List uploadedBytes = await uploadedFile.readAsBytes();
//     final PdfDocument loadedDoc = PdfDocument(inputBytes: uploadedBytes);
//
//     if (loadedDoc.pages.count > 0) {
//       loadedDoc.pages.removeAt(0); // Remove the 1st page
//     }
//
//     for (int i = 0; i < loadedDoc.pages.count; i++) {
//         final PdfPage loadedPage = loadedDoc.pages[i];
//
//         // Remove margins to prevent alignment/scaling issues on appended pages
//         newDoc.pageSettings.margins.all = 0;
//         newDoc.pageSettings.size = loadedPage.size;
//
//         final PdfTemplate template = loadedPage.createTemplate();
//         final PdfPage newPage = newDoc.pages.add();
//         newPage.graphics.drawPdfTemplate(template, const Offset(0, 0));
//     }
//
//     // Save
//     final List<int> bytes = await newDoc.save();
//     newDoc.dispose();
//     loadedDoc.dispose();
//
//     final Directory directory = await getApplicationDocumentsDirectory();
//     final String path = '${directory.path}/DXB_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
//     final File file = File(path);
//     await file.writeAsBytes(bytes);
//
//     // ignore: deprecated_member_use
//     await Share.shareXFiles([XFile(path)], text: 'DXB Property Inspection Report');
//   }
//
//   static void _drawField(PdfGraphics graphics, String label, String value, double yPos, PdfFont labelFont, PdfFont valueFont) {
//     graphics.drawString(label, labelFont, bounds: Rect.fromLTWH(50, yPos, 150, 20));
//     graphics.drawString(value, valueFont, bounds: Rect.fromLTWH(200, yPos, 300, 20));
//   }
// }
//
// //
// // import 'dart:io';
// // import 'dart:ui' as ui;
// // import 'package:flutter/services.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'package:share_plus/share_plus.dart';
// // import 'package:syncfusion_flutter_pdf/pdf.dart';
// // import 'package:flutter/material.dart';
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
// //     // Enable compression for smaller file size
// //     // newDoc.compression = PdfCompression.flate;
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
// //     // --- PAGE 1: COVER PAGE WITH HIGH QUALITY IMAGE ---
// //     final PdfPage page1 = newDoc.pages.add();
// //     try {
// //       // Load image with high quality
// //       final ByteData imageData = await rootBundle.load('assets/title.jpg');
// //       final Uint8List imageBytes = imageData.buffer.asUint8List();
// //
// //       // Get page dimensions in points (A4 is 595x842 points)
// //       final pageWidth = page1.getClientSize().width;
// //       final pageHeight = page1.getClientSize().height;
// //
// //       // Create bitmap with original quality
// //       final PdfBitmap coverImage = PdfBitmap(imageBytes);
// //
// //       // Calculate image dimensions to maintain aspect ratio while covering full page
// //       final imageWidth = coverImage.width.toDouble();
// //       final imageHeight = coverImage.height.toDouble();
// //
// //       double scaleX = pageWidth / imageWidth;
// //       double scaleY = pageHeight / imageHeight;
// //       double scale = scaleX > scaleY ? scaleX : scaleY; // Use larger scale to cover full page
// //
// //       final scaledWidth = imageWidth * scale;
// //       final scaledHeight = imageHeight * scale;
// //
// //       // Center the image
// //       final x = (pageWidth - scaledWidth) / 2;
// //       final y = (pageHeight - scaledHeight) / 2;
// //
// //       // Draw image with scaling - this maintains quality better than stretching
// //       page1.graphics.drawImage(coverImage,
// //           Rect.fromLTWH(x, y, scaledWidth, scaledHeight));
// //
// //     } catch (e) {
// //       // Fallback if image loading fails
// //       page1.graphics.drawRectangle(
// //           brush: PdfSolidBrush(PdfColor(0, 191, 165)),
// //           bounds: Rect.fromLTWH(0, 0, page1.getClientSize().width, page1.getClientSize().height));
// //       page1.graphics.drawString(
// //         'PROPERTY INSPECTION\nREPORT CARD\n(Placeholder for assets/title.jpg)',
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
// //
// //         // Compress property photo to reduce file size while maintaining quality
// //         final compressedPhoto = await _compressImage(photoBytes, quality: 85);
// //         final PdfBitmap propertyImage = PdfBitmap(compressedPhoto);
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
// //         bounds: Rect.fromLTWH(0, yPos, page2.getClientSize().width, 30),
// //         format: PdfStringFormat(alignment: PdfTextAlignment.center)
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
// //     final String introText = '''The purpose of the snagging inspection is to visually examine the property for defects, incomplete works, and non-compliance with specifications. This report documents findings that require attention before final handover.
// //
// // METHODOLOGY
// // Our report provides a visual inspection of accessible areas of the property. We identify and document any defects, incomplete items, or areas requiring remedial work. Each item is photographed and described in detail.
// //
// // LIMITATIONS
// // The inspection format covers visible and accessible areas only. No destructive testing or invasive inspection methods are employed. Electrical and mechanical systems are tested for basic functionality only.''';
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
// //       'Air Conditioning', 'Electrical', 'Plumbing', 'Walls and Ceilings',
// //       'Doors', 'Floors and Tiles', 'Joinery', 'General Items'
// //     ];
// //     for (var cat in checklistCategories) {
// //       page4.graphics.drawString(cat, bodyBoldFont, bounds: Rect.fromLTWH(0, p4y, page4.getClientSize().width, 20));
// //       p4y += 20;
// //       page4.graphics.drawString('• Complete inspection of $cat systems and components', bodyFont,
// //           bounds: Rect.fromLTWH(15, p4y, page4.getClientSize().width - 15, 20));
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
// //       ['Good', 'The overall condition is in excellent condition with no visible defects.'],
// //       ['Defective', 'The item requires repair or replacement to meet specifications.'],
// //       ['Missing', 'The item is missing and requires installation.'],
// //       ['Comment', 'Additional remarks or observations about the item.']
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
// //     // Remove the first page if needed
// //     if (loadedDoc.pages.count > 0) {
// //       loadedDoc.pages.removeAt(0);
// //     }
// //
// //     // Append remaining pages
// //     for (int i = 0; i < loadedDoc.pages.count; i++) {
// //       final PdfPage loadedPage = loadedDoc.pages[i];
// //
// //       // Remove margins for appended pages
// //       newDoc.pageSettings.margins.all = 0;
// //       newDoc.pageSettings.size = loadedPage.size;
// //
// //       final PdfTemplate template = loadedPage.createTemplate();
// //       final PdfPage newPage = newDoc.pages.add();
// //       newPage.graphics.drawPdfTemplate(template, const Offset(0, 0));
// //     }
// //
// //     // Save with optimized settings
// //     final List<int> bytes = await newDoc.save();
// //     newDoc.dispose();
// //     loadedDoc.dispose();
// //
// //     final Directory directory = await getApplicationDocumentsDirectory();
// //     final String path = '${directory.path}/DXB_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
// //     final File file = File(path);
// //     await file.writeAsBytes(bytes);
// //
// //     // Share the file
// //     // ignore: deprecated_member_use
// //     await Share.shareXFiles([XFile(path)], text: 'DXB Property Inspection Report');
// //   }
// //
// //   static void _drawField(PdfGraphics graphics, String label, String value, double yPos, PdfFont labelFont, PdfFont valueFont) {
// //     graphics.drawString(label, labelFont, bounds: Rect.fromLTWH(50, yPos, 150, 20));
// //     graphics.drawString(value, valueFont, bounds: Rect.fromLTWH(200, yPos, 300, 20));
// //   }
// //
// //   // Helper method to compress images with adjustable quality
// //   static Future<Uint8List> _compressImage(Uint8List imageBytes, {int quality = 85}) async {
// //     try {
// //       // Create a temporary file for the image
// //       final tempDir = await getTemporaryDirectory();
// //       final tempFile = File('${tempDir.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
// //       await tempFile.writeAsBytes(imageBytes);
// //
// //       // Decode and compress the image
// //       final ui.Image image = await decodeImageFromList(imageBytes);
// //
// //       // Create a picture recorder
// //       final recorder = ui.PictureRecorder();
// //       final canvas = Canvas(recorder);
// //
// //       // Draw the image with compression
// //       final paint = Paint();
// //       canvas.drawImage(image, Offset.zero, paint);
// //
// //       // Convert to bytes with quality setting
// //       final picture = recorder.endRecording();
// //       final img = await picture.toImage(image.width, image.height);
// //       final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
// //
// //       // Clean up
// //       if (await tempFile.exists()) {
// //         await tempFile.delete();
// //       }
// //
// //       return byteData?.buffer.asUint8List() ?? imageBytes;
// //     } catch (e) {
// //       // If compression fails, return original bytes
// //       return imageBytes;
// //     }
// //   }
// // }

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfGeneratorService {
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

    // Configure document settings
    newDoc.pageSettings.size = PdfPageSize.a4;

    // 🔥 Default stays SAME as your original (0 margin)
    newDoc.pageSettings.margins.all = 0;

    // Fonts
    final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 24, style: PdfFontStyle.bold);
    final PdfFont headingFont = PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold);
    final PdfFont bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
    final PdfFont bodyBoldFont = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);

    // =========================
    // PAGE 1: COVER (FULL BLEED)
    // =========================
// --- PAGE 1: COVER PAGE FULL BLEED (NO MARGINS) ---
    newDoc.pageSettings.margins.all = 0; // 🔥 remove margins for cover

    final PdfPage page1 = newDoc.pages.add();

    try {
      final ByteData imageData = await rootBundle.load('assets/title.jpg');
      final Uint8List imageBytes = imageData.buffer.asUint8List();

      final PdfBitmap coverImage = PdfBitmap(imageBytes);

      final Size pageSize = page1.getClientSize();

      // 🔥 Draw image EXACTLY to page size (edge-to-edge)
      page1.graphics.drawImage(
        coverImage,
        Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
      );

    } catch (e) {
      page1.graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(0, 191, 165)),
        bounds: Rect.fromLTWH(
          0,
          0,
          page1.getClientSize().width,
          page1.getClientSize().height,
        ),
      );

      page1.graphics.drawString(
        'PROPERTY INSPECTION\nREPORT CARD\n(Placeholder for assets/title.jpg)',
        titleFont,
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(
          0,
          0,
          page1.getClientSize().width,
          page1.getClientSize().height,
        ),
        format: PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle,
        ),
      );
    }

// 🔥 Restore margins for rest of document
    newDoc.pageSettings.margins.all = 40;
    // newDoc.pageSettings.margins.all = 0; // ensure no margin
    // final PdfPage page1 = newDoc.pages.add();
    //
    // try {
    //   final ByteData imageData = await rootBundle.load('assets/title.png');
    //   final Uint8List imageBytes = imageData.buffer.asUint8List();
    //   final PdfBitmap coverImage = PdfBitmap(imageBytes);
    //
    //   final Size pageSize = page1.getClientSize();
    //
    //   // 🔥 Edge-to-edge image (no gaps)
    //   page1.graphics.drawImage(
    //     coverImage,
    //     Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
    //   );
    //
    // } catch (_) {
    //   page1.graphics.drawRectangle(
    //     brush: PdfSolidBrush(PdfColor(0, 191, 165)),
    //     bounds: Rect.fromLTWH(0, 0, page1.getClientSize().width, page1.getClientSize().height),
    //   );
    //
    //   page1.graphics.drawString(
    //     'PROPERTY INSPECTION\nREPORT CARD\n(Placeholder for assets/title.png)',
    //     titleFont,
    //     brush: PdfBrushes.white,
    //     bounds: Rect.fromLTWH(0, 0, page1.getClientSize().width, page1.getClientSize().height),
    //     format: PdfStringFormat(
    //       alignment: PdfTextAlignment.center,
    //       lineAlignment: PdfVerticalAlignment.middle,
    //     ),
    //   );
    // }
    //
    // // 🔥 Keep margins SAME as your system (0)
    // newDoc.pageSettings.margins.all = 0;

    // =========================
    // PAGE 2
    // =========================

    final PdfPage page2 = newDoc.pages.add();
    double yPos = 20;

    final Rect imageRect = Rect.fromLTWH(0, yPos, page2.getClientSize().width, 250);

    if (propertyPhotoPath != null && propertyPhotoPath.isNotEmpty) {
      try {
        final File photoFile = File(propertyPhotoPath);
        final Uint8List photoBytes = await photoFile.readAsBytes();
        final PdfBitmap propertyImage = PdfBitmap(photoBytes);

        page2.graphics.drawImage(propertyImage, imageRect);
      } catch (e) {
        page2.graphics.drawRectangle(
          pen: PdfPen(PdfColor(0, 0, 0), width: 3),
          bounds: imageRect,
        );

        page2.graphics.drawString(
          'Error loading property photo',
          bodyFont,
          bounds: imageRect,
          format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle,
          ),
        );
      }
    } else {
      page2.graphics.drawRectangle(
        pen: PdfPen(PdfColor(0, 0, 0), width: 3),
        bounds: imageRect,
      );

      page2.graphics.drawString(
        'Property Image Placeholder',
        bodyFont,
        bounds: imageRect,
        format: PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle,
        ),
      );
    }

    yPos += 270;

    page2.graphics.drawString(
      '$age',
      headingFont,
      bounds: Rect.fromLTWH(0, yPos, page2.getClientSize().width, 30),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    yPos += 50;

    _drawField(page2.graphics, 'Property Address:', address, yPos, bodyBoldFont, bodyFont);
    yPos += 25;

    _drawField(page2.graphics, 'Inspection Date:', date, yPos, bodyBoldFont, bodyFont);
    yPos += 25;

    _drawField(page2.graphics, 'Inspected for:', inspectedFor, yPos, bodyBoldFont, bodyFont);
    yPos += 25;

    _drawField(page2.graphics, 'Inspected by:', inspectedBy, yPos, bodyBoldFont, bodyFont);

    // =========================
    // PAGE 3
    // =========================

    final PdfPage page3 = newDoc.pages.add();

    page3.graphics.drawString(
      'INTRODUCTION',
      headingFont,
      bounds: Rect.fromLTWH(0, 0, page3.getClientSize().width, 30),
    );

    final String cleanIntro = introText.replaceAll('**', '').replaceAll('*', '');

    page3.graphics.drawString(
      cleanIntro,
      bodyFont,
      bounds: Rect.fromLTWH(
        0,
        40,
        page3.getClientSize().width,
        page3.getClientSize().height - 40,
      ),
    );

    // =========================
    // PAGE 4
    // =========================

    final PdfPage page4 = newDoc.pages.add();

    final String page4Heading =
        'During Snagging, we inspect the following in your home:\n$address';

    page4.graphics.drawString(
      page4Heading,
      headingFont,
      bounds: Rect.fromLTWH(0, 0, page4.getClientSize().width, 50),
    );

    final String cleanSnagging = snaggingText.replaceAll('**', '').replaceAll('*', '');

    page4.graphics.drawString(
      cleanSnagging,
      bodyFont,
      bounds: Rect.fromLTWH(0, 60, page4.getClientSize().width, page4.getClientSize().height - 60),
    );

    // =========================
    // PAGE 5
    // =========================

    final PdfPage page5 = newDoc.pages.add();

    page5.graphics.drawString(
      'Property Details',
      headingFont,
      bounds: Rect.fromLTWH(0, 0, page5.getClientSize().width, 30),
    );

    final String cleanDetails = propertyDetailsText.replaceAll('**', '').replaceAll('*', '');

    page5.graphics.drawString(
      cleanDetails,
      bodyFont,
      bounds: Rect.fromLTWH(0, 40, page5.getClientSize().width, page5.getClientSize().height - 40),
    );

    // =========================
    // MERGE PDF
    // =========================

    final File uploadedFile = File(uploadedPdfPath);
    final Uint8List uploadedBytes = await uploadedFile.readAsBytes();
    final PdfDocument loadedDoc = PdfDocument(inputBytes: uploadedBytes);

    if (loadedDoc.pages.count > 0) {
      loadedDoc.pages.removeAt(0);
    }

    for (int i = 0; i < loadedDoc.pages.count; i++) {
      final PdfPage loadedPage = loadedDoc.pages[i];

      newDoc.pageSettings.margins.all = 0;
      newDoc.pageSettings.size = loadedPage.size;

      final PdfTemplate template = loadedPage.createTemplate();
      final PdfPage newPage = newDoc.pages.add();

      newPage.graphics.drawPdfTemplate(template, const Offset(0, 0));
    }

    // Save
    final List<int> bytes = await newDoc.save();
    newDoc.dispose();
    loadedDoc.dispose();

    final Directory directory = await getApplicationDocumentsDirectory();
    final String path =
        '${directory.path}/DXB_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';

    final File file = File(path);
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(path)],
      text: 'DXB Property Inspection Report',
    );
  }

  static void _drawField(
      PdfGraphics graphics,
      String label,
      String value,
      double yPos,
      PdfFont labelFont,
      PdfFont valueFont,
      ) {
    graphics.drawString(label, labelFont,
        bounds: Rect.fromLTWH(50, yPos, 150, 20));

    graphics.drawString(value, valueFont,
        bounds: Rect.fromLTWH(200, yPos, 300, 20));
  }
}