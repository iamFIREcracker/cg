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

(define-generator git-b-git-checkout
    ("^\\*?\\s+([^ ]+)\\s+([a-f0-9]{7,9})\\s(.*)" (branch commit rest))
  (format NIL "git checkout '~a' # ~a -> ~a" branch commit rest))

(define-generator ports-kill
    ("^(\\w+)\\s+([0-9]+)\\s+(\\w+)\\s+(\\w+)" (command pid user fd))
  (format NIL "kill '~a' # FD ~a locked by ~a (~a)" pid fd command user))

(define-generator psg-kill
    ("^([0-9]+)\\s+(.+)" (pid command))
  (format NIL "kill '~a' # ~a " pid command))

(define-generator kill-kill9
    ("kill ([0-9]+)" (pid))
  (format NIL "kill -9 '~a'" pid))

(define-generator br
    ;; https://gist.github.com/gruber/249502
    ("((?i)\\b((?:[a-z][\\w-]+:(?:/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’])))"
     (url))
  (format NIL "br '~a' " url))

(defun generate (line &optional (generators (reverse *generators*)))
  (loop
    :for fn :in generators
    :for command = (funcall fn line)
    :when command :return it))

(defun toplevel ()
  (loop
    :for line = (read-line NIL NIL :eof)
    :until (eq line :eof)
    :for command = (generate line)
    :when command :do (format T "~a~%" command)))
