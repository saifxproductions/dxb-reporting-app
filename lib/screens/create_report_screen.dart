import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  File? _selectedPdf;
  File? _selectedPhoto;
  bool _isGenerating = false;

  final Color _primaryGreen = const Color(0xFF009688); // Teal-like green from screenshots
  final Color _bgGray = const Color(0xFFF5F5F5);
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
    }
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
                    const SizedBox(height: 16),
                    _buildModernTextField('Property Address', _addressController, Icons.location_on_outlined),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildModernTextField('Inspection Date', _dateController, Icons.calendar_today)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildModernTextField('Property Age', _ageController, Icons.history)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildModernTextField('Inspected for', _forController, Icons.person_outline),
                    const SizedBox(height: 12),
                    _buildModernTextField('Inspected by', _byController, Icons.badge_outlined),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- SECTION: CONTENT & DETAILS ---
              _buildSectionHeader(Icons.edit_note_outlined, "Report Content"),

              const Text("Introduction (Page 3)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
              const SizedBox(height: 8),
              const EditableSaaSDescriptionCard(),

              const SizedBox(height: 24),

              const Text("Snagging Areas (Page 4)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
              const SizedBox(height: 8),
              const ModernSnaggingCard(),

              const SizedBox(height: 32),

              // --- SECTION: DEFINITIONS ---
              _buildSectionHeader(Icons.list_alt_outlined, "Definitions & Legend"),
              const EditablePropertyDetailsCard(),
              const SizedBox(height: 12),
              const InspectionDefinitionTable(),

              const SizedBox(height: 32),

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

  Widget _buildModernTextField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 14),
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
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: _bgGray,
  //     appBar: AppBar(
  //       title: const Text('Create Report', style: TextStyle(fontWeight: FontWeight.w600)),
  //       backgroundColor: _primaryGreen,
  //       foregroundColor: Colors.white,
  //       elevation: 0,
  //       actions: [
  //         IconButton(
  //           icon: const Icon(Icons.share),
  //           onPressed: () {},
  //         )
  //       ],
  //     ),
  //     body: SingleChildScrollView(
  //       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
  //       child: Form(
  //         key: _formKey,
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             // Page 1 Header
  //             RichText(
  //               text: TextSpan(
  //                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
  //                 children: [
  //                   const TextSpan(text: 'Page 1 will have image from '),
  //                   TextSpan(text: 'assets directory', style: TextStyle(color: _primaryGreen)),
  //                 ],
  //               ),
  //             ),
  //             const SizedBox(height: 24),
  //
  //             // Page 2 Header
  //             const Text('Page 2', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //             const SizedBox(height: 12),
  //
  //             // Page 2 - Photo Upload Card
  //             GestureDetector(
  //               onTap: _pickPhoto,
  //               child: Container(
  //                 height: 160,
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey.shade300,
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 child: _selectedPhoto != null
  //                     ? ClipRRect(
  //                         borderRadius: BorderRadius.circular(8),
  //                         child: Image.file(_selectedPhoto!, fit: BoxFit.cover),
  //                       )
  //                     : Center(
  //                         child: Text(
  //                           'UPLOAD PROPERTY PHOTO',
  //                           style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
  //                         ),
  //                       ),
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //
  //             // Page 2 - Form Card
  //             Card(
  //               elevation: 0,
  //               color: Colors.white,
  //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //               child: Padding(
  //                 padding: const EdgeInsets.all(16.0),
  //                 child: Column(
  //                   children: [
  //                     _buildCustomTextField('Property Address', _addressController, 'e.g. APT 1904...'),
  //                     const SizedBox(height: 16),
  //                     _buildCustomTextField('Inspection Date', _dateController, 'Select Date...', icon: Icons.calendar_today),
  //                     const SizedBox(height: 16),
  //                     _buildCustomTextField('Inspected for', _forController, 'Enter client name...', icon: Icons.person_outline),
  //                     const SizedBox(height: 16),
  //                     _buildCustomTextField('Inspected by', _byController, 'Enter inspector name...', icon: Icons.person),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 24),
  //
  //             // Page 3 Header
  //             const Text('Page 3', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //             const SizedBox(height: 12),
  //
  //             // Page 3 - Introduction Card
  //             const EditableSaaSDescriptionCard(),
  //             // Card(
  //             //   elevation: 0,
  //             //   color: Colors.white,
  //             //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //             //   child: Padding(
  //             //     padding: const EdgeInsets.all(16.0),
  //             //     child: Column(
  //             //       crossAxisAlignment: CrossAxisAlignment.start,
  //             //       children: [
  //             //         ElevatedButton(
  //             //           onPressed: () {},
  //             //           style: ElevatedButton.styleFrom(
  //             //             backgroundColor: _primaryGreen,
  //             //             foregroundColor: Colors.white,
  //             //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //             //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
  //             //             minimumSize: const Size(60, 30),
  //             //           ),
  //             //           child: const Text('Edit', style: TextStyle(fontSize: 12)),
  //             //         ),
  //             //         const SizedBox(height: 12),
  //             //         Container(
  //             //           padding: const EdgeInsets.all(12),
  //             //           decoration: BoxDecoration(
  //             //             border: Border(left: BorderSide(color: _primaryGreen, width: 4)),
  //             //             color: _primaryGreen.withOpacity(0.05),
  //             //           ),
  //             //           child: const Text(
  //             //             'The purpose of this snagging inspection is to provide a comprehensive and detailed evaluation of the visible areas of the property. Our objective is to identify deviations from standard construction specifications, ensuring structural integrity, aesthetics...',
  //             //             style: TextStyle(fontSize: 13, color: Colors.black87),
  //             //           ),
  //             //         )
  //             //       ],
  //             //     ),
  //             //   ),
  //             // ),
  //             const SizedBox(height: 24),
  //
  //             // Page 4 Header
  //             RichText(
  //               text: TextSpan(
  //                 style: const TextStyle(fontSize: 14, color: Colors.black87),
  //                 children: [
  //                   const TextSpan(text: 'Page 4\n', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //                   const TextSpan(text: 'During snagging, we inspect the following in your home:\n(The heading will be dynamic to the Address)'),
  //                 ],
  //               ),
  //             ),
  //             const SizedBox(height: 12),
  //
  //             // Page 4 - Snagging Details Card
  //             ModernSnaggingCard(),
  //             // Card(
  //             //   elevation: 0,
  //             //   color: Colors.white,
  //             //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //             //   child: Padding(
  //             //     padding: const EdgeInsets.all(16.0),
  //             //     child: Column(
  //             //       crossAxisAlignment: CrossAxisAlignment.start,
  //             //       children: [
  //             //         Row(
  //             //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             //           children: [
  //             //             const Text('Snagging Area Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
  //             //             ElevatedButton(
  //             //               onPressed: () {},
  //             //               style: ElevatedButton.styleFrom(
  //             //                 backgroundColor: _primaryGreen.withOpacity(0.1),
  //             //                 foregroundColor: _primaryGreen,
  //             //                 elevation: 0,
  //             //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //             //                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
  //             //                 minimumSize: const Size(60, 30),
  //             //               ),
  //             //               child: const Text('Edit/Preview', style: TextStyle(fontSize: 10)),
  //             //             ),
  //             //           ],
  //             //         ),
  //             //         const SizedBox(height: 12),
  //             //         Container(
  //             //           padding: const EdgeInsets.all(12),
  //             //           decoration: BoxDecoration(
  //             //             border: Border.all(color: Colors.grey.shade200),
  //             //             borderRadius: BorderRadius.circular(8),
  //             //           ),
  //             //           child: const Column(
  //             //             crossAxisAlignment: CrossAxisAlignment.start,
  //             //             children: [
  //             //               Text('Air Conditioning', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
  //             //               Padding(
  //             //                 padding: EdgeInsets.only(left: 8.0, top: 4.0),
  //             //                 child: Text('• The AC system operates effectively.\n• All vents and filters are clean.', style: TextStyle(fontSize: 12, color: Colors.black54)),
  //             //               ),
  //             //             ],
  //             //           ),
  //             //         ),
  //             //         const SizedBox(height: 16),
  //             //       ],
  //             //     ),
  //             //   ),
  //             // ),
  //             const SizedBox(height: 24),
  //
  //             // Page 5 Header
  //             const Text('Page 5', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //             const SizedBox(height: 12),
  //
  //             // Page 5 - Property Details Definition
  //             EditablePropertyDetailsCard(),
  //             // Card(
  //             //   elevation: 0,
  //             //   color: Colors.white,
  //             //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //             //   child: Padding(
  //             //     padding: const EdgeInsets.all(16.0),
  //             //     child: Column(
  //             //       crossAxisAlignment: CrossAxisAlignment.start,
  //             //       children: [
  //             //         const Text('Property Details Definition', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
  //             //         const SizedBox(height: 12),
  //             //         Container(
  //             //           padding: const EdgeInsets.all(12),
  //             //           decoration: BoxDecoration(
  //             //             border: Border.all(color: Colors.grey.shade200),
  //             //             borderRadius: BorderRadius.circular(8),
  //             //           ),
  //             //           child: Column(
  //             //             crossAxisAlignment: CrossAxisAlignment.start,
  //             //             children: [
  //             //               _buildBullet('Good condition'),
  //             //               _buildBullet('Defective'),
  //             //               _buildBullet('Missing'),
  //             //               _buildBullet('Comment'),
  //             //               const SizedBox(height: 16),
  //             //               Center(
  //             //                 child: Icon(Icons.table_chart_outlined, color: Colors.grey.shade400, size: 40),
  //             //               ),
  //             //               const Center(child: Text('Table Preview', style: TextStyle(color: Colors.grey, fontSize: 12))),
  //             //             ],
  //             //           ),
  //             //         ),
  //             //       ],
  //             //     ),
  //             //   ),
  //             // ),
  //             const SizedBox(height: 24),
  //             InspectionDefinitionTable(), // New table component for Page 5
  //             const SizedBox(height: 24),
  //
  //             // Page 6 Header
  //             const Text('Page 6 and onwards', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //             const SizedBox(height: 12),
  //
  //             // Page 6 - Upload External PDF
  //             Card(
  //               elevation: 0,
  //               color: Colors.white,
  //               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //               child: Padding(
  //                 padding: const EdgeInsets.all(24.0),
  //                 child: Column(
  //                   children: [
  //                     Container(
  //                       padding: const EdgeInsets.all(16),
  //                       decoration: BoxDecoration(
  //                         color: _primaryGreen.withOpacity(0.1),
  //                         shape: BoxShape.circle,
  //                       ),
  //                       child: Icon(Icons.cloud_upload_outlined, color: _primaryGreen, size: 32),
  //                     ),
  //                     const SizedBox(height: 16),
  //                     const Text('Upload External PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
  //                     const SizedBox(height: 8),
  //                     const Text('Upload a file or tap to explore', style: TextStyle(color: Colors.black54, fontSize: 12)),
  //                     const SizedBox(height: 16),
  //                     ElevatedButton.icon(
  //                       onPressed: _pickPdf,
  //                       icon: const Icon(Icons.upload_file),
  //                       label: const Text('UPLOAD PDF'),
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: _primaryGreen,
  //                         foregroundColor: Colors.white,
  //                         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  //                       ),
  //                     ),
  //                     if (_selectedPdf != null) ...[
  //                       const SizedBox(height: 12),
  //                       Text('Selected: ${_selectedPdf!.path.split('/').last.split('\\').last}', style: TextStyle(color: _primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
  //                     ]
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 32),
  //
  //             // Action Buttons
  //             ElevatedButton(
  //               onPressed: _isGenerating ? null : () => _generatePdf(share: false),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: _primaryGreen,
  //                 foregroundColor: Colors.white,
  //                 padding: const EdgeInsets.symmetric(vertical: 16),
  //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  //               ),
  //               child: _isGenerating
  //                   ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
  //                   : const Text('Merge 5 Pages + Uploaded PDF &\nGenerate', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
  //             ),
  //             const SizedBox(height: 16),
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: ElevatedButton(
  //                     onPressed: () {}, // Handled automatically in our simple implementation
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: _primaryGreen,
  //                       foregroundColor: Colors.white,
  //                       padding: const EdgeInsets.symmetric(vertical: 16),
  //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  //                     ),
  //                     child: const Text('DOWNLOAD PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
  //                   ),
  //                 ),
  //                 const SizedBox(width: 16),
  //                 Expanded(
  //                   child: ElevatedButton(
  //                     onPressed: () {},
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: _primaryGreen,
  //                       foregroundColor: Colors.white,
  //                       padding: const EdgeInsets.symmetric(vertical: 16),
  //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  //                     ),
  //                     child: const Text('SHARE PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
  //                   ),
  //                 )
  //               ],
  //             ),
  //             const SizedBox(height: 48),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
}



class EditableSaaSDescriptionCard extends StatefulWidget {
  const EditableSaaSDescriptionCard({super.key});

  @override
  State<EditableSaaSDescriptionCard> createState() => _EditableSaaSDescriptionCardState();
}

class _EditableSaaSDescriptionCardState extends State<EditableSaaSDescriptionCard> {
  late TextEditingController _controller;
  bool _isEditing = false;
  final Color _primaryGreen = const Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    // Use ** for bold headers so the Markdown renderer picks them up
    _controller = TextEditingController(
      text: '''**OBJECTIVE:**
The purpose of this snagging inspection is to identify any defects in the property that require rectification by the developer. This inspection involves a thorough physical assessment, resulting in a detailed report highlighting the condition of all installed components, as well as any defects or maintenance concerns. By conducting this inspection, home owners gain a comprehensive understanding of their property, ensuring proper upkeep and maintenance.

**DETAILS:**
This report provides a visual inspection of the property, evaluating the quality of workmanship against construction standards. The focus is primarily on interior spaces. Any areas that could not be inspected for specific reasons will be noted; however, we cannot guarantee they are free from defects.

**LIMITATIONS:**
The inspection is limited to visible and accessible areas of the property. No paneling, furniture, or floor coverings were removed during the process. External features were assessed from ground level viewpoints, which restricts our ability to report on any unexposed or inaccessible areas.''',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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
            const SizedBox(height: 12),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isEditing
                  ? TextField(
                controller: _controller,
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
                  _controller.text,
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
}




class ModernSnaggingCard extends StatefulWidget {
  const ModernSnaggingCard({super.key});

  @override
  State<ModernSnaggingCard> createState() => _ModernSnaggingCardState();
}

class _ModernSnaggingCardState extends State<ModernSnaggingCard> {
  late TextEditingController _controller;
  bool _isEditing = false;
  final Color _primaryGreen = const Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    // Example text formatted for Markdown
    _controller = TextEditingController(
      text: "**Air Conditioning**\n\n• The AC system operates effectively.\n• All vents and filters are clean.",
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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
                const Text('Snagging Area Details',
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
    return TextButton.icon(
      onPressed: () => setState(() => _isEditing = !_isEditing),
      icon: Icon(_isEditing ? Icons.check_circle_outline : Icons.edit_note, size: 18),
      label: Text(_isEditing ? 'Done' : 'Edit'),
      style: TextButton.styleFrom(
        foregroundColor: _isEditing ? _primaryGreen : Colors.blueGrey,
        backgroundColor: _isEditing ? _primaryGreen.withOpacity(0.05) : Colors.transparent,
      ),
    );
  }

  Widget _buildEditor() {
    return TextField(
      controller: _controller,
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
      _controller.text,
      style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
    );
  }
}




class EditablePropertyDetailsCard extends StatefulWidget {
  const EditablePropertyDetailsCard({super.key});

  @override
  State<EditablePropertyDetailsCard> createState() => _EditablePropertyDetailsCardState();
}

class _EditablePropertyDetailsCardState extends State<EditablePropertyDetailsCard> {
  late TextEditingController _controller;
  bool _isEditing = false;
  final Color _primaryGreen = const Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    // Default data formatted as a list
    _controller = TextEditingController(
      text: "• Good condition\n• Defective\n• Missing\n• Comment",
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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
                  'Property Details Definition',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
      controller: _controller,
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
          _controller.text,
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