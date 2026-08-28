// ============================================================
// COMPONENTES DE INTERFAZ - Estilo Academia de Artes Barranquilla
// ============================================================

// ---- COLORES DE LA ACADEMIA ----
color COLOR_PRIMARIO = color(41, 65, 115);      // Azul oscuro
color COLOR_SECUNDARIO = color(26, 115, 232);   // Azul brillante
color COLOR_FONDO = color(245, 247, 250);       // Fondo gris claro
color COLOR_TARJETA = color(255, 255, 255);     // Blanco
color COLOR_TEXTO = color(30, 30, 30);          // Gris oscuro
color COLOR_TEXTO_CLARO = color(100, 100, 100); // Gris medio
color COLOR_GRADIENTE1 = color(26, 115, 232);
color COLOR_GRADIENTE2 = color(15, 70, 150);

// ---- CLASE BOTÓN MEJORADA ----
class Boton {
  float x, y, w, h;
  String label;  // Cambiado de 'etiqueta' a 'label'
  String subtitulo;
  color colorFondo;
  color colorHover;
  color colorBorde;
  boolean tieneBorde = false;

  // Constructor para botones del menú principal (con subtítulo)
  Boton(float x, float y, float w, float h, String label, String subtitulo, color fondo, color hover) {
    this.x = x; this.y = y; this.w = w; this.h = h;
    this.label = label;
    this.subtitulo = subtitulo;
    this.colorFondo = fondo;
    this.colorHover = hover;
    this.colorBorde = color(200, 200, 200);
    this.tieneBorde = true;
  }

  // Constructor para botones simples
  Boton(float x, float y, float w, float h, String label, color fondo, color hover) {
    this.x = x; this.y = y; this.w = w; this.h = h;
    this.label = label;
    this.subtitulo = "";
    this.colorFondo = fondo;
    this.colorHover = hover;
    this.colorBorde = color(200, 200, 200);
    this.tieneBorde = true;
  }

  boolean contieneClic(float mx, float my) {
    return mx >= x && mx <= x + w && my >= y && my <= y + h;
  }

  void dibujar() {
    boolean sobre = contieneClic(mouseX, mouseY);
    
    // Sombra
    noStroke();
    fill(0, 0, 0, 30);
    rect(x + 3, y + 3, w, h, 12);
    
    // Fondo
    fill(sobre ? colorHover : colorFondo);
    stroke(tieneBorde ? colorBorde : color(0, 0, 0, 0));
    strokeWeight(1);
    rect(x, y, w, h, 12);
    
    // Título
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(18);
    text(label, x + w/2, y + h/2 - 10);
    
    // Subtítulo (si existe)
    if (!subtitulo.isEmpty()) {
      fill(200, 220, 255, 220);
      textSize(12);
      text(subtitulo, x + w/2, y + h/2 + 18);
    }
  }
}

// ---- CLASE CAMPO DE TEXTO MEJORADA ----
class CampoTexto {
  float x, y, w, h;
  String etiqueta;
  String contenido = "";
  boolean activo = false;

  CampoTexto(float x, float y, float w, float h, String etiqueta) {
    this.x = x; this.y = y; this.w = w; this.h = h;
    this.etiqueta = etiqueta;
  }

  boolean contieneClic(float mx, float my) {
    return mx >= x && mx <= x + w && my >= y && my <= y + h;
  }

  void manejarTecla(char tecla, int codigoTecla) {
    if (!activo) return;
    if (codigoTecla == BACKSPACE) {
      if (contenido.length() > 0) {
        contenido = contenido.substring(0, contenido.length() - 1);
      }
    } else if (tecla >= ' ' && tecla != CODED) {
      if (contenido.length() < 39) {
        contenido += tecla;
      }
    }
  }

  void dibujar() {
    // Etiqueta
    fill(COLOR_TEXTO_CLARO);
    textAlign(LEFT, BOTTOM);
    textSize(13);
    text(etiqueta, x, y - 8);

    // Campo
    stroke(activo ? COLOR_SECUNDARIO : color(200));
    strokeWeight(activo ? 2.5 : 1.5);
    fill(255);
    rect(x, y, w, h, 8);

    // Texto
    noStroke();
    fill(COLOR_TEXTO);
    textAlign(LEFT, CENTER);
    textSize(15);
    text(contenido, x + 12, y + h / 2);
  }

  void limpiar() {
    contenido = "";
  }
}

// ============================================================
// FUNCIONES DE DIBUJO - ESTILO ACADEMIA
// ============================================================

// ---- DIBUJA EL LOGO Y ENCABEZADO ----
void dibujarEncabezado(String titulo) {
  // Barra superior azul
  noStroke();
  fill(COLOR_PRIMARIO);
  rect(0, 0, width, 85);
  
  // Texto "BARRANQUILLA" en la barra
  fill(255);
  textAlign(LEFT, CENTER);
  textSize(22);
  text("BARRANQUILLA", 40, 30);
  
  // Línea decorativa
  fill(COLOR_SECUNDARIO);
  rect(0, 50, width, 3);
  
  // Subtítulo
  fill(200, 220, 255);
  textAlign(LEFT, CENTER);
  textSize(14);
  text("ACADEMIA DE ARTES", 40, 55);
  
  // Título de la página actual
  fill(COLOR_TEXTO);
  textAlign(CENTER, TOP);
  textSize(26);
  text(titulo, width/2, 110);
  
  // Línea decorativa inferior del título
  fill(COLOR_SECUNDARIO);
  rect(width/2 - 80, 145, 160, 3);
}

// ---- DIBUJA EL FOOTER ----
void dibujarFooter() {
  fill(COLOR_PRIMARIO);
  noStroke();
  rect(0, height - 50, width, 50);
  
  fill(200, 220, 255, 180);
  textAlign(CENTER, CENTER);
  textSize(12);
  text("© 2025 Academia de Artes Barranquilla — Arte que transforma, cultura que nos une", 
       width/2, height - 25);
}

// ---- DIBUJA EL MENÚ PRINCIPAL (ESTILO IMAGEN) ----
void dibujarMenuPrincipalEstilo() {
  // Fondo
  background(COLOR_FONDO);
  
  // Encabezado con logo
  dibujarEncabezado("MÓDULOS DEL SISTEMA");
  
  // El resto de los botones se dibujan desde main
  
  // Footer
  dibujarFooter();
}

// ---- DIBUJA UN MENÚ SECUNDARIO ----
void dibujarMenuSecundario(String titulo) {
  background(COLOR_FONDO);
  dibujarEncabezado(titulo);
}

// ---- DIBUJA UN FORMULARIO ----
void dibujarFormulario(String titulo) {
  background(COLOR_FONDO);
  dibujarEncabezado(titulo);
}

// ---- MENSAJE DE FEEDBACK MEJORADO ----
void dibujarMensaje() {
  if (mensaje == null || mensaje.isEmpty()) return;
  
  // Fondo del mensaje
  fill(255, 255, 255, 240);
  noStroke();
  rectMode(CENTER);
  rect(width/2, height - 35, mensaje.length() * 10 + 50, 40, 10);
  rectMode(CORNER);
  
  // Icono según tipo
  boolean esError = colorMensaje == color(200, 40, 40);
  String icono = esError ? "✕ " : "✓ ";
  
  // Texto del mensaje
  fill(colorMensaje);
  textAlign(CENTER, CENTER);
  textSize(14);
  text(icono + mensaje, width / 2, height - 33);
}

// ---- FUNCIONES DE UTILIDAD ----
void mostrarMensaje(String texto, boolean esError) {
  mensaje = texto;
  colorMensaje = esError ? color(200, 40, 40) : color(39, 174, 96);
}

void limpiarCamposFormulario() {
  if (campoCedula != null) campoCedula.limpiar();
  if (campoNombre != null) campoNombre.limpiar();
  if (campoEspecialidad != null) campoEspecialidad.limpiar();
  if (campoTelefono != null) campoTelefono.limpiar();
  if (campoCedulaAprendiz != null) campoCedulaAprendiz.limpiar();
  if (campoNombreAprendiz != null) campoNombreAprendiz.limpiar();
  if (campoEspecialidadAprendiz != null) campoEspecialidadAprendiz.limpiar();
  if (campoCodigoSesion != null) campoCodigoSesion.limpiar();
  if (campoFechaSesion != null) campoFechaSesion.limpiar();
  if (campoEspecialidadSesion != null) campoEspecialidadSesion.limpiar();
}

void limpiarDatosTemporales() {
  instructorEncontrado = null;
  aprendizEncontrado = null;
  sesionEncontrada = null;
  listaInstructores = null;
  listaAprendices = null;
  listaSesiones = null;
  instructoresDisponibles = null;
  instructorSeleccionadoIndex = -1;
  cedulaAprendizSeleccionado = "";
  especialidadSeleccionada = "";
}

boolean validarCedula(String cedula) {
  if (cedula == null || cedula.isEmpty()) return false;
  if (cedula.length() < 6 || cedula.length() > 15) return false;
  for (int i = 0; i < cedula.length(); i++) {
    if (!Character.isDigit(cedula.charAt(i))) return false;
  }
  return true;
}

boolean validarFecha(String fecha) {
  if (fecha == null || fecha.length() != 10) return false;
  if (fecha.charAt(4) != '-' || fecha.charAt(7) != '-') return false;
  String[] partes = fecha.split("-");
  if (partes.length != 3) return false;
  try {
    int año = Integer.parseInt(partes[0]);
    int mes = Integer.parseInt(partes[1]);
    int dia = Integer.parseInt(partes[2]);
    if (año < 2000 || año > 2100) return false;
    if (mes < 1 || mes > 12) return false;
    if (dia < 1 || dia > 31) return false;
    return true;
  } catch (NumberFormatException e) {
    return false;
  }
}

int compararFechas(String fecha1, String fecha2) {
  if (fecha1 == null || fecha2 == null) return 0;
  return fecha1.compareTo(fecha2);
}

String obtenerFechaActual() {
  java.util.Calendar cal = java.util.Calendar.getInstance();
  int año = cal.get(java.util.Calendar.YEAR);
  int mes = cal.get(java.util.Calendar.MONTH) + 1;
  int dia = cal.get(java.util.Calendar.DAY_OF_MONTH);
  return String.format("%04d-%02d-%02d", año, mes, dia);
}

String generarCodigoSesion() {
  java.util.Calendar cal = java.util.Calendar.getInstance();
  long tiempo = cal.getTimeInMillis();
  return "SES" + tiempo;
}

void activarCampoSiClic(CampoTexto campo) {
  if (campo == null) return;
  if (campo.contieneClic(mouseX, mouseY)) {
    if (campoCedula != null) campoCedula.activo = false;
    if (campoNombre != null) campoNombre.activo = false;
    if (campoEspecialidad != null) campoEspecialidad.activo = false;
    if (campoTelefono != null) campoTelefono.activo = false;
    if (campoCedulaAprendiz != null) campoCedulaAprendiz.activo = false;
    if (campoNombreAprendiz != null) campoNombreAprendiz.activo = false;
    if (campoEspecialidadAprendiz != null) campoEspecialidadAprendiz.activo = false;
    if (campoCodigoSesion != null) campoCodigoSesion.activo = false;
    if (campoFechaSesion != null) campoFechaSesion.activo = false;
    if (campoEspecialidadSesion != null) campoEspecialidadSesion.activo = false;
    campo.activo = true;
  }
}
