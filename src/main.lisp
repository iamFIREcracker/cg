(in-package #:cg)

(defvar *generators* NIL "A list of command generators; the default argument to `generate'.")

(defmacro define-generator (name (regexp group-list) &body body)
  `(let ((scanner (ppcre:create-scanner ,regexp :case-insensitive-mode t)))
     (defun ,name (line)
       (ppcre:register-groups-bind ,group-list
         (scanner line :sharedp T)
         ,@body))
     (pushnew ',name *generators*)
     ',name))

(defun generate (line &optional (generators (reverse *generators*)))
  (loop
    :for fn :in generators
    :for command = (funcall fn line)
    :when command :return it))

(defun load-rc ()
  (load "~/.cgrc"))

(defun toplevel ()
  (loop
    :initially (load-rc)
    :for line = (read-line NIL NIL :eof)
    :until (eq line :eof)
    :for command = (generate line)
    :when command :do (format T "~a~%" command)))
