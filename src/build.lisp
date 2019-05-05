(ql:quickload :cg :silent t)

(setf deploy:*status-output* nil)

(let ((deploy:*status-output* t))
  (asdf:make :cg :force t))
