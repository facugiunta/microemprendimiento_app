class Customer {
  final String id;
  final String nombre;
  final String? email;
  final String? telefono;
  final String? direccion;
  final String? ciudad;
  final String? codigoPostal;
  final String estado;
  final String? notas;
  final DateTime creadoEn;

  Customer({
    required this.id,
    required this.nombre,
    this.email,
    this.telefono,
    this.direccion,
    this.ciudad,
    this.codigoPostal,
    required this.estado,
    this.notas,
    required this.creadoEn,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      email: json['email'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      ciudad: json['ciudad'],
      codigoPostal: json['codigo_postal'],
      estado: json['estado'] ?? 'activo',
      notas: json['notas'],
      creadoEn: DateTime.parse(
        json['creado_en'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
      'ciudad': ciudad,
      'codigo_postal': codigoPostal,
      'estado': estado,
      'notas': notas,
    };
  }
}
