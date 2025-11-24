import 'dart:io';
import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/base_scaffold_widget.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../main.dart';

class PdfViewerComponent extends StatelessWidget {
  final String pdfFile;
  final bool isFile;
  const PdfViewerComponent({super.key, required this.pdfFile, this.isFile = false});

  @override
  Widget build(BuildContext context) {
    return AppScaffold( 
      appBarTitle: languages.viewPDF,
      body: isFile ? SfPdfViewer.file(File(pdfFile)) : SfPdfViewer.network(pdfFile),
    );
  }
}
