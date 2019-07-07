(in-package #:cg)

(defvar *version* NIL "Application version")
(defvar *guessers* NIL "A list of command guessers; the default argument to `guess'.")

(defmacro define-guesser (name (regexp group-list) &body body)
  `(let ((scanner (ppcre:create-scanner ,regexp :case-insensitive-mode t)))
     (defun ,name (line)
       (ppcre:register-groups-bind ,group-list
         (scanner line :sharedp T)
         ,@body))
     (pushnew ',name *guessers*)
     ',name))

(defun load-rc (&key (debug NIL))
  (setf *guessers* NIL)
  (load "~/.cgrc" :print debug))

(opts:define-opts
  (:name :help
         :description "print the help text and exit"
         :short #\h
         :long "help")
  (:name :version
         :description "print the version and exit"
         :short #\v
         :long "version")
  (:name :debug
         :description "parse the RC file and exit"
         :short #\d
         :long "debug"))

(defun parse-opts ()
  (multiple-value-bind (options)
    (handler-case
        (opts:get-opts)
      (opts:unknown-option (condition)
        (format t "~s option is unknown!~%" (opts:option condition))
        (opts:exit 1)))
    (if (getf options :help)
      (progn
        (opts:describe
          :prefix "Guess commands to run from stdin, and print them to stdout."
          :args "[keywords]")
        (opts:exit)))
    (if (getf options :version)
      (progn
        (format T "~a~%" *version*)
        (opts:exit)))
    (if (getf options :debug)
      (progn
        (load-rc :debug T)
        (opts:exit)))))

(defun guess (line &optional (guessers (reverse *guessers*)))
  (loop
    :for fn :in guessers
    :for command = (funcall fn line)
    :unless command
    :when (stringp command) :collect command
    :when (consp command) :append command))

(defun process-input ()
  (loop
    :with seen = (make-hash-table :test 'equal)
    :for line = (read-line NIL NIL :eof)
    :until (eq line :eof)
    :do (loop
          :for command :in (guess line)
          :when (and command (not (gethash command seen)))
          :do (progn
                (setf (gethash command seen) T)
                (format T "~a~%" command)))))

(defun toplevel ()
  (parse-opts)
  (load-rc)
  (process-input))
