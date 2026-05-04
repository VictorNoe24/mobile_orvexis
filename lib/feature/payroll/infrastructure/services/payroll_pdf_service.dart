import 'dart:io';

import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_report_data.dart';
import 'package:mobile_orvexis/feature/payroll/domain/entities/payroll_report_item.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PayrollPdfService {
  const PayrollPdfService();

  Future<String> generateReport(PayrollReportData report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.fromLTRB(24, 24, 24, 28),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
        ),
        build: (context) => [
          _buildHeader(report),
          pw.SizedBox(height: 14),
          _buildMetaCard(report),
          pw.SizedBox(height: 14),
          _buildSummaryCards(report),
          pw.SizedBox(height: 14),
          _buildInfoBanner(),
          pw.SizedBox(height: 12),
          _buildEmployeesTable(report),
          pw.SizedBox(height: 18),
          _buildFooter(report),
        ],
      ),
    );

    final docsDir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory(p.join(docsDir.path, 'payroll_reports'));
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    final file = File(p.join(reportsDir.path, 'nomina_${report.runId}.pdf'));
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  pw.Widget _buildHeader(PayrollReportData report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8FBFF'),
        border: pw.Border.all(color: PdfColor.fromHex('#C8D9F1')),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 54,
            height: 54,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#E8F0FF'),
              border: pw.Border.all(color: PdfColor.fromHex('#90AEE7')),
            ),
            child: pw.Text(
              'ORV',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#1D4ED8'),
              ),
            ),
          ),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  report.organizationName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#1F3A8A'),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'RESUMEN DE NOMINA PAGADA',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#111827'),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Documento interno para control de pagos y descuentos aplicados por trabajador.',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfColor.fromHex('#64748B'),
                  ),
                ),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('#1D4ED8')),
            ),
            child: pw.Text(
              report.statusLabel.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#1D4ED8'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMetaCard(PayrollReportData report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#D6E1F1')),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(child: _metaItem('TIPO', _frequencyLabel(report.payFrequency))),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _metaItem('POLITICA', report.policyName)),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _metaItem('PERIODO', report.periodLabel)),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _metaItem('PAGO', report.payDateLabel)),
          pw.SizedBox(width: 12),
          pw.Expanded(child: _metaItem('FOLIO', _folio(report.runId))),
        ],
      ),
    );
  }

  pw.Widget _metaItem(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 7,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#64748B'),
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#111827'),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSummaryCards(PayrollReportData report) {
    return pw.Row(
      children: [
        _summaryCard('TRABAJADORES', '${report.employeesCount}'),
        pw.SizedBox(width: 10),
        _summaryCard('SUELDO BASE TOTAL', _currency(report.totalGrossAmount)),
        pw.SizedBox(width: 10),
        _summaryCard('DESCUENTOS TOTAL', _currency(report.totalDeductionsAmount)),
        pw.SizedBox(width: 10),
        _summaryCard('PAGADO TOTAL', _currency(report.totalNetAmount)),
      ],
    );
  }

  pw.Widget _summaryCard(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColor.fromHex('#D6E1F1')),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 7,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#64748B'),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#1D4ED8'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildInfoBanner() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F8FBFF'),
        border: pw.Border.all(color: PdfColor.fromHex('#D6E1F1')),
      ),
      child: pw.Text(
        'Este resumen muestra, por trabajador, el sueldo configurado del periodo, el descuento aplicado y el monto final efectivamente pagado.',
        style: pw.TextStyle(
          fontSize: 8,
          color: PdfColor.fromHex('#64748B'),
        ),
      ),
    );
  }

  pw.Widget _buildEmployeesTable(PayrollReportData report) {
    final headers = [
      'Trabajador',
      'Sueldo base',
      'Descuento',
      'Pago neto',
      'Estado',
    ];

    final rows = report.items
        .map(
          (item) => [
            item.employeeName,
            _currency(item.grossAmount),
            _currency(item.deductionsAmount),
            _currency(item.netAmount),
            _paymentState(item),
          ],
        )
        .toList();

    rows.add([
      'TOTALES:',
      _currency(report.totalGrossAmount),
      _currency(report.totalDeductionsAmount),
      _currency(report.totalNetAmount),
      '',
    ]);

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerDecoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#DCEAFE'),
      ),
      headerStyle: pw.TextStyle(
        fontSize: 8,
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromHex('#1E3A8A'),
      ),
      cellStyle: const pw.TextStyle(fontSize: 8.5),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      border: pw.TableBorder.all(
        color: PdfColor.fromHex('#D6E1F1'),
        width: 0.7,
      ),
      oddRowDecoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#FBFDFF'),
      ),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.center,
      },
      headerAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.center,
      },
      columnWidths: {
        0: const pw.FlexColumnWidth(3.3),
        1: const pw.FlexColumnWidth(1.4),
        2: const pw.FlexColumnWidth(1.4),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.2),
      },
      cellBuilder: (index, data, _) {
        final rowIndex = index ~/ headers.length;
        final columnIndex = index % headers.length;
        final isTotalsRow = rowIndex == rows.length - 1;
        final isStatusColumn = columnIndex == 4 && !isTotalsRow;
        final cellAlignment = switch (columnIndex) {
          0 => pw.Alignment.centerLeft,
          1 || 2 || 3 => pw.Alignment.centerRight,
          _ => pw.Alignment.center,
        };

        if (isStatusColumn) {
          return pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text(
              data,
              style: pw.TextStyle(
                fontSize: 8,
                color: PdfColor.fromHex('#111827'),
              ),
            ),
          );
        }

        return pw.Container(
          alignment: cellAlignment,
          child: pw.Text(
            data,
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: isTotalsRow ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: columnIndex == 2
                  ? PdfColor.fromHex('#DC2626')
                  : columnIndex == 3
                  ? PdfColor.fromHex('#1D4ED8')
                  : PdfColor.fromHex('#111827'),
            ),
          ),
        );
      },
    );
  }

  pw.Widget _buildFooter(PayrollReportData report) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Generado ${report.generatedAtLabel}',
          style: pw.TextStyle(
            fontSize: 7,
            color: PdfColor.fromHex('#64748B'),
          ),
        ),
        pw.Text(
          'Total neto pagado: ${_currency(report.totalNetAmount)}',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#1D4ED8'),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSignatures() {
    return pw.Row(
      children: [
        _signatureBlock('Elaboro', 'Recursos Humanos / Nominas'),
        pw.SizedBox(width: 24),
        _signatureBlock('Reviso', 'Gerencia Administrativa'),
        pw.SizedBox(width: 24),
        _signatureBlock('Autorizo', 'Direccion General'),
      ],
    );
  }

  pw.Widget _signatureBlock(String title, String subtitle) {
    return pw.Expanded(
      child: pw.Column(
        children: [
          pw.Container(height: 1, color: PdfColor.fromHex('#94A3B8')),
          pw.SizedBox(height: 8),
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#334155'),
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            subtitle,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 7,
              color: PdfColor.fromHex('#64748B'),
            ),
          ),
        ],
      ),
    );
  }

  String _paymentState(PayrollReportItem item) {
    if (item.deductionsAmount <= 0) {
      return 'Completo';
    }
    if (item.netAmount <= 0) {
      return 'Sin pago';
    }
    return 'Ajustado';
  }

  String _folio(String runId) {
    if (runId.length <= 10) {
      return runId.toUpperCase();
    }
    return '${runId.substring(0, 8).toUpperCase()}-6';
  }

  String _frequencyLabel(String payFrequency) {
    return payFrequency == 'biweekly' ? 'Nomina quincenal' : 'Nomina semanal';
  }

  String _currency(double amount) {
    final normalized = amount.isFinite ? amount : 0;
    final fixed = normalized.toStringAsFixed(2);
    final parts = fixed.split('.');
    final integer = parts.first;
    final decimals = parts.last;
    final chars = integer.split('').reversed.toList();
    final buffer = StringBuffer();

    for (var index = 0; index < chars.length; index++) {
      if (index > 0 && index % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(chars[index]);
    }

    return '\$${buffer.toString().split('').reversed.join()}.$decimals';
  }
}
