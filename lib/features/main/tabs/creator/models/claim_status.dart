/// Server-side claim states for poet ownership.
enum ClaimStatus {
  /// Default for historical poets — anyone can claim.
  unclaimed,

  /// User submitted claim, awaiting admin review.
  pending,

  /// Admin approved (or auto-verified for new poets).
  verified,

  /// Admin rejected — user can resubmit.
  rejected;

  static ClaimStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'PENDING':
        return ClaimStatus.pending;
      case 'VERIFIED':
        return ClaimStatus.verified;
      case 'REJECTED':
        return ClaimStatus.rejected;
      case 'UNCLAIMED':
      default:
        return ClaimStatus.unclaimed;
    }
  }

  String get apiValue {
    switch (this) {
      case ClaimStatus.unclaimed:
        return 'UNCLAIMED';
      case ClaimStatus.pending:
        return 'PENDING';
      case ClaimStatus.verified:
        return 'VERIFIED';
      case ClaimStatus.rejected:
        return 'REJECTED';
    }
  }
}
