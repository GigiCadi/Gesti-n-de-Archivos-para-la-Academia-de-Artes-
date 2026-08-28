// ============================================================
// Clase: Aprendiz
// Representa un aprendiz de la Academia de Artes Barranquilla
// ============================================================
class Aprendiz {
  
  String cedula;
  String nombre;
  String especialidad;
  int sesionesRealizadas;
  
  static final int MAX_SESIONES_MES = 4;
  
  Aprendiz(String cedula, String nombre, String especialidad, int sesionesRealizadas) {
    this.cedula = cedula;
    this.nombre = nombre;
    this.especialidad = especialidad;
    this.sesionesRealizadas = sesionesRealizadas;
  }
  
  boolean estaDisponible() {
    return sesionesRealizadas < MAX_SESIONES_MES;
  }
  
  String toStringResumido() {
    return nombre + " | CC: " + cedula + " | " + especialidad +
           " | Sesiones: " + sesionesRealizadas + "/" + MAX_SESIONES_MES;
  }
}
