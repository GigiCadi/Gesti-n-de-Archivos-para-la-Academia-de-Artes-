// ============================================================
// Clase: ArchivoSesiones
// Maneja el archivo "sesiones.dat" como ARCHIVO INDEXADO
// ============================================================

class ArchivoSesiones {
  
  static final int LEN_CODIGO        = 20;
  static final int LEN_CEDULA        = 15;
  static final int LEN_NOMBRE        = 40;
  static final int LEN_ESPECIALIDAD  = 20;
  static final int LEN_FECHA         = 10;
  
  static final int RECORD_SIZE = (LEN_CODIGO + LEN_CEDULA + LEN_NOMBRE + 
                                  LEN_ESPECIALIDAD + LEN_FECHA) * 2 + 1;
  
  RandomAccessFile raf;
  String rutaArchivo;
  HashMap<String, Integer> indice;
  
  ArchivoSesiones(String rutaArchivo) {
    this.rutaArchivo = rutaArchivo;
    this.indice = new HashMap<String, Integer>();
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
      println("ERROR: no se pudo abrir el archivo de sesiones -> " + e.getMessage());
      return false;
    }
  }
  
  void cerrar() {
    try {
      if (raf != null) raf.close();
    } catch (IOException e) {
      println("ERROR al cerrar el archivo de sesiones: " + e.getMessage());
    }
  }
  
  private void construirIndice() throws IOException {
    indice.clear();
    long totalRegistros = raf.length() / RECORD_SIZE;
    for (int i = 0; i < totalRegistros; i++) {
      raf.seek((long) i * RECORD_SIZE);
      String codigo = leerCadenaFija(LEN_CODIGO);
      raf.skipBytes((LEN_CEDULA + LEN_NOMBRE + LEN_ESPECIALIDAD + LEN_FECHA) * 2);
      boolean eliminado = raf.readBoolean();
      if (!eliminado) {
        indice.put(codigo, i);
      }
    }
  }
  
  boolean existe(String codigo) {
    return indice.containsKey(codigo);
  }
  
  boolean crear(Sesion sesion) {
    if (existe(sesion.codigoUnico)) {
      println("Ya existe una sesión con ese código.");
      return false;
    }
    try {
      int nuevoRegistro = (int) (raf.length() / RECORD_SIZE);
      raf.seek(raf.length());
      escribirRegistro(sesion, false);
      indice.put(sesion.codigoUnico, nuevoRegistro);
      return true;
    } catch (IOException e) {
      println("ERROR al crear sesión: " + e.getMessage());
      return false;
    }
  }
  
  Sesion leer(String codigo) {
    Integer numRegistro = indice.get(codigo);
    if (numRegistro == null) return null;
    try {
      raf.seek((long) numRegistro * RECORD_SIZE);
      return leerRegistroCompleto();
    } catch (IOException e) {
      println("ERROR al leer sesión: " + e.getMessage());
      return null;
    }
  }
  
  boolean eliminar(String codigo) {
    Integer numRegistro = indice.get(codigo);
    if (numRegistro == null) {
      println("La sesión no existe.");
      return false;
    }
    try {
      long posBandera = (long) numRegistro * RECORD_SIZE + RECORD_SIZE - 1;
      raf.seek(posBandera);
      raf.writeBoolean(true);
      indice.remove(codigo);
      return true;
    } catch (IOException e) {
      println("ERROR al eliminar sesión: " + e.getMessage());
      return false;
    }
  }
  
  ArrayList<Sesion> listarTodas() {
    ArrayList<Sesion> resultado = new ArrayList<Sesion>();
    try {
      for (Integer numRegistro : indice.values()) {
        raf.seek((long) numRegistro * RECORD_SIZE);
        resultado.add(leerRegistroCompleto());
      }
    } catch (IOException e) {
      println("ERROR al listar sesiones: " + e.getMessage());
    }
    return resultado;
  }
  
  private void escribirRegistro(Sesion sesion, boolean eliminado) throws IOException {
    escribirCadenaFija(sesion.codigoUnico, LEN_CODIGO);
    escribirCadenaFija(sesion.cedulaAprendiz, LEN_CEDULA);
    escribirCadenaFija(sesion.nombreAprendiz, LEN_NOMBRE);
    escribirCadenaFija(sesion.especialidad, LEN_ESPECIALIDAD);
    escribirCadenaFija(sesion.cedulaInstructor, LEN_CEDULA);
    escribirCadenaFija(sesion.fechaSesion, LEN_FECHA);
    raf.writeBoolean(eliminado);
  }
  
  private Sesion leerRegistroCompleto() throws IOException {
    String codigo = leerCadenaFija(LEN_CODIGO);
    String cedulaAprendiz = leerCadenaFija(LEN_CEDULA);
    String nombreAprendiz = leerCadenaFija(LEN_NOMBRE);
    String especialidad = leerCadenaFija(LEN_ESPECIALIDAD);
    String cedulaInstructor = leerCadenaFija(LEN_CEDULA);
    String fechaSesion = leerCadenaFija(LEN_FECHA);
    raf.readBoolean();
    return new Sesion(codigo, cedulaAprendiz, nombreAprendiz, 
                     especialidad, cedulaInstructor, fechaSesion);
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
