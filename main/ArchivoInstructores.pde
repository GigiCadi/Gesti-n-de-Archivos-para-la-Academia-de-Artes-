// ============================================================
// Clase: ArchivoInstructores
// Maneja el archivo "instructores.dat" como ARCHIVO INDEXADO:
//   - Registros de LONGITUD FIJA (RandomAccessFile).
//   - Un índice en memoria (HashMap: cédula -> número de registro)
//     que permite ACCESO DIRECTO a cualquier registro sin leer
//     todo el archivo (seek directo a la posición calculada).
//   - Eliminación LÓGICA (se marca "eliminado", no se borra
//     físicamente), como es estándar en archivos indexados.
// ============================================================

class ArchivoInstructores {

  // ---- Constantes del negocio ----
  static final int MAX_SESIONES_MES = 15;

  // ---- Constantes de formato de registro (longitudes fijas en caracteres) ----
  static final int LEN_CEDULA       = 15;
  static final int LEN_NOMBRE       = 40;
  static final int LEN_ESPECIALIDAD = 20;
  static final int LEN_TELEFONO     = 15;

  // Cada char en RandomAccessFile.writeChar ocupa 2 bytes.
  // + 4 bytes del int (sesionesRealizadas) + 1 byte del boolean (eliminado)
  static final int RECORD_SIZE =
      (LEN_CEDULA + LEN_NOMBRE + LEN_ESPECIALIDAD + LEN_TELEFONO) * 2 + 4 + 1;

  RandomAccessFile raf;
  String rutaArchivo;

  // Índice en memoria: cédula -> número de registro (posición lógica en el archivo)
  HashMap<String, Integer> indice;

  ArchivoInstructores(String rutaArchivo) {
    this.rutaArchivo = rutaArchivo;
    this.indice = new HashMap<String, Integer>();
  }

  // ------------------------------------------------------------------
  // Abre (o crea si no existe) el archivo y reconstruye el índice
  // recorriendo los registros una sola vez al iniciar el programa.
  // ------------------------------------------------------------------
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

  // Recorre todo el archivo UNA vez para llenar el índice en memoria.
  // (Los registros marcados como eliminados no se agregan al índice).
  private void construirIndice() throws IOException {
    indice.clear();
    long totalRegistros = raf.length() / RECORD_SIZE;
    for (int i = 0; i < totalRegistros; i++) {
      raf.seek((long) i * RECORD_SIZE);
      String cedula = leerCadenaFija(LEN_CEDULA);
      raf.skipBytes((LEN_NOMBRE + LEN_ESPECIALIDAD + LEN_TELEFONO) * 2 + 4);
      boolean eliminado = raf.readBoolean();
      if (!eliminado) {
        indice.put(cedula, i);
      }
    }
  }

  // ------------------------------------------------------------------
  // Validación de existencia (requerimiento no funcional)
  // ------------------------------------------------------------------
  boolean existe(String cedula) {
    return indice.containsKey(cedula);
  }

  // ------------------------------------------------------------------
  // CREATE: agrega un instructor nuevo al final del archivo
  // ------------------------------------------------------------------
  boolean crear(Instructor inst) {
    if (existe(inst.cedula)) {
      println("No se puede crear: ya existe un instructor con esa cédula.");
      return false;
    }
    try {
      int nuevoRegistro = (int) (raf.length() / RECORD_SIZE);
      raf.seek(raf.length());
      escribirRegistro(inst, false);
      indice.put(inst.cedula, nuevoRegistro);
      return true;
    } catch (IOException e) {
      println("ERROR al crear instructor: " + e.getMessage());
      return false;
    }
  }

  // ------------------------------------------------------------------
  // READ: acceso DIRECTO al registro usando el índice (sin recorrer el archivo)
  // ------------------------------------------------------------------
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

  // ------------------------------------------------------------------
  // UPDATE: sobrescribe el registro existente en su misma posición
  // ------------------------------------------------------------------
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

  // ------------------------------------------------------------------
  // DELETE (lógico): marca el registro como eliminado y lo quita del índice
  // ------------------------------------------------------------------
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
      return true;
    } catch (IOException e) {
      println("ERROR al eliminar instructor: " + e.getMessage());
      return false;
    }
  }

  // ------------------------------------------------------------------
  // Incrementa en 1 las sesiones del instructor si tiene cupo disponible.
  // Retorna false si ya llegó al máximo de sesiones del mes.
  // ------------------------------------------------------------------
  boolean incrementarSesion(String cedula) {
    Instructor inst = leer(cedula);
    if (inst == null) return false;
    if (!inst.estaDisponible()) return false;
    inst.sesionesRealizadas++;
    return actualizar(inst);
  }

  // ------------------------------------------------------------------
  // Reinicia el contador de sesiones de TODOS los instructores activos a 0.
  // (Requerimiento: el archivo de instructores se reinicia cada mes).
  // ------------------------------------------------------------------
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

  // ------------------------------------------------------------------
  // Lista todos los instructores activos que dictan una especialidad
  // y que tienen cupo disponible este mes.
  // ------------------------------------------------------------------
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

  // Lista completa de instructores activos (para pantallas de consulta/listado)
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

  // ==================================================================
  // Métodos privados de lectura/escritura de bajo nivel (formato binario)
  // ==================================================================

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
    raf.readBoolean(); // bandera "eliminado", ya filtrada por el índice
    return new Instructor(cedula, nombre, especialidad, telefono, sesiones);
  }

  // Escribe una cadena en un campo de longitud fija, rellenando con
  // espacios o truncando según el caso, para que el registro siempre
  // ocupe exactamente el mismo número de bytes.
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
