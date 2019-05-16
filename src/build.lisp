(ql:quickload :deploy :silent T)

;; By adding the current directory to ql:*local-project-directories*, we can
;; QL:QUICKLOAD this without asking users to symlink this repo inside
;; ~/quicklisp/local-projects, or clone it right there in the first place.
(push #P"." ql:*local-project-directories*)
(ql:quickload :cg :silent T)

(setf deploy:*status-output* nil)

(let ((deploy:*status-output* t))
  (asdf:make :cg :force t))
