(ql:quickload :cx :silent t)

(setf deploy:*status-output* nil)

(let ((deploy:*status-output* t))
  (asdf:make :cx :force t))
