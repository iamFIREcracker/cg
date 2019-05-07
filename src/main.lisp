(in-package #:cg)

(defvar *guessers* NIL "A list of command guessers; the default argument to `guess'.")

(defmacro define-guesser (name (regexp group-list) &body body)
  `(let ((scanner (ppcre:create-scanner ,regexp :case-insensitive-mode t)))
     (defun ,name (line)
       (ppcre:register-groups-bind ,group-list
         (scanner line :sharedp T)
         ,@body))
     (pushnew ',name *guessers*)
     ',name))

(defun guess (line &optional (guessers (reverse *guessers*)))
  (loop
    :for fn :in guessers
    :for command = (funcall fn line)
    :when command :return it))

(defun load-rc ()
  (load "~/.cgrc"))

(defun toplevel ()
  (loop
    :initially (load-rc)
    :for line = (read-line NIL NIL :eof)
    :until (eq line :eof)
    :for command = (guess line)
    :when command :do (format T "~a~%" command)))
