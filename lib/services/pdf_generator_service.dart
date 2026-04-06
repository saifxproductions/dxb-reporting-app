import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfGeneratorService {
  // Your Custom Brand Color: #0db591
  static final PdfColor brandGreen = PdfColor(13, 181, 145);
  static final PdfColor darkGreen = PdfColor(10, 140, 112);
  static final PdfColor softBg = PdfColor(245, 250, 249);

  static Future<String> generateAndMergePdf({
    required String age,
    required String address,
    required String date,
    required String inspectedFor,
    required String inspectedBy,
    required String uploadedPdfPath,
    required String introText,
    required String snaggingText,
    required String propertyDetailsText,
    required String snagSummaryText,
    String? propertyPhotoPath,
    bool share = true,
  }) async {
    final PdfDocument newDoc = PdfDocument();

    // Setup Global Fonts
    final PdfFont titleFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      32,
      style: PdfFontStyle.bold,
    );
    final PdfFont headingFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      20,
      style: PdfFontStyle.bold,
    );
    final PdfFont subHeaderFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      12,
      style: PdfFontStyle.bold,
    );
    final PdfFont bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 11);
    final PdfFont bodyBoldFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      11,
      style: PdfFontStyle.bold,
    );

    // ==========================================
    // PAGE 1: COVER (FULL BLEED)
    // ==========================================
    newDoc.pageSettings.margins.all = 0;
    final PdfPage page1 = newDoc.pages.add();
    final Size pageSize = page1.getClientSize();

    try {
      final ByteData imageData = await rootBundle.load('assets/title.jpg');
      final Uint8List imageBytes = imageData.buffer.asUint8List();
      page1.graphics.drawImage(
        PdfBitmap(imageBytes),
        Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
      );
    } catch (e) {
      // Modern Graphical Fallback
      page1.graphics.drawRectangle(
        brush: PdfSolidBrush(brandGreen),
        bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
      );
      page1.graphics.drawPie(
        Rect.fromLTWH(-100, -100, 400, 400),
        0,
        360,
        brush: PdfSolidBrush(PdfColor(255, 255, 255, 30)),
      );
      page1.graphics.drawString(
        'PROPERTY\nINSPECTION\nREPORT',
        titleFont,
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(40, 0, pageSize.width - 80, pageSize.height),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle),
      );
    }

    // ==========================================
    // PAGE 2: PROPERTY OVERVIEW (ALL VERTICAL)
    // ==========================================
    newDoc.pageSettings.margins.all = 40;
    final PdfPage page2 = newDoc.pages.add();
    final double pageWidth = page2.getClientSize().width;
    double yPos = 0;

    _drawSleekHeader(
      page2.graphics,
      "PROPERTY OVERVIEW",
      headingFont,
      pageWidth,
    );
    yPos += 60;

    // Main Property Image
    // Main Property Image
    final Rect imageRect = Rect.fromLTWH(0, yPos, pageWidth, 250);

    if (propertyPhotoPath != null && propertyPhotoPath.isNotEmpty) {
      try {
        final Uint8List photoBytes = await File(
          propertyPhotoPath,
        ).readAsBytes();
        final PdfBitmap image = PdfBitmap(photoBytes);

        // 1. SAVE GRAPHICS STATE
        page2.graphics.save();

        // 2. SET CLIP AND DRAW IMAGE
        page2.graphics.setClip(bounds: imageRect);

        final double imageAspect = image.width / image.height;
        final double rectAspect = imageRect.width / imageRect.height;
        double drawWidth, drawHeight, offsetX, offsetY;

        if (imageAspect > rectAspect) {
          drawHeight = imageRect.height;
          drawWidth = imageRect.height * imageAspect;
          offsetX = imageRect.left - (drawWidth - imageRect.width) / 2;
          offsetY = imageRect.top;
        } else {
          drawWidth = imageRect.width;
          drawHeight = imageRect.width / imageAspect;
          offsetX = imageRect.left;
          offsetY = imageRect.top - (drawHeight - imageRect.height) / 2;
        }

        // 3. DRAW IMAGE (within clip bounds)
        page2.graphics.drawImage(
          image,
          Rect.fromLTWH(offsetX, offsetY, drawWidth, drawHeight),
        );

        // 4. RESTORE (remove clip before drawing border)
        page2.graphics.restore();

        // 5. DRAW BORDER AFTER RESTORE (ensures full, crisp border)
        // Replace step 5 with this:
        page2.graphics.drawRectangle(
          pen: PdfPen(PdfColor(13, 181, 145), width: 2.0),
          bounds: Rect.fromLTWH(
            imageRect.left + 0.5, // Slight offset for pixel alignment
            imageRect.top + 0.5,
            imageRect.width - 1, // Adjust for border width
            imageRect.height - 1,
          ),
        );
      } catch (e) {
        _drawGraphicalPlaceholder(
          page2.graphics,
          imageRect,
          "Property Photo Missing",
        );
      }
    } else {
      _drawGraphicalPlaceholder(
        page2.graphics,
        imageRect,
        "Property Image Placeholder",
      );
    }

    yPos += 270; // This spacing is now safe

    _drawInfoCard(
      page2.graphics,
      "Location",
      address,
      0,
      yPos,
      pageWidth,
      50,
      bodyBoldFont,
      bodyBoldFont,
    );
    yPos += 60;

    _drawInfoCard(
      page2.graphics,
      "Inspection Date",
      date,
      0,
      yPos,
      pageWidth,
      50,
      bodyBoldFont,
      bodyBoldFont,
    );
    yPos += 60;

    // _drawInfoCard(page2.graphics, "Property Age", age, 0, yPos, pageWidth, 50, bodyBoldFont, bodyFont);
    // yPos += 60;

    _drawInfoCard(
      page2.graphics,
      "Inspected For (Client)",
      inspectedFor,
      0,
      yPos,
      pageWidth,
      50,
      bodyBoldFont,
      bodyBoldFont,
    );
    yPos += 60;

    _drawInfoCard(
      page2.graphics,
      "Lead Inspector",
      inspectedBy,
      0,
      yPos,
      pageWidth,
      50,
      bodyBoldFont,
      bodyBoldFont,
    );

    // ==========================================
    // PAGE 3: INTRODUCTION
    // ==========================================
    final PdfPage page3 = newDoc.pages.add();
    _drawSleekHeader(
      page3.graphics,
      "EXECUTIVE SUMMARY",
      headingFont,
      page3.getClientSize().width,
    );

    _drawMarkdownBlocks(
      document: newDoc,
      startPage: page3,
      text: introText,
      regularFont: bodyFont,
      boldFont: bodyBoldFont,
      bounds: Rect.fromLTWH(
        0,
        70,
        page3.getClientSize().width,
        page3.getClientSize().height - 70,
      ),
    );

    // ==========================================
    // PAGE 4: SNAGGING DETAILS
    // ==========================================

    final PdfPage page4 = newDoc.pages.add();
    final double page4Width = page4.getClientSize().width;

    // 1. Header
    _drawSleekHeader(
      page4.graphics,
      "TECHNICAL OBSERVATIONS",
      headingFont,
      page4Width,
    );

    // 2. EXTRACTION: Removed internal extraction as it's now handled by the UI
    // int lastSnagCount = await _getLastEntryNumberFromPdf(uploadedPdfPath);

    // 3. FULL SENTENCE (with Auto-Wrap)
    // 3. SaaS-STYLE PROFESSIONAL GREEN INFO CARD
    const double margin = 20.0;
    const double cardHeight = 70.0; // Slightly taller for better breathability
    final double cardWidth = page4Width - (margin * 2);

// Define SaaS Professional Green Palette
    final PdfColor cardBgGreen = PdfColor(240, 249, 244); // Very Soft Mint/Sage Grey
    final PdfColor accentGreen = PdfColor(13, 148, 136);  // Professional Teal-Green (Emerald)
    final PdfColor textDeepGreen = PdfColor(20, 45, 40);  // Near-Black Green for high readability

// A. Draw the Card Background (Soft Mint)
    page4.graphics.drawRectangle(
      brush: PdfSolidBrush(cardBgGreen),
      bounds: Rect.fromLTWH(margin, 50, cardWidth, cardHeight),
    );

// B. Draw the Primary Accent Bar (Deep Emerald)
    page4.graphics.drawRectangle(
      brush: PdfSolidBrush(accentGreen),
      bounds: Rect.fromLTWH(margin, 50, 5, cardHeight), // 5px bold accent
    );

// C. Draw the Sentence with SaaS Spacing
    final PdfFont professionalFont = PdfStandardFont(
        PdfFontFamily.helvetica,
        13,
        style: PdfFontStyle.bold
    );

    PdfTextElement(
      text: snagSummaryText,
      font: professionalFont,
      brush: PdfSolidBrush(textDeepGreen),
      format: PdfStringFormat(
        lineSpacing: 4,
        alignment: PdfTextAlignment.left,
      ),
    ).draw(
      page: page4,
      bounds: Rect.fromLTWH(
          margin + 18, // Extra padding from the accent bar
          50 + 18,     // Centered vertically in the 70px card
          cardWidth - 30,
          500
      ),
    );

// 4. Update dynamic Y for the next block
// (Card Start + Card Height + Gap)
    double nextElementY = 50 + cardHeight + 35;
    // final PdfFont subHeadingBold1 = PdfStandardFont(
    //   PdfFontFamily.helvetica,
    //   14,
    //   style: PdfFontStyle.bold,
    // );
    // final String fullSentence =
    //     "During Snagging, Property Inspection noticed $lastSnagCount Snags issues were noted to be rectified for $address";
    //
    // PdfTextElement sentenceElement = PdfTextElement(
    //   text: fullSentence,
    //   font: subHeadingBold1,
    //   brush: PdfBrushes.black,
    //   format: PdfStringFormat(lineSpacing: 2, alignment: PdfTextAlignment.left),
    // );
    //
    // // Draw the sentence and capture the result to find the bottom position
    // PdfLayoutResult sentenceResult = sentenceElement.draw(
    //   page: page4,
    //   bounds: Rect.fromLTWH(0, 50, page4Width, 500),
    // )!;
    //
    // // 4. Calculate dynamic Y position for the snagging text
    // // This ensures it starts exactly after the sentence ends
    // double nextElementY = sentenceResult.bounds.bottom + 20;

    // 5. SNAGGING TEXT (Starts at nextElementY)
    _drawMarkdownBlocks(
      document: newDoc,
      startPage: page4,
      text: snaggingText,
      regularFont: bodyFont,
      boldFont: bodyBoldFont,
      bounds: Rect.fromLTWH(
        0,
        nextElementY,
        page4Width,
        page4.getClientSize().height - nextElementY,
      ),
    );

    // ==========================================
    // PAGE 5: DEFINITIONS & TABLE
    // ==========================================
    final PdfPage page5 = newDoc.pages.add();
    final double page5Width = page5.getClientSize().width;

    // 1. Main Brand Header (0db591)
    _drawSleekHeader(
      page5.graphics,
      "REPORT TERMINOLOGY",
      headingFont,
      page5Width,
    );

    // 2. New Black Sub-Heading "Property Details"
    final PdfFont subHeadingBold = PdfStandardFont(
      PdfFontFamily.helvetica,
      14,
      style: PdfFontStyle.bold,
    );

    page5.graphics.drawString(
      "Property Details",
      subHeadingBold,
      brush: PdfBrushes.black, // Explicitly set to Black
      bounds: Rect.fromLTWH(0, 50, page5Width, 25),
    );

    // 3. Bullet Points / Property Details Text
    final PdfLayoutResult? textResult = _drawMarkdownBlocks(
      document: newDoc,
      startPage: page5,
      text: propertyDetailsText,
      regularFont: bodyFont,
      boldFont: bodyBoldFont,
      bounds: Rect.fromLTWH(
        0,
        80,
        page5Width,
        page5.getClientSize().height - 80,
      ),
    );

    // 4. Grid / Table Logic remains below...
    // Determine the correct page to draw the table on (since the text may have pushed to a new page)
    PdfPage tablePage = textResult != null ? textResult.page : page5;
    double tableTop = (textResult != null)
        ? textResult.bounds.bottom + 30
        : 250;

    // If the remaining space is too small for the table and its headings, bump it to the next page
    if (tableTop + 150 > tablePage.getClientSize().height) {
      tablePage = newDoc.pages.add();
      tableTop = 50;
    }

    // 1. Add the Black Bold "Definitions" Heading
    tablePage.graphics.drawString(
      "Definitions",
      subHeadingBold,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(0, tableTop, tablePage.getClientSize().width, 25),
    );

    // 2. Adjust the Grid start position to be below the new heading
    double gridStartPos = tableTop + 35;

    // Modern Styled Grid
    final PdfGrid grid = PdfGrid();
    grid.columns.add(count: 2);
    grid.columns[0].width = 120;

    _addGridRow(grid, 'Room', 'Specific interior/exterior area evaluated.');
    _addGridRow(
      grid,
      'Status',
      'PASS: Functional\nOPEN: Rectification Needed\nFAIL: Immediate Action Required',
    );
    _addGridRow(
      grid,
      'Comments',
      'Detailed engineer notes on defects or health & safety concerns.',
    );

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
      page: tablePage,
      bounds: Rect.fromLTWH(
        0,
        gridStartPos,
        tablePage.getClientSize().width,
        0,
      ),
    );

    // ==========================================
    // PAGE 6: TRANSITION PAGE / SECTION HEADER
    // ==========================================
    newDoc.pageSettings.margins.all = 40;
    final PdfPage transitionPage = newDoc.pages.add();
    final Size tPageSize = transitionPage.getClientSize();
    final PdfGraphics tGraphics = transitionPage.graphics;

    // 1. Header Zone (Branding)
    try {
      final ByteData logoData = await rootBundle.load('assets/logo.jpg');
      final Uint8List logoBytes = logoData.buffer.asUint8List();
      final PdfBitmap logoImage = PdfBitmap(logoBytes);
      // Center logo with a reasonable width, e.g., 120
      double logoWidth = 120;
      double logoHeight = (logoImage.height / logoImage.width) * logoWidth;
      tGraphics.drawImage(
        logoImage,
        Rect.fromLTWH((tPageSize.width - logoWidth) / 2, 0, logoWidth, logoHeight),
      );
      
      PdfFont subBrandingFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
      tGraphics.drawString(
        "Dubai | United Arab Emirates",
        subBrandingFont,
        brush: PdfSolidBrush(PdfColor(100, 100, 100)),
        bounds: Rect.fromLTWH(0, logoHeight + 10, tPageSize.width, 15),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
    } catch (e) {
      // Fallback if logo not found
      PdfFont subBrandingFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
      tGraphics.drawString(
        "Dubai | United Arab Emirates",
        subBrandingFont,
        brush: PdfSolidBrush(PdfColor(100, 100, 100)),
        bounds: Rect.fromLTWH(0, 40, tPageSize.width, 15),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
    }

    // 2. Body Zone (The Message)
    PdfFont mainTitleFont = PdfStandardFont(PdfFontFamily.helvetica, 24, style: PdfFontStyle.bold);
    PdfFont subTitleFont = PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold);
    PdfFont descFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
    
    double bodyCenterY = tPageSize.height / 2 - 60;
    
    tGraphics.drawString(
      "SECTION 2",
      mainTitleFont,
      brush: PdfSolidBrush(brandGreen),
      bounds: Rect.fromLTWH(0, bodyCenterY, tPageSize.width, 30),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    
    tGraphics.drawString(
      "Detailed Inspection & Snagging Schedule",
      subTitleFont,
      brush: PdfSolidBrush(PdfColor(40, 40, 40)),
      bounds: Rect.fromLTWH(0, bodyCenterY + 40, tPageSize.width, 25),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
    
    tGraphics.drawString(
      "Comprehensive site observations and photographic evidence. Defects are categorized by area, trade, and severity.",
      descFont,
      brush: PdfSolidBrush(PdfColor(120, 120, 120)),
      bounds: Rect.fromLTWH(40, bodyCenterY + 75, tPageSize.width - 80, 40),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineSpacing: 4,
      ),
    );

    // 3. Footer Zone (Navigation)
    PdfFont footerFontInfo = PdfStandardFont(PdfFontFamily.helvetica, 10);
    PdfFont footerFontDisclaimer = PdfStandardFont(PdfFontFamily.helvetica, 8, style: PdfFontStyle.italic);
    
    tGraphics.drawString(
      "Report Section Start | Page 1",
      footerFontInfo,
      brush: PdfSolidBrush(PdfColor(150, 150, 150)),
      bounds: Rect.fromLTWH(0, tPageSize.height - 15, tPageSize.width, 15),
      format: PdfStringFormat(alignment: PdfTextAlignment.right),
    );
    
    tGraphics.drawString(
      "Indexing is mapped to original site audit records.",
      footerFontDisclaimer,
      brush: PdfSolidBrush(PdfColor(150, 150, 150)),
      bounds: Rect.fromLTWH(0, tPageSize.height - 15, tPageSize.width, 15),
      format: PdfStringFormat(alignment: PdfTextAlignment.left),
    );

    // ==========================================
    // MERGE EXTERNAL DOCUMENT
    // ==========================================
    final PdfDocument loadedDoc = PdfDocument(
      inputBytes: await File(uploadedPdfPath).readAsBytes(),
    );
    if (loadedDoc.pages.count > 0) loadedDoc.pages.removeAt(0);

    for (int i = 0; i < loadedDoc.pages.count; i++) {
      newDoc.pageSettings.margins.all = 0;
      final PdfPage newPage = newDoc.pages.add();
      newPage.graphics.drawPdfTemplate(
        loadedDoc.pages[i].createTemplate(),
        const Offset(0, 0),
      );
    }

    // SAVE & SHARE
    final List<int> bytes = await newDoc.save();
    newDoc.dispose();
    loadedDoc.dispose();

    final String sanitizedAddress = address
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '') // Remove common illegal chars
        .replaceAll(RegExp(r'\s+'), ' ')      // Replace spaces with underscores
        .trim();

    final String fileName = sanitizedAddress.isNotEmpty 
        ? sanitizedAddress 
        : "DXB_PRO_${DateTime.now().millisecondsSinceEpoch}";

    final String path =
        '${(await getApplicationDocumentsDirectory()).path}/$fileName.pdf';
    final File file = File(path);
    await file.writeAsBytes(bytes);
    if (share) {
      await Share.shareXFiles([
        XFile(path),
      ], subject: 'Premium Property Inspection Report');
    }
    
    return path;
  }

  // --- MODERN GRAPHICAL HELPERS ---

  static void _drawSleekHeader(
    PdfGraphics graphics,
    String text,
    PdfFont font,
    double width,
  ) {
    // Vertical Accent Line
    graphics.drawRectangle(
      brush: PdfSolidBrush(brandGreen),
      bounds: Rect.fromLTWH(0, 0, 5, 30),
    );
    // Text
    graphics.drawString(
      text,
      font,
      brush: PdfSolidBrush(brandGreen),
      bounds: Rect.fromLTWH(15, 0, width, 40),
    );
    // Subtle Divider

    graphics.drawLine(
      PdfPen(PdfColor(230, 230, 230), width: 1),
      Offset(0, 35),
      Offset(width, 35),
    );
  }

  static void _drawInfoCard(
    PdfGraphics graphics,
    String label,
    String value,
    double x,
    double y,
    double w,
    double h,
    PdfFont lFont,
    PdfFont vFont,
  ) {
    // Background Card
    graphics.drawRectangle(
      brush: PdfSolidBrush(softBg),
      pen: PdfPen(PdfColor(13, 181, 145, 50), width: 0.5),
      bounds: Rect.fromLTWH(x, y, w, h),
    );

    // Label - bold and larger font
    graphics.drawString(
      label.toUpperCase(),
      PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
      // increased from 8 → 12
      brush: PdfSolidBrush(darkGreen),
      bounds: Rect.fromLTWH(
        x + 10,
        y + 8,
        w - 20,
        16,
      ), // adjust height to fit bigger text
    );

    // Value - bold and larger font
    graphics.drawString(
      value,
      PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
      // use bold + bigger size
      brush: PdfSolidBrush(PdfColor(40, 40, 40)),
      bounds: Rect.fromLTWH(
        x + 10,
        y + 26,
        w - 20,
        20,
      ), // adjust y to avoid overlap
    );
  }

  static void _drawGraphicalPlaceholder(
    PdfGraphics graphics,
    Rect rect,
    String text,
  ) {
    graphics.drawRectangle(brush: PdfSolidBrush(softBg), bounds: rect);
    graphics.drawRectangle(
      pen: PdfPen(brandGreen, width: 1, dashStyle: PdfDashStyle.dash),
      bounds: rect.inflate(-10),
    );
    graphics.drawString(
      text,
      PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
      brush: PdfSolidBrush(brandGreen),
      bounds: rect,
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );
  }

  static void _addGridRow(PdfGrid grid, String title, String desc) {
    PdfGridRow row = grid.rows.add();
    row.cells[0].value = title;
    row.cells[1].value = desc;
  }

  /// NEW HELPER: Reads the last number in brackets from the uploaded file
  static Future<int> getLastEntryNumberFromPdf(String path) async {
    try {
      final File file = File(path);
      if (!await file.exists()) return 0;

      final PdfDocument document = PdfDocument(
        inputBytes: await file.readAsBytes(),
      );
      int totalPages = document.pages.count;
      if (totalPages == 0) return 0;

      // Use a more flexible Regex that handles potential spaces: ( 96 ) or (96)
      final RegExp regExp = RegExp(r'\(\s*(\d+)\s*\)');
      int highestFound = 0;

      // Scan the last 3 pages (or the whole doc if it's shorter)
      // to ensure we don't miss the snags if there's a long footer/summary at the end.
      int scanLimit = (totalPages > 3) ? totalPages - 3 : 0;

      for (int i = totalPages - 1; i >= scanLimit; i--) {
        final String pageText = PdfTextExtractor(
          document,
        ).extractText(startPageIndex: i);

        final Iterable<RegExpMatch> matches = regExp.allMatches(pageText);
        for (final match in matches) {
          int num = int.tryParse(match.group(1) ?? "0") ?? 0;
          if (num > highestFound) {
            highestFound = num;
          }
        }

        // If we found a substantial number on this page, we can likely stop scanning
        if (highestFound > 0) break;
      }

      document.dispose();
      return highestFound; // This will correctly return 39 for your Apt 607 file
    } catch (e) {
      debugPrint("Extraction Error: $e");
      return 0;
    }
  }

  /// Extracts Metadata from the first page of the uploaded PDF
  static Future<Map<String, String>> extractMetadataFromPdf(String path) async {
    try {
      final File file = File(path);
      if (!await file.exists()) return {};

      final PdfDocument document = PdfDocument(
        inputBytes: await file.readAsBytes(),
      );

      if (document.pages.count == 0) return {};

      final String pageText = PdfTextExtractor(document).extractText(startPageIndex: 0, endPageIndex: 0);
      document.dispose();

      String address = '';
      String date = '';

      // --- FORMAT 2: New Template (Blue Border) ---
      // Labels: Project, Address, Start Date
      final projectMatch = RegExp(r'Project:\s*(.*)', caseSensitive: false).firstMatch(pageText);
      final addrMatch = RegExp(r'Address:\s*(.*)', caseSensitive: false).firstMatch(pageText);
      final startDateMatch = RegExp(r'Start Date:\s*(.*)', caseSensitive: false).firstMatch(pageText);

      if (projectMatch != null || addrMatch != null || startDateMatch != null) {
        String project = projectMatch?.group(1)?.trim() ?? '';
        String addr = addrMatch?.group(1)?.trim() ?? '';
        address = [project, addr].where((s) => s.isNotEmpty).join(', ');
        date = startDateMatch?.group(1)?.trim() ?? '';
        return {'address': address, 'date': date};
      }

      // --- FORMAT 1: Original Template ---
      final dateMatch = RegExp(r'Created:\s*(.*)').firstMatch(pageText);
      if (dateMatch != null) {
        date = dateMatch.group(1)?.trim() ?? '';
      }

      final beforeCreated = pageText.split('Created:').first;
      final lines = beforeCreated
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && !e.toLowerCase().contains('inspection report') && !e.toLowerCase().contains('snagging'))
          .toList();

      if (lines.isNotEmpty) {
        address = lines.take(3).join(', ');
      }

      return {'address': address, 'date': date};
    } catch (e) {
      debugPrint("Metadata Extraction Error: $e");
      return {};
    }
  }

  /// Custom rich text renderer that handles block-level Markdown Bolding and ALL CAPS
  static PdfLayoutResult? _drawMarkdownBlocks({
    required PdfDocument document,
    required PdfPage startPage,
    required String text,
    required PdfFont regularFont,
    required PdfFont boldFont,
    required Rect bounds,
  }) {
    PdfPage currentPage = startPage;
    double currentY = bounds.top;
    PdfLayoutResult? lastResult;

    final lines = text.split('\n');

    for (var lineStr in lines) {
      if (lineStr.trim().isEmpty) {
        currentY += regularFont.height; 
        continue;
      }

      bool isBold = false;
      String cleanLine = lineStr.trim();

      // Check explicit bold "**Text**"
      if (cleanLine.startsWith('**') && cleanLine.endsWith('**') && cleanLine.length >= 4) {
        isBold = true;
        cleanLine = cleanLine.substring(2, cleanLine.length - 2).trim();
      } else if (cleanLine.contains('**')) {
        // Fallback: strip inline markdown asterisks to prevent rendering artifacts
        cleanLine = cleanLine.replaceAll('**', '');
      }

      // Check if ALL CAPS (ignoring punctuation/symbols)
      final alphas = cleanLine.replaceAll(RegExp(r'[^a-zA-Z]'), '');
      if (alphas.isNotEmpty && alphas == alphas.toUpperCase()) {
        isBold = true;
      }

      double availableHeight = currentPage.getClientSize().height - currentY;
      // Add a buffer (+ 20) to ensure we have enough space for the text and line spacing
      if (availableHeight < (isBold ? boldFont.height : regularFont.height) + 20) {
        currentPage = document.pages.add();
        currentY = 40; 
        availableHeight = currentPage.getClientSize().height - 40;
      }

      final result = PdfTextElement(
        text: cleanLine,
        font: isBold ? boldFont : regularFont,
        format: PdfStringFormat(lineSpacing: 4, wordWrap: PdfWordWrapType.character),
      ).draw(
        page: currentPage,
        bounds: Rect.fromLTWH(bounds.left, currentY, bounds.width, availableHeight),
        format: PdfLayoutFormat(
          layoutType: PdfLayoutType.paginate,
          paginateBounds: Rect.fromLTWH(bounds.left, 40, bounds.width, currentPage.getClientSize().height - 80),
        ),
      );

      if (result != null) {
        lastResult = result;
        currentPage = result.page;
        currentY = result.bounds.bottom + 6; // Add small spacing between block lines
      }
    }

    return lastResult;
  }
}
