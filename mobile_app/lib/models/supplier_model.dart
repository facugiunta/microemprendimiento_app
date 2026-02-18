class Supplier {
  final String id;
  final String nombre;
  final String? email;
  final String? telefono;
  final String? contactoPersona;
  final String? direccion;
  final String? ciudad;
  final String? codigoPostal;
  final String? pais;
  final String estado;
  final int plazoPago;
  final String? notas;
  final DateTime creadoEn;

  Supplier({
    required this.id,
    required this.nombre,
    this.email,
    this.telefono,
    this.contactoPersona,
    this.direccion,
    this.ciudad,
    this.codigoPostal,
    this.pais,
    required this.estado,
    required this.plazoPago,
    this.notas,
    required this.creadoEn,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      email: json['email'],
      telefono: json['telefono'],
      contactoPersona: json['contacto_persona'],
      direccion: json['direccion'],
      ciudad: json['ciudad'],
      codigoPostal: json['codigo_postal'],
      pais: json['pais'],
      estado: json['estado'] ?? 'activo',
      plazoPago: json['plazo_pago'] ?? 30,
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
      'contacto_persona': contactoPersona,
      'direccion': direccion,
      'ciudad': ciudad,
      'codigo_postal': codigoPostal,
      'pais': pais,
      'estado': estado,
      'plazo_pago': plazoPago,
      'notas': notas,
    };
  }
}
