// ============================================================
// Clase: ArchivoAprendices
// Maneja el archivo "aprendices.dat" como ARCHIVO INDEXADO
//
// El campo de especialidades ahora guarda, en un solo campo de texto,
// TODAS las especialidades del aprendiz junto con su contador de
// sesiones de ESE mes para CADA especialidad (ver Aprendiz.pde),
// por ejemplo: "Baile:2;Pintura:0"
// ============================================================

class ArchivoAprendices {

  static final int LEN_CEDULA         = 15;
  static final int LEN_NOMBRE         = 40;
  // Longitud generosa para poder guardar varias especialidades
  // serializadas junto con su contador de sesiones.
  static final int LEN_ESPECIALIDADES = 150;

  // (cédula + nombre + especialidades) * 2 bytes por char (writeChar) + 1 byte de "eliminado"
  static final int RECORD_SIZE = (LEN_CEDULA + LEN_NOMBRE + LEN_ESPECIALIDADES) * 2 + 1;

  RandomAccessFile raf;
  String rutaArchivo;
  HashMap<String, Integer> indice;
  ArrayList<Integer> espaciosLibres; // huecos dejados por aprendices eliminados, listos para reutilizar

  ArchivoAprendices(String rutaArchivo) {
    this.rutaArchivo = rutaArchivo;
    this.indice = new HashMap<String, Integer>();
    this.espaciosLibres = new ArrayList<Integer>();
  }

  boolean abrir() {
    try {
      File f = new File(rutaArchivo);
      if (!f.getParentFile().exists()) {
        f.getParentFile().mkdirs();
      }
      raf = new RandomAccessFile(f, "rw");
      construirIndice();
      return true;
    } catch (IOException e) {
      println("ERROR: no se pudo abrir el archivo de aprendices -> " + e.getMessage());
      return false;
    }
  }

  void cerrar() {
    try {
      if (raf != null) raf.close();
    } catch (IOException e) {
      println("ERROR al cerrar el archivo de aprendices: " + e.getMessage());
    }
  }

  private void construirIndice() throws IOException {
    indice.clear();
    espaciosLibres.clear();
    long totalRegistros = raf.length() / RECORD_SIZE;
    for (int i = 0; i < totalRegistros; i++) {
      raf.seek((long) i * RECORD_SIZE);
      String cedula = leerCadenaFija(LEN_CEDULA);
      raf.skipBytes((LEN_NOMBRE + LEN_ESPECIALIDADES) * 2);
      boolean eliminado = raf.readBoolean();
      if (!eliminado) {
        indice.put(cedula, i);
      } else {
        espaciosLibres.add(i);
      }
    }
  }

  boolean existe(String cedula) {
    return indice.containsKey(cedula);
  }

  boolean crear(Aprendiz aprendiz) {
    if (existe(aprendiz.cedula)) {
      println("Ya existe un aprendiz con esa cédula.");
      return false;
    }
    try {
      int nuevoRegistro;
      if (!espaciosLibres.isEmpty()) {
        nuevoRegistro = espaciosLibres.remove(espaciosLibres.size() - 1);
      } else {
        nuevoRegistro = (int) (raf.length() / RECORD_SIZE);
      }
      raf.seek((long) nuevoRegistro * RECORD_SIZE);
      escribirRegistro(aprendiz, false);
      indice.put(aprendiz.cedula, nuevoRegistro);
      return true;
    } catch (IOException e) {
      println("ERROR al crear aprendiz: " + e.getMessage());
      return false;
    }
  }

  Aprendiz leer(String cedula) {
    Integer numRegistro = indice.get(cedula);
    if (numRegistro == null) return null;
    try {
      raf.seek((long) numRegistro * RECORD_SIZE);
      return leerRegistroCompleto();
    } catch (IOException e) {
      println("ERROR al leer aprendiz: " + e.getMessage());
      return null;
    }
  }

  boolean actualizar(Aprendiz aprendiz) {
    Integer numRegistro = indice.get(aprendiz.cedula);
    if (numRegistro == null) {
      println("El aprendiz no existe.");
      return false;
    }
    try {
      raf.seek((long) numRegistro * RECORD_SIZE);
      escribirRegistro(aprendiz, false);
      return true;
    } catch (IOException e) {
      println("ERROR al actualizar aprendiz: " + e.getMessage());
      return false;
    }
  }

  boolean eliminar(String cedula) {
    Integer numRegistro = indice.get(cedula);
    if (numRegistro == null) {
      println("El aprendiz no existe.");
      return false;
    }
    try {
      long posBandera = (long) numRegistro * RECORD_SIZE + RECORD_SIZE - 1;
      raf.seek(posBandera);
      raf.writeBoolean(true);
      indice.remove(cedula);
      espaciosLibres.add(numRegistro);
      return true;
    } catch (IOException e) {
      println("ERROR al eliminar aprendiz: " + e.getMessage());
      return false;
    }
  }

  // Incrementa el contador de sesiones del aprendiz PARA UNA ESPECIALIDAD
  // específica (el límite de 4 sesiones/mes es por especialidad).
  boolean incrementarSesion(String cedula, String especialidad) {
    Aprendiz aprendiz = leer(cedula);
    if (aprendiz == null) return false;
    if (!aprendiz.tieneEspecialidad(especialidad)) return false;
    if (!aprendiz.estaDisponibleEn(especialidad)) return false;
    aprendiz.incrementarSesionEn(especialidad);
    return actualizar(aprendiz);
  }

  // Revierte el contador de sesiones de una especialidad (usado al
  // cancelar una sesión ya asignada).
  boolean decrementarSesion(String cedula, String especialidad) {
    Aprendiz aprendiz = leer(cedula);
    if (aprendiz == null) return false;
    aprendiz.decrementarSesionEn(especialidad);
    return actualizar(aprendiz);
  }

  boolean reiniciarSesiones() {
    try {
      for (Integer numRegistro : indice.values()) {
        raf.seek((long) numRegistro * RECORD_SIZE);
        Aprendiz aprendiz = leerRegistroCompleto();
        aprendiz.reiniciarTodasLasSesiones();
        raf.seek((long) numRegistro * RECORD_SIZE);
        escribirRegistro(aprendiz, false);
      }
      return true;
    } catch (IOException e) {
      println("ERROR al reiniciar sesiones de aprendices: " + e.getMessage());
      return false;
    }
  }

  ArrayList<Aprendiz> listarTodos() {
    ArrayList<Aprendiz> resultado = new ArrayList<Aprendiz>();
    try {
      for (Integer numRegistro : indice.values()) {
        raf.seek((long) numRegistro * RECORD_SIZE);
        resultado.add(leerRegistroCompleto());
      }
    } catch (IOException e) {
      println("ERROR al listar aprendices: " + e.getMessage());
    }
    return resultado;
  }

  private void escribirRegistro(Aprendiz aprendiz, boolean eliminado) throws IOException {
    escribirCadenaFija(aprendiz.cedula, LEN_CEDULA);
    escribirCadenaFija(aprendiz.nombre, LEN_NOMBRE);
    escribirCadenaFija(aprendiz.serializarEspecialidades(), LEN_ESPECIALIDADES);
    raf.writeBoolean(eliminado);
  }

  private Aprendiz leerRegistroCompleto() throws IOException {
    String cedula = leerCadenaFija(LEN_CEDULA);
    String nombre = leerCadenaFija(LEN_NOMBRE);
    String especialidadesSerializadas = leerCadenaFija(LEN_ESPECIALIDADES);
    raf.readBoolean();
    return new Aprendiz(cedula, nombre, especialidadesSerializadas);
  }

  private void escribirCadenaFija(String texto, int longitud) throws IOException {
    String ajustado;
    if (texto.length() >= longitud) {
      ajustado = texto.substring(0, longitud);
    } else {
      StringBuilder sb = new StringBuilder(texto);
      while (sb.length() < longitud) sb.append(' ');
      ajustado = sb.toString();
    }
    for (int i = 0; i < longitud; i++) {
      raf.writeChar(ajustado.charAt(i));
    }
  }

  private String leerCadenaFija(int longitud) throws IOException {
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < longitud; i++) {
      sb.append(raf.readChar());
    }
    return sb.toString().trim();
  }
}
