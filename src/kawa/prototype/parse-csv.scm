(require alias "alias.scm")
(require 'regex)

(provide 'parse-csv)

(define (parse-csv csv-stream ::BufferedReader)
  (let ((collector '()))
    (do ((line (*:read-line csv-stream) (*:read-line csv-stream)))
	((equal? line #!null) (reverse collector))
      (set! collector (cons (regex-split "," line) collector)))))
