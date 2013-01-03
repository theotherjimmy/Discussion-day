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
   (*:set-text (as TextView ((this):find-view-by-id R$id:discussionViewName))
	       (id->discussion-date ((this):get-db) discussion-num))
   (*:set-adapter (as ListView ((this):find-view-by-id R$id:listStudents))
		  (SimpleCursorAdapter
		   (this) R$layout:stat_row_discussion
		   (stats-list ((this):get-db) 'name 'discussion discussion-num 'student)
		   (String[] (mk-sql 'name) (mk-sql 'correct) 
			  (mk-sql 'incorrect ) (mk-sql 'pass ))
		   (int[] R$id:disName R$id:disCorrect R$id:disIncorrect R$id:disPass))))) 


(define-simple-class student-view (base-activity)
  (student-num ::long)

  ((onCreate (saved-instance-state ::Bundle))
   (invoke-special base-activity (this) 'onCreate saved-instance-state)
   (invoke-special Activity (this) 'setContentView R$layout:discussion_view)
   (set! student-num (*:get-long-extra (*:get-intent (this)) (mk-extra student-view 'student) -1))
   (*:set-text (as TextView ((this):find-view-by-id R$id:discussionViewName))
	       (id->student-name ((this):get-db) student-num))
   (*:set-adapter (as ListView ((this):find-view-by-id R$id:listStudents))
		  (SimpleCursorAdapter
		   (this) R$layout:stat_row_discussion
		   (stats-list ((this):get-db) 'date 'student student-num 'discussion)
		   (String[] (mk-sql 'name) (mk-sql 'correct) 
			  (mk-sql 'incorrect ) (mk-sql 'pass ))
		   (int[] R$id:disName R$id:disCorrect R$id:disIncorrect R$id:disPass))))) 
