import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ProductsRecord extends FirestoreRecord {
  ProductsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "nombre" field.
  String? _nombre;
  String get nombre => _nombre ?? '';
  bool hasNombre() => _nombre != null;

  // "marca" field.
  String? _marca;
  String get marca => _marca ?? '';
  bool hasMarca() => _marca != null;

  // "activo" field.
  bool? _activo;
  bool get activo => _activo ?? false;
  bool hasActivo() => _activo != null;

  // "aroma" field.
  String? _aroma;
  String get aroma => _aroma ?? '';
  bool hasAroma() => _aroma != null;

  // "categoria" field.
  String? _categoria;
  String get categoria => _categoria ?? '';
  bool hasCategoria() => _categoria != null;

  // "descripcion" field.
  String? _descripcion;
  String get descripcion => _descripcion ?? '';
  bool hasDescripcion() => _descripcion != null;

  // "imagen" field.
  String? _imagen;
  String get imagen => _imagen ?? '';
  bool hasImagen() => _imagen != null;

  // "notas" field.
  String? _notas;
  String get notas => _notas ?? '';
  bool hasNotas() => _notas != null;

  // "precio" field.
  double? _precio;
  double get precio => _precio ?? 0.0;
  bool hasPrecio() => _precio != null;

  // "stock" field.
  int? _stock;
  int get stock => _stock ?? 0;
  bool hasStock() => _stock != null;

  void _initializeFields() {
    _nombre = snapshotData['nombre'] as String?;
    _marca = snapshotData['marca'] as String?;
    _activo = snapshotData['activo'] as bool?;
    _aroma = snapshotData['aroma'] as String?;
    _categoria = snapshotData['categoria'] as String?;
    _descripcion = snapshotData['descripcion'] as String?;
    _imagen = snapshotData['imagen'] as String?;
    _notas = snapshotData['notas'] as String?;
    _precio = castToType<double>(snapshotData['precio']);
    _stock = castToType<int>(snapshotData['stock']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('products');

  static Stream<ProductsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ProductsRecord.fromSnapshot(s));

  static Future<ProductsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ProductsRecord.fromSnapshot(s));

  static ProductsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ProductsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ProductsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ProductsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ProductsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ProductsRecord && reference.path == other.reference.path;
}

Map<String, dynamic> createProductsRecordData({
  String? nombre,
  String? marca,
  bool? activo,
  String? aroma,
  String? categoria,
  String? descripcion,
  String? imagen,
  String? notas,
  double? precio,
  int? stock,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'nombre': nombre,
      'marca': marca,
      'activo': activo,
      'aroma': aroma,
      'categoria': categoria,
      'descripcion': descripcion,
      'imagen': imagen,
      'notas': notas,
      'precio': precio,
      'stock': stock,
    }.withoutNulls,
  );

  return firestoreData;
}

class ProductsRecordDocumentEquality implements Equality<ProductsRecord> {
  const ProductsRecordDocumentEquality();

  @override
  bool equals(ProductsRecord? e1, ProductsRecord? e2) {
    return e1?.nombre == e2?.nombre &&
        e1?.marca == e2?.marca &&
        e1?.activo == e2?.activo &&
        e1?.aroma == e2?.aroma &&
        e1?.categoria == e2?.categoria &&
        e1?.descripcion == e2?.descripcion &&
        e1?.imagen == e2?.imagen &&
        e1?.notas == e2?.notas &&
        e1?.precio == e2?.precio &&
        e1?.stock == e2?.stock;
  }

  @override
  int hash(ProductsRecord? e) => const ListEquality().hash([
        e?.nombre,
        e?.marca,
        e?.activo,
        e?.aroma,
        e?.categoria,
        e?.descripcion,
        e?.imagen,
        e?.notas,
        e?.precio,
        e?.stock
      ]);

  @override
  bool isValidKey(Object? o) => o is ProductsRecord;
}
