// ================================================================
//  UI.pde  —  SISTEMA DE DISEÑO
//  Academia de Artes Barranquilla · Sistema de Gestión
//
//  Contiene TODO lo visual: paleta, tipografía, layout responsivo,
//  componentes (barra lateral, barra superior, hero, breadcrumb,
//  panel, tarjetas, botones, campos, tablas, avisos) e íconos.
//
//  La lógica de datos y el flujo de estados viven en main.pde.
//  Las utilidades de validación/fecha se conservan aquí tal como
//  estaban para no romper las llamadas existentes.
// ================================================================


// ================================================================
//  1. PALETA
// ================================================================

// --- Neutros / estructura ---
color C_TINTA       = color(16, 30, 62);     // Azul marino profundo
color C_SIDEBAR     = color(17, 31, 61);     // Fondo barra lateral
color C_SIDEBAR_TXT = color(203, 213, 232);  // Texto barra lateral
color C_FONDO       = color(242, 243, 246);  // Fondo general
color C_SUPERFICIE  = color(255, 255, 255);  // Tarjetas / paneles
color C_CREMA       = color(250, 249, 246);  // Barra superior / pie
color C_BORDE       = color(226, 229, 234);  // Bordes suaves
color C_TXT         = color(28, 36, 52);     // Texto principal
color C_TXT_SUAVE   = color(106, 116, 130);  // Texto secundario
color C_TXT_TENUE   = color(152, 160, 172);  // Texto terciario

// --- Marca ---
color C_ORO         = color(196, 145, 45);   // Acento de marca (ítem activo)
color C_ORO_CLARO   = color(247, 195, 38);   // Amarillo bandera

// --- Bandera de Colombia (detalles decorativos) ---
color C_BAND_AZUL   = color(41, 65, 115);
color C_BAND_AMAR   = color(247, 195, 38);
color C_BAND_ROJO   = color(200, 40, 40);

// --- Semánticos: par (tinte pastel, trazo saturado) por acción ---
color C_AZUL    = color(26, 115, 232);  color C_AZUL_BG    = color(219, 234, 254);
color C_VERDE   = color(22, 145, 88);   color C_VERDE_BG   = color(214, 245, 227);
color C_NARANJA = color(226, 111, 33);  color C_NARANJA_BG = color(255, 232, 214);
color C_ROJO    = color(197, 48, 48);   color C_ROJO_BG    = color(255, 224, 222);
color C_MORADO  = color(124, 58, 179);  color C_MORADO_BG  = color(236, 222, 250);
color C_AMBAR   = color(198, 138, 13);  color C_AMBAR_BG   = color(253, 236, 200);
color C_GRIS    = color(100, 110, 124); color C_GRIS_BG    = color(227, 230, 236);

// --- Alias de compatibilidad -------------------------------------
// Se conservan por si algún otro archivo del sketch (modelos,
// clases de archivo) hace referencia a los nombres antiguos.
color COLOR_PRIMARIO      = C_TINTA;
color COLOR_FONDO         = C_FONDO;
color COLOR_TARJETA       = C_SUPERFICIE;
color COLOR_TEXTO         = C_TXT;
color COLOR_TEXTO_CLARO   = C_TXT_SUAVE;
color COLOR_ACENTO        = C_ORO;
color COLOR_SIDEBAR       = C_SIDEBAR;
color COLOR_SIDEBAR_TEXTO = C_SIDEBAR_TXT;
color COLOR_SIDEBAR_ACTIVO= C_ORO;
color COLOR_TOPBAR        = C_CREMA;
color COLOR_BORDE_SUAVE   = C_BORDE;
color COLOR_TITULO_MODULO = color(30, 45, 80);
color COLOR_GRIS_DESC     = C_TXT_SUAVE;
color COLOR_AMARILLO_BANDERA = C_BAND_AMAR;
color COLOR_AZUL_BANDERA     = C_BAND_AZUL;
color COLOR_ROJO_BANDERA     = C_BAND_ROJO;
color COLOR_SESIONES      = C_AZUL;
color COLOR_INSTRUCTORES  = C_VERDE;
color COLOR_APRENDICES    = C_MORADO;
color COLOR_REPORTES      = C_AMBAR;
color COLOR_SALIR         = C_ROJO;


// ================================================================
//  2. TIPOGRAFÍA
//  Se generan PFont reales a tamaño grande y con suavizado. Sin
//  esto Processing escala su fuente bitmap de 12 px y todo el
//  texto se ve dentado: era una de las causas del pixelado.
// ================================================================

PFont fSans, fSansBold, fSerif;

void inicializarTipografia() {
  String[] disponibles = PFont.list();

  String sans  = elegirFuente(disponibles, new String[] {
    "Segoe UI", "Helvetica Neue", "SF Pro Text", "Roboto",
    "Noto Sans", "DejaVu Sans", "Arial", "SansSerif" });

  String bold  = elegirFuente(disponibles, new String[] {
    "Segoe UI Semibold", "Segoe UI Bold", "Helvetica Neue Bold",
    "HelveticaNeue-Bold", "Roboto Medium", "Arial Bold",
    "Arial-BoldMT", "DejaVu Sans Bold", "SansSerif" });

  String serif = elegirFuente(disponibles, new String[] {
    "Georgia", "Playfair Display", "Times New Roman", "TimesNewRomanPSMT",
    "Noto Serif", "DejaVu Serif", "Serif" });

  char[] juego = juegoDeCaracteres();
  fSans     = createFont(sans,  64, true, juego);
  fSansBold = createFont(bold,  64, true, juego);
  fSerif    = createFont(serif, 64, true, juego);

  textFont(fSans);
}

String elegirFuente(String[] disponibles, String[] candidatas) {
  for (int i = 0; i < candidatas.length; i++) {
    for (int j = 0; j < disponibles.length; j++) {
      if (disponibles[j].equalsIgnoreCase(candidatas[i])) return disponibles[j];
    }
  }
  return candidatas[candidatas.length - 1];
}

// ASCII + Latin-1 (acentos y ñ) + comillas tipográficas y guiones.
// Se evitan glifos exóticos (✓ ✗ ⚠ ← →): esos se dibujan como
// vectores, así no dependemos de que la fuente del sistema los tenga.
char[] juegoDeCaracteres() {
  StringBuilder sb = new StringBuilder();
  for (char c = 32; c < 127; c++) sb.append(c);
  for (char c = 161; c < 256; c++) sb.append(c);
  sb.append("\u2018\u2019\u201C\u201D\u2013\u2014\u2022\u2026\u00B0");
  return sb.toString().toCharArray();
}

void tipoSans(float t)     { textFont(fSans);     textSize(t); }
void tipoSansBold(float t) { textFont(fSansBold); textSize(t); }
void tipoSerif(float t)    { textFont(fSerif);    textSize(t); }


// ================================================================
//  3. LAYOUT RESPONSIVO
//  Todas las medidas se recalculan en cada cuadro, así la interfaz
//  se adapta al redimensionar la ventana sin recrear objetos.
// ================================================================

float sidebarAncho   = 240;
float sidebarDestino = 240;
float topBarAlto     = 62;
float heroAlto       = 210;
float breadcrumbAlto = 44;
float pieAlto        = 44;
float contentX, contentW;
float margenH        = 28;
float margenV        = 22;
float radioTarjeta   = 14;

boolean sidebarColapsado = false;

// Compatibilidad: algunas versiones antiguas usaban esta constante.
final float SIDEBAR_WIDTH = 240;

void recalcularLayout() {
  boolean estrecho = (width < 1000);
  boolean compacto = sidebarColapsado || estrecho;

  sidebarDestino = compacto ? 78 : constrain(width * 0.155f, 200, 258);
  sidebarAncho   = lerp(sidebarAncho, sidebarDestino, 0.22f);
  if (abs(sidebarAncho - sidebarDestino) < 0.4f) sidebarAncho = sidebarDestino;

  topBarAlto     = constrain(height * 0.062f, 54, 70);
  heroAlto       = constrain(height * 0.245f, 150, 235);
  breadcrumbAlto = constrain(height * 0.045f, 36, 50);
  pieAlto        = constrain(height * 0.048f, 38, 50);

  contentX = sidebarAncho;
  contentW = width - sidebarAncho;
  margenH  = constrain(contentW * 0.028f, 18, 40);
  margenV  = constrain(height * 0.026f, 14, 28);
}

boolean sidebarEstaCompacta() {
  return sidebarAncho < 120;
}


// ================================================================
//  4. ANIMACIÓN
//  Un único reloj global + una transición corta al cambiar de
//  pantalla. Todo es puramente visual: nunca desplaza las zonas
//  clicables, para no desalinear el ratón.
// ================================================================

float pulso = 0;              // 0..TWO_PI, para latidos suaves
float transicion = 0;         // 1 -> 0 al entrar a una pantalla
int   estadoAnterior = -999;

void actualizarAnimaciones() {
  pulso += 0.045f;
  if (pulso > TWO_PI) pulso -= TWO_PI;

  if (estado != estadoAnterior) {
    transicion = 1;
    estadoAnterior = estado;
  }
  transicion = lerp(transicion, 0, 0.20f);
  if (transicion < 0.008f) transicion = 0;
}

// Velo de entrada sobre el área de contenido (la barra lateral
// permanece estable, como en un panel web real).
void dibujarVeloTransicion() {
  if (transicion <= 0) return;
  noStroke();
  fill(red(C_FONDO), green(C_FONDO), blue(C_FONDO), transicion * 215);
  rect(contentX, 0, contentW, height);
}

// Interpolación con paso fijo, independiente del contenido.
float suavizar(float actual, float objetivo, float velocidad) {
  return lerp(actual, objetivo, velocidad);
}


// ================================================================
//  5. PRIMITIVAS DE DIBUJO
// ================================================================

// Sombra suave por capas (Processing no tiene blur barato).
void sombraSuave(float x, float y, float w, float h, float r, float fuerza) {
  noStroke();
  int capas = 5;
  for (int i = capas; i >= 1; i--) {
    float e = i * 2.2f;
    float a = fuerza * (1.0f - (i - 1) / (float) capas) * 0.30f;
    fill(18, 28, 48, a);
    rect(x - e * 0.5f, y - e * 0.5f + 2.5f, w + e, h + e, r + e * 0.5f);
  }
}

// Panel blanco genérico.
void dibujarPanel(float x, float y, float w, float h, float r) {
  sombraSuave(x, y, w, h, r, 34);
  noStroke();
  fill(C_SUPERFICIE);
  stroke(C_BORDE);
  strokeWeight(1);
  rect(x, y, w, h, r);
  noStroke();
}

// Franja tricolor de la bandera.
void dibujarTricolor(float x, float y, float w, float alto) {
  noStroke();
  fill(C_BAND_AZUL); rect(x, y, w / 3, alto, alto * 0.5f, 0, 0, alto * 0.5f);
  fill(C_BAND_AMAR); rect(x + w / 3, y, w / 3, alto);
  fill(C_BAND_ROJO); rect(x + 2 * w / 3, y, w / 3, alto, 0, alto * 0.5f, alto * 0.5f, 0);
}

// Recorta un texto al ancho disponible y le añade puntos suspensivos.
String recortarTexto(String s, float anchoMax) {
  if (s == null) return "";
  if (textWidth(s) <= anchoMax) return s;
  String corte = s;
  while (corte.length() > 1 && textWidth(corte + "\u2026") > anchoMax) {
    corte = corte.substring(0, corte.length() - 1);
  }
  return corte + "\u2026";
}

String letraEspaciada(String s) {
  StringBuilder sb = new StringBuilder();
  for (int i = 0; i < s.length(); i++) {
    sb.append(s.charAt(i));
    if (i < s.length() - 1) sb.append(' ');
  }
  return sb.toString();
}

// Etiqueta de estado (píldora de color).
void dibujarBadge(String texto, float x, float y, color trazo, color fondo) {
  pushStyle();
  tipoSansBold(11);
  float w = textWidth(texto) + 22;
  float h = 22;
  noStroke();
  fill(fondo);
  rect(x, y, w, h, h / 2);
  fill(trazo);
  textAlign(LEFT, CENTER);
  text(texto, x + 11, y + h / 2 + 0.5f);
  popStyle();
}

// Barra de progreso reactiva a los datos (verde / ámbar / rojo).
void dibujarBarraProgreso(float x, float y, float w, float h, float valor, float maximo) {
  float t = (maximo <= 0) ? 0 : constrain(valor / maximo, 0, 1);
  color c = (t < 0.6f) ? C_VERDE : (t < 0.9f ? C_AMBAR : C_ROJO);
  noStroke();
  fill(C_GRIS_BG);
  rect(x, y, w, h, h / 2);
  fill(c);
  rect(x, y, max(h, w * t), h, h / 2);
}


// ================================================================
//  6. FONDO GENERAL
// ================================================================

void dibujarFondo() {
  background(C_FONDO);
  // Degradado vertical apenas perceptible sobre el área de contenido:
  // da profundidad sin recargar ni costar rendimiento.
  noStroke();
  int pasos = 40;
  for (int i = 0; i < pasos; i++) {
    float t = i / (float) pasos;
    fill(lerpColor(color(247, 248, 251), C_FONDO, t));
    rect(contentX, height * t, contentW, height / pasos + 1);
  }
}

// Aparca un componente fuera de la pantalla cuando la pantalla actual
// no lo muestra, para que no quede una zona clicable invisible.
void aparcar(Boton b) { if (b != null) b.colocar(-3000, -3000, 1, 1); }
void aparcar(CampoTexto c) { if (c != null) c.colocar(-3000, -3000); }


// ================================================================
//  7. BARRA LATERAL
// ================================================================

String[] NAV_LABELS  = {"Inicio", "Sesiones", "Instructores", "Aprendices", "Reportes", "Reinicio", "Salir"};
String[] NAV_ICONOS  = {"home", "calendario", "personas", "gorro", "grafico", "refrescar", "salir"};

// El destino de cada ítem se resuelve con una función y NO con un
// array inicializado en la declaración: un campo no puede referenciar
// constantes definidas en otro tab del sketch (MENU_PRINCIPAL y
// compañía viven en main.pde) y Processing lo rechaza con
// "Cannot reference a field before it is defined".
// Dentro de un método la referencia sí es válida, sea cual sea el
// orden en que Processing concatene los tabs.
int navEstado(int i) {
  switch (i) {
    case 0:  return MENU_PRINCIPAL;
    case 1:  return MENU_SESIONES;
    case 2:  return MENU_INSTRUCTORES;
    case 3:  return MENU_APRENDICES;
    case 4:  return MENU_REPORTES;
    case 5:  return -1;    // Reinicio
    default: return -2;    // Salir
  }
}

// Rectángulos de los ítems, recalculados cada cuadro (se usan para
// el dibujo y para la detección de clics: siempre coinciden).
float[] navX = new float[7];
float[] navY = new float[7];
float[] navW = new float[7];
float[] navH = new float[7];
float   navIndicadorY = -1;   // posición animada del resaltado

// Zona clicable del botón hamburguesa de la barra superior.
float hamX, hamY, hamR;

// A qué módulo pertenece el estado actual (para resaltar el ítem
// correcto aunque estemos dentro de un sub-formulario).
int grupoDeEstado(int e) {
  if (e == MENU_INSTRUCTORES || (e >= 10 && e <= 14)) return MENU_INSTRUCTORES;
  if (e == MENU_APRENDICES   || (e >= 20 && e <= 24)) return MENU_APRENDICES;
  if (e == MENU_SESIONES     || (e >= 30 && e <= 34)) return MENU_SESIONES;
  if (e == MENU_REPORTES     || e == VER_REPORTE)     return MENU_REPORTES;
  if (e == MENU_PRINCIPAL)                            return MENU_PRINCIPAL;
  return -99;
}

void dibujarBarraLateral() {
  boolean compacta = sidebarEstaCompacta();
  int grupo = grupoDeEstado(estado);

  // --- Fondo con degradado vertical sutil ---
  noStroke();
  for (int i = 0; i < 60; i++) {
    float t = i / 59.0f;
    fill(lerpColor(C_SIDEBAR, color(11, 21, 44), t));
    rect(0, height * t, sidebarAncho, height / 60.0f + 1);
  }

  // --- Logo ---
  float logoY = compacta ? 44 : constrain(height * 0.082f, 58, 92);
  float logoR = compacta ? 17 : constrain(sidebarAncho * 0.155f, 26, 40);
  float cx = sidebarAncho / 2;
  dibujarLogoAcademia(cx, logoY, logoR);

  float y = logoY + logoR * 1.9f;

  if (!compacta) {
    fill(255);
    textAlign(CENTER, TOP);
    tipoSansBold(constrain(sidebarAncho * 0.062f, 10.5f, 12.5f));
    text(letraEspaciada("ACADEMIA DE ARTES"), cx, y);
    text(letraEspaciada("BARRANQUILLA"), cx, y + 16);
    y += 38;
    dibujarTricolor(cx - 26, y, 52, 3);
    y += 20;
  } else {
    y += 6;
  }

  stroke(255, 255, 255, 34);
  strokeWeight(1);
  line(sidebarAncho * 0.16f, y, sidebarAncho * 0.84f, y);
  noStroke();
  y += 20;

  // --- Ítems de navegación ---
  float itemH = constrain(height * 0.052f, 40, 50);
  float gap   = 6;
  float pad   = compacta ? 10 : constrain(sidebarAncho * 0.075f, 12, 20);
  float indicadorObjetivo = -1;

  for (int i = 0; i < NAV_LABELS.length; i++) {
    // Separador visual antes de Reinicio / Salir
    if (i == 5) y += 12;

    navX[i] = pad;
    navY[i] = y;
    navW[i] = sidebarAncho - pad * 2;
    navH[i] = itemH;

    boolean activo = (navEstado(i) == grupo);
    boolean sobre  = enZona(navX[i], navY[i], navW[i], navH[i]);
    if (activo) indicadorObjetivo = y;

    if (!activo && sobre) {
      noStroke();
      fill(255, 255, 255, 22);
      rect(navX[i], navY[i], navW[i], navH[i], 9);
    }

    color cIcono = activo ? color(255) : (sobre ? color(255) : C_SIDEBAR_TXT);
    float ix = compacta ? navX[i] + navW[i] / 2 : navX[i] + itemH * 0.52f;
    dibujarIcono(NAV_ICONOS[i], ix, navY[i] + itemH / 2, itemH * 0.28f, cIcono);

    if (!compacta) {
      fill(cIcono);
      if (activo) tipoSansBold(constrain(sidebarAncho * 0.062f, 12, 14.5f));
      else        tipoSans(constrain(sidebarAncho * 0.062f, 12, 14.5f));
      textAlign(LEFT, CENTER);
      text(NAV_LABELS[i], navX[i] + itemH * 1.05f, navY[i] + itemH / 2 + 1);
    }

    y += itemH + gap;
  }

  // Resaltado dorado que se desliza entre ítems (sólo visual).
  if (indicadorObjetivo >= 0) {
    if (navIndicadorY < 0) navIndicadorY = indicadorObjetivo;
    navIndicadorY = suavizar(navIndicadorY, indicadorObjetivo, 0.26f);
    noStroke();
    fill(C_ORO);
    rect(pad, navIndicadorY, sidebarAncho - pad * 2, itemH, 9);
    // Se redibuja el contenido del ítem activo encima del resaltado.
    for (int i = 0; i < NAV_LABELS.length; i++) {
      if (navEstado(i) != grupo) continue;
      float ix = compacta ? navX[i] + navW[i] / 2 : navX[i] + itemH * 0.52f;
      dibujarIcono(NAV_ICONOS[i], ix, navY[i] + itemH / 2, itemH * 0.28f, color(255));
      if (!compacta) {
        fill(255);
        tipoSansBold(constrain(sidebarAncho * 0.062f, 12, 14.5f));
        textAlign(LEFT, CENTER);
        text(NAV_LABELS[i], navX[i] + itemH * 1.05f, navY[i] + itemH / 2 + 1);
      }
    }
  }

  // --- Ilustración y lema (sólo con espacio suficiente) ---
  if (!compacta && height > 620) {
    float ilY = y + 24;
    float ilH = height - ilY - 96;
    if (ilH > 70) dibujarSiluetaBarranquilla(0, ilY, sidebarAncho, ilH);

    fill(198, 209, 228);
    textAlign(CENTER, TOP);
    tipoSans(constrain(sidebarAncho * 0.05f, 8.5f, 10.5f));
    float lemaY = height - 74;
    text(letraEspaciada("ARTE QUE TRANSFORMA"), cx, lemaY);
    text(letraEspaciada("CULTURA QUE NOS UNE"), cx, lemaY + 15);
    dibujarTricolor(cx - 30, height - 30, 60, 3);
  }
}

// Sol/máscara de carnaval estilizado.
void dibujarLogoAcademia(float cx, float cy, float r) {
  pushStyle();
  noStroke();
  int rayos = 12;
  for (int i = 0; i < rayos; i++) {
    float ang = TWO_PI / rayos * i + pulso * 0.06f;
    fill((i % 2 == 0) ? C_BAND_AMAR : color(224, 90, 40));
    pushMatrix();
    translate(cx, cy);
    rotate(ang);
    triangle(0, -r * 0.62f, -r * 0.17f, -r * 1.45f, r * 0.17f, -r * 1.45f);
    popMatrix();
  }
  fill(232, 205, 158);
  ellipse(cx, cy, r * 1.25f, r * 1.25f);
  fill(C_BAND_ROJO);
  arc(cx, cy - r * 0.12f, r * 1.25f, r * 1.25f, PI, TWO_PI);
  fill(42, 32, 22);
  ellipse(cx - r * 0.24f, cy - r * 0.03f, r * 0.15f, r * 0.15f);
  ellipse(cx + r * 0.24f, cy - r * 0.03f, r * 0.15f, r * 0.15f);
  popStyle();
}

// Línea de horizonte: catedral, arcos y palmera.
void dibujarSiluetaBarranquilla(float x, float y, float w, float h) {
  pushStyle();
  noFill();
  stroke(255, 255, 255, 38);
  strokeWeight(1.1f);
  float baseY = y + h * 0.88f;

  float tx = x + w * 0.30f;
  rect(tx - w * 0.05f, baseY - h * 0.50f, w * 0.10f, h * 0.50f);
  rect(tx + w * 0.14f, baseY - h * 0.62f, w * 0.10f, h * 0.62f);
  triangle(tx + w * 0.14f, baseY - h * 0.62f, tx + w * 0.19f, baseY - h * 0.78f, tx + w * 0.24f, baseY - h * 0.62f);
  rect(tx - w * 0.22f, baseY - h * 0.36f, w * 0.10f, h * 0.36f);

  for (int i = 0; i < 3; i++) {
    float ax = x + w * 0.55f + i * w * 0.10f;
    arc(ax, baseY - h * 0.28f, w * 0.09f, h * 0.30f, PI, TWO_PI);
    line(ax - w * 0.045f, baseY - h * 0.28f, ax - w * 0.045f, baseY);
    line(ax + w * 0.045f, baseY - h * 0.28f, ax + w * 0.045f, baseY);
  }
  line(x + w * 0.08f, baseY, x + w * 0.92f, baseY);

  float px = x + w * 0.80f;
  line(px, baseY, px - w * 0.03f, baseY - h * 0.55f);
  for (int i = 0; i < 5; i++) {
    float ang = -HALF_PI + (i - 2) * 0.4f;
    line(px - w * 0.03f, baseY - h * 0.55f,
         px - w * 0.03f + cos(ang) * w * 0.16f, baseY - h * 0.55f + sin(ang) * w * 0.16f);
  }
  popStyle();
}

// Clic en barra lateral o en el botón hamburguesa.
// Devuelve true si el clic fue consumido aquí.
boolean manejarClicSidebar() {
  // Hamburguesa: contrae / expande la barra lateral (sólo visual).
  if (dist(mouseX, mouseY, hamX, hamY) <= hamR) {
    sidebarColapsado = !sidebarColapsado;
    return true;
  }

  if (mouseX > sidebarAncho) return false;

  for (int i = 0; i < NAV_LABELS.length; i++) {
    if (enZona(navX[i], navY[i], navW[i], navH[i])) {
      int destino = navEstado(i);
      if (destino == -1) {
        mostrarOpcionesReinicio();
      } else if (destino == -2) {
        exit();
      } else {
        estado = destino;
        limpiarDatosTemporales();
        limpiarCamposFormulario();
        mensaje = "";
      }
      return true;
    }
  }
  return true;   // clic dentro de la barra pero fuera de un ítem: se ignora
}

boolean enZona(float x, float y, float w, float h) {
  return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
}


// ================================================================
//  8. BARRA SUPERIOR
// ================================================================

void dibujarBarraSuperior() {
  noStroke();
  fill(C_CREMA);
  rect(sidebarAncho, 0, width - sidebarAncho, topBarAlto);
  stroke(C_BORDE);
  strokeWeight(1);
  line(sidebarAncho, topBarAlto, width, topBarAlto);
  noStroke();

  // Hamburguesa (zona clicable)
  hamX = sidebarAncho + 32;
  hamY = topBarAlto / 2;
  hamR = 18;
  boolean sobreHam = dist(mouseX, mouseY, hamX, hamY) <= hamR;
  if (sobreHam) {
    noStroke();
    fill(C_TINTA, 18);
    ellipse(hamX, hamY, hamR * 2, hamR * 2);
  }
  dibujarIcono("hamburguesa", hamX, hamY, 10, sobreHam ? C_TINTA : color(72, 80, 94));

  fill(COLOR_TITULO_MODULO);
  textAlign(LEFT, CENTER);
  tipoSansBold(constrain(width * 0.013f, 14, 18));
  text("Sistema de Gestión", sidebarAncho + 60, topBarAlto / 2);

  // Zona derecha: campana + avatar
  float derecha = width - 24;
  dibujarIcono("chevron", derecha - 8, topBarAlto / 2, 6, color(120, 128, 140));

  float txtW;
  tipoSans(13.5f);
  txtW = textWidth("Administrador");
  float nomX = derecha - 26 - txtW;
  fill(COLOR_TITULO_MODULO);
  textAlign(LEFT, CENTER);
  text("Administrador", nomX, topBarAlto / 2);

  float avX = nomX - 22;
  noStroke();
  fill(224, 228, 234);
  ellipse(avX, topBarAlto / 2, 32, 32);
  fill(160, 168, 180);
  ellipse(avX, topBarAlto / 2 - 5, 12, 12);
  arc(avX, topBarAlto / 2 + 16, 20, 17, PI, TWO_PI);

  float sepX = avX - 26;
  stroke(C_BORDE);
  strokeWeight(1);
  line(sepX, topBarAlto * 0.28f, sepX, topBarAlto * 0.72f);
  noStroke();

  float campX = sepX - 26;
  dibujarIcono("campana", campX, topBarAlto / 2, 10, color(78, 86, 100));
  // Punto de notificación con latido muy sutil
  noStroke();
  fill(C_ROJO, 200 + sin(pulso) * 55);
  ellipse(campX + 6, topBarAlto / 2 - 7, 6, 6);
}


// ================================================================
//  9. HERO DE MÓDULO
// ================================================================

void dibujarHero(PImage img, color acento, String kicker, String titulo,
                 String[] descripcion, String[] cita, String[] palabras) {
  float hx = sidebarAncho, hy = topBarAlto;
  float hw = width - sidebarAncho, hh = heroAlto;

  // --- Fondo ---
  if (img != null && img.width > 0) {
    pushStyle();
    clip(hx, hy, hw, hh);
    float escala = max(hw / (float) img.width, hh / (float) img.height);
    float iw = img.width * escala;
    float ih = img.height * escala;
    image(img, hx + (hw - iw) / 2, hy + (hh - ih) / 2, iw, ih);
    noClip();
    popStyle();
  } else {
    dibujarHeroProcedural(hx, hy, hw, hh, acento);
  }

  // --- Velo degradado para que el texto siempre sea legible ---
  noStroke();
  int pasos = 180;
  for (int i = 0; i < pasos; i++) {
    float t = i / (float) pasos;
    fill(9, 15, 28, lerp(228, 30, t));
    rect(hx + hw * t, hy, hw / pasos + 1.2f, hh);
  }
  fill(9, 15, 28, 70);
  rect(hx, hy + hh * 0.62f, hw, hh * 0.38f);

  // --- Texto ---
  float tx = hx + margenH;
  float ty = hy + hh * 0.13f;

  fill(C_ORO_CLARO);
  textAlign(LEFT, TOP);
  tipoSansBold(constrain(hh * 0.062f, 10, 13));
  text(letraEspaciada(kicker), tx, ty);

  fill(255);
  tipoSerif(constrain(hh * 0.235f, 28, 50));
  text(titulo, tx, ty + hh * 0.085f);

  float by = ty + hh * 0.085f + constrain(hh * 0.235f, 28, 50) * 1.02f;
  dibujarTricolor(tx, by, 165, 4);

  fill(232, 235, 240);
  tipoSans(constrain(hh * 0.058f, 11, 14));
  float dy = by + 16;
  for (int i = 0; i < descripcion.length; i++) {
    if (descripcion[i] == null) continue;
    text(descripcion[i], tx, dy + i * (constrain(hh * 0.058f, 11, 14) + 6));
  }

  // --- Cita y palabras clave, sólo si hay ancho suficiente ---
  if (hw > 720 && cita != null) {
    float qx = hx + hw - margenH;
    textAlign(RIGHT, TOP);
    fill(255, 255, 255, 238);
    tipoSerif(constrain(hh * 0.075f, 12, 17));
    for (int i = 0; i < cita.length; i++) {
      if (cita[i] == null) continue;
      text(cita[i], qx, hy + hh * 0.12f + i * (constrain(hh * 0.075f, 12, 17) + 6));
    }
    if (palabras != null) {
      fill(C_ORO_CLARO);
      tipoSansBold(constrain(hh * 0.045f, 8.5f, 10.5f));
      float wy = hy + hh * 0.58f;
      for (int i = 0; i < palabras.length; i++) {
        text(letraEspaciada(palabras[i]), qx, wy + i * 15);
      }
    }
    textAlign(LEFT, TOP);
  }
}

// Fondo generado por código cuando no hay imagen disponible.
// Evita depender de un JPEG de baja resolución (fuente de pixelado).
void dibujarHeroProcedural(float x, float y, float w, float h, color acento) {
  noStroke();
  int pasos = 120;
  for (int i = 0; i < pasos; i++) {
    float t = i / (float) pasos;
    fill(lerpColor(color(20, 32, 60), lerpColor(acento, color(30, 20, 14), 0.55f), t));
    rect(x + w * t, y, w / pasos + 1.2f, h);
  }
  // Arcos y trazos de "taller de arte", muy tenues.
  pushStyle();
  noFill();
  stroke(255, 255, 255, 26);
  strokeWeight(1.4f);
  for (int i = 0; i < 6; i++) {
    float ax = x + w * (0.52f + i * 0.075f);
    arc(ax, y + h * 0.92f, w * 0.055f, h * 0.75f, PI, TWO_PI);
  }
  stroke(255, 255, 255, 18);
  for (int i = 0; i < 4; i++) {
    float r = h * (0.5f + i * 0.28f);
    ellipse(x + w * 0.86f, y + h * 0.30f, r, r);
  }
  popStyle();
}


// ================================================================
//  10. BREADCRUMB / TÍTULO / PIE
// ================================================================

void dibujarBreadcrumb(String nivel1, String nivel2) {
  float by = topBarAlto + heroAlto;
  dibujarBreadcrumbEn(by, nivel1, nivel2);
}

void dibujarBreadcrumbEn(float by, String nivel1, String nivel2) {
  noStroke();
  fill(C_FONDO);
  rect(sidebarAncho, by, width - sidebarAncho, breadcrumbAlto);
  stroke(C_BORDE);
  strokeWeight(1);
  line(sidebarAncho, by + breadcrumbAlto, width, by + breadcrumbAlto);
  noStroke();

  float tx = sidebarAncho + margenH;
  float cy = by + breadcrumbAlto / 2;
  dibujarIcono("home", tx, cy, 8, color(96, 104, 118));

  textAlign(LEFT, CENTER);
  tipoSans(13);
  float xp = tx + 20;

  fill(96, 104, 118);
  text("Inicio", xp, cy);
  xp += textWidth("Inicio") + 9;

  dibujarIcono("chevron-der", xp + 4, cy, 5, color(172, 180, 190));
  xp += 17;

  if (nivel2 == null) {
    fill(COLOR_TITULO_MODULO);
    tipoSansBold(13);
    text(nivel1, xp, cy);
  } else {
    fill(96, 104, 118);
    text(nivel1, xp, cy);
    xp += textWidth(nivel1) + 9;
    dibujarIcono("chevron-der", xp + 4, cy, 5, color(172, 180, 190));
    xp += 17;
    fill(COLOR_TITULO_MODULO);
    tipoSansBold(13);
    text(nivel2, xp, cy);
  }

  // Fecha alineada a la derecha (se oculta si no cabe)
  if (width - sidebarAncho > 640) {
    fill(114, 122, 134);
    textAlign(RIGHT, CENTER);
    tipoSans(12.5f);
    text(fechaLargaEspanol(), width - margenH, cy);
    textAlign(LEFT, CENTER);
  }
}

// Título de módulo dentro del panel de contenido.
void dibujarTituloModulo(float x, float y, String titulo, String subtitulo, String cita1, String cita2) {
  fill(COLOR_TITULO_MODULO);
  textAlign(LEFT, TOP);
  tipoSerif(constrain(width * 0.021f, 22, 32));
  text(titulo, x, y);
  float th = constrain(width * 0.021f, 22, 32);

  fill(C_ORO);
  tipoSansBold(11.5f);
  text(letraEspaciada(subtitulo), x, y + th * 1.18f);

  noStroke();
  fill(C_AZUL);
  rect(x, y + th * 1.18f + 20, 52, 3, 1.5f);

  if (cita1 != null && contentW > 700) {
    fill(122, 130, 142);
    textAlign(RIGHT, TOP);
    tipoSerif(14.5f);
    text(cita1, width - margenH * 2, y + 2);
    if (cita2 != null) text(cita2, width - margenH * 2, y + 22);
    textAlign(LEFT, TOP);
  }
}

void dibujarPie() {
  float fy = height - pieAlto;
  noStroke();
  fill(C_CREMA);
  rect(sidebarAncho, fy, width - sidebarAncho, pieAlto);
  stroke(C_BORDE);
  strokeWeight(1);
  line(sidebarAncho, fy, width, fy);
  noStroke();

  fill(126, 134, 146);
  textAlign(LEFT, CENTER);
  tipoSans(11.5f);
  text("\u00A9 2025 Academia de Artes Barranquilla. Todos los derechos reservados.",
       sidebarAncho + margenH, fy + pieAlto / 2);

  if (contentW > 620) {
    textAlign(RIGHT, CENTER);
    float px = width - margenH;
    tipoSans(11.5f);
    text("Barranquilla, Atlántico, Colombia", px, fy + pieAlto / 2);
    float anchoTxt = textWidth("Barranquilla, Atlántico, Colombia");
    dibujarIcono("pin", px - anchoTxt - 12, fy + pieAlto / 2, 7, color(126, 134, 146));
    dibujarTricolor(px - anchoTxt - 110, fy + pieAlto / 2 - 1.5f, 78, 3);
    textAlign(LEFT, CENTER);
  }
}

// Alias de compatibilidad con el nombre anterior.
void dibujarPieSesiones() { dibujarPie(); }


// ================================================================
//  11. ARMADO DE PANTALLAS
//  Dos plantillas: módulo (con hero) y sub-pantalla (compacta).
//  Ambas devuelven la coordenada Y donde empieza el contenido útil.
// ================================================================

float panelX, panelY, panelW, panelH;   // panel de contenido vigente

// Pantalla de módulo: barra lateral + barra superior + hero +
// breadcrumb + panel blanco. Devuelve el Y interior del panel.
float dibujarPantallaModulo(PImage img, color acento, String kicker, String titulo,
                            String[] descripcion, String[] cita, String[] palabras,
                            String breadcrumbTexto) {
  dibujarFondo();
  dibujarBarraLateral();
  dibujarBarraSuperior();
  dibujarHero(img, acento, kicker, titulo, descripcion, cita, palabras);
  dibujarBreadcrumb(breadcrumbTexto, null);

  panelX = contentX + margenH;
  panelY = topBarAlto + heroAlto + breadcrumbAlto + margenV;
  panelW = contentW - margenH * 2;
  panelH = height - pieAlto - panelY - margenV;
  dibujarPanel(panelX, panelY, panelW, panelH, radioTarjeta);
  dibujarOrnamento(panelX + panelW * 0.62f, panelY + 18, panelW * 0.22f, 70);

  return panelY + margenV;
}

// Sub-pantalla (formularios y listados): sin hero, más espacio útil.
float dibujarPantallaSub(String modulo, String seccion) {
  dibujarFondo();
  dibujarBarraLateral();
  dibujarBarraSuperior();
  dibujarBreadcrumbEn(topBarAlto, modulo, seccion);

  panelX = contentX + margenH;
  panelY = topBarAlto + breadcrumbAlto + margenV;
  panelW = contentW - margenH * 2;
  panelH = height - pieAlto - panelY - margenV;
  dibujarPanel(panelX, panelY, panelW, panelH, radioTarjeta);

  float ty = panelY + margenV;
  fill(COLOR_TITULO_MODULO);
  textAlign(LEFT, TOP);
  tipoSerif(constrain(width * 0.019f, 20, 28));
  text(seccion, panelX + margenH, ty);
  float th = constrain(width * 0.019f, 20, 28);

  fill(C_ORO);
  tipoSansBold(11);
  text(letraEspaciada(modulo.toUpperCase()), panelX + margenH, ty + th * 1.15f);

  noStroke();
  fill(C_AZUL);
  rect(panelX + margenH, ty + th * 1.15f + 18, 46, 3, 1.5f);

  return ty + th * 1.15f + 42;
}

// Alias de compatibilidad con el nombre anterior.
float dibujarEncabezadoSesionesSub(String seccion) {
  return dibujarPantallaSub("Módulo de Sesiones", seccion);
}

// Ornamento de línea muy tenue en la esquina del panel (como en las
// referencias: un trazo de pincel/paleta apenas insinuado).
void dibujarOrnamento(float x, float y, float w, float h) {
  if (contentW < 820) return;
  pushStyle();
  noFill();
  stroke(C_TXT, 16);
  strokeWeight(1.2f);
  ellipse(x + w * 0.5f, y + h * 0.5f, w * 0.8f, h * 0.85f);
  ellipse(x + w * 0.5f, y + h * 0.5f, w * 0.5f, h * 0.5f);
  for (int i = 0; i < 4; i++) {
    float a = -0.9f + i * 0.45f;
    line(x + w * 0.5f + cos(a) * w * 0.42f, y + h * 0.5f + sin(a) * h * 0.44f,
         x + w * 0.5f + cos(a) * w * 0.62f, y + h * 0.5f + sin(a) * h * 0.66f);
  }
  popStyle();
}


// ================================================================
//  12. BOTONES Y TARJETAS
// ================================================================

// Variantes de botón simple
final int BTN_PRIMARIO = 0;
final int BTN_EXITO    = 1;
final int BTN_PELIGRO  = 2;
final int BTN_NEUTRO   = 3;
final int BTN_FANTASMA = 4;   // contorno, para "Volver"

class Boton {
  float x, y, w, h;
  String label;
  String subtitulo = "";
  String numero = "";
  String descripcion = "";
  String icono = "";

  color colorFondo;
  color colorHover;
  color colorBorde;
  color colorIconoFondo;
  color colorIconoTrazo;
  color colorAccento;

  boolean esTarjeta   = false;
  boolean habilitado  = true;
  boolean tieneBorde  = true;
  int  variante       = BTN_PRIMARIO;
  int  borderRadius   = 10;

  // Estado de animación (puramente visual)
  float animHover = 0;
  float animPress = 0;

  // --- Constructor TARJETA (módulos y acciones con ícono) ---
  Boton(float x, float y, float w, float h, String label, String descripcion,
        String icono, color colorIconoFondo, color colorIconoTrazo, color colorAccento) {
    this.x = x; this.y = y; this.w = w; this.h = h;
    this.label = label;
    this.descripcion = descripcion;
    this.icono = icono;
    this.colorIconoFondo = colorIconoFondo;
    this.colorIconoTrazo = colorIconoTrazo;
    this.colorAccento = colorAccento;
    this.esTarjeta = true;
    this.colorFondo = C_SUPERFICIE;
    this.colorHover = color(252, 252, 254);
    this.colorBorde = C_BORDE;
    this.borderRadius = 12;
  }

  // --- Constructor con número + subtítulo (compatibilidad) ---
  Boton(float x, float y, float w, float h, String numero, String label,
        String subtitulo, color fondo, color hover) {
    this.x = x; this.y = y; this.w = w; this.h = h;
    this.numero = numero;
    this.label = label;
    this.subtitulo = subtitulo;
    this.colorFondo = fondo;
    this.colorHover = hover;
    this.colorBorde = C_BORDE;
  }

  // --- Constructor SIMPLE ---
  Boton(float x, float y, float w, float h, String label, color fondo, color hover) {
    this.x = x; this.y = y; this.w = w; this.h = h;
    this.label = label;
    this.colorFondo = fondo;
    this.colorHover = hover;
    this.colorBorde = C_BORDE;
  }

  boolean contieneClic(float mx, float my) {
    if (!habilitado) return false;
    return mx >= x && mx <= x + w && my >= y && my <= y + h;
  }

  void colocar(float nx, float ny, float nw, float nh) {
    x = nx; y = ny; w = nw; h = nh;
  }

  void actualizarEstado() {
    boolean sobre = habilitado && mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
    animHover = suavizar(animHover, sobre ? 1 : 0, 0.20f);
    boolean presionado = sobre && mousePressed;
    animPress = suavizar(animPress, presionado ? 1 : 0, 0.35f);
  }

  void dibujar() {
    actualizarEstado();
    if (esTarjeta) dibujarTarjeta();
    else           dibujarSimple();
  }

  // ---------- TARJETA ----------
  void dibujarTarjeta() {
    pushStyle();
    float lift = animHover * 3 - animPress * 2;   // sólo sombra/acento
    float alpha = habilitado ? 255 : 120;

    sombraSuave(x, y - lift * 0.4f, w, h, borderRadius, 26 + animHover * 34);

    fill(lerpColor(colorFondo, colorHover, animHover));
    stroke(lerpColor(colorBorde, colorAccento, animHover * 0.5f));
    strokeWeight(1 + animHover * 0.6f);
    rect(x, y, w, h, borderRadius);
    noStroke();

    // Barra de acento inferior, crece al pasar el ratón
    float bh = 4 + animHover * 2.5f;
    fill(colorAccento, alpha);
    rect(x, y + h - bh, w, bh, 0, 0, borderRadius, borderRadius);

    float cx = x + w / 2;

    // Círculo de ícono
    float rIcono = constrain(min(w, h) * 0.19f, 20, 34);
    float cyIcono = y + h * 0.235f;
    fill(colorIconoFondo, alpha);
    ellipse(cx, cyIcono, rIcono * 2, rIcono * 2);
    if (animHover > 0.02f) {
      noFill();
      stroke(colorAccento, animHover * 70);
      strokeWeight(1.5f);
      ellipse(cx, cyIcono, rIcono * 2 + 8 * animHover, rIcono * 2 + 8 * animHover);
      noStroke();
    }
    dibujarIcono(icono, cx, cyIcono, rIcono * 0.52f, colorIconoTrazo);

    // Título
    fill(COLOR_TITULO_MODULO, alpha);
    textAlign(CENTER, TOP);
    tipoSerif(constrain(w * 0.085f, 13, 18));
    float tw = w - 24;
    text(label, cx - tw / 2, y + h * 0.44f, tw, h * 0.20f);

    // Descripción
    fill(C_TXT_SUAVE, alpha);
    tipoSans(constrain(w * 0.055f, 10.5f, 12.5f));
    textLeading(constrain(w * 0.055f, 10.5f, 12.5f) * 1.42f);
    text(descripcion, cx - tw / 2, y + h * 0.62f, tw, h * 0.26f);

    // Botón circular con flecha (se rellena al pasar el ratón)
    float rf = constrain(min(w, h) * 0.09f, 13, 20);
    float fx = x + w - rf - 16;
    float fy = y + h - rf - 16;
    fill(lerpColor(colorIconoFondo, colorAccento, animHover), alpha);
    ellipse(fx, fy, rf * 2, rf * 2);
    dibujarIcono("flecha-der", fx + animHover * 2, fy,
                 rf * 0.55f, lerpColor(colorAccento, color(255), animHover));
    popStyle();
  }

  // ---------- BOTÓN SIMPLE ----------
  void dibujarSimple() {
    pushStyle();
    color base, txt, borde;

    switch (variante) {
      case BTN_EXITO:    base = C_VERDE;  txt = color(255); borde = C_VERDE;  break;
      case BTN_PELIGRO:  base = C_ROJO;   txt = color(255); borde = C_ROJO;   break;
      case BTN_NEUTRO:   base = C_GRIS;   txt = color(255); borde = C_GRIS;   break;
      case BTN_FANTASMA: base = color(255); txt = C_TXT;    borde = C_BORDE;  break;
      default:           base = C_AZUL;   txt = color(255); borde = C_AZUL;   break;
    }

    if (!habilitado) {
      base  = C_GRIS_BG;
      txt   = C_TXT_TENUE;
      borde = C_BORDE;
    }

    float r = min(borderRadius, h / 2);
    float hundir = animPress * 1.5f;

    if (habilitado && variante != BTN_FANTASMA) {
      sombraSuave(x, y - animHover * 1.5f + hundir, w, h, r, 22 + animHover * 26);
    }

    color relleno = (variante == BTN_FANTASMA)
      ? lerpColor(color(255), color(244, 246, 250), animHover)
      : lerpColor(base, lerpColor(base, color(255), 0.16f), animHover);
    if (habilitado) relleno = lerpColor(relleno, lerpColor(base, color(0), 0.12f), animPress);

    fill(relleno);
    stroke(variante == BTN_FANTASMA ? lerpColor(borde, C_TINTA, animHover * 0.5f) : borde);
    strokeWeight(variante == BTN_FANTASMA ? 1.4f : 1);
    rect(x, y + hundir, w, h, r);
    noStroke();

    // Contenido: ícono opcional + etiqueta, centrados como bloque
    tipoSansBold(constrain(h * 0.34f, 12, 15));
    float anchoTxt = textWidth(label);
    float rIco = h * 0.22f;
    float anchoTotal = anchoTxt + (icono.isEmpty() ? 0 : rIco * 2 + 10);
    float ix = x + (w - anchoTotal) / 2;

    if (!icono.isEmpty()) {
      dibujarIcono(icono, ix + rIco, y + h / 2 + hundir, rIco, txt);
      ix += rIco * 2 + 10;
    }
    fill(txt);
    textAlign(LEFT, CENTER);
    text(label, ix, y + h / 2 + hundir + 0.5f);
    popStyle();
  }
}

// Reparte tarjetas en una rejilla dentro de un ancho dado.
// Modifica x/y/w/h de cada botón: el dibujo y el clic siempre
// usan la misma geometría, así que nunca se desalinean.
float colocarRejilla(ArrayList<Boton> lista, int desde, int hasta,
                     float x, float y, float anchoTotal, int columnas,
                     float alto, float gap) {
  int n = hasta - desde;
  if (n <= 0) return y;
  columnas = max(1, min(columnas, n));
  float cw = (anchoTotal - gap * (columnas - 1)) / columnas;
  float filaY = y;
  for (int i = 0; i < n; i++) {
    int col = i % columnas;
    int fila = i / columnas;
    filaY = y + fila * (alto + gap);
    lista.get(desde + i).colocar(x + col * (cw + gap), filaY, cw, alto);
  }
  return filaY + alto;
}


// ================================================================
//  13. CAMPO DE TEXTO
// ================================================================

class CampoTexto {
  float x, y, w, h;
  String etiqueta;
  String contenido = "";
  boolean activo = false;
  boolean habilitado = true;
  float animFoco = 0;

  // Compatibilidad con el código anterior
  color colorBorde = C_BORDE;
  color colorActivo = C_AZUL;

  CampoTexto(float x, float y, float w, float h, String etiqueta) {
    this.x = x; this.y = y; this.w = w; this.h = h;
    this.etiqueta = etiqueta;
  }

  boolean contieneClic(float mx, float my) {
    if (!habilitado) return false;
    return mx >= x && mx <= x + w && my >= y && my <= y + h;
  }

  void colocar(float nx, float ny) { x = nx; y = ny; }
  void colocar(float nx, float ny, float nw) { x = nx; y = ny; w = nw; }

  void manejarTecla(char tecla, int codigoTecla) {
    if (!activo) return;
    if (codigoTecla == BACKSPACE) {
      if (contenido.length() > 0) {
        contenido = contenido.substring(0, contenido.length() - 1);
      }
    } else if (tecla >= ' ' && tecla != CODED) {
      if (contenido.length() < 39) contenido += tecla;
    }
  }

  void dibujar() {
    pushStyle();
    animFoco = suavizar(animFoco, activo ? 1 : 0, 0.25f);
    boolean sobre = contieneClic(mouseX, mouseY);

    // Etiqueta superior
    fill(activo ? C_AZUL : C_TXT_SUAVE);
    textAlign(LEFT, BOTTOM);
    tipoSansBold(11);
    text(etiqueta, x, y - 7);

    // Halo de foco
    if (animFoco > 0.02f) {
      noStroke();
      fill(C_AZUL, animFoco * 34);
      rect(x - 4, y - 4, w + 8, h + 8, 11);
    }

    // Caja
    fill(habilitado ? color(255) : color(247, 248, 250));
    stroke(activo ? C_AZUL : (sobre ? color(178, 186, 198) : C_BORDE));
    strokeWeight(activo ? 1.8f : 1.2f);
    rect(x, y, w, h, 9);
    noStroke();

    // Contenido o marcador de posición
    textAlign(LEFT, CENTER);
    tipoSans(14);
    float cy = y + h / 2 + 0.5f;
    if (contenido.isEmpty()) {
      fill(C_TXT_TENUE);
      text(recortarTexto(etiqueta, w - 24), x + 13, cy);
    } else {
      fill(C_TXT);
      text(recortarTexto(contenido, w - 24), x + 13, cy);
    }

    // Cursor parpadeante
    if (activo && (millis() / 500) % 2 == 0) {
      float cx = x + 13 + textWidth(recortarTexto(contenido, w - 24)) + 2;
      stroke(C_AZUL);
      strokeWeight(1.6f);
      line(cx, y + h * 0.26f, cx, y + h * 0.74f);
      noStroke();
    }
    popStyle();
  }

  void limpiar() { contenido = ""; }
}


// ================================================================
//  14. TABLAS
// ================================================================

float dibujarEncabezadoTabla(float x, float y, float w, String[] cols, float[] pesos) {
  pushStyle();
  float h = 34;
  noStroke();
  fill(247, 248, 251);
  rect(x, y, w, h, 8, 8, 0, 0);
  stroke(C_BORDE);
  strokeWeight(1);
  line(x, y + h, x + w, y + h);
  noStroke();

  fill(C_TXT_SUAVE);
  tipoSansBold(11);
  textAlign(LEFT, CENTER);
  float cx = x + 14;
  for (int i = 0; i < cols.length; i++) {
    float cw = w * pesos[i];
    text(recortarTexto(letraEspaciada(cols[i].toUpperCase()), cw - 16), cx, y + h / 2);
    cx += cw;
  }
  popStyle();
  return y + h;
}

// Dibuja el fondo alterno de una fila. El texto lo pinta quien llama,
// para poder mezclar celdas de texto, insignias y barras.
void dibujarFilaTabla(float x, float y, float w, float h, int indice) {
  pushStyle();
  noStroke();
  if (indice % 2 == 1) {
    fill(250, 251, 253);
    rect(x, y, w, h);
  }
  stroke(C_BORDE, 130);
  strokeWeight(1);
  line(x + 10, y + h, x + w - 10, y + h);
  popStyle();
}

// Mensaje para tablas vacías.
void dibujarTablaVacia(float x, float y, float w, String texto) {
  pushStyle();
  noStroke();
  fill(249, 250, 252);
  rect(x, y, w, 96, 10);
  dibujarIcono("lista", x + w / 2, y + 34, 13, C_TXT_TENUE);
  fill(C_TXT_SUAVE);
  textAlign(CENTER, TOP);
  tipoSans(13.5f);
  text(texto, x + w / 2, y + 56);
  popStyle();
}


// ================================================================
//  15. AVISOS (TOAST)
// ================================================================

int   toastInicio = 0;
float toastAnim = 0;
final int TOAST_DURACION = 4600;

void mostrarMensaje(String texto, boolean esError) {
  mensaje = texto;
  colorMensaje = esError ? color(200, 40, 40) : color(39, 174, 96);
  toastInicio = millis();
}

void dibujarMensaje() {
  if (mensaje == null || mensaje.isEmpty()) {
    toastAnim = suavizar(toastAnim, 0, 0.25f);
    return;
  }

  int transcurrido = millis() - toastInicio;
  boolean saliendo = transcurrido > TOAST_DURACION;
  toastAnim = suavizar(toastAnim, saliendo ? 0 : 1, 0.22f);

  if (saliendo && toastAnim < 0.03f) {
    mensaje = "";
    return;
  }

  pushStyle();
  boolean esError = (colorMensaje == color(200, 40, 40));
  color acento = esError ? C_ROJO : C_VERDE;
  color tinte  = esError ? C_ROJO_BG : C_VERDE_BG;

  tipoSans(13);
  float anchoTexto = textWidth(mensaje);
  float w = constrain(anchoTexto + 92, 260, contentW - margenH * 2);
  float h = 54;
  float x = contentX + (contentW - w) / 2;
  float yFinal = height - pieAlto - h - 18;
  float y = lerp(yFinal + 26, yFinal, toastAnim);
  float alpha = toastAnim * 255;

  sombraSuave(x, y, w, h, 12, 46 * toastAnim);
  noStroke();
  fill(255, alpha);
  rect(x, y, w, h, 12);
  fill(acento, alpha);
  rect(x, y, 5, h, 12, 0, 0, 12);

  // Ícono en círculo
  noStroke();
  fill(tinte, alpha);
  ellipse(x + 38, y + h / 2 - 3, 30, 30);
  dibujarIcono(esError ? "equis" : "check", x + 38, y + h / 2 - 3, 7, acento);

  fill(C_TXT, alpha);
  textAlign(LEFT, CENTER);
  tipoSans(13);
  text(recortarTexto(mensaje, w - 78), x + 62, y + h / 2 - 3);

  // Barra de tiempo restante
  float t = 1 - constrain(transcurrido / (float) TOAST_DURACION, 0, 1);
  noStroke();
  fill(acento, alpha * 0.35f);
  rect(x + 5, y + h - 4, (w - 5) * t, 3, 0, 2, 2, 0);
  popStyle();
}


// ================================================================
//  16. UTILIDADES (lógica compartida — sin cambios de comportamiento)
// ================================================================

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
  desactivarTodosLosCampos();
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

void desactivarTodosLosCampos() {
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
}

void activarCampoSiClic(CampoTexto campo) {
  if (campo == null) return;
  if (campo.contieneClic(mouseX, mouseY)) {
    desactivarTodosLosCampos();
    campo.activo = true;
  }
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
    int anio = Integer.parseInt(partes[0]);
    int mes = Integer.parseInt(partes[1]);
    int dia = Integer.parseInt(partes[2]);
    if (anio < 2000 || anio > 2100) return false;
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
  int anio = cal.get(java.util.Calendar.YEAR);
  int mes = cal.get(java.util.Calendar.MONTH) + 1;
  int dia = cal.get(java.util.Calendar.DAY_OF_MONTH);
  return String.format("%04d-%02d-%02d", anio, mes, dia);
}

String generarCodigoSesion() {
  java.util.Calendar cal = java.util.Calendar.getInstance();
  long tiempo = cal.getTimeInMillis();
  return "SES" + tiempo;
}

String fechaLargaEspanol() {
  String[] dias = {"Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"};
  String[] meses = {"enero", "febrero", "marzo", "abril", "mayo", "junio", "julio",
                    "agosto", "septiembre", "octubre", "noviembre", "diciembre"};
  java.util.Calendar cal = java.util.Calendar.getInstance();
  int diaSemana = cal.get(java.util.Calendar.DAY_OF_WEEK) - 1;
  int dia = cal.get(java.util.Calendar.DAY_OF_MONTH);
  int mes = cal.get(java.util.Calendar.MONTH);
  int anio = cal.get(java.util.Calendar.YEAR);
  return dias[diaSemana] + ", " + dia + " de " + meses[mes] + " de " + anio;
}


// ================================================================
//  17. ÍCONOS VECTORIALES
//  Todos se dibujan con trazos: escalan sin pixelarse a cualquier
//  tamaño y no dependen de fuentes de símbolos ni de imágenes.
// ================================================================

void dibujarIcono(String tipo, float cx, float cy, float r, color c) {
  pushStyle();
  rectMode(CENTER);
  noFill();
  stroke(c);
  strokeWeight(max(1.5f, r * 0.17f));
  strokeCap(ROUND);
  strokeJoin(ROUND);

  if (tipo.equals("home")) {
    line(cx - r * 0.85f, cy - r * 0.05f, cx, cy - r * 0.82f);
    line(cx, cy - r * 0.82f, cx + r * 0.85f, cy - r * 0.05f);
    rect(cx, cy + r * 0.32f, r * 1.15f, r * 0.9f, r * 0.12f);

  } else if (tipo.equals("calendario")) {
    rect(cx, cy + r * 0.12f, r * 1.7f, r * 1.5f, r * 0.22f);
    line(cx - r * 0.55f, cy - r * 0.62f, cx - r * 0.55f, cy - r * 0.98f);
    line(cx + r * 0.55f, cy - r * 0.62f, cx + r * 0.55f, cy - r * 0.98f);
    line(cx - r * 0.85f, cy - r * 0.22f, cx + r * 0.85f, cy - r * 0.22f);
    noStroke(); fill(c);
    ellipse(cx - r * 0.28f, cy + r * 0.38f, r * 0.22f, r * 0.22f);
    ellipse(cx + r * 0.30f, cy + r * 0.38f, r * 0.22f, r * 0.22f);

  } else if (tipo.equals("calendario-mas")) {
    rect(cx, cy + r * 0.12f, r * 1.7f, r * 1.5f, r * 0.22f);
    line(cx - r * 0.55f, cy - r * 0.62f, cx - r * 0.55f, cy - r * 0.98f);
    line(cx + r * 0.55f, cy - r * 0.62f, cx + r * 0.55f, cy - r * 0.98f);
    line(cx - r * 0.85f, cy - r * 0.22f, cx + r * 0.85f, cy - r * 0.22f);
    line(cx, cy + r * 0.02f, cx, cy + r * 0.72f);
    line(cx - r * 0.35f, cy + r * 0.37f, cx + r * 0.35f, cy + r * 0.37f);

  } else if (tipo.equals("calendario-x")) {
    rect(cx, cy + r * 0.12f, r * 1.7f, r * 1.5f, r * 0.22f);
    line(cx - r * 0.55f, cy - r * 0.62f, cx - r * 0.55f, cy - r * 0.98f);
    line(cx + r * 0.55f, cy - r * 0.62f, cx + r * 0.55f, cy - r * 0.98f);
    line(cx - r * 0.85f, cy - r * 0.22f, cx + r * 0.85f, cy - r * 0.22f);
    line(cx - r * 0.30f, cy + r * 0.10f, cx + r * 0.30f, cy + r * 0.66f);
    line(cx + r * 0.30f, cy + r * 0.10f, cx - r * 0.30f, cy + r * 0.66f);

  } else if (tipo.equals("buscar")) {
    ellipse(cx - r * 0.14f, cy - r * 0.14f, r * 1.2f, r * 1.2f);
    line(cx + r * 0.48f, cy + r * 0.48f, cx + r * 1.0f, cy + r * 1.0f);

  } else if (tipo.equals("lista")) {
    for (int i = -1; i <= 1; i++) {
      float ly = cy + i * r * 0.52f;
      noStroke(); fill(c);
      ellipse(cx - r * 0.75f, ly, r * 0.26f, r * 0.26f);
      stroke(c); noFill();
      line(cx - r * 0.40f, ly, cx + r * 0.88f, ly);
    }

  } else if (tipo.equals("personas")) {
    ellipse(cx - r * 0.36f, cy - r * 0.30f, r * 0.62f, r * 0.62f);
    ellipse(cx + r * 0.40f, cy - r * 0.20f, r * 0.50f, r * 0.50f);
    arc(cx - r * 0.36f, cy + r * 0.56f, r * 1.15f, r * 0.95f, PI, TWO_PI);
    arc(cx + r * 0.40f, cy + r * 0.56f, r * 0.95f, r * 0.78f, PI, TWO_PI);

  } else if (tipo.equals("persona-mas")) {
    ellipse(cx - r * 0.25f, cy - r * 0.35f, r * 0.68f, r * 0.68f);
    arc(cx - r * 0.25f, cy + r * 0.55f, r * 1.25f, r * 1.0f, PI, TWO_PI);
    line(cx + r * 0.62f, cy - r * 0.12f, cx + r * 0.62f, cy + r * 0.52f);
    line(cx + r * 0.30f, cy + r * 0.20f, cx + r * 0.94f, cy + r * 0.20f);

  } else if (tipo.equals("gorro")) {
    line(cx - r * 0.92f, cy - r * 0.08f, cx, cy - r * 0.62f);
    line(cx, cy - r * 0.62f, cx + r * 0.92f, cy - r * 0.08f);
    line(cx + r * 0.92f, cy - r * 0.08f, cx, cy + r * 0.36f);
    line(cx, cy + r * 0.36f, cx - r * 0.92f, cy - r * 0.08f);
    line(cx - r * 0.38f, cy + r * 0.16f, cx - r * 0.38f, cy + r * 0.60f);
    line(cx + r * 0.38f, cy + r * 0.16f, cx + r * 0.38f, cy + r * 0.60f);
    line(cx - r * 0.38f, cy + r * 0.60f, cx + r * 0.38f, cy + r * 0.60f);

  } else if (tipo.equals("grafico")) {
    line(cx - r * 0.88f, cy + r * 0.82f, cx + r * 0.88f, cy + r * 0.82f);
    line(cx - r * 0.50f, cy + r * 0.70f, cx - r * 0.50f, cy - r * 0.10f);
    line(cx, cy + r * 0.70f, cx, cy - r * 0.62f);
    line(cx + r * 0.50f, cy + r * 0.70f, cx + r * 0.50f, cy + r * 0.20f);

  } else if (tipo.equals("lapiz")) {
    line(cx - r * 0.72f, cy + r * 0.70f, cx - r * 0.52f, cy + r * 0.12f);
    line(cx - r * 0.52f, cy + r * 0.12f, cx + r * 0.42f, cy - r * 0.80f);
    line(cx + r * 0.42f, cy - r * 0.80f, cx + r * 0.80f, cy - r * 0.42f);
    line(cx + r * 0.80f, cy - r * 0.42f, cx - r * 0.14f, cy + r * 0.50f);
    line(cx - r * 0.14f, cy + r * 0.50f, cx - r * 0.72f, cy + r * 0.70f);

  } else if (tipo.equals("basura")) {
    line(cx - r * 0.72f, cy - r * 0.52f, cx + r * 0.72f, cy - r * 0.52f);
    line(cx - r * 0.30f, cy - r * 0.75f, cx + r * 0.30f, cy - r * 0.75f);
    line(cx - r * 0.55f, cy - r * 0.52f, cx - r * 0.42f, cy + r * 0.80f);
    line(cx + r * 0.55f, cy - r * 0.52f, cx + r * 0.42f, cy + r * 0.80f);
    line(cx - r * 0.42f, cy + r * 0.80f, cx + r * 0.42f, cy + r * 0.80f);
    line(cx - r * 0.16f, cy - r * 0.28f, cx - r * 0.14f, cy + r * 0.52f);
    line(cx + r * 0.16f, cy - r * 0.28f, cx + r * 0.14f, cy + r * 0.52f);

  } else if (tipo.equals("refrescar")) {
    arc(cx, cy, r * 1.45f, r * 1.45f, -HALF_PI * 1.6f, PI * 0.85f);
    arc(cx, cy, r * 1.45f, r * 1.45f, PI * 0.15f, HALF_PI * 1.6f);
    line(cx + r * 0.56f, cy - r * 0.80f, cx + r * 0.90f, cy - r * 0.47f);
    line(cx + r * 0.90f, cy - r * 0.47f, cx + r * 0.49f, cy - r * 0.39f);
    line(cx - r * 0.56f, cy + r * 0.80f, cx - r * 0.90f, cy + r * 0.47f);
    line(cx - r * 0.90f, cy + r * 0.47f, cx - r * 0.49f, cy + r * 0.39f);

  } else if (tipo.equals("salir")) {
    line(cx - r * 0.15f, cy - r * 0.78f, cx - r * 0.72f, cy - r * 0.78f);
    line(cx - r * 0.72f, cy - r * 0.78f, cx - r * 0.72f, cy + r * 0.78f);
    line(cx - r * 0.72f, cy + r * 0.78f, cx - r * 0.15f, cy + r * 0.78f);
    line(cx - r * 0.10f, cy, cx + r * 0.86f, cy);
    line(cx + r * 0.46f, cy - r * 0.38f, cx + r * 0.86f, cy);
    line(cx + r * 0.46f, cy + r * 0.38f, cx + r * 0.86f, cy);

  } else if (tipo.equals("flecha-der")) {
    line(cx - r * 0.80f, cy, cx + r * 0.80f, cy);
    line(cx + r * 0.26f, cy - r * 0.50f, cx + r * 0.80f, cy);
    line(cx + r * 0.26f, cy + r * 0.50f, cx + r * 0.80f, cy);

  } else if (tipo.equals("flecha-izq") || tipo.equals("volver")) {
    line(cx + r * 0.80f, cy, cx - r * 0.80f, cy);
    line(cx - r * 0.26f, cy - r * 0.50f, cx - r * 0.80f, cy);
    line(cx - r * 0.26f, cy + r * 0.50f, cx - r * 0.80f, cy);

  } else if (tipo.equals("chevron")) {
    line(cx - r * 0.6f, cy - r * 0.3f, cx, cy + r * 0.3f);
    line(cx, cy + r * 0.3f, cx + r * 0.6f, cy - r * 0.3f);

  } else if (tipo.equals("chevron-der")) {
    line(cx - r * 0.35f, cy - r * 0.6f, cx + r * 0.30f, cy);
    line(cx + r * 0.30f, cy, cx - r * 0.35f, cy + r * 0.6f);

  } else if (tipo.equals("campana")) {
    arc(cx, cy - r * 0.06f, r * 1.25f, r * 1.25f, PI, TWO_PI);
    line(cx - r * 0.62f, cy - r * 0.06f, cx - r * 0.62f, cy + r * 0.36f);
    line(cx + r * 0.62f, cy - r * 0.06f, cx + r * 0.62f, cy + r * 0.36f);
    line(cx - r * 0.76f, cy + r * 0.36f, cx + r * 0.76f, cy + r * 0.36f);
    noStroke(); fill(c);
    ellipse(cx, cy + r * 0.64f, r * 0.32f, r * 0.32f);

  } else if (tipo.equals("hamburguesa")) {
    line(cx - r * 0.85f, cy - r * 0.52f, cx + r * 0.85f, cy - r * 0.52f);
    line(cx - r * 0.85f, cy, cx + r * 0.85f, cy);
    line(cx - r * 0.85f, cy + r * 0.52f, cx + r * 0.85f, cy + r * 0.52f);

  } else if (tipo.equals("pin")) {
    ellipse(cx, cy - r * 0.18f, r * 1.1f, r * 1.1f);
    noStroke(); fill(c);
    ellipse(cx, cy - r * 0.18f, r * 0.35f, r * 0.35f);
    triangle(cx - r * 0.35f, cy + r * 0.22f, cx + r * 0.35f, cy + r * 0.22f, cx, cy + r * 0.95f);

  } else if (tipo.equals("check")) {
    line(cx - r * 0.78f, cy + r * 0.06f, cx - r * 0.22f, cy + r * 0.62f);
    line(cx - r * 0.22f, cy + r * 0.62f, cx + r * 0.80f, cy - r * 0.60f);

  } else if (tipo.equals("equis")) {
    line(cx - r * 0.68f, cy - r * 0.68f, cx + r * 0.68f, cy + r * 0.68f);
    line(cx + r * 0.68f, cy - r * 0.68f, cx - r * 0.68f, cy + r * 0.68f);

  } else if (tipo.equals("alerta")) {
    line(cx, cy - r * 0.85f, cx - r * 0.95f, cy + r * 0.72f);
    line(cx - r * 0.95f, cy + r * 0.72f, cx + r * 0.95f, cy + r * 0.72f);
    line(cx + r * 0.95f, cy + r * 0.72f, cx, cy - r * 0.85f);
    line(cx, cy - r * 0.22f, cx, cy + r * 0.24f);
    noStroke(); fill(c);
    ellipse(cx, cy + r * 0.50f, r * 0.20f, r * 0.20f);

  } else if (tipo.equals("guardar")) {
    rect(cx, cy, r * 1.6f, r * 1.6f, r * 0.18f);
    line(cx - r * 0.42f, cy - r * 0.80f, cx - r * 0.42f, cy - r * 0.18f);
    line(cx + r * 0.42f, cy - r * 0.80f, cx + r * 0.42f, cy - r * 0.18f);
    line(cx - r * 0.42f, cy - r * 0.18f, cx + r * 0.42f, cy - r * 0.18f);
    rect(cx, cy + r * 0.42f, r * 0.9f, r * 0.65f, r * 0.08f);

  } else if (tipo.equals("reloj")) {
    ellipse(cx, cy, r * 1.7f, r * 1.7f);
    line(cx, cy - r * 0.48f, cx, cy);
    line(cx, cy, cx + r * 0.42f, cy + r * 0.18f);

  } else if (tipo.equals("etiqueta")) {
    ellipse(cx, cy, r * 1.7f, r * 1.7f);
    line(cx, cy - r * 0.20f, cx, cy + r * 0.52f);
    noStroke(); fill(c);
    ellipse(cx, cy - r * 0.52f, r * 0.22f, r * 0.22f);
  }

  popStyle();
}

// Alias de compatibilidad con el nombre anterior.
void dibujarIconoIndicador(String tipo, float cx, float cy, float r, color c) {
  dibujarIcono(tipo, cx, cy, r, c);
}
