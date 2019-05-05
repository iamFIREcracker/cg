(in-package #:cg)

(defvar *extractors* NIL "A list of command extractors; the default argument to `extract'.")

(defmacro define-extractor (name (regexp-string group-list) &body body)
  `(progn
     (defun ,name (line)
       (ppcre:register-groups-bind ,group-list
           (,regexp-string line :sharedp T)
         ,@body))
     (pushnew ',name *extractors*)
     ',name))

(define-extractor git-b-git-checkout
    ("^\\*?\\s+([^ ]+)\\s+[a-f0-9]{7,9}\\s+\\w" (branch)) ;; XXX can this be compiled?
  (format NIL "git checkout '~a'" branch))

(define-extractor ports-kill
    ("^(\\w+)\\s+([0-9]+)\\s+(\\w+)\\s+(\\w+)" (command pid user fd))
  (format NIL "kill '~a' # FD ~a locked by ~a (~a)" pid fd command user))

(define-extractor psg-kill
    ("^([0-9]+)\\s+(.+)" (pid command))
  (format NIL "kill '~a' # ~a " pid command))

(define-extractor kill-kill9
    ("^kill ([0-9]+)" (pid))
  (format NIL "kill -9 '~a'" pid))

(defun extract (line &optional (extractors (reverse *extractors*)))
  (loop
    :for fn :in extractors
    :for command = (funcall fn line)
    :when command :return it))

(defun toplevel ()
  (loop
    :for line = (read-line NIL NIL :eof)
    :until (eq line :eof)
    :for command = (extract line)
    :when command :do (format T "~a~%" command)))
