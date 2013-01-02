
(require alias "alias.scm")
(require database-utils "database-utils.scm")

(provide 'base)
(module-export prototype-app
	       base-activity)

(define-simple-class prototype-app (Application)
  (db ::student-data)
  ((onCreate)
   (invoke-special Application (this) 'onCreate)
   (set! db (make student-data (this))))
  ((get-db) ::student-data
   db))

(define-simple-class base-activity (ActivityGroup)
  (app ::prototype-app access: public)
  ((get-db) ::student-data
   (app:get-db))
  ((onCreate (saved-instance-state ::Bundle))
   (invoke-special ActivityGroup (this) 'onCreate saved-instance-state)
   (set! app (as prototype-app (getApplication))))
  ((onResume)
   (invoke-special ActivityGroup (this) 'onResume)))
