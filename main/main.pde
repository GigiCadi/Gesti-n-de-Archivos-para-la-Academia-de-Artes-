// ================================================================
// LABORATORIO 1 - Manejo de Archivos en Java (Processing)
// Academia de Artes Barranquilla - SISTEMA COMPLETO
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

// ---- Botones principales ----
ArrayList<Boton> botonesMenuPrincipal;
ArrayList<Boton> botonesMenuInstructores;
ArrayList<Boton> botonesMenuAprendices;
ArrayList<Boton> botonesMenuSesiones;
ArrayList<Boton> botonesMenuReportes;
ArrayList<Boton> botonesInstructoresDisponibles;

// ---- Botones de acción ----
Boton botonGuardar, botonBuscar, botonEliminar, botonVolver, botonCancelar;
Boton botonAsignar;

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

// ---- Variables para posicionamiento dinámico ----
float centroX, centroY;

// ================================================================
// SETUP: Inicialización del sistema
// ================================================================
void setup() {
  size(1280, 720);
  surface.setTitle("Academia de Artes Barranquilla - Sistema de Gestión");
  surface.setResizable(true);
  
  try {
    java.awt.Frame frame = (java.awt.Frame) surface.getNative();
    frame.setExtendedState(java.awt.Frame.MAXIMIZED_BOTH);
    frame.setVisible(true);
    frame.requestFocus();
  } catch (Exception e) {
    surface.setSize(displayWidth, displayHeight);
    println("Nota: No se pudo maximizar automáticamente.");
  }
  
  pixelDensity(1);
  noSmooth();
  
  centroX = width / 2;
  centroY = height / 2;
  
  archivoInstructores = new ArchivoInstructores(sketchPath("data/instructores.dat"));
  archivoAprendices = new ArchivoAprendices(sketchPath("data/aprendices.dat"));
  archivoSesiones = new ArchivoSesiones(sketchPath("data/sesiones.dat"));
  
  if (!archivoInstructores.abrir()) {
    mensaje = "Error: No se pudo abrir el archivo de instructores.";
    colorMensaje = color(200, 40, 40);
  }
  if (!archivoAprendices.abrir()) {
    mensaje = "Error: No se pudo abrir el archivo de aprendices.";
    colorMensaje = color(200, 40, 40);
  }
  if (!archivoSesiones.abrir()) {
    mensaje = "Error: No se pudo abrir el archivo de sesiones.";
    colorMensaje = color(200, 40, 40);
  }
  
  inicializarBotones();
  inicializarCampos();
}

// ================================================================
// INICIALIZACIÓN DE COMPONENTES
// ================================================================

void inicializarBotones() {
  // ---- MENÚ PRINCIPAL (estilo imagen) ----
  botonesMenuPrincipal = new ArrayList<Boton>();
  
  // Módulo 1: Sesiones (Azul)
  botonesMenuPrincipal.add(new Boton(centroX - 500, height * 0.23f, 350, 90, 
    "MÓDULO DE SESIONES", "Administra las sesiones de clases", 
    color(26, 115, 232), color(52, 152, 219)));
  
  // Módulo 2: Instructores (Verde)
  botonesMenuPrincipal.add(new Boton(centroX + 150, height * 0.23f, 350, 90, 
    "MÓDULO DE INSTRUCTORES", "Gestiona la información de los instructores", 
    color(39, 174, 96), color(46, 204, 113)));
  
  // Módulo 3: Aprendices (Morado)
  botonesMenuPrincipal.add(new Boton(centroX - 500, height * 0.40f, 350, 90, 
    "MÓDULO DE APRENDICES", "Gestiona la información de los aprendices", 
    color(155, 89, 182), color(169, 105, 197)));
  
  // Módulo 4: Reinicio (Amarillo)
  botonesMenuPrincipal.add(new Boton(centroX + 150, height * 0.40f, 350, 90, 
    "REINICIO Y REPORTES", "Reinicia contadores y genera reportes", 
    color(243, 156, 18), color(241, 196, 15)));
  
  // Módulo 5: Salir (Rojo)
  botonesMenuPrincipal.add(new Boton(centroX - 120, height * 0.57f, 240, 60, 
    "SALIR", "Guarda los cambios y sale del sistema", 
    color(192, 57, 43), color(231, 76, 60)));
  
  // ---- MENÚ DE INSTRUCTORES ----
  botonesMenuInstructores = new ArrayList<Boton>();
  botonesMenuInstructores.add(new Boton(centroX - 150, height * 0.22f, 300, 48, "Crear instructor", color(26, 115, 232), color(52, 152, 219)));
  botonesMenuInstructores.add(new Boton(centroX - 150, height * 0.30f, 300, 48, "Consultar instructor", color(26, 115, 232), color(52, 152, 219)));
  botonesMenuInstructores.add(new Boton(centroX - 150, height * 0.38f, 300, 48, "Actualizar instructor", color(26, 115, 232), color(52, 152, 219)));
  botonesMenuInstructores.add(new Boton(centroX - 150, height * 0.46f, 300, 48, "Eliminar instructor", color(192, 57, 43), color(231, 76, 60)));
  botonesMenuInstructores.add(new Boton(centroX - 150, height * 0.54f, 300, 48, "Listar instructores", color(26, 115, 232), color(52, 152, 219)));
  botonesMenuInstructores.add(new Boton(centroX - 150, height * 0.62f, 300, 48, "Reiniciar sesiones del mes", color(243, 156, 18), color(241, 196, 15)));
  botonesMenuInstructores.add(new Boton(centroX - 150, height * 0.72f, 300, 42, "← Volver", color(149, 165, 166), color(189, 195, 199)));
  
  // ---- MENÚ DE APRENDICES ----
  botonesMenuAprendices = new ArrayList<Boton>();
  botonesMenuAprendices.add(new Boton(centroX - 150, height * 0.22f, 300, 48, "Crear aprendiz", color(155, 89, 182), color(169, 105, 197)));
  botonesMenuAprendices.add(new Boton(centroX - 150, height * 0.30f, 300, 48, "Consultar aprendiz", color(155, 89, 182), color(169, 105, 197)));
  botonesMenuAprendices.add(new Boton(centroX - 150, height * 0.38f, 300, 48, "Actualizar aprendiz", color(155, 89, 182), color(169, 105, 197)));
  botonesMenuAprendices.add(new Boton(centroX - 150, height * 0.46f, 300, 48, "Eliminar aprendiz", color(192, 57, 43), color(231, 76, 60)));
  botonesMenuAprendices.add(new Boton(centroX - 150, height * 0.54f, 300, 48, "Listar aprendices", color(155, 89, 182), color(169, 105, 197)));
  botonesMenuAprendices.add(new Boton(centroX - 150, height * 0.62f, 300, 48, "Reiniciar sesiones del mes", color(243, 156, 18), color(241, 196, 15)));
  botonesMenuAprendices.add(new Boton(centroX - 150, height * 0.72f, 300, 42, "← Volver", color(149, 165, 166), color(189, 195, 199)));
  
  // ---- MENÚ DE SESIONES ----
  botonesMenuSesiones = new ArrayList<Boton>();
  botonesMenuSesiones.add(new Boton(centroX - 150, height * 0.25f, 300, 55, "Asignar sesión", color(26, 115, 232), color(52, 152, 219)));
  botonesMenuSesiones.add(new Boton(centroX - 150, height * 0.34f, 300, 55, "Consultar sesión", color(26, 115, 232), color(52, 152, 219)));
  botonesMenuSesiones.add(new Boton(centroX - 150, height * 0.43f, 300, 55, "Cancelar sesión", color(192, 57, 43), color(231, 76, 60)));
  botonesMenuSesiones.add(new Boton(centroX - 150, height * 0.52f, 300, 55, "Listar sesiones", color(26, 115, 232), color(52, 152, 219)));
  botonesMenuSesiones.add(new Boton(centroX - 150, height * 0.63f, 300, 55, "← Volver", color(149, 165, 166), color(189, 195, 199)));
  
  // ---- MENÚ DE REPORTES Y REINICIO ----
  botonesMenuReportes = new ArrayList<Boton>();
  botonesMenuReportes.add(new Boton(centroX - 175, height * 0.30f, 350, 55, "Ver reporte de disponibilidad", color(26, 115, 232), color(52, 152, 219)));
  botonesMenuReportes.add(new Boton(centroX - 175, height * 0.42f, 350, 55, "Reiniciar contadores del mes", color(243, 156, 18), color(241, 196, 15)));
  botonesMenuReportes.add(new Boton(centroX - 175, height * 0.54f, 350, 42, "← Volver", color(149, 165, 166), color(189, 195, 199)));

  // ---- BOTONES DE ACCIÓN ----
  float yBase = height * 0.78f;
  botonGuardar  = new Boton(centroX - 80, yBase, 160, 45, "Guardar", color(39, 174, 96), color(46, 204, 113));
  botonBuscar   = new Boton(centroX + 170, height * 0.28f, 120, 40, "Buscar", color(26, 115, 232), color(52, 152, 219));
  botonEliminar = new Boton(centroX - 80, height * 0.40f, 160, 45, "Eliminar", color(192, 57, 43), color(231, 76, 60));
  botonCancelar = new Boton(centroX + 100, yBase, 160, 45, "Cancelar", color(149, 165, 166), color(189, 195, 199));
  botonVolver   = new Boton(width * 0.04f, height * 0.88f, 130, 42, "← Volver", color(149, 165, 166), color(189, 195, 199));
  botonAsignar  = new Boton(centroX - 100, yBase, 200, 45, "Asignar Sesión", color(26, 115, 232), color(52, 152, 219));
  
  botonesInstructoresDisponibles = new ArrayList<Boton>();
}

void inicializarCampos() {
  float anchoCampo = 340;
  float inicioX = centroX - anchoCampo/2;
  
  campoCedula       = new CampoTexto(inicioX, height * 0.28f, anchoCampo, 38, "Cédula");
  campoNombre       = new CampoTexto(inicioX, height * 0.38f, anchoCampo, 38, "Nombre");
  campoEspecialidad = new CampoTexto(inicioX, height * 0.48f, anchoCampo, 38, "Especialidad");
  campoTelefono     = new CampoTexto(inicioX, height * 0.58f, anchoCampo, 38, "Teléfono");
  
  campoCedulaAprendiz       = new CampoTexto(inicioX, height * 0.28f, anchoCampo, 38, "Cédula");
  campoNombreAprendiz       = new CampoTexto(inicioX, height * 0.38f, anchoCampo, 38, "Nombre");
  campoEspecialidadAprendiz = new CampoTexto(inicioX, height * 0.48f, anchoCampo, 38, "Especialidades (separadas por coma)");
  
  campoCodigoSesion = new CampoTexto(inicioX, height * 0.28f, anchoCampo, 38, "Código de sesión");
  campoFechaSesion  = new CampoTexto(inicioX, height * 0.38f, anchoCampo, 38, "Fecha (AAAA-MM-DD)");
  campoEspecialidadSesion = new CampoTexto(inicioX, height * 0.52f, anchoCampo, 38, "Especialidad");
}

// ================================================================
// DRAW: Bucle principal de dibujo
// ================================================================
void draw() {
  centroX = width / 2;
  centroY = height / 2;
  
  background(240, 245, 250);
  
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
  
  dibujarMensaje();
}

// ================================================================
// FUNCIONES DE DIBUJO PARA CADA PANTALLA
// ================================================================

void dibujarMenuPrincipal() {
  dibujarEncabezado("Academia de Artes Barranquilla");
  fill(80);
  textAlign(CENTER, TOP);
  textSize(16);
  text("Sistema de Gestión de Instructores, Aprendices y Sesiones", width/2, height * 0.12f);
  for (Boton b : botonesMenuPrincipal) b.dibujar();
  fill(150, 180);
  textAlign(CENTER, BOTTOM);
  textSize(12);
  text("© 2025 Academia de Artes Barranquilla - Arte que transforma, cultura que nos une", width/2, height-15);
}

void dibujarMenuInstructores() {
  dibujarEncabezado("Gestión de Instructores");
  for (Boton b : botonesMenuInstructores) b.dibujar();
}

void dibujarMenuAprendices() {
  dibujarEncabezado("Gestión de Aprendices");
  for (Boton b : botonesMenuAprendices) b.dibujar();
}

void dibujarMenuSesiones() {
  dibujarEncabezado("Gestión de Sesiones");
  for (Boton b : botonesMenuSesiones) b.dibujar();
}

void dibujarMenuReportes() {
  dibujarEncabezado("Reportes y Reinicio Mensual");
  for (Boton b : botonesMenuReportes) b.dibujar();
}

void dibujarReporte() {
  dibujarEncabezado("Reporte de Disponibilidad y Sesiones");
  botonVolver.dibujar();

  ArrayList<Instructor> instructores = archivoInstructores.listarTodos();
  ArrayList<Aprendiz> aprendices = archivoAprendices.listarTodos();
  ArrayList<Sesion> sesiones = archivoSesiones.listarTodas();

  // ---- Conteos por especialidad de instructores ----
  HashMap<String, Integer> totalPorEspecialidad = new HashMap<String, Integer>();
  HashMap<String, Integer> disponiblesPorEspecialidad = new HashMap<String, Integer>();
  int instructoresDisponiblesTotal = 0;
  for (Instructor inst : instructores) {
    String esp = inst.especialidad;
    totalPorEspecialidad.put(esp, (totalPorEspecialidad.containsKey(esp) ? totalPorEspecialidad.get(esp) : 0) + 1);
    if (inst.estaDisponible()) {
      instructoresDisponiblesTotal++;
      disponiblesPorEspecialidad.put(esp, (disponiblesPorEspecialidad.containsKey(esp) ? disponiblesPorEspecialidad.get(esp) : 0) + 1);
    }
  }

  // ---- Sesiones asignadas por especialidad ----
  HashMap<String, Integer> sesionesPorEspecialidad = new HashMap<String, Integer>();
  for (Sesion s : sesiones) {
    String esp = s.especialidad;
    sesionesPorEspecialidad.put(esp, (sesionesPorEspecialidad.containsKey(esp) ? sesionesPorEspecialidad.get(esp) : 0) + 1);
  }

  // ---- Aprendices con cupo disponible ----
  int aprendicesConCupo = 0;
  for (Aprendiz a : aprendices) {
    if (a.tieneAlgunCupoDisponible()) aprendicesConCupo++;
  }

  float inicioXIzq = width * 0.06f;
  float inicioXDer = width * 0.53f;
  float y = height * 0.19f;

  fill(20);
  textAlign(LEFT, TOP);
  textSize(17);
  text("Resumen general", inicioXIzq, y);
  y += 30;
  textSize(14);
  fill(60);
  text("Instructores registrados: " + instructores.size(), inicioXIzq, y); y += 24;
  text("Instructores disponibles (menos de " + ArchivoInstructores.MAX_SESIONES_MES + " sesiones): " + instructoresDisponiblesTotal, inicioXIzq, y); y += 24;
  text("Aprendices registrados: " + aprendices.size(), inicioXIzq, y); y += 24;
  text("Aprendices con al menos una especialidad con cupo: " + aprendicesConCupo, inicioXIzq, y); y += 24;
  text("Sesiones activas asignadas: " + sesiones.size(), inicioXIzq, y); y += 34;

  fill(20);
  textSize(17);
  text("Disponibilidad por especialidad (instructores)", inicioXIzq, y);
  y += 30;
  textSize(14);
  fill(60);
  if (totalPorEspecialidad.isEmpty()) {
    text("No hay instructores registrados.", inicioXIzq, y);
  } else {
    for (String esp : totalPorEspecialidad.keySet()) {
      int total = totalPorEspecialidad.get(esp);
      int disp = disponiblesPorEspecialidad.containsKey(esp) ? disponiblesPorEspecialidad.get(esp) : 0;
      text(esp + ": " + disp + " disponibles de " + total, inicioXIzq, y);
      y += 24;
      if (y > height - 90) break;
    }
  }

  float yDer = height * 0.19f;
  fill(20);
  textSize(17);
  text("Sesiones asignadas por especialidad", inicioXDer, yDer);
  yDer += 30;
  textSize(14);
  fill(60);
  if (sesionesPorEspecialidad.isEmpty()) {
    text("No hay sesiones asignadas todavía.", inicioXDer, yDer);
  } else {
    for (String esp : sesionesPorEspecialidad.keySet()) {
      text(esp + ": " + sesionesPorEspecialidad.get(esp) + " sesión(es)", inicioXDer, yDer);
      yDer += 24;
      if (yDer > height - 90) break;
    }
  }
}

void dibujarFormularioCrearInstructor() {
  dibujarEncabezado("Crear Instructor");
  campoCedula.dibujar();
  campoNombre.dibujar();
  campoEspecialidad.dibujar();
  campoTelefono.dibujar();
  botonGuardar.dibujar();
  botonCancelar.dibujar();
  botonVolver.dibujar();
}

void dibujarFormularioConsultarInstructor() {
  dibujarEncabezado("Consultar Instructor");
  float inicioX = centroX - 170;
  campoCedula.x = inicioX; campoCedula.y = height * 0.28f;
  campoCedula.dibujar();
  botonBuscar.x = inicioX + 360; botonBuscar.y = height * 0.27f;
  botonBuscar.w = 120; botonBuscar.h = 40;
  botonBuscar.dibujar();
  botonVolver.dibujar();
  if (instructorEncontrado != null) {
    fill(20);
    textAlign(LEFT, TOP);
    textSize(18);
    text(instructorEncontrado.toStringResumido(), inicioX, height * 0.40f);
    text(instructorEncontrado.estaDisponible() ? "✓ Disponible este mes" : "✗ SIN cupo este mes", inicioX, height * 0.46f);
  }
}

void dibujarFormularioActualizarInstructor() {
  dibujarEncabezado("Actualizar Instructor");
  float inicioX = centroX - 170;
  campoCedula.x = inicioX; campoCedula.y = height * 0.22f;
  campoCedula.dibujar();
  botonBuscar.x = inicioX + 360; botonBuscar.y = height * 0.21f;
  botonBuscar.w = 120; botonBuscar.h = 40;
  botonBuscar.dibujar();
  campoNombre.y = height * 0.34f;
  campoEspecialidad.y = height * 0.44f;
  campoTelefono.y = height * 0.54f;
  campoNombre.dibujar();
  campoEspecialidad.dibujar();
  campoTelefono.dibujar();
  botonGuardar.y = height * 0.66f;
  botonGuardar.dibujar();
  botonVolver.dibujar();
}

void dibujarFormularioEliminarInstructor() {
  dibujarEncabezado("Eliminar Instructor");
  float inicioX = centroX - 170;
  campoCedula.x = inicioX; campoCedula.y = height * 0.28f;
  campoCedula.dibujar();
  botonEliminar.x = inicioX; botonEliminar.y = height * 0.40f;
  botonEliminar.dibujar();
  botonVolver.dibujar();
}

void dibujarListadoInstructores() {
  dibujarEncabezado("Instructores Registrados");
  botonVolver.dibujar();
  if (listaInstructores == null) listaInstructores = archivoInstructores.listarTodos();
  float inicioX = width * 0.08f;
  float y = height * 0.20f;
  fill(20);
  textAlign(LEFT, TOP);
  textSize(16);
  if (listaInstructores.isEmpty()) {
    text("No hay instructores registrados.", inicioX, y);
  } else {
    fill(100);
    text("Nombre", inicioX, y);
    text("Cédula", inicioX + 250, y);
    text("Especialidad", inicioX + 400, y);
    text("Sesiones", inicioX + 550, y);
    y += 30;
    fill(20);
    for (Instructor inst : listaInstructores) {
      text(inst.nombre, inicioX, y);
      text(inst.cedula, inicioX + 250, y);
      text(inst.especialidad, inicioX + 400, y);
      text(inst.sesionesRealizadas + "/" + ArchivoInstructores.MAX_SESIONES_MES, inicioX + 550, y);
      y += 30;
      if (y > height - 80) break;
    }
  }
}

void dibujarFormularioCrearAprendiz() {
  dibujarEncabezado("Crear Aprendiz");
  campoCedulaAprendiz.dibujar();
  campoNombreAprendiz.dibujar();
  campoEspecialidadAprendiz.dibujar();
  botonGuardar.dibujar();
  botonCancelar.dibujar();
  botonVolver.dibujar();
}

void dibujarFormularioConsultarAprendiz() {
  dibujarEncabezado("Consultar Aprendiz");
  float inicioX = centroX - 170;
  campoCedulaAprendiz.x = inicioX; campoCedulaAprendiz.y = height * 0.28f;
  campoCedulaAprendiz.dibujar();
  botonBuscar.x = inicioX + 360; botonBuscar.y = height * 0.27f;
  botonBuscar.w = 120; botonBuscar.h = 40;
  botonBuscar.dibujar();
  botonVolver.dibujar();
  if (aprendizEncontrado != null) {
    fill(20);
    textAlign(LEFT, TOP);
    textSize(18);
    text(aprendizEncontrado.toStringResumido(), inicioX, height * 0.40f);
  }
}

void dibujarFormularioActualizarAprendiz() {
  dibujarEncabezado("Actualizar Aprendiz");
  float inicioX = centroX - 170;
  campoCedulaAprendiz.x = inicioX; campoCedulaAprendiz.y = height * 0.22f;
  campoCedulaAprendiz.dibujar();
  botonBuscar.x = inicioX + 360; botonBuscar.y = height * 0.21f;
  botonBuscar.w = 120; botonBuscar.h = 40;
  botonBuscar.dibujar();
  campoNombreAprendiz.y = height * 0.34f;
  campoEspecialidadAprendiz.y = height * 0.44f;
  campoNombreAprendiz.dibujar();
  campoEspecialidadAprendiz.dibujar();
  botonGuardar.y = height * 0.56f;
  botonGuardar.dibujar();
  botonVolver.dibujar();
}

void dibujarFormularioEliminarAprendiz() {
  dibujarEncabezado("Eliminar Aprendiz");
  float inicioX = centroX - 170;
  campoCedulaAprendiz.x = inicioX; campoCedulaAprendiz.y = height * 0.28f;
  campoCedulaAprendiz.dibujar();
  botonEliminar.x = inicioX; botonEliminar.y = height * 0.40f;
  botonEliminar.dibujar();
  botonVolver.dibujar();
}

void dibujarListadoAprendices() {
  dibujarEncabezado("Aprendices Registrados");
  botonVolver.dibujar();
  if (listaAprendices == null) listaAprendices = archivoAprendices.listarTodos();
  float inicioX = width * 0.08f;
  float y = height * 0.20f;
  fill(20);
  textAlign(LEFT, TOP);
  textSize(16);
  if (listaAprendices.isEmpty()) {
    text("No hay aprendices registrados.", inicioX, y);
  } else {
    fill(100);
    text("Nombre", inicioX, y);
    text("Cédula", inicioX + 250, y);
    text("Especialidades (sesiones/mes)", inicioX + 400, y);
    y += 30;
    fill(20);
    for (Aprendiz apr : listaAprendices) {
      text(apr.nombre, inicioX, y);
      text(apr.cedula, inicioX + 250, y);
      text(apr.especialidadesResumenCorto(), inicioX + 400, y);
      y += 30;
      if (y > height - 80) break;
    }
  }
}

void dibujarFormularioAsignarSesion() {
  dibujarEncabezado("Asignar Sesión");
  float inicioX = centroX - 170;
  fill(80);
  textAlign(LEFT, TOP);
  textSize(14);
  text("Paso 1: Ingresa la cédula del aprendiz", inicioX, height * 0.18f);
  campoCedulaAprendiz.x = inicioX;
  campoCedulaAprendiz.y = height * 0.24f;
  campoCedulaAprendiz.dibujar();
  botonBuscar.x = inicioX + 360;
  botonBuscar.y = height * 0.23f;
  botonBuscar.w = 120;
  botonBuscar.h = 40;
  botonBuscar.label = "Verificar";
  botonBuscar.dibujar();
  if (aprendizEncontrado != null) {
    fill(20);
    textAlign(LEFT, TOP);
    textSize(15);
    text("Aprendiz: " + aprendizEncontrado.nombre, inicioX, height * 0.34f);
    text("Especialidades: " + aprendizEncontrado.especialidadesResumenCorto(), inicioX, height * 0.38f);
    if (!aprendizEncontrado.tieneAlgunCupoDisponible()) {
      fill(200, 40, 40);
      text("⚠ El aprendiz ya completó sus sesiones del mes en todas sus especialidades", inicioX, height * 0.44f);
    } else {
      fill(39, 174, 96);
      text("✓ El aprendiz tiene cupo disponible en al menos una especialidad", inicioX, height * 0.44f);
      fill(80);
      text("Especialidad de la sesión (debe ser una que practique):", inicioX, height * 0.52f);
      campoEspecialidadSesion.x = inicioX;
      campoEspecialidadSesion.y = height * 0.57f;
      campoEspecialidadSesion.dibujar();
      text("Fecha de la sesión (AAAA-MM-DD, hoy o futura; vacío = hoy):", inicioX, height * 0.63f);
      campoFechaSesion.x = inicioX;
      campoFechaSesion.y = height * 0.68f;
      campoFechaSesion.dibujar();
      botonAsignar.x = inicioX;
      botonAsignar.y = height * 0.78f;
      botonAsignar.dibujar();
    }
  }
  botonVolver.dibujar();
}

void dibujarSeleccionInstructor() {
  dibujarEncabezado("Seleccionar Instructor");
  float inicioX = centroX - 250;
  fill(80);
  textAlign(LEFT, TOP);
  textSize(16);
  text("Paso 2: Instructores disponibles para " + especialidadSeleccionada + 
       " el " + fechaSesionSeleccionada, inicioX, height * 0.18f);
  if (instructoresDisponibles == null || instructoresDisponibles.isEmpty()) {
    fill(200, 40, 40);
    textAlign(CENTER, TOP);
    textSize(18);
    text("No hay instructores disponibles para esta especialidad", width/2, height * 0.30f);
    botonVolver.dibujar();
    return;
  }
  float y = height * 0.24f;
  int index = 0;
  for (Instructor inst : instructoresDisponibles) {
    if (index >= botonesInstructoresDisponibles.size()) {
      botonesInstructoresDisponibles.add(new Boton(inicioX, y, 500, 42, 
        inst.nombre + " | " + inst.cedula + " | Sesiones: " + 
        inst.sesionesRealizadas + "/" + ArchivoInstructores.MAX_SESIONES_MES,
        color(41, 128, 185), color(52, 152, 219)));
    } else {
      Boton b = botonesInstructoresDisponibles.get(index);
      b.x = inicioX;
      b.y = y;
      b.label = inst.nombre + " | " + inst.cedula + " | Sesiones: " + 
                   inst.sesionesRealizadas + "/" + ArchivoInstructores.MAX_SESIONES_MES;
      b.dibujar();
    }
    y += 50;
    index++;
  }
  while (botonesInstructoresDisponibles.size() > index) {
    botonesInstructoresDisponibles.remove(botonesInstructoresDisponibles.size() - 1);
  }
  botonVolver.dibujar();
}

void dibujarFormularioConsultarSesion() {
  dibujarEncabezado("Consultar Sesión");
  float inicioX = centroX - 170;
  campoCodigoSesion.x = inicioX; campoCodigoSesion.y = height * 0.28f;
  campoCodigoSesion.dibujar();
  botonBuscar.x = inicioX + 360; botonBuscar.y = height * 0.27f;
  botonBuscar.w = 120; botonBuscar.h = 40;
  botonBuscar.dibujar();
  botonVolver.dibujar();
  if (sesionEncontrada != null) {
    fill(20);
    textAlign(LEFT, TOP);
    textSize(16);
    float y = height * 0.40f;
    text("Código: " + sesionEncontrada.codigoUnico, inicioX, y);
    text("Aprendiz: " + sesionEncontrada.nombreAprendiz, inicioX, y + 35);
    text("Cédula: " + sesionEncontrada.cedulaAprendiz, inicioX, y + 70);
    text("Especialidad: " + sesionEncontrada.especialidad, inicioX, y + 105);
    text("Instructor: " + sesionEncontrada.cedulaInstructor, inicioX, y + 140);
    text("Fecha: " + sesionEncontrada.fechaSesion, inicioX, y + 175);
  }
}

void dibujarFormularioCancelarSesion() {
  dibujarEncabezado("Cancelar Sesión");
  float inicioX = centroX - 170;
  fill(80);
  textAlign(LEFT, TOP);
  textSize(14);
  text("Ingresa el código de la sesión a cancelar (solo fechas futuras)", inicioX, height * 0.20f);
  campoCodigoSesion.x = inicioX;
  campoCodigoSesion.y = height * 0.28f;
  campoCodigoSesion.dibujar();
  botonEliminar.x = inicioX;
  botonEliminar.y = height * 0.40f;
  botonEliminar.label = "Cancelar Sesión";
  botonEliminar.dibujar();
  botonVolver.dibujar();
}

void dibujarListadoSesiones() {
  dibujarEncabezado("Sesiones Registradas");
  botonVolver.dibujar();
  if (listaSesiones == null) listaSesiones = archivoSesiones.listarTodas();
  float inicioX = width * 0.08f;
  float y = height * 0.20f;
  fill(20);
  textAlign(LEFT, TOP);
  textSize(15);
  if (listaSesiones.isEmpty()) {
    text("No hay sesiones registradas.", inicioX, y);
  } else {
    fill(100);
    text("Código", inicioX, y);
    text("Aprendiz", inicioX + 150, y);
    text("Especialidad", inicioX + 330, y);
    text("Fecha", inicioX + 480, y);
    y += 28;
    fill(20);
    for (Sesion ses : listaSesiones) {
      text(ses.codigoUnico, inicioX, y);
      text(ses.nombreAprendiz, inicioX + 150, y);
      text(ses.especialidad, inicioX + 330, y);
      text(ses.fechaSesion, inicioX + 480, y);
      y += 28;
      if (y > height - 80) break;
    }
  }
}

// ================================================================
// FUNCIONES DE ACCIÓN PARA INSTRUCTORES
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
// FUNCIONES DE ACCIÓN PARA APRENDICES
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

// Convierte "Baile, Pintura,  Canto" en una lista limpia sin vacíos
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
// FUNCIONES DE ACCIÓN PARA SESIONES
// ================================================================

void accionVerificarAprendiz() {
  String cedula = campoCedulaAprendiz.contenido.trim();
  if (!validarCedula(cedula)) {
    mostrarMensaje("Ingresa una cédula válida.", true);
    return;
  }
  aprendizEncontrado = archivoAprendices.leer(cedula);
  if (aprendizEncontrado == null) {
    mostrarMensaje("No existe un aprendiz con esa cédula. Regístrelo primero.", true);
    return;
  }
  if (!aprendizEncontrado.tieneAlgunCupoDisponible()) {
    mostrarMensaje("El aprendiz ya completó sus " + Aprendiz.MAX_SESIONES_MES + " sesiones del mes en todas sus especialidades.", true);
    aprendizEncontrado = null;
    return;
  }
  mostrarMensaje("✓ Aprendiz verificado: " + aprendizEncontrado.nombre, false);
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
    mostrarMensaje("El aprendiz ya completó sus " + Aprendiz.MAX_SESIONES_MES + " sesiones de " + especialidadSeleccionada + " este mes.", true);
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
  mostrarMensaje("✓ Sesión asignada exitosamente. Código: " + codigoSesion, false);
  limpiarDatosTemporales();
  limpiarCamposFormulario();
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
  mostrarMensaje("✓ Sesión cancelada correctamente.", false);
  campoCodigoSesion.limpiar();
  sesionEncontrada = null;
}

void mostrarOpcionesReinicio() {
  mostrarMensaje("Reiniciando sesiones de instructores y aprendices...", false);
  boolean exito = true;
  if (archivoInstructores != null) {
    if (archivoInstructores.reiniciarSesiones()) {
      println("✓ Sesiones de instructores reiniciadas.");
    } else {
      exito = false;
      println("✗ Error al reiniciar sesiones de instructores.");
    }
  }
  if (archivoAprendices != null) {
    if (archivoAprendices.reiniciarSesiones()) {
      println("✓ Sesiones de aprendices reiniciadas.");
    } else {
      exito = false;
      println("✗ Error al reiniciar sesiones de aprendices.");
    }
  }
  if (exito) {
    mostrarMensaje("✓ Todas las sesiones reiniciadas correctamente.", false);
  } else {
    mostrarMensaje("Error al reiniciar algunas sesiones.", true);
  }
}

// ================================================================
// MANEJO DE EVENTOS DEL MOUSE
// ================================================================

void mousePressed() {
  switch (estado) {
    case MENU_PRINCIPAL:
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
      } else if (botonesMenuInstructores.get(6).contieneClic(mouseX, mouseY)) {
        estado = MENU_PRINCIPAL; limpiarDatosTemporales(); mensaje = "";
      }
      break;
      
    case MENU_APRENDICES:
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
      } else if (botonesMenuAprendices.get(6).contieneClic(mouseX, mouseY)) {
        estado = MENU_PRINCIPAL; limpiarDatosTemporales(); mensaje = "";
      }
      break;
      
    case MENU_SESIONES:
      if (botonesMenuSesiones.get(0).contieneClic(mouseX, mouseY)) {
        estado = ASIGNAR_SESION; limpiarDatosTemporales(); limpiarCamposFormulario(); mensaje = "";
        botonBuscar.label = "Verificar";
      } else if (botonesMenuSesiones.get(1).contieneClic(mouseX, mouseY)) {
        estado = CONSULTAR_SESION; limpiarDatosTemporales(); limpiarCamposFormulario(); mensaje = "";
      } else if (botonesMenuSesiones.get(2).contieneClic(mouseX, mouseY)) {
        estado = CANCELAR_SESION; limpiarDatosTemporales(); limpiarCamposFormulario(); mensaje = "";
        botonEliminar.label = "Cancelar Sesión";
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
      if (botonBuscar.contieneClic(mouseX, mouseY)) {
        accionVerificarAprendiz();
      } else if (botonAsignar.contieneClic(mouseX, mouseY) && aprendizEncontrado != null) {
        accionBuscarInstructoresDisponibles();
      } else if (botonVolver.contieneClic(mouseX, mouseY)) {
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
      if (botonVolver.contieneClic(mouseX, mouseY)) {
        estado = ASIGNAR_SESION; mensaje = "";
      }
      break;
      
    case CONSULTAR_SESION:
      activarCampoSiClic(campoCodigoSesion);
      if (botonBuscar.contieneClic(mouseX, mouseY)) {
        accionBuscarSesion();
      } else if (botonVolver.contieneClic(mouseX, mouseY)) {
        estado = MENU_SESIONES; limpiarCamposFormulario(); sesionEncontrada = null; mensaje = "";
      }
      break;
      
    case CANCELAR_SESION:
      activarCampoSiClic(campoCodigoSesion);
      if (botonEliminar.contieneClic(mouseX, mouseY)) {
        accionCancelarSesion();
      } else if (botonVolver.contieneClic(mouseX, mouseY)) {
        estado = MENU_SESIONES; limpiarCamposFormulario(); mensaje = "";
      }
      break;
      
    case LISTAR_SESIONES:
      if (botonVolver.contieneClic(mouseX, mouseY)) {
        estado = MENU_SESIONES; listaSesiones = null; mensaje = "";
      }
      break;
  }
}

// ================================================================
// MANEJO DE TECLADO
// ================================================================

void keyPressed() {
  // Solo se envían las teclas a los campos que realmente están
  // visibles en la pantalla actual, en vez de actualizar los diez
  // campos del sistema en cada pulsación.
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
      // Ningún campo de texto visible en este estado: no se hace nada.
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
