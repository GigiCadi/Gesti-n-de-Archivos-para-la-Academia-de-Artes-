// ============================================================
// Clase: Aprendiz
// Representa un aprendiz de la Academia de Artes Barranquilla
//
// NOTA IMPORTANTE: un aprendiz puede practicar VARIAS especialidades
// (ej: Baile y Pintura) y el límite de 4 sesiones/mes aplica de
// forma INDEPENDIENTE por cada especialidad (no un total global).
// Por eso las especialidades se guardan en un mapa
// "nombreEspecialidad -> sesionesRealizadasEsteMes".
// ============================================================

import java.util.LinkedHashMap;
import java.util.Map;

class Aprendiz {

  String cedula;
  String nombre;
  // Especialidad practicada -> cantidad de sesiones realizadas en el mes
  LinkedHashMap<String, Integer> especialidades;

  static final int MAX_SESIONES_MES = 4;

  // Constructor para un aprendiz nuevo, sin especialidades todavía
  Aprendiz(String cedula, String nombre) {
    this.cedula = cedula;
    this.nombre = nombre;
    this.especialidades = new LinkedHashMap<String, Integer>();
  }

  // Constructor a partir de un mapa de especialidades ya armado
  Aprendiz(String cedula, String nombre, LinkedHashMap<String, Integer> especialidades) {
    this.cedula = cedula;
    this.nombre = nombre;
    this.especialidades = (especialidades != null) ? especialidades : new LinkedHashMap<String, Integer>();
  }

  // Constructor a partir de la cadena serializada leída del archivo
  // Formato: "Baile:2;Pintura:0;Escritura:4"
  Aprendiz(String cedula, String nombre, String especialidadesSerializadas) {
    this.cedula = cedula;
    this.nombre = nombre;
    this.especialidades = deserializarEspecialidades(especialidadesSerializadas);
  }

  // ---- Utilidades de especialidades ----

  // Busca la clave real (con mayúsculas/minúsculas originales) que
  // corresponde a una especialidad, comparando sin distinguir mayúsculas.
  private String buscarClave(String especialidad) {
    if (especialidad == null) return null;
    String buscado = especialidad.trim();
    for (String clave : especialidades.keySet()) {
      if (clave.equalsIgnoreCase(buscado)) return clave;
    }
    return null;
  }

  boolean tieneEspecialidad(String especialidad) {
    return buscarClave(especialidad) != null;
  }

  int sesionesEn(String especialidad) {
    String clave = buscarClave(especialidad);
    if (clave == null) return 0;
    return especialidades.get(clave);
  }

  // Un aprendiz está disponible para una especialidad si la practica
  // y todavía no llega al máximo de sesiones de ESA especialidad.
  boolean estaDisponibleEn(String especialidad) {
    String clave = buscarClave(especialidad);
    if (clave == null) return false;
    return especialidades.get(clave) < MAX_SESIONES_MES;
  }

  // ¿Tiene cupo en AL MENOS una de sus especialidades?
  boolean tieneAlgunCupoDisponible() {
    for (int sesiones : especialidades.values()) {
      if (sesiones < MAX_SESIONES_MES) return true;
    }
    return false;
  }

  void incrementarSesionEn(String especialidad) {
    String clave = buscarClave(especialidad);
    if (clave == null) return;
    especialidades.put(clave, especialidades.get(clave) + 1);
  }

  void decrementarSesionEn(String especialidad) {
    String clave = buscarClave(especialidad);
    if (clave == null) return;
    int actual = especialidades.get(clave);
    especialidades.put(clave, Math.max(0, actual - 1));
  }

  void reiniciarTodasLasSesiones() {
    for (String clave : especialidades.keySet()) {
      especialidades.put(clave, 0);
    }
  }

  // Reemplaza el conjunto de especialidades practicadas. Las
  // especialidades que ya existían conservan su contador de sesiones;
  // las nuevas empiezan en 0.
  void establecerEspecialidades(ArrayList<String> nuevasEspecialidades) {
    LinkedHashMap<String, Integer> actualizado = new LinkedHashMap<String, Integer>();
    for (String esp : nuevasEspecialidades) {
      String limpio = esp.trim();
      if (limpio.isEmpty()) continue;
      String claveExistente = buscarClave(limpio);
      int sesiones = (claveExistente != null) ? especialidades.get(claveExistente) : 0;
      if (!existeClaveEnMapa(actualizado, limpio)) {
        actualizado.put(limpio, sesiones);
      }
    }
    this.especialidades = actualizado;
  }

  private boolean existeClaveEnMapa(LinkedHashMap<String, Integer> mapa, String clave) {
    for (String k : mapa.keySet()) {
      if (k.equalsIgnoreCase(clave)) return true;
    }
    return false;
  }

  // ---- Serialización para el archivo indexado ----

  String serializarEspecialidades() {
    StringBuilder sb = new StringBuilder();
    for (Map.Entry<String, Integer> entrada : especialidades.entrySet()) {
      if (sb.length() > 0) sb.append(";");
      sb.append(entrada.getKey()).append(":").append(entrada.getValue());
    }
    return sb.toString();
  }

  LinkedHashMap<String, Integer> deserializarEspecialidades(String datos) {
    LinkedHashMap<String, Integer> mapa = new LinkedHashMap<String, Integer>();
    if (datos == null || datos.trim().isEmpty()) return mapa;
    String[] pares = datos.split(";");
    for (String par : pares) {
      if (par == null || par.trim().isEmpty()) continue;
      String[] partes = par.split(":");
      if (partes.length == 2) {
        try {
          mapa.put(partes[0].trim(), Integer.parseInt(partes[1].trim()));
        } catch (NumberFormatException e) {
          // registro corrupto: se ignora esa especialidad puntual
        }
      }
    }
    return mapa;
  }

  // ---- Presentación ----

  String especialidadesResumenCorto() {
    if (especialidades.isEmpty()) return "Sin especialidades";
    StringBuilder sb = new StringBuilder();
    boolean primero = true;
    for (Map.Entry<String, Integer> entrada : especialidades.entrySet()) {
      if (!primero) sb.append(", ");
      sb.append(entrada.getKey()).append(" (").append(entrada.getValue())
        .append("/").append(MAX_SESIONES_MES).append(")");
      primero = false;
    }
    return sb.toString();
  }

  String toStringResumido() {
    return nombre + " | CC: " + cedula + " | " + especialidadesResumenCorto();
  }
}
