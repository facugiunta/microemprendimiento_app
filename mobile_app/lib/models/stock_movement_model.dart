class StockMovement {
  final String id;
  final String warehouseId;
  final String warehouseName;
  final String productId;
  final String productName;
  final String productCode;
  final String movementType;
  final int quantity;
  final String? referenceType;
  final String? referenceId;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;

  StockMovement({
    required this.id,
    required this.warehouseId,
    required this.warehouseName,
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.movementType,
    required this.quantity,
    this.referenceType,
    this.referenceId,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] ?? '',
      warehouseId: json['warehouse_id'] ?? '',
      warehouseName: json['warehouse_name'] ?? 'N/A',
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? 'N/A',
      productCode: json['product_code'] ?? '',
      movementType: json['movement_type'] ?? 'entrada',
      quantity: json['quantity'] ?? 0,
      referenceType: json['reference_type'],
      referenceId: json['reference_id'],
      notes: json['notes'],
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
