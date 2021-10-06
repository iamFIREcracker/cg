(ql:quickload "deploy" :silent T)
(ql:quickload "cg" :silent T)

(setf cg:*version* (let* ((system (asdf:find-system :cg nil))
                          (base-version (asdf:component-version system))
                          (git-cmd (format NIL "git rev-list ~a..HEAD --count" base-version))
                          (output (uiop:run-program git-cmd
                                                    :output :string
                                                    :ignore-error-status T))
                          (pending (parse-integer output :junk-allowed T)))
                     (if (or (not pending) (zerop pending))
                       (format NIL "~a" base-version)
                       (format NIL "~a-r~a" base-version pending))))

;; From :deploy README:
;;
;;   Alternatively, on Windows, you can build your binary with the feature
;;   flag :deploy-console present, which will force it to deploy as a console
;;   application.
(pushnew :deploy-console *features*)

(asdf:make :cg :force t)
