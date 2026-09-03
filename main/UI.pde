// ============================================================
// COMPONENTES DE INTERFAZ - Estilo Academia de Artes Barranquilla
// Barra lateral + panel de módulos, según la imagen de referencia
// ============================================================

// ---- COLORES DE LA ACADEMIA ----
color COLOR_PRIMARIO = color(20, 30, 70);        // Azul muy oscuro (sidebar / encabezados)
color COLOR_FONDO = color(240, 242, 248);         // Fondo gris claro
color COLOR_TARJETA = color(255, 255, 255);       // Blanco
color COLOR_TEXTO = color(30, 30, 50);            // Gris oscuro
color COLOR_TEXTO_CLARO = color(120, 125, 150);   // Gris medio
color COLOR_SOMBRA = color(0, 0, 0, 25);
color COLOR_ACENTO = color(230, 180, 60);         // Dorado, acento de marca

// Colores de los módulos (igual a la imagen)
color COLOR_SESIONES = color(30, 120, 220);
color COLOR_INSTRUCTORES = color(40, 180, 100);
color COLOR_APRENDICES = color(150, 70, 200);
color COLOR_REPORTES = color(220, 160, 30);
color COLOR_SALIR = color(200, 50, 50);

// ---- PALETA "DASHBOARD" (módulo de Sesiones estilo panel web) ----
color COLOR_SIDEBAR        = color(20, 33, 61);     // Azul marino oscuro
color COLOR_SIDEBAR_TEXTO  = color(210, 220, 235);
color COLOR_SIDEBAR_ACTIVO = color(196, 145, 45);   // Dorado/mostaza (ítem activo)
color COLOR_TOPBAR         = color(250, 249, 246);  // Crema muy claro
color COLOR_BORDE_SUAVE    = color(225, 228, 232);
color COLOR_AMARILLO_BANDERA = color(247, 195, 38);
color COLOR_AZUL_BANDERA     = color(41, 65, 115);
color COLOR_ROJO_BANDERA     = color(200, 40, 40);
color COLOR_TITULO_MODULO    = color(30, 45, 80);
color COLOR_GRIS_DESC        = color(110, 118, 128);

// ============================================================
// BARRA LATERAL DE NAVEGACIÓN
// ============================================================

class ItemNav {
  String icono;        // tipo de ícono a dibujar
  String etiqueta;      // texto mostrado
  int estadoDestino;    // estado al que navega; -1 = reinicio, -2 = salir
  float yPos;           // posición vertical calculada al dibujar (para clic)
  float altura = 46;

  ItemNav(String icono, String etiqueta, int estadoDestino) {
    this.icono = icono;
    this.etiqueta = etiqueta;
    this.estadoDestino = estadoDestino;
  }
}

// Determina a qué módulo "pertenece" un estado, para resaltar el
// ítem correspondiente en la barra lateral aunque estemos en un
// sub-formulario (crear, consultar, listar, etc.)
int grupoDeEstado(int e) {
  if (e == MENU_PRINCIPAL) return MENU_PRINCIPAL;
  if (e == MENU_INSTRUCTORES || (e >= 10 && e <= 14)) return MENU_INSTRUCTORES;
  if (e == MENU_APRENDICES || (e >= 20 && e <= 24)) return MENU_APRENDICES;
  if (e == MENU_SESIONES || (e >= 30 && e <= 34)) return MENU_SESIONES;
  if (e == MENU_REPORTES || e == VER_REPORTE) return MENU_REPORTES;
  return -99;
}

void dibujarSidebar() {
  noStroke();
  fill(COLOR_PRIMARIO);
  rect(0, 0, SIDEBAR_WIDTH, height);

  // Logo circular con inicial de la academia
  fill(COLOR_ACENTO);
  ellipse(SIDEBAR_WIDTH / 2, 55, 62, 62);
  fill(COLOR_PRIMARIO);
  textAlign(CENTER, CENTER);
  textSize(24);
  text("A", SIDEBAR_WIDTH / 2, 56);

  fill(255);
  textAlign(CENTER, TOP);
  textSize(12);
  text("ACADEMIA DE ARTES", SIDEBAR_WIDTH / 2, 98);
  textSize(13);
  text("BARRANQUILLA", SIDEBAR_WIDTH / 2, 114);

  stroke(255, 255, 255, 60);
  strokeWeight(1);
  line(28, 145, SIDEBAR_WIDTH - 28, 145);
  noStroke();

  float y = 168;
  int grupoActivo = grupoDeEstado(estado);
  for (int i = 0; i < itemsNav.size(); i++) {
    ItemNav item = itemsNav.get(i);

    // Separador antes de "Salir" para distinguirlo del resto
    if (item.estadoDestino == -2) {
      stroke(255, 255, 255, 50);
      line(28, y + 6, SIDEBAR_WIDTH - 28, y + 6);
      noStroke();
      y += 22;
    }

    item.yPos = y;
    boolean activo = (item.estadoDestino == grupoActivo);
    dibujarUnItemNav(item, y, activo);
    y += item.altura;
  }
}

void dibujarUnItemNav(ItemNav item, float y, boolean activo) {
  float x = 14;
  float w = SIDEBAR_WIDTH - 28;
  float h = item.altura - 6;
  boolean sobre = (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h);

  if (activo) {
    noStroke();
    fill(COLOR_ACENTO);
    rect(x, y, w, h, 8);
  } else if (sobre) {
    noStroke();
    fill(255, 255, 255, 28);
    rect(x, y, w, h, 8);
  }

  color colorIcono = activo ? COLOR_PRIMARIO : color(220, 225, 245);
  color colorTexto = activo ? COLOR_PRIMARIO : color(230, 233, 245);

  dibujarIconoNav(item.icono, x + 26, y + h / 2, 20, colorIcono);

  fill(colorTexto);
  textAlign(LEFT, CENTER);
  textSize(14);
  text(item.etiqueta, x + 48, y + h / 2 + 1);
}

// Detecta y procesa clics en la barra lateral. Devuelve true si el
// clic fue manejado ahí (para que mousePressed no siga evaluando
// los botones de la pantalla actual).
boolean manejarClicSidebar() {
  if (mouseX > SIDEBAR_WIDTH) return false;
  for (ItemNav item : itemsNav) {
    float x = 14;
    float w = SIDEBAR_WIDTH - 28;
    float h = item.altura - 6;
    if (mouseX >= x && mouseX <= x + w && mouseY >= item.yPos && mouseY <= item.yPos + h) {
      if (item.estadoDestino == -1) {
        mostrarOpcionesReinicio();
      } else if (item.estadoDestino == -2) {
        exit();
      } else {
        estado = item.estadoDestino;
        limpiarDatosTemporales();
        limpiarCamposFormulario();
        mensaje = "";
      }
      return true;
    }
  }
  return false;
}

// ---- ÍCONOS SIMPLES DIBUJADOS CON FORMAS BÁSICAS ----
void dibujarIconoNav(String tipo, float cx, float cy, float s, color c) {
  noStroke();
  fill(c);
  switch (tipo) {
    case "home":
      triangle(cx - s * 0.5f, cy - s * 0.02f, cx + s * 0.5f, cy - s * 0.02f, cx, cy - s * 0.5f);
      rect(cx - s * 0.32f, cy - s * 0.05f, s * 0.64f, s * 0.5f, 1);
      break;

    case "instructores":
      ellipse(cx, cy - s * 0.22f, s * 0.42f, s * 0.42f);
      arc(cx, cy + s * 0.32f, s * 0.85f, s * 0.6f, PI, TWO_PI);
      break;

    case "aprendices":
      triangle(cx - s * 0.5f, cy - s * 0.02f, cx + s * 0.5f, cy - s * 0.02f, cx, cy - s * 0.42f);
      rect(cx - s * 0.38f, cy + s * 0.02f, s * 0.76f, s * 0.14f, 2);
      break;

    case "sesiones":
      rect(cx - s * 0.42f, cy - s * 0.32f, s * 0.84f, s * 0.68f, 3);
      fill(255);
      rect(cx - s * 0.42f, cy - s * 0.32f, s * 0.84f, s * 0.2f, 3, 3, 0, 0);
      fill(c);
      rect(cx - s * 0.26f, cy - s * 0.42f, s * 0.08f, s * 0.2f, 2);
      rect(cx + s * 0.18f, cy - s * 0.42f, s * 0.08f, s * 0.2f, 2);
      break;

    case "reportes":
      rect(cx - s * 0.4f, cy + s * 0.05f, s * 0.2f, s * 0.32f);
      rect(cx - s * 0.08f, cy - s * 0.18f, s * 0.2f, s * 0.55f);
      rect(cx + s * 0.24f, cy - s * 0.35f, s * 0.2f, s * 0.72f);
      break;

    case "reinicio":
      noFill();
      stroke(c);
      strokeWeight(2.4f);
      arc(cx, cy, s * 0.7f, s * 0.7f, -PI * 0.75f, PI * 0.95f);
      noStroke();
      fill(c);
      triangle(cx + s * 0.32f, cy - s * 0.3f, cx + s * 0.5f, cy - s * 0.12f, cx + s * 0.2f, cy - s * 0.06f);
      break;

    case "salir":
      noFill();
      stroke(c);
      strokeWeight(2.4f);
      rect(cx - s * 0.32f, cy - s * 0.36f, s * 0.32f, s * 0.72f, 2);
      line(cx - s * 0.04f, cy, cx + s * 0.42f, cy);
      line(cx + s * 0.2f, cy - s * 0.18f, cx + s * 0.42f, cy);
      line(cx + s * 0.2f, cy + s * 0.18f, cx + s * 0.42f, cy);
      noStroke();
      break;
  }
}

// ============================================================
// TARJETA DE MÓDULO (panel principal, estilo imagen de referencia)
// ============================================================
void dibujarTarjetaModulo(Boton b, String iconoTipo) {
  boolean sobre = b.contieneClic(mouseX, mouseY);

  noStroke();
  fill(0, 0, 0, sobre ? 30 : 15);
  rect(b.x + 3, b.y + 4, b.w, b.h, 14);

  fill(sobre ? color(252, 252, 255) : 255);
  stroke(224, 226, 232);
  strokeWeight(1);
  rect(b.x, b.y, b.w, b.h, 14);
  noStroke();

  float cx = b.x + b.w / 2;

  // Ícono dentro de un círculo de fondo suave
  float iconY = b.y + 46;
  fill(lerpColor(b.colorFondo, color(255), 0.82f));
  ellipse(cx, iconY, 56, 56);
  dibujarIconoNav(iconoTipo, cx, iconY, 26, b.colorFondo);

  // Número del módulo
  fill(b.colorFondo);
  textAlign(CENTER, TOP);
  textSize(20);
  text(b.numero, cx, iconY + 34);

  // Título (puede tener salto de línea)
  fill(b.colorFondo);
  textSize(13);
  textLeading(16);
  text(b.label, cx - (b.w - 20) / 2, iconY + 62, b.w - 20, 40);

  // Descripción
  fill(COLOR_TEXTO_CLARO);
  textAlign(CENTER, TOP);
  textSize(11);
  textLeading(15);
  text(b.subtitulo, cx - (b.w - 24) / 2, iconY + 100, b.w - 24, b.h - (iconY - b.y) - 130);

  // Enlace "Ver módulo"
  fill(b.colorFondo);
  textAlign(CENTER, BOTTOM);
  textSize(12);
  text("Ver módulo →", cx, b.y + b.h - 14);
}

// ---- CLASE BOTÓN TIPO TARJETA (usada en submenús y listas) ----
class Boton {
  float x, y, w, h;
  String label;
  String subtitulo;
  String numero;
  color colorFondo;
  color colorHover;
  color colorBorde;
  boolean tieneBorde = true;
  int borderRadius = 14;

  // ---- Campos exclusivos del estilo "tarjeta de módulo" ----
  boolean esTarjeta = false;
  String descripcion = "";
  String icono = "";
  color colorIconoFondo;
  color colorIconoTrazo;
  color colorAccento;

  // Constructor para tarjetas del módulo de sesiones (CON ICONO)
  Boton(float x, float y, float w, float h, String label, String descripcion,
        String icono, color colorIconoFondo, color colorIconoTrazo, color colorAccento) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.descripcion = descripcion;
    this.icono = icono;
    this.colorIconoFondo = colorIconoFondo;
    this.colorIconoTrazo = colorIconoTrazo;
    this.colorAccento = colorAccento;
    this.esTarjeta = true;
    this.subtitulo = "";
    this.colorFondo = color(255);
    this.colorHover = color(250, 251, 253);
    this.colorBorde = COLOR_BORDE_SUAVE;
    this.tieneBorde = true;
  }

  // Constructor para botones del menú principal (con número y subtítulo)
  Boton(float x, float y, float w, float h, String numero, String label, String subtitulo, color fondo, color hover) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.numero = numero;
    this.label = label;
    this.subtitulo = subtitulo;
    this.colorFondo = fondo;
    this.colorHover = hover;
    this.colorBorde = color(220, 222, 230);
    this.tieneBorde = true;
  }

  // Constructor para botones simples (menús secundarios)
  Boton(float x, float y, float w, float h, String label, color fondo, color hover) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.numero = "";
    this.label = label;
    this.subtitulo = "";
    this.colorFondo = fondo;
    this.colorHover = hover;
    this.colorBorde = color(200, 200, 200);
    this.tieneBorde = true;
    this.borderRadius = 10;
  }

  boolean contieneClic(float mx, float my) {
    return mx >= x && mx <= x + w && my >= y && my <= y + h;
  }

  void dibujar() {
    if (esTarjeta) {
      dibujarTarjeta();
      return;
    }

    boolean sobre = contieneClic(mouseX, mouseY);

    pushMatrix();

    // Sombra suave
    noStroke();
    fill(0, 0, 0, sobre ? 35 : 20);
    rect(x + 3, y + 4, w, h, borderRadius);

    // Fondo blanco de la tarjeta
    fill(sobre ? color(252, 252, 255) : 255);
    stroke(colorBorde);
    strokeWeight(1);
    rect(x, y, w, h, borderRadius);

    // Línea de color en el lado izquierdo
    noStroke();
    fill(colorFondo);
    rect(x, y + 12, 6, h - 24, 3);

    // Número en círculo (solo si aplica)
    if (numero != null && !numero.isEmpty()) {
      float circleX = x + 38;
      float circleY = y + h / 2 - 6;
      float circleSize = 44;

      noStroke();
      fill(colorFondo);
      ellipse(circleX, circleY, circleSize, circleSize);

      fill(255);
      textAlign(CENTER, CENTER);
      textSize(18);
      text(numero, circleX, circleY + 1);
    }

    // Título
    float textX = x + (numero != null && !numero.isEmpty() ? 70 : 24);
    float textY = y + h / 2 - (subtitulo.isEmpty() ? 0 : 14);
    fill(COLOR_TEXTO);
    textAlign(LEFT, CENTER);
    textSize(16);
    text(label, textX, textY);

    // Subtítulo
    if (!subtitulo.isEmpty()) {
      fill(COLOR_TEXTO_CLARO);
      textSize(12);
      text(subtitulo, textX, textY + 28);
    }

    popMatrix();
  }

  // ---- Dibuja la tarjeta estilo "módulo" ----
  void dibujarTarjeta() {
    pushStyle();
    boolean sobre = contieneClic(mouseX, mouseY);

    // Sombra suave
    noStroke();
    fill(30, 40, 60, sobre ? 45 : 22);
    rect(x + 2, y + 5, w, h, 14);

    // Fondo de la tarjeta
    fill(sobre ? colorHover : colorFondo);
    stroke(colorBorde);
    strokeWeight(1);
    rect(x, y, w, h, 14);

    // Barra de acento inferior
    noStroke();
    fill(colorAccento);
    rect(x, y + h - 5, w, 5, 0, 0, 14, 14);

    // Círculo de ícono
    float rIcono = min(w, h) * 0.20f;
    float cx = x + w * 0.26f;
    float cy = y + h * 0.30f;
    noStroke();
    fill(colorIconoFondo);
    ellipse(cx, cy, rIcono * 2, rIcono * 2);
    dibujarIconoIndicador(icono, cx, cy, rIcono * 0.58f, colorIconoTrazo);

    // Título
    fill(COLOR_TITULO_MODULO);
    textAlign(LEFT, TOP);
    textSize(constrain(w * 0.086f, 13, 19));
    text(label, x + w * 0.11f, y + h * 0.52f, w * 0.80f, h * 0.20f);

    // Descripción
    fill(COLOR_GRIS_DESC);
    textSize(constrain(w * 0.058f, 10.5f, 13));
    text(descripcion, x + w * 0.11f, y + h * 0.71f, w * 0.80f, h * 0.26f);

    // Botón circular con flecha
    float rFlecha = min(w, h) * 0.095f;
    float fx = x + w - rFlecha * 1.9f;
    float fy = y + h - rFlecha * 2.1f;
    noStroke();
    fill(colorIconoFondo);
    ellipse(fx, fy, rFlecha * 2, rFlecha * 2);
    dibujarIconoIndicador("flecha-der", fx, fy, rFlecha * 0.62f, colorIconoTrazo);
    popStyle();
  }
}

// ---- CLASE CAMPO DE TEXTO ----
class CampoTexto {
  float x, y, w, h;
  String etiqueta;
  String contenido = "";
  boolean activo = false;
  color colorBorde = color(200, 202, 210);
  color colorActivo = color(30, 80, 180);

  CampoTexto(float x, float y, float w, float h, String etiqueta) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
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
    textSize(12);
    text(etiqueta, x, y - 6);

    // Campo con sombra
    noStroke();
    fill(0, 0, 0, 12);
    rect(x + 2, y + 3, w, h, 8);

    stroke(activo ? colorActivo : colorBorde);
    strokeWeight(activo ? 2.5f : 1.5f);
    fill(255);
    rect(x, y, w, h, 8);

    // Texto
    noStroke();
    fill(COLOR_TEXTO);
    textAlign(LEFT, CENTER);
    textSize(14);

    if (contenido.isEmpty() && !activo) {
      fill(180, 182, 190);
      text(etiqueta, x + 12, y + h / 2);
    } else {
      text(contenido, x + 12, y + h / 2);
    }
  }

  void limpiar() {
    contenido = "";
  }
}

// ============================================================
// ENCABEZADO PARA PANTALLAS SECUNDARIAS (todo excepto Inicio)
// ============================================================
void dibujarEncabezado(String titulo) {
  noStroke();
  fill(COLOR_PRIMARIO);
  rect(contentX, 0, contentW, 88);

  fill(COLOR_ACENTO);
  rect(contentX, 85, contentW, 3);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(24);
  text(titulo, contentX + contentW / 2, 44);
}

// ---- DIBUJA EL FOOTER (disponible para usarse en pantallas propias) ----
void dibujarFooter() {
  noStroke();
  fill(COLOR_PRIMARIO);
  rect(contentX, height - 45, contentW, 45);

  fill(200, 210, 240, 150);
  textAlign(CENTER, CENTER);
  textSize(11);
  text("© 2025 Academia de Artes Barranquilla — Arte que transforma, cultura que nos une",
    contentX + contentW / 2, height - 22);
}

// ---- MENSAJE DE FEEDBACK ----
void dibujarMensaje() {
  if (mensaje == null || mensaje.isEmpty()) return;

  boolean esError = colorMensaje == color(200, 40, 40);
  color bgColor = esError ? color(200, 50, 50, 235) : color(40, 180, 100, 235);

  // Fondo del mensaje
  noStroke();
  fill(bgColor);
  float wMsg = min(mensaje.length() * 9 + 80, width - 40);
  rectMode(CENTER);
  rect((contentX + width) / 2, height - 35, wMsg, 40, 10);
  rectMode(CORNER);

  // Icono
  String icono = esError ? "✕" : "✓";
  fill(255);
  textAlign(LEFT, CENTER);
  textSize(15);
  text(icono, (contentX + width) / 2 - wMsg / 2 + 18, height - 33);

  // Texto del mensaje
  textAlign(LEFT, CENTER);
  textSize(13);
  text(mensaje, (contentX + width) / 2 - wMsg / 2 + 42, height - 33);
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
  fechaSesionSeleccionada = "";
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

// ============================================================
// FUNCIONES DEL NUEVO DISEÑO DEL MÓDULO DE SESIONES
// ============================================================

// ---- FECHA LARGA EN ESPAÑOL ----
String fechaLargaEspanol() {
  String[] dias = {"Domingo","Lunes","Martes","Miércoles","Jueves","Viernes","Sábado"};
  String[] meses = {"enero","febrero","marzo","abril","mayo","junio","julio",
                     "agosto","septiembre","octubre","noviembre","diciembre"};
  java.util.Calendar cal = java.util.Calendar.getInstance();
  int diaSemana = cal.get(java.util.Calendar.DAY_OF_WEEK) - 1;
  int dia = cal.get(java.util.Calendar.DAY_OF_MONTH);
  int mes = cal.get(java.util.Calendar.MONTH);
  int anio = cal.get(java.util.Calendar.YEAR);
  return dias[diaSemana] + ", " + dia + " de " + meses[mes] + " de " + anio;
}

// ---- BARRA LATERAL DEL NUEVO DISEÑO ----
String[] NAV_LABELS  = {"Inicio", "Sesiones", "Instructores", "Aprendices", "Reportes", "Reinicio", "Salir"};
String[] NAV_ICONOS  = {"home", "calendario", "personas", "gorro", "grafico", "refrescar", "salir"};

void dibujarBarraLateral(String activo) {
  // Fondo del sidebar
  noStroke();
  fill(COLOR_SIDEBAR);
  rect(0, 0, sidebarAncho, height);

  // ---- Logo (sol/máscara estilizado) ----
  float logoY = height * 0.075f;
  float logoR = sidebarAncho * 0.16f;
  float logoCx = sidebarAncho / 2;

  pushStyle();
  noStroke();
  int nRayos = 12;
  for (int i = 0; i < nRayos; i++) {
    float ang = TWO_PI / nRayos * i;
    color cRayo = (i % 2 == 0) ? COLOR_AMARILLO_BANDERA : color(224, 90, 40);
    fill(cRayo);
    pushMatrix();
    translate(logoCx, logoY);
    rotate(ang);
    triangle(0, -logoR * 0.55f, -logoR * 0.16f, -logoR * 1.5f, logoR * 0.16f, -logoR * 1.5f);
    popMatrix();
  }
  fill(230, 200, 150);
  ellipse(logoCx, logoY, logoR * 1.15f, logoR * 1.15f);
  fill(COLOR_ROJO_BANDERA);
  arc(logoCx, logoY - logoR * 0.15f, logoR * 1.15f, logoR * 1.15f, PI, TWO_PI);
  fill(40, 30, 20);
  ellipse(logoCx - logoR * 0.22f, logoY - logoR * 0.05f, logoR * 0.12f, logoR * 0.12f);
  ellipse(logoCx + logoR * 0.22f, logoY - logoR * 0.05f, logoR * 0.12f, logoR * 0.12f);
  popStyle();

  // ---- Nombre de la academia ----
  fill(255);
  textAlign(CENTER, TOP);
  textSize(constrain(sidebarAncho * 0.086f, 12, 15));
  text("ACADEMIA DE ARTES", logoCx, logoY + logoR * 1.7f);
  text("BARRANQUILLA", logoCx, logoY + logoR * 1.7f + textAscent() + 4);

  // ---- Línea divisoria ----
  stroke(255, 255, 255, 40);
  strokeWeight(1);
  float divY = logoY + logoR * 1.7f + (textAscent() + 4) * 2 + 14;
  line(sidebarAncho * 0.14f, divY, sidebarAncho * 0.86f, divY);
  noStroke();

  // ---- Ítems de navegación ----
  float itemAlto = height * 0.058f;
  float itemY0 = divY + 22;
  float pad = sidebarAncho * 0.09f;

  // NOTA: botonesSidebar se declara en main.pde, no aquí
  if (botonesSidebar.size() < NAV_LABELS.length) {
    botonesSidebar.clear();
    for (int i = 0; i < NAV_LABELS.length; i++) {
      botonesSidebar.add(new Boton(pad, itemY0 + i * itemAlto, sidebarAncho - pad * 2, itemAlto * 0.82f,
        NAV_LABELS[i], color(0, 0, 0, 0), color(0, 0, 0, 0)));
    }
  }

  textAlign(LEFT, CENTER);
  for (int i = 0; i < NAV_LABELS.length; i++) {
    float iy = itemY0 + i * itemAlto;
    Boton item = botonesSidebar.get(i);
    item.x = pad; item.y = iy; item.w = sidebarAncho - pad * 2; item.h = itemAlto * 0.82f;

    boolean activoItem = NAV_LABELS[i].equals(activo);
    boolean sobre = item.contieneClic(mouseX, mouseY);

    if (activoItem) {
      noStroke();
      fill(COLOR_SIDEBAR_ACTIVO);
      rect(item.x, item.y, item.w, item.h, 8);
    } else if (sobre) {
      noStroke();
      fill(255, 255, 255, 18);
      rect(item.x, item.y, item.w, item.h, 8);
    }

    color cIcono = activoItem ? color(255) : COLOR_SIDEBAR_TEXTO;
    dibujarIconoIndicador(NAV_ICONOS[i], item.x + item.h * 0.55f, item.y + item.h / 2, item.h * 0.30f, cIcono);

    fill(activoItem ? color(255) : COLOR_SIDEBAR_TEXTO);
    textSize(constrain(sidebarAncho * 0.075f, 12, 14.5f));
    text(NAV_LABELS[i], item.x + item.h * 1.15f, item.y + item.h / 2 + 1);
  }

  // ---- Ilustración decorativa inferior ----
  float ilustY = height * 0.74f;
  dibujarIlustracionBarranquilla(0, ilustY, sidebarAncho, height - ilustY - height * 0.09f);

  // ---- Lema inferior ----
  fill(210, 220, 235);
  textAlign(CENTER, TOP);
  textSize(constrain(sidebarAncho * 0.062f, 9, 11));
  float lemaY = height - height * 0.075f;
  text("ARTE,", logoCx, lemaY);
  text("DIVERSIDAD", logoCx, lemaY + 14);
  text("Y OPORTUNIDADES", logoCx, lemaY + 28);
  text("PARA TODOS", logoCx, lemaY + 42);

  // Barrita tricolor
  float barY = height - height * 0.028f;
  float barW = sidebarAncho * 0.5f;
  float barX = logoCx - barW / 2;
  noStroke();
  fill(COLOR_AZUL_BANDERA); rect(barX, barY, barW / 3, 3);
  fill(COLOR_AMARILLO_BANDERA); rect(barX + barW / 3, barY, barW / 3, 3);
  fill(COLOR_ROJO_BANDERA); rect(barX + 2 * barW / 3, barY, barW / 3, 3);
}

// ---- ILUSTRACIÓN DE BARRANQUILLA ----
void dibujarIlustracionBarranquilla(float x, float y, float w, float h) {
  pushStyle();
  noFill();
  stroke(255, 255, 255, 45);
  strokeWeight(1.2f);
  float baseY = y + h * 0.88f;

  float torreX = x + w * 0.30f;
  rect(torreX - w * 0.05f, baseY - h * 0.5f, w * 0.10f, h * 0.5f);
  rect(torreX + w * 0.14f, baseY - h * 0.62f, w * 0.10f, h * 0.62f);
  triangle(torreX + w * 0.14f, baseY - h * 0.62f, torreX + w * 0.19f, baseY - h * 0.78f, torreX + w * 0.24f, baseY - h * 0.62f);
  rect(torreX - w * 0.22f, baseY - h * 0.36f, w * 0.10f, h * 0.36f);

  for (int i = 0; i < 3; i++) {
    float ax = x + w * 0.55f + i * w * 0.10f;
    arc(ax, baseY - h * 0.28f, w * 0.09f, h * 0.30f, PI, TWO_PI);
    line(ax - w * 0.045f, baseY - h * 0.28f, ax - w * 0.045f, baseY);
    line(ax + w * 0.045f, baseY - h * 0.28f, ax + w * 0.045f, baseY);
  }

  line(x + w * 0.08f, baseY, x + w * 0.92f, baseY);

  float palX = x + w * 0.80f;
  line(palX, baseY, palX - w * 0.03f, baseY - h * 0.55f);
  for (int i = 0; i < 5; i++) {
    float ang = -HALF_PI + (i - 2) * 0.4f;
    line(palX - w * 0.03f, baseY - h * 0.55f,
         palX - w * 0.03f + cos(ang) * w * 0.16f, baseY - h * 0.55f + sin(ang) * w * 0.16f);
  }
  popStyle();
}

// ---- BARRA SUPERIOR ----
void dibujarBarraSuperior() {
  noStroke();
  fill(COLOR_TOPBAR);
  rect(sidebarAncho, 0, width - sidebarAncho, topBarAlto);
  stroke(COLOR_BORDE_SUAVE);
  strokeWeight(1);
  line(sidebarAncho, topBarAlto, width, topBarAlto);
  noStroke();

  dibujarIconoIndicador("hamburguesa", sidebarAncho + 34, topBarAlto / 2, 11, color(60, 68, 80));
  fill(COLOR_TITULO_MODULO);
  textAlign(LEFT, CENTER);
  textSize(18);
  text("Sistema de Gestión", sidebarAncho + 60, topBarAlto / 2);

  float campanaX = width - 230;
  dibujarIconoIndicador("campana", campanaX, topBarAlto / 2, 11, color(70, 78, 90));

  float avatarX = width - 165;
  noStroke();
  fill(210, 214, 220);
  ellipse(avatarX, topBarAlto / 2, 30, 30);
  fill(150, 156, 165);
  ellipse(avatarX, topBarAlto / 2 - 5, 12, 12);
  arc(avatarX, topBarAlto / 2 + 16, 20, 16, PI, TWO_PI);

  fill(COLOR_TITULO_MODULO);
  textAlign(LEFT, CENTER);
  textSize(14);
  text("Administrador", avatarX + 22, topBarAlto / 2);
  dibujarIconoIndicador("chevron", width - 34, topBarAlto / 2, 6, color(90, 98, 110));
}

// ---- HERO DEL MÓDULO DE SESIONES ----
void dibujarHeroSesiones() {
  float hx = sidebarAncho, hy = topBarAlto, hw = width - sidebarAncho, hh = heroAlto;

  if (imgEncabezadoSesiones != null) {
    pushMatrix();
    clip(hx, hy, hw, hh);
    float escala = max(hw / imgEncabezadoSesiones.width, hh / imgEncabezadoSesiones.height);
    float iw = imgEncabezadoSesiones.width * escala;
    float ih = imgEncabezadoSesiones.height * escala;
    image(imgEncabezadoSesiones, hx + (hw - iw) / 2, hy + (hh - ih) / 2, iw, ih);
    noClip();
    popMatrix();
  } else {
    noStroke();
    fill(40, 45, 60);
    rect(hx, hy, hw, hh);
  }

  noStroke();
  for (int i = 0; i < 100; i++) {
    float t = i / 100.0f;
    float alpha = lerp(210, 40, t);
    fill(10, 15, 25, alpha);
    rect(hx + hw * t, hy, hw / 100.0f + 1, hh);
  }
  fill(10, 15, 25, 90);
  rect(hx, hy + hh * 0.7f, hw, hh * 0.3f);

  float tx = hx + hw * 0.035f;
  fill(COLOR_AMARILLO_BANDERA);
  textAlign(LEFT, TOP);
  textSize(constrain(hh * 0.075f, 11, 15));
  text("M Ó D U L O   D E", tx, hy + hh * 0.10f);

  fill(255);
  textSize(constrain(hh * 0.22f, 30, 46));
  text("SESIONES", tx, hy + hh * 0.20f);

  float byPos = hy + hh * 0.52f;
  noStroke();
  fill(COLOR_AZUL_BANDERA); rect(tx, byPos, 55, 4);
  fill(COLOR_AMARILLO_BANDERA); rect(tx + 58, byPos, 55, 4);
  fill(COLOR_ROJO_BANDERA); rect(tx + 116, byPos, 55, 4);

  fill(230, 232, 236);
  textSize(constrain(hh * 0.062f, 11, 14));
  text("Coordina cada encuentro entre instructores y aprendices.", tx, byPos + 16);
  text("Agenda, consulta y da seguimiento a las sesiones de la academia.", tx, byPos + 16 + hh * 0.075f);

  float qx = hx + hw * 0.80f;
  fill(255, 255, 255, 235);
  textAlign(LEFT, TOP);
  textSize(constrain(hh * 0.075f, 12, 16));
  text("“Cada sesión", qx, hy + hh * 0.10f);
  text("es un paso", qx, hy + hh * 0.10f + hh * 0.10f);
  text("hacia el arte”", qx, hy + hh * 0.10f + hh * 0.20f);

  fill(COLOR_AMARILLO_BANDERA);
  textSize(constrain(hh * 0.048f, 8.5f, 10.5f));
  float wy = hy + hh * 0.60f;
  String[] palabras = {"AGENDAR", "ENSEÑAR", "PRACTICAR", "CRECER"};
  for (int i = 0; i < palabras.length; i++) {
    text(palabras[i], qx, wy + i * (hh * 0.088f));
  }
}

// ---- BREADCRUMB ----
void dibujarBreadcrumb(String seccion) {
  float by = topBarAlto + heroAlto;
  noStroke();
  fill(COLOR_FONDO);
  rect(sidebarAncho, by, width - sidebarAncho, breadcrumbAlto);
  stroke(COLOR_BORDE_SUAVE);
  strokeWeight(1);
  line(sidebarAncho, by + breadcrumbAlto, width, by + breadcrumbAlto);
  noStroke();

  float tx = sidebarAncho + width * 0.022f;
  float cy = by + breadcrumbAlto / 2;
  dibujarIconoIndicador("home", tx, cy, 8, color(90, 98, 110));

  textAlign(LEFT, CENTER);
  textSize(13.5f);
  fill(90, 98, 110);
  float xPos = tx + 20;
  text("Inicio", xPos, cy);
  xPos += textWidth("Inicio") + 10;
  fill(160, 168, 178);
  text(">", xPos, cy);
  xPos += textWidth(">") + 10;
  fill(COLOR_TITULO_MODULO);
  text(seccion, xPos, cy);

  fill(110, 118, 128);
  textAlign(RIGHT, CENTER);
  textSize(13);
  text(fechaLargaEspanol(), width - width * 0.022f, cy);
}

// ---- TÍTULO DE MÓDULO ----
void dibujarTituloModulo(float x, float y, String titulo, String subtitulo, String cita1, String cita2) {
  fill(COLOR_TITULO_MODULO);
  textAlign(LEFT, TOP);
  textSize(30);
  text(titulo, x, y);

  fill(COLOR_SIDEBAR_ACTIVO);
  textSize(13);
  text(letraEspaciada(subtitulo), x, y + 38);

  noStroke();
  fill(26, 115, 232);
  rect(x, y + 60, 55, 3);

  if (cita1 != null) {
    fill(120, 128, 140);
    textAlign(RIGHT, TOP);
    textSize(15);
    text(cita1, width - width * 0.03f, y + 4);
    if (cita2 != null) text(cita2, width - width * 0.03f, y + 24);
  }
}

String letraEspaciada(String s) {
  StringBuilder sb = new StringBuilder();
  for (int i = 0; i < s.length(); i++) {
    sb.append(s.charAt(i));
    if (i < s.length() - 1) sb.append(' ');
  }
  return sb.toString();
}

// ---- ENCABEZADO PARA SUB-PANTALLAS DEL MÓDULO DE SESIONES ----
float dibujarEncabezadoSesionesSub(String seccion) {
  background(COLOR_FONDO);
  dibujarBarraLateral("Sesiones");
  dibujarBarraSuperior();

  float by = topBarAlto;
  noStroke();
  fill(COLOR_FONDO);
  rect(sidebarAncho, by, width - sidebarAncho, breadcrumbAlto);
  stroke(COLOR_BORDE_SUAVE);
  strokeWeight(1);
  line(sidebarAncho, by + breadcrumbAlto, width, by + breadcrumbAlto);
  noStroke();

  float tx = sidebarAncho + width * 0.022f;
  float cy = by + breadcrumbAlto / 2;
  dibujarIconoIndicador("home", tx, cy, 8, color(90, 98, 110));

  textAlign(LEFT, CENTER);
  textSize(13.5f);
  fill(90, 98, 110);
  float xPos = tx + 20;
  text("Inicio", xPos, cy);
  xPos += textWidth("Inicio") + 10;
  fill(160, 168, 178);
  text(">", xPos, cy);
  xPos += textWidth(">") + 10;
  fill(90, 98, 110);
  text("Módulo de Sesiones", xPos, cy);
  xPos += textWidth("Módulo de Sesiones") + 10;
  fill(160, 168, 178);
  text(">", xPos, cy);
  xPos += textWidth(">") + 10;
  fill(COLOR_TITULO_MODULO);
  text(seccion, xPos, cy);

  fill(110, 118, 128);
  textAlign(RIGHT, CENTER);
  textSize(13);
  text(fechaLargaEspanol(), width - width * 0.022f, cy);

  float contentTop = by + breadcrumbAlto;
  fill(COLOR_TITULO_MODULO);
  textAlign(LEFT, TOP);
  textSize(24);
  text(seccion, sidebarAncho + width * 0.022f, contentTop + height * 0.028f);
  noStroke();
  fill(26, 115, 232);
  rect(sidebarAncho + width * 0.022f, contentTop + height * 0.028f + 34, 50, 3);

  return contentTop + height * 0.09f;
}

// ---- PIE DE PÁGINA DEL MÓDULO DE SESIONES ----
void dibujarPieSesiones() {
  float fy = height - 42;
  noStroke();
  fill(COLOR_TOPBAR);
  rect(sidebarAncho, fy, width - sidebarAncho, 42);
  stroke(COLOR_BORDE_SUAVE);
  strokeWeight(1);
  line(sidebarAncho, fy, width, fy);
  noStroke();

  fill(120, 128, 138);
  textAlign(LEFT, CENTER);
  textSize(12);
  text("© 2025 Academia de Artes Barranquilla. Todos los derechos reservados.",
       sidebarAncho + width * 0.022f, fy + 21);

  float pinX = width - width * 0.16f;
  dibujarIconoIndicador("pin", pinX, fy + 21, 7, color(120, 128, 138));
  fill(120, 128, 138);
  textAlign(LEFT, CENTER);
  textSize(12);
  text("Barranquilla, Atlántico, Colombia", pinX + 14, fy + 21);

  float barW = 90;
  float barX = pinX - 20 - barW;
  fill(COLOR_AZUL_BANDERA); rect(barX, fy + 19, barW / 3, 3);
  fill(COLOR_AMARILLO_BANDERA); rect(barX + barW / 3, fy + 19, barW / 3, 3);
  fill(COLOR_ROJO_BANDERA); rect(barX + 2 * barW / 3, fy + 19, barW / 3, 3);
}

// ---- ÍCONOS VECTORIALES PARA EL NUEVO DISEÑO ----
void dibujarIconoIndicador(String tipo, float cx, float cy, float r, color c) {
  pushStyle();
  rectMode(CENTER);
  noFill();
  stroke(c);
  strokeWeight(max(1.6f, r * 0.18f));
  strokeCap(ROUND);
  strokeJoin(ROUND);

  if (tipo.equals("calendario")) {
    rect(cx, cy + r * 0.12f, r * 1.7f, r * 1.5f, r * 0.22f);
    line(cx - r * 0.55f, cy - r * 0.62f, cx - r * 0.55f, cy - r * 0.98f);
    line(cx + r * 0.55f, cy - r * 0.62f, cx + r * 0.55f, cy - r * 0.98f);
    line(cx - r * 0.85f, cy - r * 0.22f, cx + r * 0.85f, cy - r * 0.22f);
    noStroke(); fill(c);
    ellipse(cx - r * 0.25f, cy + r * 0.35f, r * 0.22f, r * 0.22f);
    ellipse(cx + r * 0.30f, cy + r * 0.35f, r * 0.22f, r * 0.22f);
  } else if (tipo.equals("buscar")) {
    ellipse(cx - r * 0.12f, cy - r * 0.12f, r * 1.15f, r * 1.15f);
    line(cx + r * 0.5f, cy + r * 0.5f, cx + r * 1.0f, cy + r * 1.0f);
  } else if (tipo.equals("cancelar")) {
    line(cx - r * 0.65f, cy - r * 0.55f, cx + r * 0.65f, cy - r * 0.55f);
    line(cx - r * 0.28f, cy - r * 0.75f, cx + r * 0.28f, cy - r * 0.75f);
    rect(cx, cy + r * 0.08f, r * 1.05f, r * 1.2f, r * 0.12f);
    line(cx - r * 0.22f, cy - r * 0.20f, cx - r * 0.22f, cy + r * 0.50f);
    line(cx + r * 0.22f, cy - r * 0.20f, cx + r * 0.22f, cy + r * 0.50f);
  } else if (tipo.equals("lista")) {
    for (int i = -1; i <= 1; i++) {
      float ly = cy + i * r * 0.5f;
      noStroke(); fill(c);
      ellipse(cx - r * 0.75f, ly, r * 0.22f, r * 0.22f);
      stroke(c); noFill();
      line(cx - r * 0.42f, ly, cx + r * 0.88f, ly);
    }
  } else if (tipo.equals("volver") || tipo.equals("flecha-izq")) {
    line(cx + r * 0.8f, cy, cx - r * 0.8f, cy);
    line(cx - r * 0.28f, cy - r * 0.48f, cx - r * 0.8f, cy);
    line(cx - r * 0.28f, cy + r * 0.48f, cx - r * 0.8f, cy);
  } else if (tipo.equals("flecha-der")) {
    line(cx - r * 0.8f, cy, cx + r * 0.8f, cy);
    line(cx + r * 0.28f, cy - r * 0.48f, cx + r * 0.8f, cy);
    line(cx + r * 0.28f, cy + r * 0.48f, cx + r * 0.8f, cy);
  } else if (tipo.equals("home")) {
    line(cx - r * 0.85f, cy - r * 0.05f, cx, cy - r * 0.8f);
    line(cx, cy - r * 0.8f, cx + r * 0.85f, cy - r * 0.05f);
    rect(cx, cy + r * 0.30f, r * 1.15f, r * 0.9f);
  } else if (tipo.equals("personas")) {
    ellipse(cx - r * 0.35f, cy - r * 0.28f, r * 0.6f, r * 0.6f);
    ellipse(cx + r * 0.38f, cy - r * 0.18f, r * 0.5f, r * 0.5f);
    arc(cx - r * 0.35f, cy + r * 0.55f, r * 1.1f, r * 0.9f, PI, TWO_PI);
    arc(cx + r * 0.38f, cy + r * 0.55f, r * 0.95f, r * 0.75f, PI, TWO_PI);
  } else if (tipo.equals("gorro")) {
    line(cx - r * 0.9f, cy - r * 0.05f, cx, cy - r * 0.6f);
    line(cx, cy - r * 0.6f, cx + r * 0.9f, cy - r * 0.05f);
    line(cx + r * 0.9f, cy - r * 0.05f, cx, cy + r * 0.35f);
    line(cx, cy + r * 0.35f, cx - r * 0.9f, cy - r * 0.05f);
    line(cx - r * 0.35f, cy + r * 0.15f, cx - r * 0.35f, cy + r * 0.55f);
    line(cx + r * 0.35f, cy + r * 0.15f, cx + r * 0.35f, cy + r * 0.55f);
    line(cx - r * 0.35f, cy + r * 0.55f, cx + r * 0.35f, cy + r * 0.55f);
  } else if (tipo.equals("grafico")) {
    line(cx - r * 0.85f, cy + r * 0.8f, cx + r * 0.85f, cy + r * 0.8f);
    line(cx - r * 0.5f, cy + r * 0.7f, cx - r * 0.5f, cy - r * 0.1f);
    line(cx, cy + r * 0.7f, cx, cy - r * 0.6f);
    line(cx + r * 0.5f, cy + r * 0.7f, cx + r * 0.5f, cy + r * 0.2f);
  } else if (tipo.equals("refrescar")) {
    arc(cx, cy, r * 1.4f, r * 1.4f, -HALF_PI * 1.6f, PI * 0.85f);
    arc(cx, cy, r * 1.4f, r * 1.4f, PI * 0.15f, HALF_PI * 1.6f);
    line(cx + r * 0.55f, cy - r * 0.78f, cx + r * 0.88f, cy - r * 0.46f);
    line(cx + r * 0.88f, cy - r * 0.46f, cx + r * 0.48f, cy - r * 0.38f);
    line(cx - r * 0.55f, cy + r * 0.78f, cx - r * 0.88f, cy + r * 0.46f);
    line(cx - r * 0.88f, cy + r * 0.46f, cx - r * 0.48f, cy + r * 0.38f);
  } else if (tipo.equals("salir")) {
    rect(cx - r * 0.15f, cy, r * 1.1f, r * 1.5f, r * 0.15f);
    line(cx - r * 0.1f, cy, cx + r * 0.9f, cy);
    line(cx + r * 0.5f, cy - r * 0.35f, cx + r * 0.9f, cy);
    line(cx + r * 0.5f, cy + r * 0.35f, cx + r * 0.9f, cy);
  } else if (tipo.equals("campana")) {
    arc(cx, cy - r * 0.08f, r * 1.2f, r * 1.2f, PI, TWO_PI);
    line(cx - r * 0.6f, cy - r * 0.08f, cx - r * 0.6f, cy + r * 0.35f);
    line(cx + r * 0.6f, cy - r * 0.08f, cx + r * 0.6f, cy + r * 0.35f);
    line(cx - r * 0.72f, cy + r * 0.35f, cx + r * 0.72f, cy + r * 0.35f);
    noStroke(); fill(c);
    ellipse(cx, cy + r * 0.62f, r * 0.3f, r * 0.3f);
  } else if (tipo.equals("hamburguesa")) {
    line(cx - r * 0.85f, cy - r * 0.5f, cx + r * 0.85f, cy - r * 0.5f);
    line(cx - r * 0.85f, cy, cx + r * 0.85f, cy);
    line(cx - r * 0.85f, cy + r * 0.5f, cx + r * 0.85f, cy + r * 0.5f);
  } else if (tipo.equals("chevron")) {
    line(cx - r * 0.6f, cy - r * 0.3f, cx, cy + r * 0.3f);
    line(cx, cy + r * 0.3f, cx + r * 0.6f, cy - r * 0.3f);
  } else if (tipo.equals("pin")) {
    ellipse(cx, cy - r * 0.18f, r * 1.1f, r * 1.1f);
    noStroke(); fill(c);
    ellipse(cx, cy - r * 0.18f, r * 0.35f, r * 0.35f);
    triangle(cx - r * 0.35f, cy + r * 0.22f, cx + r * 0.35f, cy + r * 0.22f, cx, cy + r * 0.95f);
  }
  popStyle();
}
