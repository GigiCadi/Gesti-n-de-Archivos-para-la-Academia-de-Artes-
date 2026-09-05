// ================================================================
// LABORATORIO 1 - Manejo de Archivos en Java (Processing)
// Academia de Artes Barranquilla - SISTEMA COMPLETO
//
// main.pde  ->  estados, datos, eventos y composición de pantallas
// UI.pde    ->  sistema de diseño (paleta, tipografía, componentes)
//
// La lógica de negocio (validaciones, archivos, contadores) es la
// misma de la versión anterior. Sólo cambió la capa visual y la
// configuración de render.
// ================================================================

import java.io.RandomAccessFile;
import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.ArrayList;

// ---- Estados de la aplicación ----
final int MENU_PRINCIPAL       = 0;
final int MENU_INSTRUCTORES    = 1;
final int MENU_APRENDICES      = 2;
final int MENU_SESIONES        = 3;
final int MENU_REPORTES        = 4;
final int VER_REPORTE          = 40;

// Sub-estados de instructores
final int CREAR_INSTRUCTOR     = 10;
final int CONSULTAR_INSTRUCTOR = 11;
final int ACTUALIZAR_INSTRUCTOR= 12;
final int ELIMINAR_INSTRUCTOR  = 13;
final int LISTAR_INSTRUCTORES  = 14;

// Sub-estados de aprendices
final int CREAR_APRENDIZ       = 20;
final int CONSULTAR_APRENDIZ   = 21;
final int ACTUALIZAR_APRENDIZ  = 22;
final int ELIMINAR_APRENDIZ    = 23;
final int LISTAR_APRENDICES    = 24;

// Sub-estados de sesiones
final int ASIGNAR_SESION       = 30;
final int CONSULTAR_SESION     = 31;
final int CANCELAR_SESION      = 32;
final int LISTAR_SESIONES      = 33;
final int SELECCIONAR_INSTRUCTOR_SESION = 34;

int estado = MENU_PRINCIPAL;

// ---- Archivos ----
ArchivoInstructores archivoInstructores;
ArchivoAprendices archivoAprendices;
ArchivoSesiones archivoSesiones;

// ---- Botones ----
ArrayList<Boton> botonesMenuPrincipal;
ArrayList<Boton> botonesMenuInstructores;
ArrayList<Boton> botonesMenuAprendices;
ArrayList<Boton> botonesMenuSesiones;
ArrayList<Boton> botonesMenuReportes;
ArrayList<Boton> botonesInstructoresDisponibles;

Boton botonGuardar, botonBuscar, botonEliminar, botonVolver, botonCancelar;
Boton botonAsignar;
Boton botonVolverSesiones;

// ---- Campos de formulario ----
CampoTexto campoCedula, campoNombre, campoEspecialidad, campoTelefono;
CampoTexto campoCedulaAprendiz, campoNombreAprendiz, campoEspecialidadAprendiz;
CampoTexto campoCodigoSesion, campoFechaSesion;
CampoTexto campoEspecialidadSesion;

// ---- Feedback ----
String mensaje = "";
color colorMensaje = color(0);

// ---- Resultados y datos temporales ----
Instructor instructorEncontrado = null;
Aprendiz aprendizEncontrado = null;
Sesion sesionEncontrada = null;
ArrayList<Instructor> listaInstructores = null;
ArrayList<Aprendiz> listaAprendices = null;
ArrayList<Sesion> listaSesiones = null;
ArrayList<Instructor> instructoresDisponibles = null;
String cedulaAprendizSeleccionado = "";
String especialidadSeleccionada = "";
String fechaSesionSeleccionada = "";
int instructorSeleccionadoIndex = -1;

// ---- Imágenes de cabecera (opcionales: si no existen, el hero se
//      genera por código y así nunca se ve una imagen ampliada) ----
PImage imgEncabezadoInicio;
PImage imgEncabezadoSesiones;
PImage imgEncabezadoInstructores;
PImage imgEncabezadoAprendices;
PImage imgEncabezadoReportes;

// ---- Estadísticas del inicio (con caché para no leer los archivos
//      en cada cuadro) ----
int statInstructores = 0, statInstDisponibles = 0;
int statAprendices = 0, statAprConCupo = 0, statSesiones = 0;
int ultimoRefrescoStats = -99999;


// ================================================================
// SETTINGS: configuración de render
//
// Aquí estaba la causa del pixelado:
//   - noSmooth() apagaba el antialiasing de TODO el sketch.
//   - pixelDensity(1) forzaba 1x incluso en pantallas HiDPI.
// Ahora se activa el suavizado y se usa la densidad real del monitor.
// ================================================================
void settings() {
  size(1440, 900);
  pixelDensity(displayDensity());
  smooth();
}

// ================================================================
// SETUP
// ================================================================
void setup() {
  surface.setTitle("Academia de Artes Barranquilla - Sistema de Gestión");
  surface.setResizable(true);

  try {
    java.awt.Frame frame = (java.awt.Frame) surface.getNative();
    frame.setExtendedState(java.awt.Frame.MAXIMIZED_BOTH);
    frame.setVisible(true);
    frame.requestFocus();
  } catch (Exception e) {
    println("Nota: no se pudo maximizar automáticamente.");
  }

  // Fuentes reales y suavizadas (sustituyen a la fuente bitmap
  // por defecto, que Processing escalaba y se veía dentada).
  inicializarTipografia();

  recalcularLayout();
  cargarImagenesCabecera();

  archivoInstructores = new ArchivoInstructores(sketchPath("data/instructores.dat"));
  archivoAprendices   = new ArchivoAprendices(sketchPath("data/aprendices.dat"));
  archivoSesiones     = new ArchivoSesiones(sketchPath("data/sesiones.dat"));

  if (!archivoInstructores.abrir()) mostrarMensaje("No se pudo abrir el archivo de instructores.", true);
  if (!archivoAprendices.abrir())   mostrarMensaje("No se pudo abrir el archivo de aprendices.", true);
  if (!archivoSesiones.abrir())     mostrarMensaje("No se pudo abrir el archivo de sesiones.", true);

  inicializarBotones();
  inicializarCampos();
}

// Carga una imagen sólo si el archivo existe, probando extensiones
// comunes. Evita los errores en consola y el hero queda procedural.
PImage cargarImagenOpcional(String base) {
  String[] ext = {".jpg", ".jpeg", ".png"};
  for (int i = 0; i < ext.length; i++) {
    File f = new File(dataPath(base + ext[i]));
    if (f.exists()) return loadImage(base + ext[i]);
  }
  return null;
}

void cargarImagenesCabecera() {
  imgEncabezadoInicio       = cargarImagenOpcional("header_inicio");
  imgEncabezadoSesiones     = cargarImagenOpcional("header_sesiones");
  imgEncabezadoInstructores = cargarImagenOpcional("header_instructores");
  imgEncabezadoAprendices   = cargarImagenOpcional("header_aprendices");
  imgEncabezadoReportes     = cargarImagenOpcional("header_reportes");
}


// ================================================================
// INICIALIZACIÓN DE COMPONENTES
// La geometría se asigna después, en cada cuadro, para que la
// interfaz se adapte al tamaño real de la ventana.
// ================================================================

void inicializarBotones() {
  // ---- MENÚ PRINCIPAL (5 módulos) ----
  botonesMenuPrincipal = new ArrayList<Boton>();
  botonesMenuPrincipal.add(new Boton(0, 0, 10, 10, "Módulo de Sesiones",
    "Asigna, consulta, cancela y lista las sesiones del mes.",
    "calendario", C_AZUL_BG, C_AZUL, C_AZUL));
  botonesMenuPrincipal.add(new Boton(0, 0, 10, 10, "Módulo de Instructores",
    "Crea, consulta, actualiza y elimina instructores.",
    "personas", C_VERDE_BG, C_VERDE, C_VERDE));
  botonesMenuPrincipal.add(new Boton(0, 0, 10, 10, "Módulo de Aprendices",
    "Gestiona los aprendices y sus especialidades.",
    "gorro", C_MORADO_BG, C_MORADO, C_MORADO));
  botonesMenuPrincipal.add(new Boton(0, 0, 10, 10, "Reportes y Reinicio",
    "Consulta disponibilidad y reinicia los contadores.",
    "grafico", C_AMBAR_BG, C_AMBAR, C_AMBAR));
  botonesMenuPrincipal.add(new Boton(0, 0, 10, 10, "Salir del Sistema",
    "Guarda los cambios y cierra la aplicación.",
    "salir", C_ROJO_BG, C_ROJO, C_ROJO));

  // ---- MENÚ DE INSTRUCTORES (7 acciones) ----
  botonesMenuInstructores = new ArrayList<Boton>();
  botonesMenuInstructores.add(new Boton(0, 0, 10, 10, "Crear Instructor",
    "Registra un nuevo instructor en la academia.",
    "persona-mas", C_AZUL_BG, C_AZUL, C_AZUL));
  botonesMenuInstructores.add(new Boton(0, 0, 10, 10, "Consultar Instructor",
    "Busca la información de un instructor por su cédula.",
    "buscar", C_VERDE_BG, C_VERDE, C_VERDE));
  botonesMenuInstructores.add(new Boton(0, 0, 10, 10, "Actualizar Instructor",
    "Modifica nombre, especialidad o teléfono.",
    "lapiz", C_NARANJA_BG, C_NARANJA, C_NARANJA));
  botonesMenuInstructores.add(new Boton(0, 0, 10, 10, "Eliminar Instructor",
    "Elimina un instructor del sistema.",
    "basura", C_ROJO_BG, C_ROJO, C_ROJO));
  botonesMenuInstructores.add(new Boton(0, 0, 10, 10, "Listar Instructores",
    "Visualiza todos los instructores y sus sesiones.",
    "lista", C_MORADO_BG, C_MORADO, C_MORADO));
  botonesMenuInstructores.add(new Boton(0, 0, 10, 10, "Reiniciar Sesiones del Mes",
    "Pone en cero el contador de todos los instructores.",
    "refrescar", C_AMBAR_BG, C_AMBAR, C_AMBAR));
  botonesMenuInstructores.add(new Boton(0, 0, 10, 10, "Volver",
    "Regresa al menú principal.",
    "flecha-izq", C_GRIS_BG, C_GRIS, color(70, 80, 96)));

  // ---- MENÚ DE APRENDICES (7 acciones) ----
  botonesMenuAprendices = new ArrayList<Boton>();
  botonesMenuAprendices.add(new Boton(0, 0, 10, 10, "Crear Aprendiz",
    "Registra un nuevo aprendiz en la academia.",
    "persona-mas", C_AZUL_BG, C_AZUL, C_AZUL));
  botonesMenuAprendices.add(new Boton(0, 0, 10, 10, "Consultar Aprendiz",
    "Busca la información de un aprendiz por su cédula.",
    "buscar", C_VERDE_BG, C_VERDE, C_VERDE));
  botonesMenuAprendices.add(new Boton(0, 0, 10, 10, "Actualizar Aprendiz",
    "Modifica el nombre o las especialidades.",
    "lapiz", C_NARANJA_BG, C_NARANJA, C_NARANJA));
  botonesMenuAprendices.add(new Boton(0, 0, 10, 10, "Eliminar Aprendiz",
    "Elimina un aprendiz del sistema.",
    "basura", C_ROJO_BG, C_ROJO, C_ROJO));
  botonesMenuAprendices.add(new Boton(0, 0, 10, 10, "Listar Aprendices",
    "Visualiza todos los aprendices y sus sesiones.",
    "lista", C_MORADO_BG, C_MORADO, C_MORADO));
  botonesMenuAprendices.add(new Boton(0, 0, 10, 10, "Reiniciar Sesiones del Mes",
    "Pone en cero el contador de todos los aprendices.",
    "refrescar", C_AMBAR_BG, C_AMBAR, C_AMBAR));
  botonesMenuAprendices.add(new Boton(0, 0, 10, 10, "Volver",
    "Regresa al menú principal.",
    "flecha-izq", C_GRIS_BG, C_GRIS, color(70, 80, 96)));

  // ---- MENÚ DE SESIONES (4 tarjetas + Volver) ----
  botonesMenuSesiones = new ArrayList<Boton>();
  botonesMenuSesiones.add(new Boton(0, 0, 10, 10, "Asignar Nueva Sesión",
    "Registra una nueva sesión de clase siguiendo el proceso guiado.",
    "calendario-mas", C_AZUL_BG, C_AZUL, C_AZUL));
  botonesMenuSesiones.add(new Boton(0, 0, 10, 10, "Consultar Sesión por Código",
    "Busca la información de una sesión usando su código único.",
    "buscar", C_VERDE_BG, C_VERDE, C_VERDE));
  botonesMenuSesiones.add(new Boton(0, 0, 10, 10, "Cancelar Sesión",
    "Cancela una sesión programada (sólo si es con fecha futura).",
    "calendario-x", C_NARANJA_BG, C_NARANJA, C_NARANJA));
  botonesMenuSesiones.add(new Boton(0, 0, 10, 10, "Listar Sesiones del Mes",
    "Visualiza todas las sesiones programadas actualmente.",
    "lista", C_MORADO_BG, C_MORADO, C_MORADO));
  // Índice 4: se conserva la posición para no alterar mousePressed,
  // pero se dibuja como botón de contorno, igual que en la referencia.
  Boton volverSes = new Boton(0, 0, 130, 42, "Volver", color(255), color(248));
  volverSes.variante = BTN_FANTASMA;
  volverSes.icono = "flecha-izq";
  botonesMenuSesiones.add(volverSes);

  // ---- MENÚ DE REPORTES (3 tarjetas) ----
  botonesMenuReportes = new ArrayList<Boton>();
  botonesMenuReportes.add(new Boton(0, 0, 10, 10, "Reporte de Disponibilidad",
    "Consulta los instructores con cupo y los aprendices con especialidades disponibles.",
    "grafico", C_MORADO_BG, C_MORADO, C_MORADO));
  botonesMenuReportes.add(new Boton(0, 0, 10, 10, "Reiniciar Contadores del Mes",
    "Reinicia el contador de sesiones de instructores y aprendices a 0.",
    "refrescar", C_AMBAR_BG, C_AMBAR, C_AMBAR));
  botonesMenuReportes.add(new Boton(0, 0, 10, 10, "Volver",
    "Regresa al menú principal.",
    "flecha-izq", C_GRIS_BG, C_GRIS, color(70, 80, 96)));

  // ---- BOTONES DE ACCIÓN ----
  botonGuardar  = new Boton(0, 0, 170, 46, "Guardar", C_VERDE, C_VERDE);
  botonGuardar.variante = BTN_EXITO;
  botonGuardar.icono = "guardar";

  botonBuscar   = new Boton(0, 0, 130, 46, "Buscar", C_AZUL, C_AZUL);
  botonBuscar.variante = BTN_PRIMARIO;
  botonBuscar.icono = "buscar";

  botonEliminar = new Boton(0, 0, 180, 46, "Eliminar", C_ROJO, C_ROJO);
  botonEliminar.variante = BTN_PELIGRO;
  botonEliminar.icono = "basura";

  botonCancelar = new Boton(0, 0, 140, 46, "Cancelar", color(255), color(248));
  botonCancelar.variante = BTN_FANTASMA;

  botonVolver   = new Boton(0, 0, 130, 42, "Volver", color(255), color(248));
  botonVolver.variante = BTN_FANTASMA;
  botonVolver.icono = "flecha-izq";

  botonAsignar  = new Boton(0, 0, 210, 46, "Asignar Sesión", C_AZUL, C_AZUL);
  botonAsignar.variante = BTN_PRIMARIO;
  botonAsignar.icono = "calendario-mas";

  botonVolverSesiones = new Boton(0, 0, 130, 42, "Volver", color(255), color(248));
  botonVolverSesiones.variante = BTN_FANTASMA;
  botonVolverSesiones.icono = "flecha-izq";

  botonesInstructoresDisponibles = new ArrayList<Boton>();
}

void inicializarCampos() {
  campoCedula       = new CampoTexto(0, 0, 340, 44, "Cédula");
  campoNombre       = new CampoTexto(0, 0, 340, 44, "Nombre");
  campoEspecialidad = new CampoTexto(0, 0, 340, 44, "Especialidad");
  campoTelefono     = new CampoTexto(0, 0, 340, 44, "Teléfono");

  campoCedulaAprendiz       = new CampoTexto(0, 0, 340, 44, "Cédula");
  campoNombreAprendiz       = new CampoTexto(0, 0, 340, 44, "Nombre");
  campoEspecialidadAprendiz = new CampoTexto(0, 0, 340, 44, "Especialidades (separadas por coma)");

  campoCodigoSesion       = new CampoTexto(0, 0, 340, 44, "Código de sesión");
  campoFechaSesion        = new CampoTexto(0, 0, 340, 44, "Fecha (AAAA-MM-DD)");
  campoEspecialidadSesion = new CampoTexto(0, 0, 340, 44, "Especialidad");
}


// ================================================================
// DRAW
// ================================================================
void draw() {
  recalcularLayout();
  actualizarAnimaciones();

  switch (estado) {
    case MENU_PRINCIPAL:        dibujarMenuPrincipal(); break;
    case MENU_INSTRUCTORES:     dibujarMenuInstructores(); break;
    case MENU_APRENDICES:       dibujarMenuAprendices(); break;
    case MENU_SESIONES:         dibujarMenuSesiones(); break;
    case MENU_REPORTES:         dibujarMenuReportes(); break;
    case VER_REPORTE:           dibujarReporte(); break;
    case CREAR_INSTRUCTOR:      dibujarFormularioCrearInstructor(); break;
    case CONSULTAR_INSTRUCTOR:  dibujarFormularioConsultarInstructor(); break;
    case ACTUALIZAR_INSTRUCTOR: dibujarFormularioActualizarInstructor(); break;
    case ELIMINAR_INSTRUCTOR:   dibujarFormularioEliminarInstructor(); break;
    case LISTAR_INSTRUCTORES:   dibujarListadoInstructores(); break;
    case CREAR_APRENDIZ:        dibujarFormularioCrearAprendiz(); break;
    case CONSULTAR_APRENDIZ:    dibujarFormularioConsultarAprendiz(); break;
    case ACTUALIZAR_APRENDIZ:   dibujarFormularioActualizarAprendiz(); break;
    case ELIMINAR_APRENDIZ:     dibujarFormularioEliminarAprendiz(); break;
    case LISTAR_APRENDICES:     dibujarListadoAprendices(); break;
    case ASIGNAR_SESION:        dibujarFormularioAsignarSesion(); break;
    case SELECCIONAR_INSTRUCTOR_SESION: dibujarSeleccionInstructor(); break;
    case CONSULTAR_SESION:      dibujarFormularioConsultarSesion(); break;
    case CANCELAR_SESION:       dibujarFormularioCancelarSesion(); break;
    case LISTAR_SESIONES:       dibujarListadoSesiones(); break;
    default: break;
  }

  dibujarVeloTransicion();
  dibujarMensaje();
}


// ================================================================
// TEXTOS DE CABECERA POR MÓDULO
// ================================================================

String[] descInicio = {
  "Plataforma de gestión académica de la Academia de Artes Barranquilla.",
  "Administra sesiones, instructores, aprendices y reportes del mes." };
String[] citaInicio = { "\u201CEl arte", "siempre encuentra", "un lugar\u201D" };
String[] palInicio  = { "CREAR", "ENSEÑAR", "CRECER" };

String[] descSesiones = {
  "Gestiona las sesiones de clases de la academia.",
  "Asigna, consulta, cancela y visualiza las sesiones del mes." };
String[] citaSesiones = { "\u201CCada sesión", "es una nueva historia", "por crear\u201D" };
String[] palSesiones  = { "AGENDAR", "ENSEÑAR", "PRACTICAR", "CRECER" };

String[] descInstructores = {
  "Gestiona la información de los instructores que",
  "hacen posible el arte en nuestra academia." };
String[] citaInstructores = { "\u201CGrandes obras", "nacen de", "grandes maestros\u201D" };
String[] palInstructores  = { "FORMAR", "INSPIRAR", "TRASCENDER" };

String[] descAprendices = {
  "Acompañamos el talento que transforma. Gestiona la información",
  "de los aprendices y su participación en nuestra academia." };
String[] citaAprendices = { "\u201CAquí también", "nacen grandes", "historias\u201D" };
String[] palAprendices  = { "APRENDER", "CREAR", "COMPARTIR" };

String[] descReportes = {
  "Información que impulsa el arte. Genera reportes y consulta",
  "la disponibilidad de nuestra comunidad artística." };
String[] citaReportes = { "\u201CLos datos también", "cuentan historias\u201D" };
String[] palReportes  = { "CULTURA", "GESTIÓN", "COMUNIDAD" };


// ================================================================
// PANTALLA: MENÚ PRINCIPAL
// ================================================================
void dibujarMenuPrincipal() {
  float y = dibujarPantallaModulo(imgEncabezadoInicio, C_ORO,
              "SISTEMA DE GESTIÓN", "ACADEMIA DE ARTES",
              descInicio, citaInicio, palInicio, "Inicio");

  float x = panelX + margenH;
  float w = panelW - margenH * 2;

  dibujarTituloModulo(x, y, "Módulos del Sistema", "SELECCIONA UNA OPCIÓN", null, null);
  y += 74;

  float fondoY = panelY + panelH - margenV;
  float disponible = fondoY - y;

  // Tira de indicadores: sólo si sobra espacio para las tarjetas.
  if (disponible > 250) {
    refrescarEstadisticas();
    dibujarTiraIndicadores(x, y, w);
    y += 88;
    disponible = fondoY - y;
  }

  float altoTarjeta = constrain(disponible, 150, 250);
  colocarRejilla(botonesMenuPrincipal, 0, 5, x, y, w, 5, altoTarjeta, 16);
  for (int i = 0; i < botonesMenuPrincipal.size(); i++) botonesMenuPrincipal.get(i).dibujar();

  dibujarPie();
}

void refrescarEstadisticas() {
  if (millis() - ultimoRefrescoStats < 2500) return;
  ultimoRefrescoStats = millis();

  if (archivoInstructores == null || archivoAprendices == null || archivoSesiones == null) return;

  ArrayList<Instructor> ins = archivoInstructores.listarTodos();
  ArrayList<Aprendiz> aps = archivoAprendices.listarTodos();
  ArrayList<Sesion> ses = archivoSesiones.listarTodas();

  statInstructores = (ins == null) ? 0 : ins.size();
  statAprendices   = (aps == null) ? 0 : aps.size();
  statSesiones     = (ses == null) ? 0 : ses.size();

  statInstDisponibles = 0;
  if (ins != null) for (Instructor i : ins) if (i.estaDisponible()) statInstDisponibles++;

  statAprConCupo = 0;
  if (aps != null) for (Aprendiz a : aps) if (a.tieneAlgunCupoDisponible()) statAprConCupo++;
}

void dibujarTiraIndicadores(float x, float y, float w) {
  String[] etiquetas = {"Instructores", "Con cupo este mes", "Aprendices", "Sesiones activas"};
  int[]    valores   = {statInstructores, statInstDisponibles, statAprendices, statSesiones};
  String[] iconos    = {"personas", "check", "gorro", "calendario"};
  color[]  tintes    = {C_VERDE_BG, C_AZUL_BG, C_MORADO_BG, C_AMBAR_BG};
  color[]  trazos    = {C_VERDE, C_AZUL, C_MORADO, C_AMBAR};

  float gap = 14;
  float cw = (w - gap * 3) / 4;
  float ch = 72;

  for (int i = 0; i < 4; i++) {
    float cx = x + i * (cw + gap);
    noStroke();
    fill(249, 250, 252);
    stroke(C_BORDE);
    strokeWeight(1);
    rect(cx, y, cw, ch, 10);
    noStroke();

    fill(tintes[i]);
    ellipse(cx + 34, y + ch / 2, 40, 40);
    dibujarIcono(iconos[i], cx + 34, y + ch / 2, 10, trazos[i]);

    fill(COLOR_TITULO_MODULO);
    textAlign(LEFT, BOTTOM);
    tipoSansBold(constrain(cw * 0.13f, 20, 28));
    text(str(valores[i]), cx + 62, y + ch / 2 + 4);

    fill(C_TXT_SUAVE);
    textAlign(LEFT, TOP);
    tipoSans(11.5f);
    text(recortarTexto(etiquetas[i], cw - 74), cx + 62, y + ch / 2 + 6);
  }
}


// ================================================================
// PANTALLA: MENÚ DE INSTRUCTORES
// ================================================================
void dibujarMenuInstructores() {
  float y = dibujarPantallaModulo(imgEncabezadoInstructores, C_VERDE,
              "MÓDULO DE", "INSTRUCTORES",
              descInstructores, citaInstructores, palInstructores,
              "Módulo de Instructores");

  float x = panelX + margenH;
  float w = panelW - margenH * 2;

  dibujarTituloModulo(x, y, "Módulo de Instructores", "GESTIÓN Y ADMINISTRACIÓN", null, null);
  y += 74;

  float disponible = (panelY + panelH - margenV) - y;
  float altoTarjeta = constrain((disponible - 16) / 2, 112, 210);
  colocarRejilla(botonesMenuInstructores, 0, 7, x, y, w, 4, altoTarjeta, 16);
  for (int i = 0; i < botonesMenuInstructores.size(); i++) botonesMenuInstructores.get(i).dibujar();

  dibujarPie();
}


// ================================================================
// PANTALLA: MENÚ DE APRENDICES
// ================================================================
void dibujarMenuAprendices() {
  float y = dibujarPantallaModulo(imgEncabezadoAprendices, C_MORADO,
              "MÓDULO DE", "APRENDICES",
              descAprendices, citaAprendices, palAprendices,
              "Módulo de Aprendices");

  float x = panelX + margenH;
  float w = panelW - margenH * 2;

  dibujarTituloModulo(x, y, "Módulo de Aprendices", "GESTIÓN Y SEGUIMIENTO", null, null);
  y += 74;

  float disponible = (panelY + panelH - margenV) - y;
  float altoTarjeta = constrain((disponible - 16) / 2, 112, 210);
  colocarRejilla(botonesMenuAprendices, 0, 7, x, y, w, 4, altoTarjeta, 16);
  for (int i = 0; i < botonesMenuAprendices.size(); i++) botonesMenuAprendices.get(i).dibujar();

  dibujarPie();
}


// ================================================================
// PANTALLA: MENÚ DE SESIONES
// ================================================================
void dibujarMenuSesiones() {
  float y = dibujarPantallaModulo(imgEncabezadoSesiones, C_AZUL,
              "MÓDULO DE", "SESIONES",
              descSesiones, citaSesiones, palSesiones,
              "Módulo de Sesiones");

  float x = panelX + margenH;
  float w = panelW - margenH * 2;

  dibujarTituloModulo(x, y, "Módulo de Sesiones", "SELECCIONA UNA OPCIÓN", null, null);
  y += 74;

  float disponible = (panelY + panelH - margenV) - y;
  float altoTarjeta = constrain(disponible - 62, 150, 240);
  colocarRejilla(botonesMenuSesiones, 0, 4, x, y, w, 4, altoTarjeta, 16);
  for (int i = 0; i < 4; i++) botonesMenuSesiones.get(i).dibujar();

  // Botón "Volver" (índice 4) como píldora de contorno
  Boton volver = botonesMenuSesiones.get(4);
  volver.colocar(x, y + altoTarjeta + 14, 132, 42);
  volver.dibujar();

  dibujarPie();
}


// ================================================================
// PANTALLA: MENÚ DE REPORTES
// ================================================================
void dibujarMenuReportes() {
  float y = dibujarPantallaModulo(imgEncabezadoReportes, C_AMBAR,
              "MÓDULO DE", "REPORTES",
              descReportes, citaReportes, palReportes,
              "Módulo de Reportes");

  float x = panelX + margenH;
  float w = panelW - margenH * 2;

  dibujarTituloModulo(x, y, "Módulo de Reportes", "CONSULTA Y ANÁLISIS", null, null);
  y += 74;

  float disponible = (panelY + panelH - margenV) - y;
  float altoTarjeta = constrain(disponible, 160, 250);
  colocarRejilla(botonesMenuReportes, 0, 3, x, y, w, 3, altoTarjeta, 18);
  for (int i = 0; i < botonesMenuReportes.size(); i++) botonesMenuReportes.get(i).dibujar();

  dibujarPie();
}


// ================================================================
// PANTALLA: REPORTE DE DISPONIBILIDAD
// ================================================================
void dibujarReporte() {
  float y = dibujarPantallaSub("Módulo de Reportes", "Reporte de Disponibilidad");
  float x = panelX + margenH;
  float w = panelW - margenH * 2;

  refrescarEstadisticas();
  dibujarTiraIndicadores(x, y, w);
  y += 92;

  ArrayList<Instructor> instructores = archivoInstructores.listarTodos();
  ArrayList<Sesion> sesiones = archivoSesiones.listarTodas();

  // ---- Conteos por especialidad de instructores ----
  HashMap<String, Integer> totalPorEspecialidad = new HashMap<String, Integer>();
  HashMap<String, Integer> disponiblesPorEspecialidad = new HashMap<String, Integer>();
  for (Instructor inst : instructores) {
    String esp = inst.especialidad;
    totalPorEspecialidad.put(esp, (totalPorEspecialidad.containsKey(esp) ? totalPorEspecialidad.get(esp) : 0) + 1);
    if (inst.estaDisponible()) {
      disponiblesPorEspecialidad.put(esp, (disponiblesPorEspecialidad.containsKey(esp) ? disponiblesPorEspecialidad.get(esp) : 0) + 1);
    }
  }

  // ---- Sesiones asignadas por especialidad ----
  HashMap<String, Integer> sesionesPorEspecialidad = new HashMap<String, Integer>();
  for (Sesion s : sesiones) {
    String esp = s.especialidad;
    sesionesPorEspecialidad.put(esp, (sesionesPorEspecialidad.containsKey(esp) ? sesionesPorEspecialidad.get(esp) : 0) + 1);
  }

  float colW = (w - 24) / 2;
  float limiteY = panelY + panelH - margenV - 60;

  // ---- Columna izquierda ----
  fill(COLOR_TITULO_MODULO);
  textAlign(LEFT, TOP);
  tipoSansBold(15);
  text("Disponibilidad por especialidad", x, y);
  float yi = y + 30;

  if (totalPorEspecialidad.isEmpty()) {
    dibujarTablaVacia(x, yi, colW, "No hay instructores registrados.");
  } else {
    for (String esp : totalPorEspecialidad.keySet()) {
      if (yi > limiteY) break;
      int total = totalPorEspecialidad.get(esp);
      int disp = disponiblesPorEspecialidad.containsKey(esp) ? disponiblesPorEspecialidad.get(esp) : 0;

      fill(C_TXT);
      tipoSans(13);
      textAlign(LEFT, TOP);
      text(recortarTexto(esp, colW - 90), x, yi);
      fill(C_TXT_SUAVE);
      textAlign(RIGHT, TOP);
      text(disp + " de " + total, x + colW, yi);
      textAlign(LEFT, TOP);
      dibujarBarraProgreso(x, yi + 20, colW, 7, disp, max(1, total));
      yi += 40;
    }
  }

  // ---- Columna derecha ----
  float xd = x + colW + 24;
  fill(COLOR_TITULO_MODULO);
  textAlign(LEFT, TOP);
  tipoSansBold(15);
  text("Sesiones asignadas por especialidad", xd, y);
  float yd = y + 30;

  if (sesionesPorEspecialidad.isEmpty()) {
    dibujarTablaVacia(xd, yd, colW, "No hay sesiones asignadas todavía.");
  } else {
    int maxSes = 1;
    for (String esp : sesionesPorEspecialidad.keySet()) maxSes = max(maxSes, sesionesPorEspecialidad.get(esp));
    for (String esp : sesionesPorEspecialidad.keySet()) {
      if (yd > limiteY) break;
      int n = sesionesPorEspecialidad.get(esp);
      fill(C_TXT);
      tipoSans(13);
      textAlign(LEFT, TOP);
      text(recortarTexto(esp, colW - 90), xd, yd);
      fill(C_TXT_SUAVE);
      textAlign(RIGHT, TOP);
      text(n + (n == 1 ? " sesión" : " sesiones"), xd + colW, yd);
      textAlign(LEFT, TOP);
      dibujarBarraProgreso(xd, yd + 20, colW, 7, n, maxSes);
      yd += 40;
    }
  }

  colocarBotonVolverPanel(botonVolver);
  botonVolver.dibujar();
  dibujarPie();
}


// ================================================================
// AYUDAS DE COMPOSICIÓN DE FORMULARIOS
// ================================================================

// Coloca un botón "Volver" en la esquina inferior izquierda del panel.
void colocarBotonVolverPanel(Boton b) {
  b.colocar(panelX + margenH, panelY + panelH - margenV - 42, 132, 42);
}

// Tarjeta lateral con las reglas del formulario. Es sólo informativa.
void dibujarTarjetaAyuda(float x, float y, float w, String titulo, String[] lineas) {
  float h = 46 + lineas.length * 26;
  noStroke();
  fill(249, 250, 252);
  stroke(C_BORDE);
  strokeWeight(1);
  rect(x, y, w, h, 10);
  noStroke();

  dibujarIcono("etiqueta", x + 22, y + 26, 8, C_AZUL);
  fill(COLOR_TITULO_MODULO);
  textAlign(LEFT, CENTER);
  tipoSansBold(12.5f);
  text(titulo, x + 38, y + 26);

  textAlign(LEFT, TOP);
  tipoSans(12);
  for (int i = 0; i < lineas.length; i++) {
    fill(C_TXT_TENUE);
    ellipse(x + 24, y + 52 + i * 26 + 6, 4, 4);
    fill(C_TXT_SUAVE);
    text(recortarTexto(lineas[i], w - 50), x + 36, y + 52 + i * 26);
  }
}

// Ficha de resultado (consulta de instructor / aprendiz / sesión).
void dibujarFichaDatos(float x, float y, float w, String titulo,
                       String[] etiquetas, String[] valores, color acento) {
  float h = 58 + etiquetas.length * 32;
  sombraSuave(x, y, w, h, 12, 26);
  noStroke();
  fill(255);
  stroke(C_BORDE);
  strokeWeight(1);
  rect(x, y, w, h, 12);
  noStroke();
  fill(acento);
  rect(x, y, w, 4, 12, 12, 0, 0);

  fill(COLOR_TITULO_MODULO);
  textAlign(LEFT, TOP);
  tipoSerif(17);
  text(titulo, x + 20, y + 18);

  for (int i = 0; i < etiquetas.length; i++) {
    float fy = y + 54 + i * 32;
    fill(C_TXT_TENUE);
    tipoSansBold(10.5f);
    textAlign(LEFT, TOP);
    text(letraEspaciada(etiquetas[i].toUpperCase()), x + 20, fy);
    fill(C_TXT);
    tipoSans(13.5f);
    textAlign(RIGHT, TOP);
    text(recortarTexto(valores[i], w * 0.55f), x + w - 20, fy - 1);
    textAlign(LEFT, TOP);
  }
}


// ================================================================
// FORMULARIOS: INSTRUCTORES
// ================================================================

void dibujarFormularioCrearInstructor() {
  float y = dibujarPantallaSub("Módulo de Instructores", "Crear Instructor");
  float x = panelX + margenH;
  float colW = min((panelW - margenH * 2) * 0.48f, 400);

  campoCedula.colocar(x, y + 24, colW);
  campoNombre.colocar(x, y + 24 + 76, colW);
  campoEspecialidad.colocar(x, y + 24 + 152, colW);
  campoTelefono.colocar(x, y + 24 + 228, colW);
  campoCedula.dibujar();
  campoNombre.dibujar();
  campoEspecialidad.dibujar();
  campoTelefono.dibujar();

  dibujarTarjetaAyuda(x + colW + 32, y + 24, min(panelW - margenH * 2 - colW - 32, 380),
    "Antes de guardar", new String[] {
      "La cédula debe tener entre 6 y 15 dígitos.",
      "Todos los campos son obligatorios.",
      "No puede repetirse una cédula ya registrada.",
      "El límite mensual es de " + ArchivoInstructores.MAX_SESIONES_MES + " sesiones." });

  float by = panelY + panelH - margenV - 46;
  botonGuardar.label = "Guardar";
  botonGuardar.colocar(x, by, 170, 46);
  botonCancelar.colocar(x + 186, by, 140, 46);
  botonGuardar.dibujar();
  botonCancelar.dibujar();

  botonVolver.colocar(panelX + panelW - margenH - 132, by + 2, 132, 42);
  botonVolver.dibujar();
  dibujarPie();
}

void dibujarFormularioConsultarInstructor() {
  float y = dibujarPantallaSub("Módulo de Instructores", "Consultar Instructor");
  float x = panelX + margenH;
  float colW = min((panelW - margenH * 2) * 0.44f, 360);

  campoCedula.colocar(x, y + 24, colW - 148);
  campoCedula.dibujar();
  botonBuscar.label = "Buscar";
  botonBuscar.colocar(x + colW - 138, y + 24, 138, 44);
  botonBuscar.dibujar();

  if (instructorEncontrado != null) {
    dibujarFichaDatos(x, y + 104, min(panelW - margenH * 2, 520),
      instructorEncontrado.nombre,
      new String[] {"Cédula", "Especialidad", "Teléfono", "Sesiones del mes"},
      new String[] {
        instructorEncontrado.cedula,
        instructorEncontrado.especialidad,
        instructorEncontrado.telefono,
        instructorEncontrado.sesionesRealizadas + " / " + ArchivoInstructores.MAX_SESIONES_MES },
      C_VERDE);

    boolean disp = instructorEncontrado.estaDisponible();
    dibujarBadge(disp ? "Disponible este mes" : "Sin cupo este mes",
      x, y + 104 + 58 + 4 * 32 + 14,
      disp ? C_VERDE : C_ROJO, disp ? C_VERDE_BG : C_ROJO_BG);
  } else {
    dibujarTarjetaAyuda(x, y + 104, min(panelW - margenH * 2, 520),
      "Cómo consultar", new String[] {
        "Escribe la cédula del instructor y pulsa Buscar.",
        "Se mostrará su especialidad y su cupo del mes." });
  }

  colocarBotonVolverPanel(botonVolver);
  botonVolver.dibujar();
  dibujarPie();
}

void dibujarFormularioActualizarInstructor() {
  float y = dibujarPantallaSub("Módulo de Instructores", "Actualizar Instructor");
  float x = panelX + margenH;
  float colW = min((panelW - margenH * 2) * 0.48f, 400);

  campoCedula.colocar(x, y + 24, colW - 148);
  campoCedula.dibujar();
  botonBuscar.label = "Buscar";
  botonBuscar.colocar(x + colW - 138, y + 24, 138, 44);
  botonBuscar.dibujar();

  campoNombre.colocar(x, y + 24 + 84, colW);
  campoEspecialidad.colocar(x, y + 24 + 160, colW);
  campoTelefono.colocar(x, y + 24 + 236, colW);
  campoNombre.dibujar();
  campoEspecialidad.dibujar();
  campoTelefono.dibujar();

  dibujarTarjetaAyuda(x + colW + 32, y + 24, min(panelW - margenH * 2 - colW - 32, 380),
    "Cómo actualizar", new String[] {
      "Busca primero al instructor por su cédula.",
      "Los campos se rellenan con los datos actuales.",
      "Modifica lo necesario y pulsa Guardar." });

  float by = panelY + panelH - margenV - 46;
  botonGuardar.label = "Guardar cambios";
  botonGuardar.colocar(x, by, 200, 46);
  botonGuardar.dibujar();

  botonVolver.colocar(panelX + panelW - margenH - 132, by + 2, 132, 42);
  botonVolver.dibujar();
  dibujarPie();
}

void dibujarFormularioEliminarInstructor() {
  float y = dibujarPantallaSub("Módulo de Instructores", "Eliminar Instructor");
  float x = panelX + margenH;
  float colW = min((panelW - margenH * 2) * 0.44f, 360);

  campoCedula.colocar(x, y + 24, colW);
  campoCedula.dibujar();

  dibujarAvisoPeligro(x, y + 104, min(panelW - margenH * 2, 520),
    "Esta acción no se puede deshacer",
    "El registro del instructor se eliminará de forma permanente del archivo.");

  botonEliminar.label = "Eliminar instructor";
  botonEliminar.colocar(x, y + 200, 210, 46);
  botonEliminar.dibujar();

  colocarBotonVolverPanel(botonVolver);
  botonVolver.dibujar();
  dibujarPie();
}

void dibujarAvisoPeligro(float x, float y, float w, String titulo, String detalle) {
  float h = 70;
  noStroke();
  fill(C_ROJO_BG);
  rect(x, y, w, h, 10);
  fill(C_ROJO);
  rect(x, y, 4, h, 10, 0, 0, 10);
  dibujarIcono("alerta", x + 32, y + h / 2, 11, C_ROJO);

  fill(C_ROJO);
  textAlign(LEFT, TOP);
  tipoSansBold(13);
  text(titulo, x + 56, y + 16);
  fill(150, 60, 60);
  tipoSans(12);
  text(recortarTexto(detalle, w - 76), x + 56, y + 38);
}

void dibujarListadoInstructores() {
  float y = dibujarPantallaSub("Módulo de Instructores", "Instructores Registrados");
  float x = panelX + margenH;
  float w = panelW - margenH * 2;

  if (listaInstructores == null) listaInstructores = archivoInstructores.listarTodos();

  if (listaInstructores.isEmpty()) {
    dibujarTablaVacia(x, y + 12, w, "No hay instructores registrados.");
  } else {
    String[] cols = {"Nombre", "Cédula", "Especialidad", "Teléfono", "Sesiones del mes"};
    float[] pesos = {0.28f, 0.15f, 0.22f, 0.15f, 0.20f};
    float ty = dibujarEncabezadoTabla(x, y + 12, w, cols, pesos);

    float altoFila = 44;
    float limite = panelY + panelH - margenV - 56;
    int i = 0;
    for (Instructor inst : listaInstructores) {
      if (ty + altoFila > limite) break;
      dibujarFilaTabla(x, ty, w, altoFila, i);

      float cx = x + 14;
      textAlign(LEFT, CENTER);
      fill(C_TXT);
      tipoSansBold(13);
      text(recortarTexto(inst.nombre, w * pesos[0] - 18), cx, ty + altoFila / 2);
      cx += w * pesos[0];

      tipoSans(13);
      fill(C_TXT_SUAVE);
      text(inst.cedula, cx, ty + altoFila / 2);
      cx += w * pesos[1];
      fill(C_TXT);
      text(recortarTexto(inst.especialidad, w * pesos[2] - 18), cx, ty + altoFila / 2);
      cx += w * pesos[2];
      fill(C_TXT_SUAVE);
      text(recortarTexto(inst.telefono, w * pesos[3] - 18), cx, ty + altoFila / 2);
      cx += w * pesos[3];

      // Última columna: contador + barra reactiva al dato
      float barW = w * pesos[4] - 24;
      fill(C_TXT);
      tipoSansBold(12);
      text(inst.sesionesRealizadas + " / " + ArchivoInstructores.MAX_SESIONES_MES, cx, ty + altoFila / 2 - 8);
      dibujarBarraProgreso(cx, ty + altoFila / 2 + 6, barW, 6,
                           inst.sesionesRealizadas, ArchivoInstructores.MAX_SESIONES_MES);

      ty += altoFila;
      i++;
    }
    dibujarPieDeTabla(x, ty, w, i, listaInstructores.size(), "instructores");
  }

  colocarBotonVolverPanel(botonVolver);
  botonVolver.dibujar();
  dibujarPie();
}

void dibujarPieDeTabla(float x, float y, float w, int mostrados, int total, String etiqueta) {
  fill(C_TXT_TENUE);
  textAlign(LEFT, TOP);
  tipoSans(11.5f);
  if (mostrados < total) {
    text("Mostrando " + mostrados + " de " + total + " " + etiqueta +
         " (amplía la ventana para ver más).", x, y + 12);
  } else {
    text("Total: " + total + " " + etiqueta + ".", x, y + 12);
  }
}


// ================================================================
// FORMULARIOS: APRENDICES
// ================================================================

void dibujarFormularioCrearAprendiz() {
  float y = dibujarPantallaSub("Módulo de Aprendices", "Crear Aprendiz");
  float x = panelX + margenH;
  float colW = min((panelW - margenH * 2) * 0.48f, 400);

  campoCedulaAprendiz.colocar(x, y + 24, colW);
  campoNombreAprendiz.colocar(x, y + 24 + 76, colW);
  campoEspecialidadAprendiz.colocar(x, y + 24 + 152, colW);
  campoCedulaAprendiz.dibujar();
  campoNombreAprendiz.dibujar();
  campoEspecialidadAprendiz.dibujar();

  dibujarTarjetaAyuda(x + colW + 32, y + 24, min(panelW - margenH * 2 - colW - 32, 380),
    "Antes de guardar", new String[] {
      "La cédula debe tener entre 6 y 15 dígitos.",
      "Separa las especialidades con comas.",
      "Ejemplo: Danza, Pintura, Música.",
      "Límite: " + Aprendiz.MAX_SESIONES_MES + " sesiones por especialidad al mes." });

  float by = panelY + panelH - margenV - 46;
  botonGuardar.label = "Guardar";
  botonGuardar.colocar(x, by, 170, 46);
  botonCancelar.colocar(x + 186, by, 140, 46);
  botonGuardar.dibujar();
  botonCancelar.dibujar();

  botonVolver.colocar(panelX + panelW - margenH - 132, by + 2, 132, 42);
  botonVolver.dibujar();
  dibujarPie();
}

void dibujarFormularioConsultarAprendiz() {
  float y = dibujarPantallaSub("Módulo de Aprendices", "Consultar Aprendiz");
  float x = panelX + margenH;
  float colW = min((panelW - margenH * 2) * 0.44f, 360);

  campoCedulaAprendiz.colocar(x, y + 24, colW - 148);
  campoCedulaAprendiz.dibujar();
  botonBuscar.label = "Buscar";
  botonBuscar.colocar(x + colW - 138, y + 24, 138, 44);
  botonBuscar.dibujar();

  if (aprendizEncontrado != null) {
    dibujarFichaDatos(x, y + 104, min(panelW - margenH * 2, 560),
      aprendizEncontrado.nombre,
      new String[] {"Cédula", "Especialidades"},
      new String[] {aprendizEncontrado.cedula, aprendizEncontrado.especialidadesResumenCorto()},
      C_MORADO);

    boolean cupo = aprendizEncontrado.tieneAlgunCupoDisponible();
    dibujarBadge(cupo ? "Tiene cupo disponible" : "Sin cupo este mes",
      x, y + 104 + 58 + 2 * 32 + 14,
      cupo ? C_VERDE : C_ROJO, cupo ? C_VERDE_BG : C_ROJO_BG);
  } else {
    dibujarTarjetaAyuda(x, y + 104, min(panelW - margenH * 2, 560),
      "Cómo consultar", new String[] {
        "Escribe la cédula del aprendiz y pulsa Buscar.",
        "Verás sus especialidades y las sesiones usadas." });
  }

  colocarBotonVolverPanel(botonVolver);
  botonVolver.dibujar();
  dibujarPie();
}

void dibujarFormularioActualizarAprendiz() {
  float y = dibujarPantallaSub("Módulo de Aprendices", "Actualizar Aprendiz");
  float x = panelX + margenH;
  float colW = min((panelW - margenH * 2) * 0.48f, 400);

  campoCedulaAprendiz.colocar(x, y + 24, colW - 148);
  campoCedulaAprendiz.dibujar();
  botonBuscar.label = "Buscar";
  botonBuscar.colocar(x + colW - 138, y + 24, 138, 44);
  botonBuscar.dibujar();

  campoNombreAprendiz.colocar(x, y + 24 + 84, colW);
  campoEspecialidadAprendiz.colocar(x, y + 24 + 160, colW);
  campoNombreAprendiz.dibujar();
  campoEspecialidadAprendiz.dibujar();

  dibujarTarjetaAyuda(x + colW + 32, y + 24, min(panelW - margenH * 2 - colW - 32, 380),
    "Cómo actualizar", new String[] {
      "Busca primero al aprendiz por su cédula.",
      "Separa las especialidades con comas.",
      "Modifica lo necesario y pulsa Guardar." });

  float by = panelY + panelH - margenV - 46;
  botonGuardar.label = "Guardar cambios";
  botonGuardar.colocar(x, by, 200, 46);
  botonGuardar.dibujar();

  botonVolver.colocar(panelX + panelW - margenH - 132, by + 2, 132, 42);
  botonVolver.dibujar();
  dibujarPie();
}

void dibujarFormularioEliminarAprendiz() {
  float y = dibujarPantallaSub("Módulo de Aprendices", "Eliminar Aprendiz");
  float x = panelX + margenH;
  float colW = min((panelW - margenH * 2) * 0.44f, 360);

  campoCedulaAprendiz.colocar(x, y + 24, colW);
  campoCedulaAprendiz.dibujar();

  dibujarAvisoPeligro(x, y + 104, min(panelW - margenH * 2, 520),
    "Esta acción no se puede deshacer",
    "El registro del aprendiz se eliminará de forma permanente del archivo.");

  botonEliminar.label = "Eliminar aprendiz";
  botonEliminar.colocar(x, y + 200, 200, 46);
  botonEliminar.dibujar();

  colocarBotonVolverPanel(botonVolver);
  botonVolver.dibujar();
  dibujarPie();
}

void dibujarListadoAprendices() {
  float y = dibujarPantallaSub("Módulo de Aprendices", "Aprendices Registrados");
  float x = panelX + margenH;
  float w = panelW - margenH * 2;

  if (listaAprendices == null) listaAprendices = archivoAprendices.listarTodos();

  if (listaAprendices.isEmpty()) {
    dibujarTablaVacia(x, y + 12, w, "No hay aprendices registrados.");
  } else {
    String[] cols = {"Nombre", "Cédula", "Especialidades (sesiones del mes)", "Estado"};
    float[] pesos = {0.26f, 0.15f, 0.42f, 0.17f};
    float ty = dibujarEncabezadoTabla(x, y + 12, w, cols, pesos);

    float altoFila = 42;
    float limite = panelY + panelH - margenV - 56;
    int i = 0;
    for (Aprendiz apr : listaAprendices) {
      if (ty + altoFila > limite) break;
      dibujarFilaTabla(x, ty, w, altoFila, i);

      float cx = x + 14;
      textAlign(LEFT, CENTER);
      fill(C_TXT);
      tipoSansBold(13);
      text(recortarTexto(apr.nombre, w * pesos[0] - 18), cx, ty + altoFila / 2);
      cx += w * pesos[0];

      tipoSans(13);
      fill(C_TXT_SUAVE);
      text(apr.cedula, cx, ty + altoFila / 2);
      cx += w * pesos[1];
      fill(C_TXT);
      text(recortarTexto(apr.especialidadesResumenCorto(), w * pesos[2] - 18), cx, ty + altoFila / 2);
      cx += w * pesos[2];

      boolean cupo = apr.tieneAlgunCupoDisponible();
      dibujarBadge(cupo ? "Con cupo" : "Completo", cx, ty + altoFila / 2 - 11,
                   cupo ? C_VERDE : C_ROJO, cupo ? C_VERDE_BG : C_ROJO_BG);

      ty += altoFila;
      i++;
    }
    dibujarPieDeTabla(x, ty, w, i, listaAprendices.size(), "aprendices");
  }

  colocarBotonVolverPanel(botonVolver);
  botonVolver.dibujar();
  dibujarPie();
}


// ================================================================
// FORMULARIOS: SESIONES
// ================================================================

void dibujarFormularioAsignarSesion() {
  float y = dibujarPantallaSub("Módulo de Sesiones", "Asignar Sesión");
  float x = panelX + margenH;
  float colW = min((panelW - margenH * 2) * 0.46f, 400);

  // ---- Paso 1 ----
  dibujarEtiquetaPaso(x, y, 1, "Identifica al aprendiz");
  campoCedulaAprendiz.colocar(x, y + 46, colW - 158);
  campoCedulaAprendiz.dibujar();
  botonBuscar.label = "Verificar";
  botonBuscar.colocar(x + colW - 148, y + 46, 148, 44);
  botonBuscar.dibujar();

  float y2 = y + 122;

  // Por defecto, los controles del paso 2 quedan fuera de pantalla;
  // sólo se colocan cuando realmente se dibujan.
  aparcar(campoEspecialidadSesion);
  aparcar(campoFechaSesion);
  aparcar(botonAsignar);

  if (aprendizEncontrado == null) {
    dibujarTarjetaAyuda(x, y2, min(panelW - margenH * 2, 560),
      "Proceso de asignación", new String[] {
        "1. Verifica la cédula del aprendiz.",
        "2. Indica la especialidad y la fecha de la sesión.",
        "3. Elige un instructor disponible de la lista." });
  } else {
    dibujarFichaDatos(x, y2, min(panelW - margenH * 2, 560),
      aprendizEncontrado.nombre,
      new String[] {"Cédula", "Especialidades"},
      new String[] {aprendizEncontrado.cedula, aprendizEncontrado.especialidadesResumenCorto()},
      C_AZUL);
    float fichaAlto = 58 + 2 * 32;

    if (!aprendizEncontrado.tieneAlgunCupoDisponible()) {
      dibujarAvisoPeligro(x, y2 + fichaAlto + 16, min(panelW - margenH * 2, 560),
        "Sin cupo disponible",
        "El aprendiz ya completó sus sesiones del mes en todas sus especialidades.");
    } else {
      dibujarBadge("Tiene cupo disponible", x, y2 + fichaAlto + 14, C_VERDE, C_VERDE_BG);

      float y3 = y2 + fichaAlto + 52;
      dibujarEtiquetaPaso(x, y3, 2, "Especialidad y fecha de la sesión");

      campoEspecialidadSesion.colocar(x, y3 + 46, colW);
      campoFechaSesion.colocar(x, y3 + 122, colW);
      campoEspecialidadSesion.dibujar();
      campoFechaSesion.dibujar();

      fill(C_TXT_TENUE);
      textAlign(LEFT, TOP);
      tipoSans(11.5f);
      text("Debe ser una especialidad que el aprendiz practique.", x, y3 + 94);
      text("Formato AAAA-MM-DD, hoy o futura. Vacío = hoy.", x, y3 + 170);

      botonAsignar.label = "Buscar instructores";
      botonAsignar.colocar(x, y3 + 200, 230, 46);
      botonAsignar.dibujar();
    }
  }

  botonVolverSesiones.colocar(panelX + panelW - margenH - 132, panelY + panelH - margenV - 42, 132, 42);
  botonVolverSesiones.dibujar();
  dibujarPie();
}

void dibujarEtiquetaPaso(float x, float y, int numero, String texto) {
  noStroke();
  fill(C_AZUL_BG);
  ellipse(x + 14, y + 14, 28, 28);
  fill(C_AZUL);
  textAlign(CENTER, CENTER);
  tipoSansBold(13);
  text(str(numero), x + 14, y + 14);

  fill(COLOR_TITULO_MODULO);
  textAlign(LEFT, CENTER);
  tipoSansBold(14);
  text(texto, x + 38, y + 14);
}

void dibujarSeleccionInstructor() {
  float y = dibujarPantallaSub("Módulo de Sesiones", "Seleccionar Instructor");
  float x = panelX + margenH;
  float w = panelW - margenH * 2;

  dibujarEtiquetaPaso(x, y, 3, "Instructores disponibles para " +
    especialidadSeleccionada + " el " + fechaSesionSeleccionada);

  float ty = y + 52;

  if (instructoresDisponibles == null || instructoresDisponibles.isEmpty()) {
    dibujarAvisoPeligro(x, ty, min(w, 560),
      "No hay instructores disponibles",
      "Ningún instructor de esta especialidad tiene cupo en el mes.");
    botonesInstructoresDisponibles.clear();
  } else {
    // Se asegura que exista un botón por instructor ANTES de dibujar,
    // para que todos se rendericen ya en el primer cuadro.
    while (botonesInstructoresDisponibles.size() < instructoresDisponibles.size()) {
      botonesInstructoresDisponibles.add(new Boton(-3000, -3000, 1, 1, "", C_AZUL, C_AZUL));
    }
    while (botonesInstructoresDisponibles.size() > instructoresDisponibles.size()) {
      botonesInstructoresDisponibles.remove(botonesInstructoresDisponibles.size() - 1);
    }

    float anchoFila = min(w, 720);
    float altoFila = 62;
    float limite = panelY + panelH - margenV - 56;
    int visibles = 0;

    for (int i = 0; i < instructoresDisponibles.size(); i++) {
      if (ty + altoFila > limite) break;
      visibles = i + 1;
      Instructor inst = instructoresDisponibles.get(i);
      Boton b = botonesInstructoresDisponibles.get(i);
      b.colocar(x, ty, anchoFila, altoFila);
      b.actualizarEstado();

      boolean sobre = b.animHover > 0.02f;
      noStroke();
      if (sobre) sombraSuave(x, ty, anchoFila, altoFila, 10, b.animHover * 34);
      fill(lerpColor(color(255), color(248, 251, 255), b.animHover));
      stroke(lerpColor(C_BORDE, C_AZUL, b.animHover));
      strokeWeight(1 + b.animHover * 0.6f);
      rect(x, ty, anchoFila, altoFila, 10);
      noStroke();

      fill(C_VERDE_BG);
      ellipse(x + 34, ty + altoFila / 2, 36, 36);
      dibujarIcono("personas", x + 34, ty + altoFila / 2, 9, C_VERDE);

      fill(C_TXT);
      textAlign(LEFT, BOTTOM);
      tipoSansBold(14);
      text(recortarTexto(inst.nombre, anchoFila * 0.4f), x + 62, ty + altoFila / 2 + 1);
      fill(C_TXT_SUAVE);
      textAlign(LEFT, TOP);
      tipoSans(12);
      text("Cédula " + inst.cedula, x + 62, ty + altoFila / 2 + 4);

      float barX = x + anchoFila - 210;
      fill(C_TXT_SUAVE);
      textAlign(LEFT, BOTTOM);
      tipoSans(11.5f);
      text("Sesiones: " + inst.sesionesRealizadas + " / " + ArchivoInstructores.MAX_SESIONES_MES,
           barX, ty + altoFila / 2);
      dibujarBarraProgreso(barX, ty + altoFila / 2 + 6, 120, 6,
                           inst.sesionesRealizadas, ArchivoInstructores.MAX_SESIONES_MES);

      float fx = x + anchoFila - 34;
      fill(lerpColor(C_AZUL_BG, C_AZUL, b.animHover));
      ellipse(fx, ty + altoFila / 2, 32, 32);
      dibujarIcono("flecha-der", fx + b.animHover * 2, ty + altoFila / 2, 8,
                   lerpColor(C_AZUL, color(255), b.animHover));

      ty += altoFila + 10;
    }

    // Las filas que no caben no deben quedar clicables.
    for (int i = visibles; i < botonesInstructoresDisponibles.size(); i++) {
      aparcar(botonesInstructoresDisponibles.get(i));
    }
    if (visibles < instructoresDisponibles.size()) {
      fill(C_TXT_TENUE);
      textAlign(LEFT, TOP);
      tipoSans(11.5f);
      text("Mostrando " + visibles + " de " + instructoresDisponibles.size() +
           " instructores disponibles (amplía la ventana para ver más).", x, ty);
    }
  }

  botonVolverSesiones.colocar(panelX + panelW - margenH - 132, panelY + panelH - margenV - 42, 132, 42);
  botonVolverSesiones.dibujar();
  dibujarPie();
}

void dibujarFormularioConsultarSesion() {
  float y = dibujarPantallaSub("Módulo de Sesiones", "Consultar Sesión");
  float x = panelX + margenH;
  float colW = min((panelW - margenH * 2) * 0.46f, 400);

  campoCodigoSesion.colocar(x, y + 24, colW - 148);
  campoCodigoSesion.dibujar();
  botonBuscar.label = "Buscar";
  botonBuscar.colocar(x + colW - 138, y + 24, 138, 44);
  botonBuscar.dibujar();

  if (sesionEncontrada != null) {
    dibujarFichaDatos(x, y + 104, min(panelW - margenH * 2, 560),
      "Sesión " + sesionEncontrada.codigoUnico,
      new String[] {"Aprendiz", "Cédula del aprendiz", "Especialidad", "Cédula del instructor", "Fecha"},
      new String[] {
        sesionEncontrada.nombreAprendiz,
        sesionEncontrada.cedulaAprendiz,
        sesionEncontrada.especialidad,
        sesionEncontrada.cedulaInstructor,
        sesionEncontrada.fechaSesion },
      C_VERDE);
  } else {
    dibujarTarjetaAyuda(x, y + 104, min(panelW - margenH * 2, 560),
      "Cómo consultar", new String[] {
        "El código único se genera al asignar la sesión.",
        "Tiene el formato SES seguido de varios dígitos." });
  }

  botonVolverSesiones.colocar(panelX + margenH, panelY + panelH - margenV - 42, 132, 42);
  botonVolverSesiones.dibujar();
  dibujarPie();
}

void dibujarFormularioCancelarSesion() {
  float y = dibujarPantallaSub("Módulo de Sesiones", "Cancelar Sesión");
  float x = panelX + margenH;
  float colW = min((panelW - margenH * 2) * 0.44f, 360);

  campoCodigoSesion.colocar(x, y + 24, colW);
  campoCodigoSesion.dibujar();

  dibujarAvisoPeligro(x, y + 104, min(panelW - margenH * 2, 560),
    "Sólo se cancelan sesiones futuras",
    "Al cancelar se libera el cupo del instructor y del aprendiz.");

  botonEliminar.label = "Cancelar sesión";
  botonEliminar.colocar(x, y + 200, 200, 46);
  botonEliminar.dibujar();

  botonVolverSesiones.colocar(panelX + margenH, panelY + panelH - margenV - 42, 132, 42);
  botonVolverSesiones.dibujar();
  dibujarPie();
}

void dibujarListadoSesiones() {
  float y = dibujarPantallaSub("Módulo de Sesiones", "Sesiones Registradas");
  float x = panelX + margenH;
  float w = panelW - margenH * 2;

  if (listaSesiones == null) listaSesiones = archivoSesiones.listarTodas();

  if (listaSesiones.isEmpty()) {
    dibujarTablaVacia(x, y + 12, w, "No hay sesiones registradas.");
  } else {
    String[] cols = {"Código", "Aprendiz", "Especialidad", "Instructor", "Fecha"};
    float[] pesos = {0.22f, 0.24f, 0.20f, 0.16f, 0.18f};
    float ty = dibujarEncabezadoTabla(x, y + 12, w, cols, pesos);

    float altoFila = 40;
    float limite = panelY + panelH - margenV - 56;
    String hoy = obtenerFechaActual();
    int i = 0;

    for (Sesion ses : listaSesiones) {
      if (ty + altoFila > limite) break;
      dibujarFilaTabla(x, ty, w, altoFila, i);

      float cx = x + 14;
      textAlign(LEFT, CENTER);
      tipoSans(12.5f);
      fill(C_TXT_SUAVE);
      text(recortarTexto(ses.codigoUnico, w * pesos[0] - 18), cx, ty + altoFila / 2);
      cx += w * pesos[0];
      fill(C_TXT);
      tipoSansBold(12.5f);
      text(recortarTexto(ses.nombreAprendiz, w * pesos[1] - 18), cx, ty + altoFila / 2);
      cx += w * pesos[1];
      tipoSans(12.5f);
      text(recortarTexto(ses.especialidad, w * pesos[2] - 18), cx, ty + altoFila / 2);
      cx += w * pesos[2];
      fill(C_TXT_SUAVE);
      text(recortarTexto(ses.cedulaInstructor, w * pesos[3] - 18), cx, ty + altoFila / 2);
      cx += w * pesos[3];

      // La fecha se colorea según sea pasada o futura
      boolean futura = compararFechas(ses.fechaSesion, hoy) >= 0;
      fill(futura ? C_VERDE : C_TXT_TENUE);
      tipoSansBold(12.5f);
      text(ses.fechaSesion, cx, ty + altoFila / 2);

      ty += altoFila;
      i++;
    }
    dibujarPieDeTabla(x, ty, w, i, listaSesiones.size(), "sesiones");
  }

  botonVolverSesiones.colocar(panelX + margenH, panelY + panelH - margenV - 42, 132, 42);
  botonVolverSesiones.dibujar();
  dibujarPie();
}


// ================================================================
// FUNCIONES DE ACCIÓN PARA INSTRUCTORES  (lógica sin cambios)
// ================================================================

void accionGuardarInstructor() {
  String cedula = campoCedula.contenido.trim();
  String nombre = campoNombre.contenido.trim();
  String especialidad = campoEspecialidad.contenido.trim();
  String telefono = campoTelefono.contenido.trim();
  if (!validarCedula(cedula)) {
    mostrarMensaje("Cédula inválida (solo dígitos, 6 a 15 caracteres).", true);
    return;
  }
  if (nombre.isEmpty() || especialidad.isEmpty() || telefono.isEmpty()) {
    mostrarMensaje("Todos los campos son obligatorios.", true);
    return;
  }
  if (archivoInstructores.existe(cedula)) {
    mostrarMensaje("Ya existe un instructor con esa cédula.", true);
    return;
  }
  Instructor nuevo = new Instructor(cedula, nombre, especialidad, telefono, 0);
  if (archivoInstructores.crear(nuevo)) {
    mostrarMensaje("Instructor creado correctamente.", false);
    limpiarCamposFormulario();
  } else {
    mostrarMensaje("No se pudo crear el instructor.", true);
  }
}

void accionBuscarInstructor() {
  String cedula = campoCedula.contenido.trim();
  if (!validarCedula(cedula)) {
    mostrarMensaje("Ingresa una cédula válida.", true);
    return;
  }
  instructorEncontrado = archivoInstructores.leer(cedula);
  if (instructorEncontrado == null) {
    mostrarMensaje("No existe un instructor con esa cédula.", true);
  } else {
    mensaje = "";
  }
}

void accionBuscarParaActualizarInstructor() {
  String cedula = campoCedula.contenido.trim();
  if (!validarCedula(cedula)) {
    mostrarMensaje("Ingresa una cédula válida.", true);
    return;
  }
  Instructor inst = archivoInstructores.leer(cedula);
  if (inst == null) {
    mostrarMensaje("No existe un instructor con esa cédula.", true);
    return;
  }
  campoNombre.contenido = inst.nombre;
  campoEspecialidad.contenido = inst.especialidad;
  campoTelefono.contenido = inst.telefono;
  mensaje = "";
}

void accionGuardarActualizarInstructor() {
  String cedula = campoCedula.contenido.trim();
  if (!archivoInstructores.existe(cedula)) {
    mostrarMensaje("Primero busca un instructor válido.", true);
    return;
  }
  String nombre = campoNombre.contenido.trim();
  String especialidad = campoEspecialidad.contenido.trim();
  String telefono = campoTelefono.contenido.trim();
  if (nombre.isEmpty() || especialidad.isEmpty() || telefono.isEmpty()) {
    mostrarMensaje("Todos los campos son obligatorios.", true);
    return;
  }
  Instructor actual = archivoInstructores.leer(cedula);
  actual.nombre = nombre;
  actual.especialidad = especialidad;
  actual.telefono = telefono;
  if (archivoInstructores.actualizar(actual)) {
    mostrarMensaje("Instructor actualizado correctamente.", false);
  } else {
    mostrarMensaje("No se pudo actualizar el instructor.", true);
  }
}

void accionEliminarInstructor() {
  String cedula = campoCedula.contenido.trim();
  if (!validarCedula(cedula)) {
    mostrarMensaje("Ingresa una cédula válida.", true);
    return;
  }
  if (!archivoInstructores.existe(cedula)) {
    mostrarMensaje("No existe un instructor con esa cédula.", true);
    return;
  }
  if (archivoInstructores.eliminar(cedula)) {
    mostrarMensaje("Instructor eliminado.", false);
    campoCedula.limpiar();
  } else {
    mostrarMensaje("No se pudo eliminar el instructor.", true);
  }
}


// ================================================================
// FUNCIONES DE ACCIÓN PARA APRENDICES  (lógica sin cambios)
// ================================================================

void accionGuardarAprendiz() {
  String cedula = campoCedulaAprendiz.contenido.trim();
  String nombre = campoNombreAprendiz.contenido.trim();
  String especialidadesTexto = campoEspecialidadAprendiz.contenido.trim();
  if (!validarCedula(cedula)) {
    mostrarMensaje("Cédula inválida (solo dígitos, 6 a 15 caracteres).", true);
    return;
  }
  if (nombre.isEmpty() || especialidadesTexto.isEmpty()) {
    mostrarMensaje("Todos los campos son obligatorios.", true);
    return;
  }
  if (archivoAprendices.existe(cedula)) {
    mostrarMensaje("Ya existe un aprendiz con esa cédula.", true);
    return;
  }
  ArrayList<String> especialidades = parsearEspecialidades(especialidadesTexto);
  if (especialidades.isEmpty()) {
    mostrarMensaje("Ingresa al menos una especialidad válida.", true);
    return;
  }
  Aprendiz nuevo = new Aprendiz(cedula, nombre);
  nuevo.establecerEspecialidades(especialidades);
  if (archivoAprendices.crear(nuevo)) {
    mostrarMensaje("Aprendiz creado correctamente.", false);
    limpiarCamposFormulario();
  } else {
    mostrarMensaje("No se pudo crear el aprendiz.", true);
  }
}

ArrayList<String> parsearEspecialidades(String texto) {
  ArrayList<String> resultado = new ArrayList<String>();
  String[] partes = texto.split(",");
  for (String parte : partes) {
    String limpio = parte.trim();
    if (!limpio.isEmpty()) resultado.add(limpio);
  }
  return resultado;
}

void accionBuscarAprendiz() {
  String cedula = campoCedulaAprendiz.contenido.trim();
  if (!validarCedula(cedula)) {
    mostrarMensaje("Ingresa una cédula válida.", true);
    return;
  }
  aprendizEncontrado = archivoAprendices.leer(cedula);
  if (aprendizEncontrado == null) {
    mostrarMensaje("No existe un aprendiz con esa cédula.", true);
  } else {
    mensaje = "";
  }
}

void accionBuscarParaActualizarAprendiz() {
  String cedula = campoCedulaAprendiz.contenido.trim();
  if (!validarCedula(cedula)) {
    mostrarMensaje("Ingresa una cédula válida.", true);
    return;
  }
  Aprendiz apr = archivoAprendices.leer(cedula);
  if (apr == null) {
    mostrarMensaje("No existe un aprendiz con esa cédula.", true);
    return;
  }
  campoNombreAprendiz.contenido = apr.nombre;
  campoEspecialidadAprendiz.contenido = String.join(", ", apr.especialidades.keySet());
  mensaje = "";
}

void accionGuardarActualizarAprendiz() {
  String cedula = campoCedulaAprendiz.contenido.trim();
  if (!archivoAprendices.existe(cedula)) {
    mostrarMensaje("Primero busca un aprendiz válido.", true);
    return;
  }
  String nombre = campoNombreAprendiz.contenido.trim();
  String especialidadesTexto = campoEspecialidadAprendiz.contenido.trim();
  if (nombre.isEmpty() || especialidadesTexto.isEmpty()) {
    mostrarMensaje("Todos los campos son obligatorios.", true);
    return;
  }
  ArrayList<String> especialidades = parsearEspecialidades(especialidadesTexto);
  if (especialidades.isEmpty()) {
    mostrarMensaje("Ingresa al menos una especialidad válida.", true);
    return;
  }
  Aprendiz actual = archivoAprendices.leer(cedula);
  actual.nombre = nombre;
  actual.establecerEspecialidades(especialidades);
  if (archivoAprendices.actualizar(actual)) {
    mostrarMensaje("Aprendiz actualizado correctamente.", false);
  } else {
    mostrarMensaje("No se pudo actualizar el aprendiz.", true);
  }
}

void accionEliminarAprendiz() {
  String cedula = campoCedulaAprendiz.contenido.trim();
  if (!validarCedula(cedula)) {
    mostrarMensaje("Ingresa una cédula válida.", true);
    return;
  }
  if (!archivoAprendices.existe(cedula)) {
    mostrarMensaje("No existe un aprendiz con esa cédula.", true);
    return;
  }
  if (archivoAprendices.eliminar(cedula)) {
    mostrarMensaje("Aprendiz eliminado.", false);
    campoCedulaAprendiz.limpiar();
  } else {
    mostrarMensaje("No se pudo eliminar el aprendiz.", true);
  }
}


// ================================================================
// FUNCIONES DE ACCIÓN PARA SESIONES  (lógica sin cambios)
// ================================================================

void accionVerificarAprendiz() {
  String cedula = campoCedulaAprendiz.contenido.trim();
  if (!validarCedula(cedula)) {
    mostrarMensaje("Ingresa una cédula válida.", true);
    return;
  }
  aprendizEncontrado = archivoAprendices.leer(cedula);
  if (aprendizEncontrado == null) {
    mostrarMensaje("No existe un aprendiz con esa cédula. Regístralo primero.", true);
    return;
  }
  if (!aprendizEncontrado.tieneAlgunCupoDisponible()) {
    mostrarMensaje("El aprendiz ya completó sus " + Aprendiz.MAX_SESIONES_MES +
                   " sesiones del mes en todas sus especialidades.", true);
    aprendizEncontrado = null;
    return;
  }
  mostrarMensaje("Aprendiz verificado: " + aprendizEncontrado.nombre, false);
}

void accionBuscarInstructoresDisponibles() {
  if (aprendizEncontrado == null) {
    mostrarMensaje("Primero verifica al aprendiz.", true);
    return;
  }
  especialidadSeleccionada = campoEspecialidadSesion.contenido.trim();
  if (especialidadSeleccionada.isEmpty()) {
    mostrarMensaje("Ingresa la especialidad para la sesión.", true);
    return;
  }
  if (!aprendizEncontrado.tieneEspecialidad(especialidadSeleccionada)) {
    mostrarMensaje("El aprendiz no practica la especialidad \"" + especialidadSeleccionada + "\".", true);
    return;
  }
  if (!aprendizEncontrado.estaDisponibleEn(especialidadSeleccionada)) {
    mostrarMensaje("El aprendiz ya completó sus " + Aprendiz.MAX_SESIONES_MES +
                   " sesiones de " + especialidadSeleccionada + " este mes.", true);
    return;
  }
  String fechaTexto = campoFechaSesion.contenido.trim();
  String fechaHoy = obtenerFechaActual();
  if (fechaTexto.isEmpty()) {
    fechaSesionSeleccionada = fechaHoy;
  } else {
    if (!validarFecha(fechaTexto)) {
      mostrarMensaje("Fecha inválida. Usa el formato AAAA-MM-DD.", true);
      return;
    }
    if (compararFechas(fechaTexto, fechaHoy) < 0) {
      mostrarMensaje("La fecha de la sesión no puede ser anterior a hoy.", true);
      return;
    }
    fechaSesionSeleccionada = fechaTexto;
  }
  instructoresDisponibles = archivoInstructores.disponiblesPorEspecialidad(especialidadSeleccionada);
  if (instructoresDisponibles == null || instructoresDisponibles.isEmpty()) {
    mostrarMensaje("No hay instructores disponibles para " + especialidadSeleccionada, true);
    return;
  }
  cedulaAprendizSeleccionado = aprendizEncontrado.cedula;
  botonesInstructoresDisponibles.clear();
  estado = SELECCIONAR_INSTRUCTOR_SESION;
  mensaje = "";
}

void accionAsignarSesionCompleta() {
  if (instructorSeleccionadoIndex < 0 || instructorSeleccionadoIndex >= instructoresDisponibles.size()) {
    mostrarMensaje("Selecciona un instructor válido.", true);
    return;
  }
  Instructor instructorSeleccionado = instructoresDisponibles.get(instructorSeleccionadoIndex);
  instructorSeleccionado = archivoInstructores.leer(instructorSeleccionado.cedula);
  if (instructorSeleccionado == null || !instructorSeleccionado.estaDisponible()) {
    mostrarMensaje("El instructor ya no tiene cupo disponible.", true);
    return;
  }
  Aprendiz aprendiz = archivoAprendices.leer(cedulaAprendizSeleccionado);
  if (aprendiz == null || !aprendiz.estaDisponibleEn(especialidadSeleccionada)) {
    mostrarMensaje("El aprendiz ya no tiene cupo disponible en esa especialidad.", true);
    return;
  }
  String fechaSesion = fechaSesionSeleccionada.isEmpty() ? obtenerFechaActual() : fechaSesionSeleccionada;
  if (archivoSesiones.existeSesionDuplicada(aprendiz.cedula, instructorSeleccionado.cedula, especialidadSeleccionada, fechaSesion)) {
    mostrarMensaje("Ya existe una sesión igual para este aprendiz/instructor en esta fecha.", true);
    return;
  }
  String codigoSesion = generarCodigoSesion();
  Sesion nuevaSesion = new Sesion(codigoSesion, aprendiz.cedula, aprendiz.nombre,
    especialidadSeleccionada, instructorSeleccionado.cedula, fechaSesion);
  if (!archivoSesiones.crear(nuevaSesion)) {
    mostrarMensaje("No se pudo crear la sesión.", true);
    return;
  }
  if (!archivoInstructores.incrementarSesion(instructorSeleccionado.cedula)) {
    mostrarMensaje("Error al actualizar instructor.", true);
    return;
  }
  if (!archivoAprendices.incrementarSesion(aprendiz.cedula, especialidadSeleccionada)) {
    mostrarMensaje("Error al actualizar aprendiz.", true);
    return;
  }
  mostrarMensaje("Sesión asignada exitosamente. Código: " + codigoSesion, false);
  limpiarDatosTemporales();
  limpiarCamposFormulario();
  botonesInstructoresDisponibles.clear();
  estado = MENU_SESIONES;
}

void accionBuscarSesion() {
  String codigo = campoCodigoSesion.contenido.trim();
  if (codigo.isEmpty()) {
    mostrarMensaje("Ingresa el código de la sesión.", true);
    return;
  }
  sesionEncontrada = archivoSesiones.leer(codigo);
  if (sesionEncontrada == null) {
    mostrarMensaje("No existe una sesión con ese código.", true);
  } else {
    mostrarMensaje("Sesión encontrada.", false);
  }
}

void accionCancelarSesion() {
  String codigo = campoCodigoSesion.contenido.trim();
  if (codigo.isEmpty()) {
    mostrarMensaje("Ingresa el código de la sesión.", true);
    return;
  }
  Sesion sesion = archivoSesiones.leer(codigo);
  if (sesion == null) {
    mostrarMensaje("No existe una sesión con ese código.", true);
    return;
  }
  String fechaActual = obtenerFechaActual();
  if (compararFechas(sesion.fechaSesion, fechaActual) < 0) {
    mostrarMensaje("No se puede cancelar: la sesión ya se realizó (fecha pasada).", true);
    return;
  }
  if (!archivoSesiones.eliminar(codigo)) {
    mostrarMensaje("No se pudo cancelar la sesión.", true);
    return;
  }
  Instructor instructor = archivoInstructores.leer(sesion.cedulaInstructor);
  if (instructor != null) {
    instructor.sesionesRealizadas--;
    archivoInstructores.actualizar(instructor);
  }
  archivoAprendices.decrementarSesion(sesion.cedulaAprendiz, sesion.especialidad);
  mostrarMensaje("Sesión cancelada correctamente.", false);
  campoCodigoSesion.limpiar();
  sesionEncontrada = null;
}

void mostrarOpcionesReinicio() {
  boolean exito = true;
  if (archivoInstructores != null) {
    if (archivoInstructores.reiniciarSesiones()) {
      println("Sesiones de instructores reiniciadas.");
    } else {
      exito = false;
      println("Error al reiniciar sesiones de instructores.");
    }
  }
  if (archivoAprendices != null) {
    if (archivoAprendices.reiniciarSesiones()) {
      println("Sesiones de aprendices reiniciadas.");
    } else {
      exito = false;
      println("Error al reiniciar sesiones de aprendices.");
    }
  }
  ultimoRefrescoStats = -99999;   // fuerza recalcular los indicadores
  if (exito) {
    mostrarMensaje("Todas las sesiones fueron reiniciadas correctamente.", false);
  } else {
    mostrarMensaje("Error al reiniciar algunas sesiones.", true);
  }
}


// ================================================================
// MANEJO DE EVENTOS DEL MOUSE
// (mismo flujo y mismos índices de botones que la versión anterior)
// ================================================================

void mousePressed() {
  // La barra lateral y la hamburguesa tienen prioridad.
  if (manejarClicSidebar()) return;

  switch (estado) {
    case MENU_PRINCIPAL:
      if (botonesMenuPrincipal.size() < 5) break;
      if (botonesMenuPrincipal.get(0).contieneClic(mouseX, mouseY)) {
        estado = MENU_SESIONES;
        limpiarDatosTemporales();
      } else if (botonesMenuPrincipal.get(1).contieneClic(mouseX, mouseY)) {
        estado = MENU_INSTRUCTORES;
        limpiarDatosTemporales();
      } else if (botonesMenuPrincipal.get(2).contieneClic(mouseX, mouseY)) {
        estado = MENU_APRENDICES;
        limpiarDatosTemporales();
      } else if (botonesMenuPrincipal.get(3).contieneClic(mouseX, mouseY)) {
        estado = MENU_REPORTES; limpiarDatosTemporales(); mensaje = "";
      } else if (botonesMenuPrincipal.get(4).contieneClic(mouseX, mouseY)) {
        exit();
      }
      break;

    case MENU_REPORTES:
      if (botonesMenuReportes.size() < 3) break;
      if (botonesMenuReportes.get(0).contieneClic(mouseX, mouseY)) {
        estado = VER_REPORTE; mensaje = "";
      } else if (botonesMenuReportes.get(1).contieneClic(mouseX, mouseY)) {
        mostrarOpcionesReinicio();
      } else if (botonesMenuReportes.get(2).contieneClic(mouseX, mouseY)) {
        estado = MENU_PRINCIPAL; mensaje = "";
      }
      break;

    case VER_REPORTE:
      if (botonVolver.contieneClic(mouseX, mouseY)) {
        estado = MENU_REPORTES; mensaje = "";
      }
      break;

    case MENU_INSTRUCTORES:
      if (botonesMenuInstructores.size() < 7) break;
      if (botonesMenuInstructores.get(0).contieneClic(mouseX, mouseY)) {
        estado = CREAR_INSTRUCTOR; limpiarDatosTemporales(); limpiarCamposFormulario(); mensaje = "";
      } else if (botonesMenuInstructores.get(1).contieneClic(mouseX, mouseY)) {
        estado = CONSULTAR_INSTRUCTOR; limpiarDatosTemporales(); limpiarCamposFormulario(); mensaje = "";
      } else if (botonesMenuInstructores.get(2).contieneClic(mouseX, mouseY)) {
        estado = ACTUALIZAR_INSTRUCTOR; limpiarDatosTemporales(); limpiarCamposFormulario(); mensaje = "";
      } else if (botonesMenuInstructores.get(3).contieneClic(mouseX, mouseY)) {
        estado = ELIMINAR_INSTRUCTOR; limpiarDatosTemporales(); limpiarCamposFormulario(); mensaje = "";
      } else if (botonesMenuInstructores.get(4).contieneClic(mouseX, mouseY)) {
        listaInstructores = archivoInstructores.listarTodos(); estado = LISTAR_INSTRUCTORES; mensaje = "";
      } else if (botonesMenuInstructores.get(5).contieneClic(mouseX, mouseY)) {
        if (archivoInstructores.reiniciarSesiones()) {
          mostrarMensaje("Sesiones reiniciadas para todos los instructores.", false);
        } else {
          mostrarMensaje("No se pudieron reiniciar las sesiones.", true);
        }
        ultimoRefrescoStats = -99999;
      } else if (botonesMenuInstructores.get(6).contieneClic(mouseX, mouseY)) {
        estado = MENU_PRINCIPAL; limpiarDatosTemporales(); mensaje = "";
      }
      break;

    case MENU_APRENDICES:
      if (botonesMenuAprendices.size() < 7) break;
      if (botonesMenuAprendices.get(0).contieneClic(mouseX, mouseY)) {
        estado = CREAR_APRENDIZ; limpiarDatosTemporales(); limpiarCamposFormulario(); mensaje = "";
      } else if (botonesMenuAprendices.get(1).contieneClic(mouseX, mouseY)) {
        estado = CONSULTAR_APRENDIZ; limpiarDatosTemporales(); limpiarCamposFormulario(); mensaje = "";
      } else if (botonesMenuAprendices.get(2).contieneClic(mouseX, mouseY)) {
        estado = ACTUALIZAR_APRENDIZ; limpiarDatosTemporales(); limpiarCamposFormulario(); mensaje = "";
      } else if (botonesMenuAprendices.get(3).contieneClic(mouseX, mouseY)) {
        estado = ELIMINAR_APRENDIZ; limpiarDatosTemporales(); limpiarCamposFormulario(); mensaje = "";
      } else if (botonesMenuAprendices.get(4).contieneClic(mouseX, mouseY)) {
        listaAprendices = archivoAprendices.listarTodos(); estado = LISTAR_APRENDICES; mensaje = "";
      } else if (botonesMenuAprendices.get(5).contieneClic(mouseX, mouseY)) {
        if (archivoAprendices.reiniciarSesiones()) {
          mostrarMensaje("Sesiones reiniciadas para todos los aprendices.", false);
        } else {
          mostrarMensaje("No se pudieron reiniciar las sesiones.", true);
        }
        ultimoRefrescoStats = -99999;
      } else if (botonesMenuAprendices.get(6).contieneClic(mouseX, mouseY)) {
        estado = MENU_PRINCIPAL; limpiarDatosTemporales(); mensaje = "";
      }
      break;

    case MENU_SESIONES:
      if (botonesMenuSesiones.size() < 5) break;
      if (botonesMenuSesiones.get(0).contieneClic(mouseX, mouseY)) {
        estado = ASIGNAR_SESION; limpiarDatosTemporales(); limpiarCamposFormulario(); mensaje = "";
        botonBuscar.label = "Verificar";
      } else if (botonesMenuSesiones.get(1).contieneClic(mouseX, mouseY)) {
        estado = CONSULTAR_SESION; limpiarDatosTemporales(); limpiarCamposFormulario(); mensaje = "";
      } else if (botonesMenuSesiones.get(2).contieneClic(mouseX, mouseY)) {
        estado = CANCELAR_SESION; limpiarDatosTemporales(); limpiarCamposFormulario(); mensaje = "";
      } else if (botonesMenuSesiones.get(3).contieneClic(mouseX, mouseY)) {
        listaSesiones = archivoSesiones.listarTodas(); estado = LISTAR_SESIONES; mensaje = "";
      } else if (botonesMenuSesiones.get(4).contieneClic(mouseX, mouseY)) {
        estado = MENU_PRINCIPAL; limpiarDatosTemporales(); mensaje = "";
      }
      break;

    case CREAR_INSTRUCTOR:
      activarCampoSiClic(campoCedula);
      activarCampoSiClic(campoNombre);
      activarCampoSiClic(campoEspecialidad);
      activarCampoSiClic(campoTelefono);
      if (botonGuardar.contieneClic(mouseX, mouseY)) {
        accionGuardarInstructor();
      } else if (botonCancelar.contieneClic(mouseX, mouseY) || botonVolver.contieneClic(mouseX, mouseY)) {
        estado = MENU_INSTRUCTORES; limpiarCamposFormulario(); mensaje = "";
      }
      break;

    case CONSULTAR_INSTRUCTOR:
      activarCampoSiClic(campoCedula);
      if (botonBuscar.contieneClic(mouseX, mouseY)) {
        accionBuscarInstructor();
      } else if (botonVolver.contieneClic(mouseX, mouseY)) {
        estado = MENU_INSTRUCTORES; limpiarCamposFormulario(); instructorEncontrado = null; mensaje = "";
      }
      break;

    case ACTUALIZAR_INSTRUCTOR:
      activarCampoSiClic(campoCedula);
      activarCampoSiClic(campoNombre);
      activarCampoSiClic(campoEspecialidad);
      activarCampoSiClic(campoTelefono);
      if (botonBuscar.contieneClic(mouseX, mouseY)) {
        accionBuscarParaActualizarInstructor();
      } else if (botonGuardar.contieneClic(mouseX, mouseY)) {
        accionGuardarActualizarInstructor();
      } else if (botonVolver.contieneClic(mouseX, mouseY)) {
        estado = MENU_INSTRUCTORES; limpiarCamposFormulario(); mensaje = "";
      }
      break;

    case ELIMINAR_INSTRUCTOR:
      activarCampoSiClic(campoCedula);
      if (botonEliminar.contieneClic(mouseX, mouseY)) {
        accionEliminarInstructor();
      } else if (botonVolver.contieneClic(mouseX, mouseY)) {
        estado = MENU_INSTRUCTORES; limpiarCamposFormulario(); mensaje = "";
      }
      break;

    case LISTAR_INSTRUCTORES:
      if (botonVolver.contieneClic(mouseX, mouseY)) {
        estado = MENU_INSTRUCTORES; listaInstructores = null; mensaje = "";
      }
      break;

    case CREAR_APRENDIZ:
      activarCampoSiClic(campoCedulaAprendiz);
      activarCampoSiClic(campoNombreAprendiz);
      activarCampoSiClic(campoEspecialidadAprendiz);
      if (botonGuardar.contieneClic(mouseX, mouseY)) {
        accionGuardarAprendiz();
      } else if (botonCancelar.contieneClic(mouseX, mouseY) || botonVolver.contieneClic(mouseX, mouseY)) {
        estado = MENU_APRENDICES; limpiarCamposFormulario(); mensaje = "";
      }
      break;

    case CONSULTAR_APRENDIZ:
      activarCampoSiClic(campoCedulaAprendiz);
      if (botonBuscar.contieneClic(mouseX, mouseY)) {
        accionBuscarAprendiz();
      } else if (botonVolver.contieneClic(mouseX, mouseY)) {
        estado = MENU_APRENDICES; limpiarCamposFormulario(); aprendizEncontrado = null; mensaje = "";
      }
      break;

    case ACTUALIZAR_APRENDIZ:
      activarCampoSiClic(campoCedulaAprendiz);
      activarCampoSiClic(campoNombreAprendiz);
      activarCampoSiClic(campoEspecialidadAprendiz);
      if (botonBuscar.contieneClic(mouseX, mouseY)) {
        accionBuscarParaActualizarAprendiz();
      } else if (botonGuardar.contieneClic(mouseX, mouseY)) {
        accionGuardarActualizarAprendiz();
      } else if (botonVolver.contieneClic(mouseX, mouseY)) {
        estado = MENU_APRENDICES; limpiarCamposFormulario(); mensaje = "";
      }
      break;

    case ELIMINAR_APRENDIZ:
      activarCampoSiClic(campoCedulaAprendiz);
      if (botonEliminar.contieneClic(mouseX, mouseY)) {
        accionEliminarAprendiz();
      } else if (botonVolver.contieneClic(mouseX, mouseY)) {
        estado = MENU_APRENDICES; limpiarCamposFormulario(); mensaje = "";
      }
      break;

    case LISTAR_APRENDICES:
      if (botonVolver.contieneClic(mouseX, mouseY)) {
        estado = MENU_APRENDICES; listaAprendices = null; mensaje = "";
      }
      break;

    case ASIGNAR_SESION:
      activarCampoSiClic(campoCedulaAprendiz);
      activarCampoSiClic(campoEspecialidadSesion);
      activarCampoSiClic(campoFechaSesion);
      if (botonBuscar.contieneClic(mouseX, mouseY)) {
        accionVerificarAprendiz();
      } else if (botonAsignar.contieneClic(mouseX, mouseY) && aprendizEncontrado != null) {
        accionBuscarInstructoresDisponibles();
      } else if (botonVolverSesiones.contieneClic(mouseX, mouseY)) {
        estado = MENU_SESIONES; limpiarDatosTemporales(); limpiarCamposFormulario(); mensaje = "";
      }
      break;

    case SELECCIONAR_INSTRUCTOR_SESION:
      for (int i = 0; i < botonesInstructoresDisponibles.size(); i++) {
        if (botonesInstructoresDisponibles.get(i).contieneClic(mouseX, mouseY)) {
          instructorSeleccionadoIndex = i;
          accionAsignarSesionCompleta();
          break;
        }
      }
      if (botonVolverSesiones.contieneClic(mouseX, mouseY)) {
        estado = ASIGNAR_SESION; mensaje = "";
      }
      break;

    case CONSULTAR_SESION:
      activarCampoSiClic(campoCodigoSesion);
      if (botonBuscar.contieneClic(mouseX, mouseY)) {
        accionBuscarSesion();
      } else if (botonVolverSesiones.contieneClic(mouseX, mouseY)) {
        estado = MENU_SESIONES; limpiarCamposFormulario(); sesionEncontrada = null; mensaje = "";
      }
      break;

    case CANCELAR_SESION:
      activarCampoSiClic(campoCodigoSesion);
      if (botonEliminar.contieneClic(mouseX, mouseY)) {
        accionCancelarSesion();
      } else if (botonVolverSesiones.contieneClic(mouseX, mouseY)) {
        estado = MENU_SESIONES; limpiarCamposFormulario(); mensaje = "";
      }
      break;

    case LISTAR_SESIONES:
      if (botonVolverSesiones.contieneClic(mouseX, mouseY)) {
        estado = MENU_SESIONES; listaSesiones = null; mensaje = "";
      }
      break;
  }
}


// ================================================================
// MANEJO DE TECLADO  (sin cambios)
// ================================================================

void keyPressed() {
  switch (estado) {
    case CREAR_INSTRUCTOR:
    case ACTUALIZAR_INSTRUCTOR:
      campoCedula.manejarTecla(key, keyCode);
      campoNombre.manejarTecla(key, keyCode);
      campoEspecialidad.manejarTecla(key, keyCode);
      campoTelefono.manejarTecla(key, keyCode);
      break;

    case CONSULTAR_INSTRUCTOR:
    case ELIMINAR_INSTRUCTOR:
      campoCedula.manejarTecla(key, keyCode);
      break;

    case CREAR_APRENDIZ:
    case ACTUALIZAR_APRENDIZ:
      campoCedulaAprendiz.manejarTecla(key, keyCode);
      campoNombreAprendiz.manejarTecla(key, keyCode);
      campoEspecialidadAprendiz.manejarTecla(key, keyCode);
      break;

    case CONSULTAR_APRENDIZ:
    case ELIMINAR_APRENDIZ:
      campoCedulaAprendiz.manejarTecla(key, keyCode);
      break;

    case ASIGNAR_SESION:
      campoCedulaAprendiz.manejarTecla(key, keyCode);
      campoEspecialidadSesion.manejarTecla(key, keyCode);
      campoFechaSesion.manejarTecla(key, keyCode);
      break;

    case CONSULTAR_SESION:
    case CANCELAR_SESION:
      campoCodigoSesion.manejarTecla(key, keyCode);
      break;

    default:
      break;
  }
}


// ================================================================
// CIERRE DE LA APLICACIÓN
// ================================================================

public void exit() {
  if (archivoInstructores != null) archivoInstructores.cerrar();
  if (archivoAprendices != null) archivoAprendices.cerrar();
  if (archivoSesiones != null) archivoSesiones.cerrar();
  super.exit();
}
