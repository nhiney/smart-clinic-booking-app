import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../domain/entities/invoice_entity.dart';

/// Builds a printable PDF for an invoice and opens the share/print sheet.
class InvoicePdf {
  static final _currency = NumberFormat.decimalPattern('vi');

  static String _money(num value) => '${_currency.format(value)} đ';

  static Future<void> shareInvoice(InvoiceEntity invoice) async {
    final bytes = await _build(invoice);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'hoa-don-${invoice.id}.pdf',
    );
  }

  static Future<Uint8List> _build(InvoiceEntity invoice) async {
    final doc = pw.Document();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(invoice.createdAt);
    final isPaid = invoice.status.toLowerCase() == 'paid';

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('ICARE CLINIC',
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
            pw.SizedBox(height: 2),
            pw.Text('HÓA ĐƠN DỊCH VỤ Y TẾ', style: const pw.TextStyle(fontSize: 13, color: PdfColors.grey700)),
            pw.Divider(thickness: 1.2, color: PdfColors.blue800),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Mã hóa đơn: ${invoice.id}'),
                pw.Text('Ngày: $dateStr'),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Text('Trạng thái: ${isPaid ? 'ĐÃ THANH TOÁN' : 'CHƯA THANH TOÁN'}',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: isPaid ? PdfColors.green700 : PdfColors.orange700,
                )),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue50),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
              },
              headers: ['Dịch vụ', 'SL', 'Đơn giá', 'Thành tiền'],
              data: invoice.services
                  .map((s) => [
                        s.name,
                        '${s.quantity}',
                        _money(s.price),
                        _money(s.price * s.quantity),
                      ])
                  .toList(),
            ),
            pw.SizedBox(height: 12),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('TỔNG CỘNG: ${_money(invoice.total)}',
                  style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
            ),
            pw.Spacer(),
            pw.Center(
              child: pw.Text('Cảm ơn quý khách đã sử dụng dịch vụ của ICare.',
                  style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }
}
