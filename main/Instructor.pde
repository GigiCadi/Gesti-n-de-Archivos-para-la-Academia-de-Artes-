// ============================================================
// Clase: Instructor
// Representa un instructor de la Academia de Artes Barranquilla.
// Es solo el "molde" de datos; el manejo del archivo indexado
// vive en ArchivoInstructores.pde
// ============================================================
class Instructor {

  String cedula;
  String nombre;
  String especialidad;
  String telefono;
  int sesionesRealizadas;

  Instructor(String cedula, String nombre, String especialidad, String telefono, int sesionesRealizadas) {
    this.cedula = cedula;
    this.nombre = nombre;
    this.especialidad = especialidad;
    this.telefono = telefono;
    this.sesionesRealizadas = sesionesRealizadas;
  }

  // Un instructor está disponible si tiene menos de 15 sesiones en el mes
  boolean estaDisponible() {
    return sesionesRealizadas < ArchivoInstructores.MAX_SESIONES_MES;
  }

  String toStringResumido() {
    return nombre + " | CC: " + cedula + " | " + especialidad +
           " | Sesiones: " + sesionesRealizadas + "/" + ArchivoInstructores.MAX_SESIONES_MES;
  }
}
