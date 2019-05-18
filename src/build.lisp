;; Install/load quicklisp
#-quicklisp
(let ((quicklisp-init (merge-pathnames "quicklisp/setup.lisp"
                                       (user-homedir-pathname))))
  ;; load quicklisp -- if available -- otherwise install it
  ;; https://stackoverflow.com/questions/40903944/how-to-do-dynamic-load-load-in-common-lisp
  (if (probe-file quicklisp-init)
    (load quicklisp-init)
    (progn
      (load "vendor/quicklisp.lisp")
      (let ((qq-install (find-symbol (string '#:install) :quicklisp-quickstart)))
        (funcall qq-install)))))

(ql:quickload :deploy :silent T)

;; By adding the current directory to ql:*local-project-directories*, we can
;; QL:QUICKLOAD this without asking users to symlink this repo inside
;; ~/quicklisp/local-projects, or clone it right there in the first place.
(push #P"." ql:*local-project-directories*)
(ql:quickload :cg :silent T)

(setf cg:*version* (let* ((system (asdf:find-system :cg nil))
                          (base-version (asdf:component-version system))
                          (git-cmd (format NIL "git rev-list ~a..HEAD --count" base-version))
                          (pending (parse-integer (uiop:run-program git-cmd :output :string))))
                     (if (zerop pending)
                       (format NIL "~a" base-version)
                       (format NIL "~a-r~a" base-version pending))))

(setf deploy:*status-output* nil)

(let ((deploy:*status-output* t))
  (asdf:make :cg :force t))
