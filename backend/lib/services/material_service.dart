import 'package:postgres/postgres.dart';
import '../models/material_model.dart';
import 'database_service.dart';

class MaterialService {
  final DatabaseService _db = DatabaseService();

  /// Get all materials
  Future<List<Material>> getAllMaterials() async {
    final conn = await _db.getConnection();

    try {
      final results = await conn.execute(
        'SELECT ID_Material, ID_Habilidad, Titulo, Tipo_Material, URL_Recurso, Contenido_Texto, Duracion_Minutos, Orden, Nivel_Acceso, Fecha_Creacion, Creado_Por FROM Materiales_Estudio ORDER BY ID_Habilidad, Orden ASC',
      );

      return results.map((row) {
        return Material.fromMap({
          'id': row[0],
          'habilidad_id': row[1],
          'titulo': row[2],
          'tipo_material': row[3],
          'url_recurso': row[4],
          'contenido_texto': row[5],
          'duracion_minutos': row[6],
          'orden': row[7],
          'nivel_acceso': row[8],
          'fecha_creacion': row[9]?.toString(),
          'creado_por': row[10],
        });
      }).toList();
    } finally {
      // Connection is managed by DatabaseService pool
    }
  }

  /// Get materials by skill ID
  Future<List<Material>> getMaterialsBySkillId(int skillId) async {
    final conn = await _db.getConnection();

    try {
      final results = await conn.execute(
        Sql.named('SELECT ID_Material, ID_Habilidad, Titulo, Tipo_Material, URL_Recurso, Contenido_Texto, Duracion_Minutos, Orden, Nivel_Acceso, Fecha_Creacion, Creado_Por FROM Materiales_Estudio WHERE ID_Habilidad = @skill_id ORDER BY Orden ASC'),
        parameters: {'skill_id': skillId},
      );

      return results.map((row) {
        return Material.fromMap({
          'id': row[0],
          'habilidad_id': row[1],
          'titulo': row[2],
          'tipo_material': row[3],
          'url_recurso': row[4],
          'contenido_texto': row[5],
          'duracion_minutos': row[6],
          'orden': row[7],
          'nivel_acceso': row[8],
          'fecha_creacion': row[9]?.toString(),
          'creado_por': row[10],
        });
      }).toList();
    } finally {
      // Connection is managed by DatabaseService pool
    }
  }

  /// Get material by ID
  Future<Material?> getMaterialById(int id) async {
    final conn = await _db.getConnection();

    try {
      final results = await conn.execute(
        Sql.named('SELECT ID_Material, ID_Habilidad, Titulo, Tipo_Material, URL_Recurso, Contenido_Texto, Duracion_Minutos, Orden, Nivel_Acceso, Fecha_Creacion, Creado_Por FROM Materiales_Estudio WHERE ID_Material = @id'),
        parameters: {'id': id},
      );

      if (results.isEmpty) return null;

      final row = results.first;
      return Material.fromMap({
        'id': row[0],
        'habilidad_id': row[1],
        'titulo': row[2],
        'tipo_material': row[3],
        'url_recurso': row[4],
        'contenido_texto': row[5],
        'duracion_minutos': row[6],
        'orden': row[7],
        'nivel_acceso': row[8],
        'fecha_creacion': row[9]?.toString(),
        'creado_por': row[10],
      });
    } finally {
      // Connection is managed by DatabaseService pool
    }
  }

  /// Create new material
  Future<Material> createMaterial(Material material) async {
    final conn = await _db.getConnection();

    try {
      final results = await conn.execute(
        Sql.named('''
          INSERT INTO Materiales_Estudio
          (ID_Habilidad, Titulo, Tipo_Material, URL_Recurso, Contenido_Texto, Duracion_Minutos, Orden, Nivel_Acceso, Creado_Por)
          VALUES (@habilidad_id, @titulo, @tipo_material, @url_recurso, @contenido_texto, @duracion_minutos, @orden, @nivel_acceso, @creado_por)
          RETURNING ID_Material, ID_Habilidad, Titulo, Tipo_Material, URL_Recurso, Contenido_Texto, Duracion_Minutos, Orden, Nivel_Acceso, Fecha_Creacion, Creado_Por
        '''),
        parameters: {
          'habilidad_id': material.habilidadId,
          'titulo': material.titulo,
          'tipo_material': material.tipoMaterial,
          'url_recurso': material.urlRecurso,
          'contenido_texto': material.contenidoTexto,
          'duracion_minutos': material.duracionMinutos,
          'orden': material.orden,
          'nivel_acceso': material.nivelAcceso,
          'creado_por': material.creadoPor,
        },
      );

      final row = results.first;
      return Material.fromMap({
        'id': row[0],
        'habilidad_id': row[1],
        'titulo': row[2],
        'tipo_material': row[3],
        'url_recurso': row[4],
        'contenido_texto': row[5],
        'duracion_minutos': row[6],
        'orden': row[7],
        'nivel_acceso': row[8],
        'fecha_creacion': row[9]?.toString(),
        'creado_por': row[10],
      });
    } finally {
      // Connection is managed by DatabaseService pool
    }
  }

  /// Update material
  Future<Material?> updateMaterial(int id, Material material) async {
    final conn = await _db.getConnection();

    try {
      final results = await conn.execute(
        Sql.named('''
          UPDATE Materiales_Estudio
          SET ID_Habilidad = @habilidad_id,
              Titulo = @titulo,
              Tipo_Material = @tipo_material,
              URL_Recurso = @url_recurso,
              Contenido_Texto = @contenido_texto,
              Duracion_Minutos = @duracion_minutos,
              Orden = @orden,
              Nivel_Acceso = @nivel_acceso,
              Creado_Por = @creado_por
          WHERE ID_Material = @id
          RETURNING ID_Material, ID_Habilidad, Titulo, Tipo_Material, URL_Recurso, Contenido_Texto, Duracion_Minutos, Orden, Nivel_Acceso, Fecha_Creacion, Creado_Por
        '''),
        parameters: {
          'id': id,
          'habilidad_id': material.habilidadId,
          'titulo': material.titulo,
          'tipo_material': material.tipoMaterial,
          'url_recurso': material.urlRecurso,
          'contenido_texto': material.contenidoTexto,
          'duracion_minutos': material.duracionMinutos,
          'orden': material.orden,
          'nivel_acceso': material.nivelAcceso,
          'creado_por': material.creadoPor,
        },
      );

      if (results.isEmpty) return null;

      final row = results.first;
      return Material.fromMap({
        'id': row[0],
        'habilidad_id': row[1],
        'titulo': row[2],
        'tipo_material': row[3],
        'url_recurso': row[4],
        'contenido_texto': row[5],
        'duracion_minutos': row[6],
        'orden': row[7],
        'nivel_acceso': row[8],
        'fecha_creacion': row[9]?.toString(),
        'creado_por': row[10],
      });
    } finally {
      // Connection is managed by DatabaseService pool
    }
  }

  /// Delete material
  Future<bool> deleteMaterial(int id) async {
    final conn = await _db.getConnection();

    try {
      final result = await conn.execute(
        Sql.named('DELETE FROM Materiales_Estudio WHERE ID_Material = @id'),
        parameters: {'id': id},
      );

      return result.affectedRows > 0;
    } finally {
      // Connection is managed by DatabaseService pool
    }
  }
}
