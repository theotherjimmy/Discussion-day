(require alias "alias.scm")
(require database-utils "database-utils.scm")
(require 'regex)

(provide 'parse-csv)

(define (parse-csv csv-stream ::BufferedReader)
  (let ((collector '()))
    (do ((line (*:read-line csv-stream) (*:read-line csv-stream)))
	((equal? line #!null) (reverse collector))
      (set! collector (cons (regex-split "," line) collector)))))

(define (null->zero int)
  (if (equal? #!null int)
      0
      int))

(define (export-csv cursor ::SQLCursor stream ::BufferedWriter Title ::String)
  (let ((indexes (map cursor:get-column-index
		      (map mk-sql '(name correct incorrect pass)))))
    (*:write stream Title)
    (*:write stream ", Correct , Incorrect , Pass")
    (*:new-line stream)
    (*:move-to-first cursor)
    (let loop ()
      (unless (*:is-after-last cursor)
	      (Log:d "export" (mk-sql (cursor:get-string (car indexes))
					     " , "
					     (null->zero (cursor:get-int (cadr indexes)))
					     " , "
					     (null->zero (cursor:get-int (caddr indexes)))
					     " , "
					     (null->zero (cursor:get-int (cadddr indexes)))))
	      (*:write stream (mk-sql (cursor:get-string (car indexes))
					     " , "
					     (null->zero (cursor:get-int (cadr indexes)))
					     " , "
					     (null->zero (cursor:get-int (caddr indexes)))
					     " , "
					     (null->zero (cursor:get-int (cadddr indexes)))))
	      (*:new-line stream)
	      (*:move-to-next cursor)
	      (loop)))))
  
