class TransferOwnershipRequest {
  final String newOwnerId;

  const TransferOwnershipRequest({required this.newOwnerId});

  Map<String, dynamic> toJson() => {'newOwnerId': newOwnerId};
}

