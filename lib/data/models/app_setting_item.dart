/// Model representing key-value configuration stored in app_settings table.
class AppSettingItem {
  final String key;
  final String value;
  final DateTime updatedAt;

  const AppSettingItem({
    required this.key,
    required this.value,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AppSettingItem.fromMap(Map<String, dynamic> map) {
    return AppSettingItem(
      key: map['key'] as String? ?? '',
      value: map['value'] as String? ?? '',
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
