;;; marca-lc.el --- marca la línea donde está el cursor

;; Copyright (C) 2023 Ulpiano Tur de Vargas

;; Autor: Ulpiano Tur de Vargas <ulpiano.tur.devargas@gmail.com>
;; Creado: 29/01/2023

;; Este fichero es para usarse con GNU Emacs, pero no es parte de él.

;; Este programa es software libre; usted puede distribuirlo y/o
;; modificarlo bajo los términos de la Licencia Pública General de GNU
;; según la publicó la Fundación del Software Libre; ya sea la versión
;; 3, o (a su elección) una versión superior.

;; Este programa se distribuye con la esperanza de que sea útil, pero
;; SIN NINGUNA GARANTIA; ni siquiera la garantía implícita de
;; COMERCIABILIDAD o APTITUD PARA UN PROPÓSITO DETERMINADO. Vea la
;; Licencia Pública General de GNU para más detalles.

;; Usted debería haber recibido una copia de la Licencia Pública
;; General de GNU junto con este programa; mire el fichero LICENSE. Si
;; no, mire <https://www.gnu.org/licenses/>.

;; Comentario:

;; Este programa proporciona un modo menor de Emacs (conmutado por
;; Alt-x modo-marca-línea-cursor) que marca la línea actual donde está
;; el cursor, resaltándola con el aspecto `aspecto-marca-linea'.

;; Para usarlo desde Emacs basta con escribir lo siguiente en el
;; fichero de inicio `~/.emacs': (require 'marca-lc) (add-hook
;; 'text-mode-hook 'activa-modo-marca-línea-cursor)

(defvar var-modo-marca-línea-cursor nil
  "Variable para controlar el modo menor.")

;; Ejecutar sólo la primera vez
(defvar sobrecapa-activada nil)

;; Aspecto utilizado para marcar la línea del cursor
(defvar aspecto-marca-linea 'aspecto-marca-linea
  "Aspecto usado para marcar la línea del cursor.")

(defvar sobrecapa-marca-linea  nil
  "Sobrecapa parea marcar la línea actual.")

(make-variable-buffer-local 'var-modo-marca-línea-cursor)

(defface aspecto-marca-linea
  '((t :extend t))
  "Aspecto predeterminado para marcar la línea actua en el modo `Lc'.")

(defun crea-sobrecapa ()
  (let ((sbrcp (make-overlay (point) (point))))
    (overlay-put sbrcp 'priority -50)
    (overlay-put sbrcp 'face aspecto-marca-linea)
    sbrcp))

;;;###autoload
(defun modo-marca-línea-cursor (&optional conmuta)
  "Modo menor para resaltar la línea del cursor.
Si no se le pasan argumentos, este comando alterna el modo.
Un argumento no-nulo activa el modo.
Un argumento nulo desactiva el modo."
  (interactive "P")
  (unless (assq 'var-modo-marca-línea-cursor minor-mode-alist)
    (setq minor-mode-alist
          (cons '(var-modo-marca-línea-cursor " Lc") minor-mode-alist)))
  (setq var-modo-marca-línea-cursor
        (if (null conmuta)
            (not var-modo-marca-línea-cursor)
          (> (prefix-numeric-value conmuta) 0)))
  (if var-modo-marca-línea-cursor
      (activa-resalta-línea-cursor)
    (desactiva-resalta-línea-cursor)))

;; Comando post-enganche para resaltar la línea del cursor
(defun resalta-línea-cursor ()
  "Función para resaltar la línea del cursor."
  (if var-modo-marca-línea-cursor
      (let ((ini (line-beginning-position))
            (fin (line-beginning-position 2)))
        (delete-overlay sobrecapa-marca-linea)
        (move-overlay sobrecapa-marca-linea ini fin))))

;;;###autoload
(defun activa-resalta-línea-cursor ()
  "Activa la opción resalta-línea-cursor."
  (require 'overlay)
  ;; Ejecuta sólo la primera vez
  (unless sobrecapa-activada
    (setq sobrecapa-marca-linea (crea-sobrecapa))
    (setq sobrecapa-activada t))
  (add-hook 'post-command-hook 'resalta-línea-cursor t nil))

;;;###autoload
(defun desactiva-resalta-línea-cursor ()
  "Desactiva la opción resalta-línea-cursor."
  (remove-hook 'post-command-hook 'resalta-línea-cursor nil)
  (delete-overlay sobrecapa-marca-linea))

(defun activa-modo-marca-línea-cursor ()
  "Activa el modo menor para marcar la línea del cursor."
  (modo-marca-línea-cursor 1))

;; Desactivar dentro del 'minibúfer'
(add-hook 'minibuffer-setup-hook 'desactiva-resalta-línea-cursor t nil)
;; Volver a activar al salir del 'minibúfer'
(add-hook 'minibuffer-exit-hook 'activa-resalta-línea-cursor t nil)

(provide 'marca-lc)

;;; marca-lc.el acaba aquí