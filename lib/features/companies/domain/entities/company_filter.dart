import 'package:equatable/equatable.dart';

/// The three switches that make up the product's one question:
/// *which companies hire Flutter, are reachable from Delhi NCR or remote,
/// and which of those are about to hire?*
class CompanyFilter extends Equatable {
  /// Require evidence the company builds in Flutter.
  final bool flutterOnly;

  /// Require a posting in Delhi NCR or flagged remote.
  final bool ncrOrRemote;

  /// Require a funding or expansion signal in the last 90 days.
  final bool hiringSoon;

  const CompanyFilter({
    this.flutterOnly = true,
    this.ncrOrRemote = true,
    this.hiringSoon = false,
  });

  /// Defaults answer the question as asked. Both of the first two start on
  /// because a list without them is just "every company we have ever seen".
  static const CompanyFilter initial = CompanyFilter();

  CompanyFilter copyWith({
    bool? flutterOnly,
    bool? ncrOrRemote,
    bool? hiringSoon,
  }) =>
      CompanyFilter(
        flutterOnly: flutterOnly ?? this.flutterOnly,
        ncrOrRemote: ncrOrRemote ?? this.ncrOrRemote,
        hiringSoon: hiringSoon ?? this.hiringSoon,
      );

  Map<String, dynamic> toQuery({required int limit, required int offset}) => {
        'flutter_only': flutterOnly,
        'ncr_or_remote': ncrOrRemote,
        'hiring_soon': hiringSoon,
        'limit': limit,
        'offset': offset,
      };

  Map<String, dynamic> toJson() => {
        'flutter_only': flutterOnly,
        'ncr_or_remote': ncrOrRemote,
        'hiring_soon': hiringSoon,
      };

  static CompanyFilter fromJson(Map<String, dynamic> json) => CompanyFilter(
        flutterOnly: json['flutter_only'] as bool? ?? true,
        ncrOrRemote: json['ncr_or_remote'] as bool? ?? true,
        hiringSoon: json['hiring_soon'] as bool? ?? false,
      );

  int get activeCount =>
      (flutterOnly ? 1 : 0) + (ncrOrRemote ? 1 : 0) + (hiringSoon ? 1 : 0);

  @override
  List<Object?> get props => [flutterOnly, ncrOrRemote, hiringSoon];
}
