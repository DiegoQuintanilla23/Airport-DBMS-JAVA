
package Aeropuerto;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;

/**
 * Clase que implementa la interfaz KeyListener para restringir ciertos caracteres
 * en un componente de la interfaz gráfica de usuario (GUI).
 */
public class restrictChar implements KeyListener {

    /**
     * Este método se llama cuando se ha detectado una tecla presionada en el componente.
     * Se consume el evento si el carácter es '-', '(', ')' o '.' para evitar que se ingrese.
     *
     * @param e Evento de tecla que contiene información sobre la tecla presionada.
     */
    @Override
    public void keyTyped(KeyEvent e) {
        char c = e.getKeyChar();
        if (c == '-' || c == '(' || c == ')' || c == '.') {
            e.consume();
        }
    }

    /**
     * Este método se llama cuando una tecla ha sido presionada y aún no ha sido liberada.
     * No se necesita implementación en este contexto.
     *
     * @param e Evento de tecla que contiene información sobre la tecla presionada.
     */
    @Override
    public void keyPressed(KeyEvent e) {
        // No necesitamos implementar este método, pero debe estar presente
    }

    /**
     * Este método se llama cuando una tecla ha sido liberada.
     * No se necesita implementación en este contexto.
     *
     * @param e Evento de tecla que contiene información sobre la tecla liberada.
     */
    @Override
    public void keyReleased(KeyEvent e) {
        // No necesitamos implementar este método, pero debe estar presente
    }
}
