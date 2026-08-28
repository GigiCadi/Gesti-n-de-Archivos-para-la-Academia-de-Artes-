// ============================================================
// Componentes de interfaz gráfica reutilizables (sin librerías
// externas): botones clickeables y campos de texto editables.
// ============================================================

class Boton {
  float x, y, w, h;
  String etiqueta;

  Boton(float x, float y, float w, float h, String etiqueta) {
    this.x = x; this.y = y; this.w = w; this.h = h;
    this.etiqueta = etiqueta;
  }

  boolean contieneClic(float mx, float my) {
    return mx >= x && mx <= x + w && my >= y && my <= y + h;
  }

  void dibujar() {
    boolean sobre = contieneClic(mouseX, mouseY);
    fill(sobre ? color(70, 130, 200) : color(90, 90, 110));
    noStroke();
    rect(x, y, w, h, 8);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(15);
    text(etiqueta, x + w / 2, y + h / 2);
  }
}

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
      // Límite razonable para no desbordar el campo fijo del archivo
      if (contenido.length() < 39) {
        contenido += tecla;
      }
    }
  }

  void dibujar() {
    fill(30);
    textAlign(LEFT, BOTTOM);
    textSize(13);
    text(etiqueta, x, y - 6);

    stroke(activo ? color(70, 130, 200) : color(180));
    strokeWeight(activo ? 2 : 1);
    fill(255);
    rect(x, y, w, h, 4);

    noStroke();
    fill(20);
    textAlign(LEFT, CENTER);
    textSize(15);
    text(contenido, x + 8, y + h / 2);
  }

  void limpiar() {
    contenido = "";
  }
}
