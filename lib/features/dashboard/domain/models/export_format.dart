enum ExportFormat {
  pdf,
  excel,
  csv;

  String get title {
    switch (this) {
      case ExportFormat.pdf:
        return 'Báo cáo PDF (Định dạng Solarn)';
      case ExportFormat.excel:
        return 'Bảng tính Excel (.xlsx)';
      case ExportFormat.csv:
        return 'Dữ liệu thô CSV (.csv)';
    }
  }

  String get subtitle {
    switch (this) {
      case ExportFormat.pdf:
        return 'Định dạng tài liệu trực quan, biểu đồ và bố cục Solarn chuẩn in ấn';
      case ExportFormat.excel:
        return 'Đầy đủ bảng phân bổ danh mục, biểu đồ và công thức tài chính';
      case ExportFormat.csv:
        return 'Dữ liệu dạng bảng phân tách bằng dấu phẩy tiện phân tích';
    }
  }

  String get extension {
    switch (this) {
      case ExportFormat.pdf:
        return 'pdf';
      case ExportFormat.excel:
        return 'xlsx';
      case ExportFormat.csv:
        return 'csv';
    }
  }

  String get icon {
    switch (this) {
      case ExportFormat.pdf:
        return '📕';
      case ExportFormat.excel:
        return '📗';
      case ExportFormat.csv:
        return '📄';
    }
  }
}
