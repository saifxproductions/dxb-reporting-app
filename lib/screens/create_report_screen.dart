import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../services/pdf_generator_service.dart';

import 'package:gpt_markdown/gpt_markdown.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController(); // Not seen in new UI, but required by PDF
  final _addressController = TextEditingController();
  final _dateController = TextEditingController();
  final _forController = TextEditingController();
  final _byController = TextEditingController();
  
  final _introController = TextEditingController(
    text: '''**OBJECTIVE:**
The purpose of this snagging inspection is to identify any defects in the property that require rectification by the developer. This inspection involves a thorough physical assessment, resulting in a detailed report highlighting the condition of all installed components, as well as any defects or maintenance concerns. By conducting this inspection, home owners gain a comprehensive understanding of their property, ensuring proper upkeep and maintenance.

**DETAILS:**
This report provides a visual inspection of the property, evaluating the quality of workmanship against construction standards. The focus is primarily on interior spaces. Any areas that could not be inspected for specific reasons will be noted; however, we cannot guarantee they are free from defects.

**LIMITATIONS:**
The inspection is limited to visible and accessible areas of the property. No paneling, furniture, or floor coverings were removed during the process. External features were assessed from ground level viewpoints, which restricts our ability to report on any unexposed or inaccessible areas.''',
  );

  final _snaggingController = TextEditingController(
    text: "**Air Conditioning**\n\n• The AC system operates effectively.\n• All vents and filters are clean.",
  );

  final _detailsController = TextEditingController(
    text: "• Good condition\n• Defective\n• Missing\n• Comment",
  );
  
  final _snagCountController = TextEditingController(text: '0');
  late final TextEditingController _snagSummaryController;
  bool _isInternalUpdate = false;

  File? _selectedPdf;
  File? _selectedPhoto;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _snagSummaryController = TextEditingController(text: _generateSnagSummary());
    
    // Listen for changes to address and snag count to auto-update the summary
    _addressController.addListener(_handleSyncChange);
    _snagCountController.addListener(_handleSyncChange);
  }

  void _handleSyncChange() {
    if (_isInternalUpdate) return;
    setState(() {
      _snagSummaryController.text = _generateSnagSummary();
    });
  }

  String _generateSnagSummary() {
    final count = _snagCountController.text.isEmpty ? '0' : _snagCountController.text;
    final addr = _addressController.text.isEmpty ? '[Property Address]' : _addressController.text;
    return "During Snagging, Property Inspection noticed $count Snags issues were noted to be rectified for $addr.";
  }

  final Color _primaryGreen = const Color(0xFF009688); // Teal-like green from screenshots
  Color _backgroundColor = const Color(0xFFF8F9FA); // Standard SaaS light grey background
  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (!mounted) return;
      setState(() {
        _selectedPhoto = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      if (!mounted) return;
      setState(() {
        _selectedPdf = File(result.files.single.path!);
      });

      // Extract metadata from the uploaded PDF
      final metadata = await PdfGeneratorService.extractMetadataFromPdf(_selectedPdf!.path);
      if (metadata.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          if (metadata['address'] != null && metadata['address']!.isNotEmpty) {
            _addressController.text = metadata['address']!;
            _forController.text = metadata['address']!;
          }
          if (metadata['date'] != null && metadata['date']!.isNotEmpty) {

            // _dateController.text = metadata['date']!;
            _dateController.text = formatDateFromPDF( metadata['date']!);

          }
        });
      }

      // Extract snag count from PDF
      final count = await PdfGeneratorService.getLastEntryNumberFromPdf(_selectedPdf!.path);
      if (count > 0) {
        if (!mounted) return;
        setState(() {
          _isInternalUpdate = true;
          _snagCountController.text = count.toString();
          _snagSummaryController.text = _generateSnagSummary();
          _isInternalUpdate = false;
        });
      }
    }
  }

  String formatDateFromPDF(String dateString) {
    // Parse the input string: "Tue 24 Mar 10:53 2026"
    DateFormat inputFormat = DateFormat('EEE dd MMM HH:mm yyyy');

    // Parse the input string into a DateTime object
    DateTime parsedDate = inputFormat.parse(dateString);

    // Format the DateTime object to 'dd MMM yyyy' (e.g., '24 Mar 2026')
    DateFormat outputFormat = DateFormat('dd MMM yyyy');
    return outputFormat.format(parsedDate);
  }


  Future<void> _generatePdf({bool share = false}) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required text fields')),
      );
      return;
    }
    if (_selectedPdf == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an external PDF to merge with.')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      await PdfGeneratorService.generateAndMergePdf(
        age: _ageController.text.isEmpty ? 'N/A' : _ageController.text, // Age isn't visible in new UI, handle gracefully
        address: _addressController.text,
        date: _dateController.text,
        inspectedFor: _forController.text,
        inspectedBy: _byController.text,
        uploadedPdfPath: _selectedPdf!.path,
        propertyPhotoPath: _selectedPhoto?.path,
        introText: _introController.text,
        snaggingText: _snaggingController.text,
        propertyDetailsText: _detailsController.text,
        snagSummaryText: _snagSummaryController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF Generated Successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    _forController.dispose();
    _byController.dispose();
    _introController.dispose();
    _snaggingController.dispose();
    _detailsController.dispose();
    _snagCountController.dispose();
    _snagSummaryController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text("Report Builder", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.help_outline, color: Colors.grey)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECTION: COVER & INFO ---
              _buildSectionHeader(Icons.insert_drive_file_outlined, "Cover & Property Info"),

              // Cover Image Preview Card
              _buildSaaSCard(
                child: Column(
                  children: [
                    _buildPhotoUploader(),
                    const SizedBox(height: 20), // Increased spacing for a cleaner look
                    _buildModernTextField('Property Address', _addressController, Icons.location_on_outlined),
                    const SizedBox(height: 16),

                    // Inspection Date moved out of the Row to its own line
                    _buildModernTextField('Inspection Date', _dateController, Icons.calendar_today),
                    const SizedBox(height: 16),

                    // Property Age
                    _buildModernTextField('Property Age', _ageController, Icons.history),
                    const SizedBox(height: 16),

                    _buildModernTextField('Inspected for', _forController, Icons.person_outline),
                    const SizedBox(height: 16),

                    _buildModernTextField('Inspected by', _byController, Icons.badge_outlined),
                    const SizedBox(height: 12),
                    _buildInspectorChips(),
                    const Divider(height: 32),
                    
                    // New Snag Summary Section
                    const Text("SNAGGING SUMMARY", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1)),
                    const SizedBox(height: 12),
                    _buildModernTextField('Snag Count', _snagCountController, Icons.format_list_numbered, keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildModernTextField('Final Snag Summary Statement', _snagSummaryController, Icons.short_text, maxLines: 3),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- SECTION: CONTENT & DETAILS ---
              _buildSectionHeader(Icons.edit_note_outlined, "Report Content"),

              if (false) ...[
                const Text("Introduction (Page 3)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
                const SizedBox(height: 8),
                EditableSaaSDescriptionCard(controller: _introController),
                const SizedBox(height: 24),
              ],

              const Text("Snagging Areas (Page 4)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
              const SizedBox(height: 8),
              ModernSnaggingCard(controller: _snaggingController),

              const SizedBox(height: 32),

              // --- SECTION: DEFINITIONS ---
              _buildSectionHeader(Icons.list_alt_outlined, "Definitions & Legend"),
              EditablePropertyDetailsCard(controller: _detailsController),
              const SizedBox(height: 12),
              if (false) ...[
                _buildSectionHeader(Icons.table_chart_outlined, "Table"),
                const InspectionDefinitionTable(),
                const SizedBox(height: 32),
              ],

              // --- SECTION: ATTACHMENTS ---
              _buildSectionHeader(Icons.attachment_outlined, "External Attachments"),
              _buildPdfUploadCard(),

              const SizedBox(height: 40),

              // --- FINAL ACTIONS ---
              _buildFinalActions(),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

// --- REUSABLE SAAS UI COMPONENTS ---

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _primaryGreen),
          const SizedBox(width: 8),
          Text(title.toUpperCase(),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade800, letterSpacing: 1.1)),
        ],
      ),
    );
  }

  Widget _buildSaaSCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildModernTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 14),
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _primaryGreen, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildPhotoUploader() {
    return GestureDetector(
      onTap: _pickPhoto,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.none),
        ),
        child: _selectedPhoto != null
            ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_selectedPhoto!, fit: BoxFit.cover))
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: _primaryGreen, size: 40),
            const SizedBox(height: 8),
            Text("Tap to upload cover photo", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfUploadCard() {
    return _buildSaaSCard(
      child: Column(
        children: [
          Icon(Icons.picture_as_pdf_outlined, color: Colors.redAccent.withOpacity(0.7), size: 40),
          const SizedBox(height: 12),
          const Text("Append External PDF", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("This will be merged at the end of your report", style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickPdf,
            icon: const Icon(Icons.upload_file),
            label: Text(_selectedPdf == null ? "SELECT FILE" : "CHANGE FILE"),
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryGreen,
              side: BorderSide(color: _primaryGreen),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _isGenerating ? null : () => _generatePdf(share: false),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isGenerating
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("GENERATE FINAL REPORT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.2)),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildSecondaryAction(Icons.file_download_outlined, "DOWNLOAD", () {})),
            const SizedBox(width: 12),
            Expanded(child: _buildSecondaryAction(Icons.share_outlined, "SHARE", () {})),
          ],
        )
      ],
    );
  }

  Widget _buildSecondaryAction(IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        foregroundColor: Colors.blueGrey.shade700,
        side: BorderSide(color: Colors.blueGrey.shade200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildCustomTextField(String label, TextEditingController controller, String hint, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: icon != null ? Icon(icon, color: Colors.grey.shade400, size: 20) : null,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: Colors.grey.shade400, shape: BoxShape.circle),
          ),
          Expanded(child: Text(text, style: TextStyle(color: Colors.black54, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildInspectorChips() {
    final List<String> inspectors = [
      'Engr. Nafees',
      'Engr. Salman',
      'Engr. Inzi',
      'Engr. Sohaib',
      'Engr. Sajjad'
    ];

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text("Quick Select: ", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        ...inspectors.map((name) {
          return ActionChip(
            label: Text(name, style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade800)),
            backgroundColor: Colors.grey.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            onPressed: () {
              setState(() {
                _byController.text = name;
              });
            },
          );
        }),
      ],
    );
  }
}



class EditableSaaSDescriptionCard extends StatefulWidget {
  final TextEditingController controller;
  const EditableSaaSDescriptionCard({super.key, required this.controller});

  @override
  State<EditableSaaSDescriptionCard> createState() => _EditableSaaSDescriptionCardState();
}

class _EditableSaaSDescriptionCardState extends State<EditableSaaSDescriptionCard> {
  bool _isEditing = false;
  final Color _primaryGreen = const Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Property Description",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: _pasteFromClipboard,
                      icon: const Icon(Icons.paste, size: 16),
                      label: const Text('Paste', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _toggleEdit,
                      icon: Icon(_isEditing ? Icons.check_circle : Icons.edit, size: 16),
                      label: Text(_isEditing ? 'Save' : 'Edit', style: const TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: _isEditing ? _primaryGreen : Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isEditing
                  ? TextField(
                controller: widget.controller,
                maxLines: null,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _primaryGreen.withOpacity(0.05),
                  hintText: "Use **TEXT** for bold headers",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: _primaryGreen, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              )
                  : Container(
                key: const ValueKey("DisplayMode"),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: _primaryGreen, width: 4)),
                  color: _primaryGreen.withOpacity(0.05),
                ),
                // 🔥 CHANGED: Using GptMarkdown to render the bold headings
                child: GptMarkdown(
                  widget.controller.text,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.6, // Better readability for long text
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      setState(() {
        widget.controller.text = _formatSnaggingText(data.text!);
        _isEditing = true; // Auto-enter edit mode to show the new text
      });
    }
  }

  String _formatSnaggingText(String text) {
    final lines = text.split('\n');
    final formattedLines = <String>[];
    
    for (var line in lines) {
      var trimmed = line.trim();
      if (trimmed.isEmpty) {
        formattedLines.add('');
        continue;
      }

      // Check if it's a list item: starts with -, •, +, ., " followed by a space
      // OR starts with * followed by a space (ensures *NoSpace is a header)
      // OR starts with • or - at the beginning
      final listItemRegex = RegExp(r'^([\-\•\+\.\"”\.]\s+|^\*\s+|^[•\-]\s*)(.*)');
      final match = listItemRegex.firstMatch(trimmed);

      if (match != null) {
        // It's a list item. Standardize to -
        final content = match.group(2)?.trim() ?? '';
        formattedLines.add('- $content');
      } else {
        // It's a header.
        // Remove any existing wrapping like * or ** to avoid nesting
        var headerText = trimmed.replaceAll(RegExp(r'^\**|\**$'), '').trim();
        formattedLines.add('**$headerText**');
      }
    }
    
    return formattedLines.join('\n');
  }
}




class ModernSnaggingCard extends StatefulWidget {
  final TextEditingController controller;
  const ModernSnaggingCard({super.key, required this.controller});

  @override
  State<ModernSnaggingCard> createState() => _ModernSnaggingCardState();
}

class _ModernSnaggingCardState extends State<ModernSnaggingCard> {
  bool _isEditing = false;
  final Color _primaryGreen = const Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Snaggingx',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                _buildActionButton(),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: _isEditing ? _primaryGreen.withOpacity(0.3) : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(8),
                color: _isEditing ? Colors.grey.shade50 : Colors.white,
              ),
              child: _isEditing ? _buildEditor() : _buildPreview(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton.icon(
          onPressed: _pasteFromClipboard,
          icon: const Icon(Icons.paste, size: 18),
          label: const Text('Paste'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blueGrey,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
        const SizedBox(width: 4),
        TextButton.icon(
          onPressed: () => setState(() => _isEditing = !_isEditing),
          icon: Icon(_isEditing ? Icons.check_circle_outline : Icons.edit_note, size: 18),
          label: Text(_isEditing ? 'Done' : 'Edit'),
          style: TextButton.styleFrom(
            foregroundColor: _isEditing ? _primaryGreen : Colors.blueGrey,
            backgroundColor: _isEditing ? _primaryGreen.withOpacity(0.05) : Colors.transparent,
          ),
        ),
      ],
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      setState(() {
        widget.controller.text = _formatSnaggingText(data.text!);
        _isEditing = true; // Auto-enter edit mode to show the new text
      });
    }
  }

  String _formatSnaggingText(String text) {
    final lines = text.split('\n');
    final formattedLines = <String>[];
    
    for (var line in lines) {
      var trimmed = line.trim();
      if (trimmed.isEmpty) {
        formattedLines.add('');
        continue;
      }

      // Check if it's a list item: starts with -, •, +, ., " followed by a space
      // OR starts with * followed by a space (ensures *NoSpace is a header)
      // OR starts with • or - at the beginning
      final listItemRegex = RegExp(r'^([\-\•\+\.\"”\.]\s+|^\*\s+|^[•\-]\s*)(.*)');
      final match = listItemRegex.firstMatch(trimmed);

      if (match != null) {
        // It's a list item. Standardize to -
        final content = match.group(2)?.trim() ?? '';
        formattedLines.add('- $content');
      } else {
        // It's a header.
        // Remove any existing wrapping like * or ** to avoid nesting
        var headerText = trimmed.replaceAll(RegExp(r'^\**|\**$'), '').trim();
        formattedLines.add('**$headerText**');
      }
    }
    
    return formattedLines.join('\n');
  }

  Widget _buildEditor() {
    return TextField(
      controller: widget.controller,
      maxLines: null,
      autofocus: true,
      style: const TextStyle(fontSize: 13, height: 1.5),
      decoration: const InputDecoration(
        hintText: "Paste text here... (Use ** for bold)",
        border: InputBorder.none,
        isDense: true,
      ),
    );
  }

  Widget _buildPreview() {
    // GptMarkdown handles the 'WhatsApp style' bolding and bullets out of the box
    return GptMarkdown(
      widget.controller.text,
      style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
    );
  }
}




class EditablePropertyDetailsCard extends StatefulWidget {
  final TextEditingController controller;
  const EditablePropertyDetailsCard({super.key, required this.controller});

  @override
  State<EditablePropertyDetailsCard> createState() => _EditablePropertyDetailsCardState();
}

class _EditablePropertyDetailsCardState extends State<EditablePropertyDetailsCard> {
  bool _isEditing = false;
  final Color _primaryGreen = const Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Edit Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Property Definition',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: _pasteFromClipboard,
                      icon: const Icon(Icons.paste, size: 18),
                      label: const Text('Paste', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blueGrey,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _isEditing = !_isEditing),
                      icon: Icon(
                        _isEditing ? Icons.check_circle : Icons.edit_note,
                        color: _isEditing ? _primaryGreen : Colors.blueGrey,
                      ),
                      tooltip: _isEditing ? "Save" : "Edit",
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                    color: _isEditing ? _primaryGreen.withOpacity(0.5) : Colors.grey.shade200
                ),
                borderRadius: BorderRadius.circular(8),
                color: _isEditing ? Colors.grey.shade50 : Colors.white,
              ),
              child: _isEditing ? _buildEditor() : _buildPreview(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return TextField(
      controller: widget.controller,
      maxLines: null,
      autofocus: true,
      style: const TextStyle(fontSize: 13, height: 1.6),
      decoration: const InputDecoration(
        hintText: "Enter definitions (use • for bullets)",
        border: InputBorder.none,
        isDense: true,
      ),
    );
  }

  Widget _buildPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Renders the list professionally
        GptMarkdown(
          widget.controller.text,
          style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.6),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        Center(
          child: Column(
            children: [
              Icon(Icons.table_chart_outlined, color: Colors.grey.shade400, size: 32),
              const Text(
                'Table Preview',
                style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      setState(() {
        if (!mounted) return;
        widget.controller.text = _formatSnaggingText(data.text!);
        _isEditing = true;
      });
    }
  }

  String _formatSnaggingText(String text) {
    final lines = text.split('\n');
    final formattedLines = <String>[];
    
    for (var line in lines) {
      var trimmed = line.trim();
      if (trimmed.isEmpty) {
        formattedLines.add('');
        continue;
      }

      // Check if it's a list item: starts with -, •, +, ., " followed by a space
      // OR starts with * followed by a space (ensures *NoSpace is a header)
      // OR starts with • or - at the beginning
      final listItemRegex = RegExp(r'^([\-\•\+\.\"”\.]\s+|^\*\s+|^[•\-]\s*)(.*)');
      final match = listItemRegex.firstMatch(trimmed);

      if (match != null) {
        // It's a list item. Standardize to -
        final content = match.group(2)?.trim() ?? '';
        formattedLines.add('- $content');
      } else {
        // It's a header.
        // Remove any existing wrapping like * or ** to avoid nesting
        var headerText = trimmed.replaceAll(RegExp(r'^\**|\**$'), '').trim();
        formattedLines.add('**$headerText**');
      }
    }
    
    return formattedLines.join('\n');
  }
}



class InspectionDefinitionTable extends StatelessWidget {
  const InspectionDefinitionTable({super.key});

  final Color _primaryGreen = const Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1), // Label column
            1: FlexColumnWidth(2), // Content column
          },
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey.shade100, width: 1),
          ),
          children: [
            _buildRow('Room', 'The specific area or room in the property being inspected (e.g., Master Bedroom, Kitchen, Balcony, etc.).'),
            _buildStatusRow(),
            _buildRow('Comments', 'A description of the specific issues or observations in the room, highlighting defects, damages, or areas that need repair or maintenance.'),
          ],
        ),
      ),
    );
  }

  TableRow _buildRow(String label, String description) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(description, style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.4)),
        ),
      ],
    );
  }

  TableRow _buildStatusRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade50), // Subtle highlight for the status section
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('The result of the inspection for each area:', style: TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 8),
              _buildStatusBadge('PASS', 'In good condition & functional.', Colors.green),
              _buildStatusBadge('OPEN', 'Defects that need attention.', Colors.orange),
              _buildStatusBadge('FAIL', 'Urgent attention or repairs.', Colors.red),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String text, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(desc, style: const TextStyle(fontSize: 11, color: Colors.black87))),
        ],
      ),
    );
  }
}