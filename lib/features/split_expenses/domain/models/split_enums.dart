enum SplitStatus {
  pending('pending'),
  allAccepted('all_accepted'),
  confirmed('confirmed'),
  cancelled('cancelled');

  const SplitStatus(this.value);
  final String value;

  static SplitStatus fromString(String val) {
    return SplitStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == val.toLowerCase(),
      orElse: () => SplitStatus.pending,
    );
  }

  String get label {
    switch (this) {
      case SplitStatus.pending:
        return 'Chờ xác nhận';
      case SplitStatus.allAccepted:
        return 'Đã đồng thuận';
      case SplitStatus.confirmed:
        return 'Đã chốt sổ nợ';
      case SplitStatus.cancelled:
        return 'Đã hủy';
    }
  }
}

enum ParticipantStatus {
  pending('pending'),
  accepted('accepted'),
  rejected('rejected'),
  proposed('proposed');

  const ParticipantStatus(this.value);
  final String value;

  static ParticipantStatus fromString(String val) {
    return ParticipantStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == val.toLowerCase(),
      orElse: () => ParticipantStatus.pending,
    );
  }

  String get label {
    switch (this) {
      case ParticipantStatus.pending:
        return 'Đang chờ';
      case ParticipantStatus.accepted:
        return 'Đã đồng ý';
      case ParticipantStatus.rejected:
        return 'Đã từ chối';
      case ParticipantStatus.proposed:
        return 'Đề xuất lại';
    }
  }
}

enum SplitType {
  equal('equal'),
  custom('custom'),
  percentage('percentage');

  const SplitType(this.value);
  final String value;

  static SplitType fromString(String val) {
    return SplitType.values.firstWhere(
      (e) => e.value.toLowerCase() == val.toLowerCase(),
      orElse: () => SplitType.equal,
    );
  }

  String get label {
    switch (this) {
      case SplitType.equal:
        return 'Chia đều';
      case SplitType.custom:
        return 'Tùy chỉnh';
      case SplitType.percentage:
        return 'Phần trăm';
    }
  }
}
