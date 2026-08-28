// ============================================================
// Clase: Sesion
// Representa una sesión de entrenamiento asignada
// ============================================================
class Sesion {
  
  String codigoUnico;
  String cedulaAprendiz;
  String nombreAprendiz;
  String especialidad;
  String cedulaInstructor;
  String fechaSesion;
  
  Sesion(String codigoUnico, String cedulaAprendiz, String nombreAprendiz, 
         String especialidad, String cedulaInstructor, String fechaSesion) {
    this.codigoUnico = codigoUnico;
    this.cedulaAprendiz = cedulaAprendiz;
    this.nombreAprendiz = nombreAprendiz;
    this.especialidad = especialidad;
    this.cedulaInstructor = cedulaInstructor;
    this.fechaSesion = fechaSesion;
  }
  
  String toStringResumido() {
    return "Código: " + codigoUnico + " | Aprendiz: " + nombreAprendiz +
           " | Especialidad: " + especialidad + " | Fecha: " + fechaSesion;
  }
}
