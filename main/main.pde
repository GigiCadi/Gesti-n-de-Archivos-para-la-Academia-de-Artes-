// ================================================================
// LABORATORIO 1 - Manejo de Archivos en Java (Processing)
// Academia de Artes Barranquilla - Módulo de Instructores
//
// Este sketch implementa el CRUD de instructores usando un
// ARCHIVO INDEXADO (ver ArchivoInstructores.pde) y una interfaz
// gráfica simple construida a mano (ver UI.pde).
// ================================================================

import java.io.RandomAccessFile;
import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.ArrayList;

// ---- Estados de la aplicación (máquina de estados simple) ----
final int MENU_PRINCIPAL       = 0;
final int MENU_INSTRUCTORES    = 1;
final int CREAR_INSTRUCTOR     = 2;
final int CONSULTAR_INSTRUCTOR = 3;
final int ACTUALIZAR_INSTRUCTOR= 4;
final int ELIMINAR_INSTRUCTOR  = 5;
final int LISTAR_INSTRUCTORES  = 6;

int estado = MENU_PRINCIPAL;

// ---- Acceso a datos ----
ArchivoInstructores archivoInstructores;

// ---- Botones por pantalla ----
ArrayList<Boton> botonesMenuPrincipal;
ArrayList<Boton> botonesMenuInstructores;
Boton botonGuardar, botonBuscar, botonEliminar, botonVolver, botonCancelar;

// ---- Formulario reutilizado por Crear / Consultar / Actualizar / Eliminar ----
CampoTexto campoCedula, campoNombre, campoEspecialidad, campoTelefono;
ArrayList<CampoTexto> camposActivosEnPantalla; // cuáles campos se muestran según el estado

// ---- Feedback visual ----
String mensaje = "";
color colorMensaje = color(0);

// ---- Resultados para mostrar en pantalla ----
Instructor instructorEncontrado = null;
ArrayList<Instructor> listaParaMostrar = null;

void setup() {
  size(820, 600);

  archivoInstructores = new ArchivoInstructores("data/instructores.dat");
  if (!archivoInstructores.abrir()) {
    mensaje = "No se pudo abrir el archivo de instructores.";
    colorMensaje = color(200, 40, 40);
  }

  // ---- Menú principal ----
  botonesMenuPrincipal = new ArrayList<Boton>();
  botonesMenuPrincipal.add(new Boton(300, 220, 220, 50, "Instructores"));
  botonesMenuPrincipal.add(new Boton(300, 290, 220, 50, "Aprendices"));
  botonesMenuPrincipal.add(new Boton(300, 360, 220, 50, "Sesiones"));

  // ---- Menú de instructores ----
  botonesMenuInstructores = new ArrayList<Boton>();
  botonesMenuInstructores.add(new Boton(280, 140, 260, 45, "Crear instructor"));
  botonesMenuInstructores.add(new Boton(280, 195, 260, 45, "Consultar instructor"));
  botonesMenuInstructores.add(new Boton(280, 250, 260, 45, "Actualizar instructor"));
  botonesMenuInstructores.add(new Boton(280, 305, 260, 45, "Eliminar instructor"));
  botonesMenuInstructores.add(new Boton(280, 360, 260, 45, "Listar instructores"));
  botonesMenuInstructores.add(new Boton(280, 415, 260, 45, "Reiniciar sesiones del mes"));
  botonesMenuInstructores.add(new Boton(280, 490, 260, 40, "Volver"));

  // ---- Campos de formulario (se reutilizan según la pantalla) ----
  campoCedula       = new CampoTexto(300, 190, 300, 36, "Cédula");
  campoNombre       = new CampoTexto(300, 260, 300, 36, "Nombre");
  campoEspecialidad = new CampoTexto(300, 330, 300, 36, "Especialidad");
  campoTelefono     = new CampoTexto(300, 400, 300, 36, "Teléfono");

  botonGuardar  = new Boton(300, 460, 140, 42, "Guardar");
  botonBuscar   = new Boton(300, 250, 140, 42, "Buscar");
  botonEliminar = new Boton(300, 250, 140, 42, "Eliminar");
  botonCancelar = new Boton(460, 460, 140, 42, "Cancelar");
  botonVolver   = new Boton(30, 530, 120, 40, "Volver");
}

void draw() {
  background(245);

  switch (estado) {
    case MENU_PRINCIPAL:        dibujarMenuPrincipal(); break;
    case MENU_INSTRUCTORES:     dibujarMenuInstructores(); break;
    case CREAR_INSTRUCTOR:      dibujarFormularioCrear(); break;
    case CONSULTAR_INSTRUCTOR:  dibujarFormularioConsultar(); break;
    case ACTUALIZAR_INSTRUCTOR: dibujarFormularioActualizar(); break;
    case ELIMINAR_INSTRUCTOR:   dibujarFormularioEliminar(); break;
    case LISTAR_INSTRUCTORES:   dibujarListado(); break;
  }

  dibujarMensaje();
}

// ================================================================
// PANTALLA: Menú principal
// ================================================================
void dibujarMenuPrincipal() {
  dibujarEncabezado("Academia de Artes Barranquilla");
  for (Boton b : botonesMenuPrincipal) b.dibujar();
}

// ================================================================
// PANTALLA: Menú de instructores
// ================================================================
void dibujarMenuInstructores() {
  dibujarEncabezado("Gestión de Instructores");
  for (Boton b : botonesMenuInstructores) b.dibujar();
}

// ================================================================
// PANTALLA: Crear instructor
// ================================================================
void dibujarFormularioCrear() {
  dibujarEncabezado("Crear instructor");
  campoCedula.dibujar();
  campoNombre.dibujar();
  campoEspecialidad.dibujar();
  campoTelefono.dibujar();
  botonGuardar.dibujar();
  botonCancelar.dibujar();
  botonVolver.dibujar();
}

void accionGuardarCrear() {
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

// ================================================================
// PANTALLA: Consultar instructor
// ================================================================
void dibujarFormularioConsultar() {
  dibujarEncabezado("Consultar instructor");
  campoCedula.x = 300; campoCedula.y = 190;
  campoCedula.dibujar();
  botonBuscar.dibujar();
  botonVolver.dibujar();

  if (instructorEncontrado != null) {
    fill(20);
    textAlign(LEFT, TOP);
    textSize(16);
    text(instructorEncontrado.toStringResumido(), 300, 280);
    text(instructorEncontrado.estaDisponible() ? "Disponible este mes" : "SIN cupo este mes",
         300, 310);
  }
}

void accionBuscarConsultar() {
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

// ================================================================
// PANTALLA: Actualizar instructor
// ================================================================
void dibujarFormularioActualizar() {
  dibujarEncabezado("Actualizar instructor");
  campoCedula.x = 300; campoCedula.y = 150;
  campoCedula.dibujar();
  botonBuscar.x = 620; botonBuscar.y = 145;
  botonBuscar.w = 100; botonBuscar.h = 40;
  botonBuscar.dibujar();

  campoNombre.y = 230;
  campoEspecialidad.y = 300;
  campoTelefono.y = 370;
  campoNombre.dibujar();
  campoEspecialidad.dibujar();
  campoTelefono.dibujar();

  botonGuardar.y = 430;
  botonGuardar.dibujar();
  botonVolver.dibujar();
}

void accionBuscarParaActualizar() {
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

void accionGuardarActualizar() {
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

// ================================================================
// PANTALLA: Eliminar instructor
// ================================================================
void dibujarFormularioEliminar() {
  dibujarEncabezado("Eliminar instructor");
  campoCedula.x = 300; campoCedula.y = 190;
  campoCedula.dibujar();
  botonEliminar.dibujar();
  botonVolver.dibujar();
}

void accionEliminar() {
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
// PANTALLA: Listado de instructores
// ================================================================
void dibujarListado() {
  dibujarEncabezado("Instructores registrados");
  botonVolver.dibujar();

  if (listaParaMostrar == null) return;

  fill(20);
  textAlign(LEFT, TOP);
  textSize(15);
  float y = 140;
  if (listaParaMostrar.isEmpty()) {
    text("No hay instructores registrados.", 60, y);
  }
  for (Instructor inst : listaParaMostrar) {
    text(inst.toStringResumido(), 60, y);
    y += 28;
  }
}

// ================================================================
// Utilidades de UI compartidas
// ================================================================
void dibujarEncabezado(String titulo) {
  fill(30);
  textAlign(CENTER, TOP);
  textSize(26);
  text(titulo, width / 2, 40);
}

void mostrarMensaje(String texto, boolean esError) {
  mensaje = texto;
  colorMensaje = esError ? color(200, 40, 40) : color(30, 140, 60);
}

void dibujarMensaje() {
  if (mensaje.isEmpty()) return;
  fill(colorMensaje);
  textAlign(CENTER, TOP);
  textSize(14);
  text(mensaje, width / 2, height - 40);
}

void limpiarCamposFormulario() {
  campoCedula.limpiar();
  campoNombre.limpiar();
  campoEspecialidad.limpiar();
  campoTelefono.limpiar();
}

void irAMenuInstructores() {
  estado = MENU_INSTRUCTORES;
  mensaje = "";
  limpiarCamposFormulario();
  instructorEncontrado = null;
  listaParaMostrar = null;
}

boolean validarCedula(String cedula) {
  if (cedula.length() < 6 || cedula.length() > 15) return false;
  for (int i = 0; i < cedula.length(); i++) {
    if (!Character.isDigit(cedula.charAt(i))) return false;
  }
  return true;
}

// ================================================================
// Manejo de mouse
// ================================================================
void mousePressed() {
  switch (estado) {

    case MENU_PRINCIPAL:
      if (botonesMenuPrincipal.get(0).contieneClic(mouseX, mouseY)) {
        estado = MENU_INSTRUCTORES;
      }
      // Los otros botones (Aprendices, Sesiones) se conectan en próximas entregas.
      break;

    case MENU_INSTRUCTORES:
      if (botonesMenuInstructores.get(0).contieneClic(mouseX, mouseY)) { estado = CREAR_INSTRUCTOR; limpiarCamposFormulario(); mensaje=""; }
      else if (botonesMenuInstructores.get(1).contieneClic(mouseX, mouseY)) { estado = CONSULTAR_INSTRUCTOR; limpiarCamposFormulario(); instructorEncontrado=null; mensaje=""; }
      else if (botonesMenuInstructores.get(2).contieneClic(mouseX, mouseY)) { estado = ACTUALIZAR_INSTRUCTOR; limpiarCamposFormulario(); mensaje=""; }
      else if (botonesMenuInstructores.get(3).contieneClic(mouseX, mouseY)) { estado = ELIMINAR_INSTRUCTOR; limpiarCamposFormulario(); mensaje=""; }
      else if (botonesMenuInstructores.get(4).contieneClic(mouseX, mouseY)) { listaParaMostrar = archivoInstructores.listarTodos(); estado = LISTAR_INSTRUCTORES; }
      else if (botonesMenuInstructores.get(5).contieneClic(mouseX, mouseY)) {
        if (archivoInstructores.reiniciarSesiones()) mostrarMensaje("Sesiones reiniciadas para todos los instructores.", false);
        else mostrarMensaje("No se pudieron reiniciar las sesiones.", true);
      }
      else if (botonesMenuInstructores.get(6).contieneClic(mouseX, mouseY)) { estado = MENU_PRINCIPAL; mensaje=""; }
      break;

    case CREAR_INSTRUCTOR:
      activarCampoSiClic(campoCedula); activarCampoSiClic(campoNombre);
      activarCampoSiClic(campoEspecialidad); activarCampoSiClic(campoTelefono);
      if (botonGuardar.contieneClic(mouseX, mouseY)) accionGuardarCrear();
      else if (botonCancelar.contieneClic(mouseX, mouseY)) irAMenuInstructores();
      else if (botonVolver.contieneClic(mouseX, mouseY)) irAMenuInstructores();
      break;

    case CONSULTAR_INSTRUCTOR:
      activarCampoSiClic(campoCedula);
      if (botonBuscar.contieneClic(mouseX, mouseY)) accionBuscarConsultar();
      else if (botonVolver.contieneClic(mouseX, mouseY)) irAMenuInstructores();
      break;

    case ACTUALIZAR_INSTRUCTOR:
      activarCampoSiClic(campoCedula); activarCampoSiClic(campoNombre);
      activarCampoSiClic(campoEspecialidad); activarCampoSiClic(campoTelefono);
      if (botonBuscar.contieneClic(mouseX, mouseY)) accionBuscarParaActualizar();
      else if (botonGuardar.contieneClic(mouseX, mouseY)) accionGuardarActualizar();
      else if (botonVolver.contieneClic(mouseX, mouseY)) irAMenuInstructores();
      break;

    case ELIMINAR_INSTRUCTOR:
      activarCampoSiClic(campoCedula);
      if (botonEliminar.contieneClic(mouseX, mouseY)) accionEliminar();
      else if (botonVolver.contieneClic(mouseX, mouseY)) irAMenuInstructores();
      break;

    case LISTAR_INSTRUCTORES:
      if (botonVolver.contieneClic(mouseX, mouseY)) irAMenuInstructores();
      break;
  }
}

void activarCampoSiClic(CampoTexto campo) {
  if (campo.contieneClic(mouseX, mouseY)) {
    campoCedula.activo = (campo == campoCedula);
    campoNombre.activo = (campo == campoNombre);
    campoEspecialidad.activo = (campo == campoEspecialidad);
    campoTelefono.activo = (campo == campoTelefono);
  }
}

// ================================================================
// Manejo de teclado (escribir en el campo activo)
// ================================================================
void keyPressed() {
  campoCedula.manejarTecla(key, keyCode);
  campoNombre.manejarTecla(key, keyCode);
  campoEspecialidad.manejarTecla(key, keyCode);
  campoTelefono.manejarTecla(key, keyCode);
}

// Al cerrar la aplicación, liberar el archivo correctamente.
public void exit() {
  archivoInstructores.cerrar();
  super.exit();
}
