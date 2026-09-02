// ============================================================
// Clase: ArchivoInstructores
// Maneja el archivo "instructores.dat" como ARCHIVO INDEXADO
// ============================================================

class ArchivoInstructores {

  static final int MAX_SESIONES_MES = 15;

  static final int LEN_CEDULA       = 15;
  static final int LEN_NOMBRE       = 40;
  static final int LEN_ESPECIALIDAD = 20;
  static final int LEN_TELEFONO     = 15;

  static final int RECORD_SIZE =
      (LEN_CEDULA + LEN_NOMBRE + LEN_ESPECIALIDAD + LEN_TELEFONO) * 2 + 4 + 1;

  RandomAccessFile raf;
  String rutaArchivo;
  HashMap<String, Integer> indice;
  ArrayList<Integer> espaciosLibres; // huecos dejados por instructores eliminados, listos para reutilizar

  ArchivoInstructores(String rutaArchivo) {
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
      println("ERROR: no se pudo abrir el archivo de instructores -> " + e.getMessage());
      return false;
    }
  }

  void cerrar() {
    try {
      if (raf != null) raf.close();
    } catch (IOException e) {
      println("ERROR al cerrar el archivo de instructores: " + e.getMessage());
    }
  }

  private void construirIndice() throws IOException {
    indice.clear();
    espaciosLibres.clear();
    long totalRegistros = raf.length() / RECORD_SIZE;
    for (int i = 0; i < totalRegistros; i++) {
      raf.seek((long) i * RECORD_SIZE);
      String cedula = leerCadenaFija(LEN_CEDULA);
      raf.skipBytes((LEN_NOMBRE + LEN_ESPECIALIDAD + LEN_TELEFONO) * 2 + 4);
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

  boolean crear(Instructor inst) {
    if (existe(inst.cedula)) {
      println("No se puede crear: ya existe un instructor con esa cédula.");
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
      escribirRegistro(inst, false);
      indice.put(inst.cedula, nuevoRegistro);
      return true;
    } catch (IOException e) {
      println("ERROR al crear instructor: " + e.getMessage());
      return false;
    }
  }

  Instructor leer(String cedula) {
    Integer numRegistro = indice.get(cedula);
    if (numRegistro == null) return null;
    try {
      raf.seek((long) numRegistro * RECORD_SIZE);
      return leerRegistroCompleto();
    } catch (IOException e) {
      println("ERROR al leer instructor: " + e.getMessage());
      return null;
    }
  }

  boolean actualizar(Instructor inst) {
    Integer numRegistro = indice.get(inst.cedula);
    if (numRegistro == null) {
      println("No se puede actualizar: el instructor no existe.");
      return false;
    }
    try {
      raf.seek((long) numRegistro * RECORD_SIZE);
      escribirRegistro(inst, false);
      return true;
    } catch (IOException e) {
      println("ERROR al actualizar instructor: " + e.getMessage());
      return false;
    }
  }

  boolean eliminar(String cedula) {
    Integer numRegistro = indice.get(cedula);
    if (numRegistro == null) {
      println("No se puede eliminar: el instructor no existe.");
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
      println("ERROR al eliminar instructor: " + e.getMessage());
      return false;
    }
  }

  boolean incrementarSesion(String cedula) {
    Instructor inst = leer(cedula);
    if (inst == null) return false;
    if (!inst.estaDisponible()) return false;
    inst.sesionesRealizadas++;
    return actualizar(inst);
  }

  boolean reiniciarSesiones() {
    try {
      for (Integer numRegistro : indice.values()) {
        raf.seek((long) numRegistro * RECORD_SIZE);
        Instructor inst = leerRegistroCompleto();
        raf.seek((long) numRegistro * RECORD_SIZE);
        inst.sesionesRealizadas = 0;
        escribirRegistro(inst, false);
      }
      return true;
    } catch (IOException e) {
      println("ERROR al reiniciar sesiones: " + e.getMessage());
      return false;
    }
  }

  ArrayList<Instructor> disponiblesPorEspecialidad(String especialidad) {
    ArrayList<Instructor> resultado = new ArrayList<Instructor>();
    try {
      for (Integer numRegistro : indice.values()) {
        raf.seek((long) numRegistro * RECORD_SIZE);
        Instructor inst = leerRegistroCompleto();
        if (inst.especialidad.equalsIgnoreCase(especialidad) && inst.estaDisponible()) {
          resultado.add(inst);
        }
      }
    } catch (IOException e) {
      println("ERROR al listar disponibles: " + e.getMessage());
    }
    return resultado;
  }

  ArrayList<Instructor> listarTodos() {
    ArrayList<Instructor> resultado = new ArrayList<Instructor>();
    try {
      for (Integer numRegistro : indice.values()) {
        raf.seek((long) numRegistro * RECORD_SIZE);
        resultado.add(leerRegistroCompleto());
      }
    } catch (IOException e) {
      println("ERROR al listar instructores: " + e.getMessage());
    }
    return resultado;
  }

  private void escribirRegistro(Instructor inst, boolean eliminado) throws IOException {
    escribirCadenaFija(inst.cedula, LEN_CEDULA);
    escribirCadenaFija(inst.nombre, LEN_NOMBRE);
    escribirCadenaFija(inst.especialidad, LEN_ESPECIALIDAD);
    escribirCadenaFija(inst.telefono, LEN_TELEFONO);
    raf.writeInt(inst.sesionesRealizadas);
    raf.writeBoolean(eliminado);
  }

  private Instructor leerRegistroCompleto() throws IOException {
    String cedula = leerCadenaFija(LEN_CEDULA);
    String nombre = leerCadenaFija(LEN_NOMBRE);
    String especialidad = leerCadenaFija(LEN_ESPECIALIDAD);
    String telefono = leerCadenaFija(LEN_TELEFONO);
    int sesiones = raf.readInt();
    raf.readBoolean();
    return new Instructor(cedula, nombre, especialidad, telefono, sesiones);
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
