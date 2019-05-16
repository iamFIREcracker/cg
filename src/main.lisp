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

(opts:define-opts
  (:name :help
         :description "print this help text and exit"
         :short #\h
         :long "help")
  (:name :version
         :description "print the version and exit"
         :short #\v
         :long "version"))

(defun parse-opts ()
  (multiple-value-bind (options)
      (opts:get-opts)
    (if (getf options :help)
      (progn
        (opts:describe
          :prefix "Usage:"
          :args "[keywords]")
        (opts:exit)))
    (if (getf options :version)
      (let* ((system (asdf:find-system :cg nil))
             (version (asdf:component-version system)))
        (format T "~a~%" version)
        (opts:exit)))))

(defun load-rc ()
  (load "~/.cgrc"))

(defun guess (line &optional (guessers (reverse *guessers*)))
  (loop
    :for fn :in guessers
    :for command = (funcall fn line)
    :when command :return it))

(defun toplevel ()
  (loop
    :initially (parse-opts)
    :initially (load-rc)
    :for line = (read-line NIL NIL :eof)
    :until (eq line :eof)
    :for command = (guess line)
    :when command :do (format T "~a~%" command)))
