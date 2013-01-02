(require alias "alias.scm")
(require base "base.scm")
(require database-utils "database-utils.scm")
(require utils "utils.scm")

(provide 'discussion-view)

(define-simple-class discussion-view (base-activity)
  (discussion-num ::long)

  ((onCreate (saved-instance-state ::Bundle))
   (invoke-special base-activity (this) 'onCreate saved-instance-state)
   (invoke-special Activity (this) 'setContentView R$layout:discussion_view)
   (set! discussion-num (*:get-long-extra (*:get-intent (this)) (mk-extra discussion-view 'discussion) -1))
   (*:set-adapter (as ListView ((this):find-view-by-id R$id:listStudents))
		  (SimpleCursorAdapter
		   (this) R$layout:stat_row_discussion
		   (stats-list ((this):get-db) 'name 'discussion discussion-num 'student)
		   (String[] (mk-sql 'name) (mk-sql 'correct) 
			  (mk-sql 'incorrect ) (mk-sql 'pass ))
		   (int[] R$id:disName R$id:disCorrect R$id:disIncorrect R$id:disPass))))) 
