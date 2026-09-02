// ============================================================
// Clase: ArchivoSesiones
// Maneja el archivo "sesiones.dat" como ARCHIVO INDEXADO
//
// Optimizaciones incluidas:
//  1) Índice secundario (indiceAprendizFecha): agrupa los números de
//     registro de sesiones activas por la llave "cedulaAprendiz|fecha".
//     Así, verificar si una sesión es duplicada ya NO recorre todas
//     las sesiones del archivo: solo revisa el pequeño grupo de
//     sesiones que ese aprendiz tiene ESE día (normalmente 0 o 1).
//  2) Lista de espacios libres (espaciosLibres): cuando se elimina
//     una sesión, su posición en el archivo se guarda para ser
//     reutilizada por la siguiente sesión que se cree, en lugar de
//     seguir creciendo el archivo indefinidamente.
// ============================================================

class ArchivoSesiones {
  
  static final int LEN_CODIGO        = 20;
  static final int LEN_CEDULA        = 15;
  static final int LEN_NOMBRE        = 40;
  static final int LEN_ESPECIALIDAD  = 20;
  static final int LEN_FECHA         = 10;
  
  // El registro guarda DOS cédulas (aprendiz e instructor): la fórmula
  // original solo contaba una LEN_CEDULA y por eso cada registro se
  // escribía 30 bytes más largo de lo calculado, corrompiendo el
  // archivo a partir del segundo registro. Se corrige aquí.
  static final int RECORD_SIZE = (LEN_CODIGO + LEN_CEDULA + LEN_CEDULA + LEN_NOMBRE + 
                                  LEN_ESPECIALIDAD + LEN_FECHA) * 2 + 1;
  
  RandomAccessFile raf;
  String rutaArchivo;
  HashMap<String, Integer> indice;                       // código de sesión -> número de registro
  HashMap<String, ArrayList<Integer>> indiceAprendizFecha; // "cedulaAprendiz|fecha" -> números de registro
  ArrayList<Integer> espaciosLibres;                     // huecos dejados por sesiones eliminadas
  
  ArchivoSesiones(String rutaArchivo) {
    this.rutaArchivo = rutaArchivo;
    this.indice = new HashMap<String, Integer>();
    this.indiceAprendizFecha = new HashMap<String, ArrayList<Integer>>();
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
  
  private String claveAprendizFecha(String cedulaAprendiz, String fecha) {
    return cedulaAprendiz + "|" + fecha;
  }
  
  private void construirIndice() throws IOException {
    indice.clear();
    indiceAprendizFecha.clear();
    espaciosLibres.clear();
    long totalRegistros = raf.length() / RECORD_SIZE;
    for (int i = 0; i < totalRegistros; i++) {
      raf.seek((long) i * RECORD_SIZE);
      String codigo = leerCadenaFija(LEN_CODIGO);
      String cedulaAprendiz = leerCadenaFija(LEN_CEDULA);
      raf.skipBytes((LEN_NOMBRE + LEN_ESPECIALIDAD + LEN_CEDULA) * 2);
      String fecha = leerCadenaFija(LEN_FECHA);
      boolean eliminado = raf.readBoolean();
      if (!eliminado) {
        indice.put(codigo, i);
        agregarAIndiceSecundario(cedulaAprendiz, fecha, i);
      } else {
        espaciosLibres.add(i);
      }
    }
  }
  
  private void agregarAIndiceSecundario(String cedulaAprendiz, String fecha, int numRegistro) {
    String clave = claveAprendizFecha(cedulaAprendiz, fecha);
    ArrayList<Integer> lista = indiceAprendizFecha.get(clave);
    if (lista == null) {
      lista = new ArrayList<Integer>();
      indiceAprendizFecha.put(clave, lista);
    }
    lista.add(numRegistro);
  }
  
  private void quitarDeIndiceSecundario(String cedulaAprendiz, String fecha, int numRegistro) {
    String clave = claveAprendizFecha(cedulaAprendiz, fecha);
    ArrayList<Integer> lista = indiceAprendizFecha.get(clave);
    if (lista != null) {
      lista.remove(Integer.valueOf(numRegistro));
      if (lista.isEmpty()) indiceAprendizFecha.remove(clave);
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
      int numRegistro;
      if (!espaciosLibres.isEmpty()) {
        // Reutiliza el hueco de una sesión eliminada en vez de crecer el archivo
        numRegistro = espaciosLibres.remove(espaciosLibres.size() - 1);
      } else {
        numRegistro = (int) (raf.length() / RECORD_SIZE);
      }
      raf.seek((long) numRegistro * RECORD_SIZE);
      escribirRegistro(sesion, false);
      indice.put(sesion.codigoUnico, numRegistro);
      agregarAIndiceSecundario(sesion.cedulaAprendiz, sesion.fechaSesion, numRegistro);
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
      // Se necesita leer el registro completo antes de borrarlo para
      // poder quitarlo también del índice secundario.
      raf.seek((long) numRegistro * RECORD_SIZE);
      Sesion s = leerRegistroCompleto();
      long posBandera = (long) numRegistro * RECORD_SIZE + RECORD_SIZE - 1;
      raf.seek(posBandera);
      raf.writeBoolean(true);
      indice.remove(codigo);
      quitarDeIndiceSecundario(s.cedulaAprendiz, s.fechaSesion, numRegistro);
      espaciosLibres.add(numRegistro);
      return true;
    } catch (IOException e) {
      println("ERROR al eliminar sesión: " + e.getMessage());
      return false;
    }
  }
  
  // Requerimiento no funcional: no se pueden registrar sesiones
  // duplicadas para el mismo instructor o el mismo aprendiz, es decir,
  // que ya exista una sesión activa con el mismo aprendiz, la misma
  // especialidad y la misma fecha (sin importar el instructor), o
  // una sesión activa con el mismo instructor y la misma fecha para
  // ese mismo aprendiz.
  //
  // OPTIMIZACIÓN: en vez de recorrer TODAS las sesiones del archivo,
  // usamos el índice secundario "cedulaAprendiz|fecha" para obtener
  // de una vez el pequeño subconjunto de sesiones que ese aprendiz
  // tiene ese día, y solo comparamos dentro de ese subconjunto.
  boolean existeSesionDuplicada(String cedulaAprendiz, String cedulaInstructor, String especialidad, String fecha) {
    ArrayList<Integer> candidatos = indiceAprendizFecha.get(claveAprendizFecha(cedulaAprendiz, fecha));
    if (candidatos == null || candidatos.isEmpty()) return false;
    try {
      for (Integer numRegistro : candidatos) {
        raf.seek((long) numRegistro * RECORD_SIZE);
        Sesion s = leerRegistroCompleto();
        boolean mismaEspecialidad = s.especialidad.equalsIgnoreCase(especialidad);
        boolean mismoInstructor = s.cedulaInstructor.equals(cedulaInstructor);
        if (mismaEspecialidad || mismoInstructor) return true;
      }
    } catch (IOException e) {
      println("ERROR al verificar sesiones duplicadas: " + e.getMessage());
    }
    return false;
  }

  ArrayList<Sesion> buscarPorInstructor(String cedulaInstructor) {
    ArrayList<Sesion> resultado = new ArrayList<Sesion>();
    try {
      for (Integer numRegistro : indice.values()) {
        raf.seek((long) numRegistro * RECORD_SIZE);
        Sesion s = leerRegistroCompleto();
        if (s.cedulaInstructor.equals(cedulaInstructor)) resultado.add(s);
      }
    } catch (IOException e) {
      println("ERROR al buscar sesiones por instructor: " + e.getMessage());
    }
    return resultado;
  }

  ArrayList<Sesion> buscarPorAprendiz(String cedulaAprendiz) {
    ArrayList<Sesion> resultado = new ArrayList<Sesion>();
    try {
      for (Integer numRegistro : indice.values()) {
        raf.seek((long) numRegistro * RECORD_SIZE);
        Sesion s = leerRegistroCompleto();
        if (s.cedulaAprendiz.equals(cedulaAprendiz)) resultado.add(s);
      }
    } catch (IOException e) {
      println("ERROR al buscar sesiones por aprendiz: " + e.getMessage());
    }
    return resultado;
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
