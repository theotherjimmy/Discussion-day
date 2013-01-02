(provide 'utils)

(define nil '())

(define (mk-extra class symbol)
  "concatinate destonation class and symbol as required by put-extra"
  (*:to-string (string-append (*:to-string class) "." (*:to-string symbol))))

(define (array-reduce func array ::Object[] #!optional (seed nil))
  (letrec ((loop (lambda (pos acc)
		   (if (>= pos array:length)
		       acc
		       (loop (+ 1 pos) (func acc (array pos)))))))
    (loop 0 seed))) 


;; This will never work, as the autoboxing of argumnents causes the put-extra function with second argument java.lang.Boolean to be called _all_ the time.
;;(define (mk-intent me ::android.content.Context target ::java.lang.Class . extra-list)
;;  (letrec ((add-extras
;;	    (lambda (intent ::Intent remaining-extras)
;;	      (try-catch
;;	       (add-extras (apply *:put-extra
;;				  (list intent
;;					(mk-extra target (car remaining-extras))
;;					(as (cadr remaining-extras) 
;;					    (caddr remaining-extras))))
;;			   (cdddr remaining-extras))
;;	       (e java.lang.Exception
;;		  intent)))))
;;    (add-extras (Intent me target) extra-list)))

