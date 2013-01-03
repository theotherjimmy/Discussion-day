
(require alias "alias.scm")
(require base "base.scm")
(require database-utils "database-utils.scm")
(require utils "utils.scm")
(require record-questions "record-questions.scm")
(require discussion-view "discussion-view.scm")
(require parse-csv "parse-csv.scm")

(provide 'class-view)

(define-simple-class class-view (base-activity)
  (class-num ::int)
  
  ((onCreateOptionsMenu (menu ::Menu))
   ((getMenuInflater):inflate R$menu:class_view menu)
   #t)

  ((onOptionsItemSelected (item ::MenuItem)) 
   (Log:d "Prototype" "menu item touched, that tickles!")
   (Log:d "Prototype" (*:get-item-id item))
   (Log:d "Prototype" R$id:createStudent)
   (Log:d "Prototype" R$id:MenuImport)
   (let ((id (*:get-item-id item)))
     (cond 
      ((= R$id:createStudent id) 
       (let ((name (EditText (this) hint: "Name"))
	     (eid  (EditText (this) hint: "EID")))
	 (*:show
	  (*:set-negative-button
	   (*:set-positive-button
	    (make <android.app.AlertDialog$Builder>
	      (this)
	      title: "Add Student"
	      view: (LinearLayout (this)
				  orientation: LinearLayout:VERTICAL
				  view: name
				  view: eid))
	    "Add Student"
	    (lambda (dialog ::Dialog button)
	      (*:dismiss dialog)
	      (add-student ((this):get-db) (*:get-text name) (*:get-text eid) class-num)
	      (onResume)))
	   "Cancel"
	   (lambda (dialog ::Dialog button)
	     (*:cancel dialog))))))
      ((= R$id:MenuImport id) 
       (let ((filename (EditText (this) hint: "File Name")))
	 (*:show
	  (*:set-negative-button
	   (*:set-positive-button
	    (make <android.app.AlertDialog$Builder>
	      (this)
	      title: "Import from CSV File"
	      view: filename)
	    "Add Students"
	    (lambda (dialog ::Dialog button)
	      (*:dismiss dialog)
	      (try-catch (map (lambda (row)
				(try-catch
				 (add-student ((this):get-db) (car row) (cadr row) class-num)
				 (e java.lang.ClassCastException
				    nil)))
			      (parse-csv (BufferedReader (FileReader (File (*:get-text filename))))))
			 (e java.io.FileNotFoundException
			    ((Toast:make-text
			      (this) "Could Not Import: File Not Found!"
			      Toast:LENGTH_SHORT):show)))
	      (onResume)))
	   "Cancel"
	   (lambda (dialog ::Dialog button)
	     (*:cancel dialog))))))))
   #t)

  ((onCreate (saved-instance-state ::Bundle))
   (invoke-special base-activity (this) 'onCreate saved-instance-state)
   (invoke-special Activity (this) 'setContentView R$layout:class_view)
   (when (let ((params (((this):get-window):get-attributes)))
	   (> params:width params:height))
	 ((as LinearLayout ((this):find-view-by-id R$id:classViewLayout)):set-orientation
	  LinearLayout:HORIZONTAL))
   (when ((getIntent):has-extra (mk-extra class-view 'class))
	 (set! class-num ((getIntent):get-int-extra
			  (mk-extra class-view 'class) 0)))
   (when (= (*:get-count (students ((this):get-db) class-num)) 0)
	 ((Toast:make-text (this) "You should start by adding students to this class. You can do that by touching the menu button" Toast:LENGTH_SHORT):show))
   ((as TextView ((this):find-view-by-id R$id:className)):set-text
    (id->class-name ((this):get-db) class-num))
   (((this):find-view-by-id R$id:classViewStartDiscussion):set-on-click-listener
    (lambda (v)
      (if (> (*:get-count (students ((this):get-db) class-num)) 0)
	    (startActivity
	     ((make <android.content.Intent> (as Context (this)) record-question):put-extra
	      (mk-extra record-question 'class) class-num))
	    ((Toast:make-text (this) "Please add a few students before starting a discussion. Students may be added by touching the menu button" Toast:LENGTH_LONG):show))))
   (let ((tabhost ::TabHost (as TabHost (Activity:find-view-by-id (this) R$id:classViewTabs))))
     (tabhost:setup (getLocalActivityManager))
     (tabhost:add-tab (*:set-content
		       (*:set-indicator (tabhost:new-tab-spec "students") "Students")
		       ((make <android.content.Intent> (as Context (this)) tab-students):put-extra
			(mk-extra tab-students 'class) class-num))) 
     (tabhost:add-tab (*:set-content
		       (*:set-indicator (tabhost:new-tab-spec "discussions") "Discussions")
		       ((make <android.content.Intent> (as Context (this)) tab-discussions):put-extra
			(mk-extra tab-discussions 'class) class-num)))))

  ((onResume)
   (invoke-special base-activity (this) 'onResume)
   
   ((as ListView ((this):find-view-by-id R$id:classViewStats)):set-adapter
    (SimpleCursorAdapter
     (this) R$layout:stat_row (stats ((this):get-db) 'class class-num)
     (String[] (mk-sql "SUM(" 'correct ")") (mk-sql "SUM(" 'incorrect ")") (mk-sql "SUM(" 'pass ")"))
     (int[] R$id:rowCorrectStat R$id:rowIncorrectStat R$id:rowPassStat)))))


(define-simple-class tab-students (base-activity)
  (class-num ::int)

  ((onResume)
   (invoke-special base-activity (this) 'onResume)
   ((as ListView ((this):find-view-by-id R$id:tabStudents)):set-adapter
    (SimpleCursorAdapter
     (this) R$layout:stat_row_discussion (stats-list ((this):get-db) 'name 'class class-num 'student)
     (String[] (mk-sql 'name) (mk-sql 'correct) (mk-sql 'incorrect) (mk-sql 'pass))
     (int[] R$id:disName R$id:disCorrect R$id:disIncorrect R$id:disPass))))
   
  ((onCreate (saved-instance-state ::Bundle))
   (invoke-special base-activity (this) 'onCreate saved-instance-state)
   (invoke-special Activity (this) 'setContentView R$layout:tab_students)
   (when ((getIntent):has-extra (mk-extra tab-students 'class))
	 (set! class-num ((getIntent):get-int-extra
			  (mk-extra tab-students 'class) 0)))
    (let  ((cursor (students ((this):get-db) class-num)))
      (startManagingCursor cursor)
      (Log:d "prototype" (cursor:get-count))
      ((as ListView ((this):find-view-by-id R$id:tabStudents)):set-on-item-click-listener
       (lambda (parent view pos id ::long)
	 (*:show
	  (make <android.app.AlertDialog$Builder>
	    (this)
	    title: (id->student-name ((this):get-db) id)
	    view: (LinearLayout (this)
				orientation: LinearLayout:VERTICAL
				view: (Button (this)
					      on-click-listener:
					      (lambda (view)
						(startActivity
						 ((make <android.content.Intent> (as Context (this))
							student-view):put-extra
							(mk-extra student-view 'student) id)))
					      text: "View Student Participation in all Discussions")
				view: (Button (this)
					      on-click-listener:
					      (lambda (view)
						(*:show
						 (*:set-negative-button
						  (*:set-positive-button
						   (make <android.app.AlertDialog$Builder>
						     (this)
						     title: (id->student-name ((this):get-db) id)
						     view: (TextView
							    (this)
							    text: "would you like to permanently remove this student?"))
						   "yes"
						   (lambda (dialog ::Dialog button)
						     (*:dismiss dialog)
						     (delete-student ((this):get-db) id)))
						  "cancel"
						  (lambda (dialog ::Dialog button)
						    (*:cancel dialog)))))
					      text: "Delete this Student"))))
	 #t)))))
  

(define-simple-class tab-discussions (base-activity)
  (class-num ::int)

  ((onResume)
   (invoke-special base-activity (this) 'onResume)
   (let  ((cursor (discussions ((this):get-db) class-num)))
      (startManagingCursor cursor)
      (Log:d "prototype" (cursor:get-count))
      ((as ListView ((this):find-view-by-id R$id:tabDiscussions)):set-adapter
       (SimpleCursorAdapter
	(this) R$layout:stat_row_discussion (stats-list ((this):get-db) 'date 'class class-num 'discussion)
	(String[] (mk-sql 'name) (mk-sql 'correct) (mk-sql 'incorrect) (mk-sql 'pass))
	(int[] R$id:disName R$id:disCorrect R$id:disIncorrect R$id:disPass)))))

  ((onCreate (saved-instance-state ::Bundle))
   (invoke-special base-activity (this) 'onCreate saved-instance-state)
   (invoke-special Activity (this) 'setContentView R$layout:tab_discussions)
   (when ((getIntent):has-extra (mk-extra tab-discussions 'class))
	 (set! class-num ((getIntent):get-int-extra
			  (mk-extra tab-discussions 'class) 0)))
   ((as ListView ((this):find-view-by-id R$id:tabDiscussions)):set-on-item-click-listener
    (lambda (parent view pos id ::long)
      (*:show
       (make <android.app.AlertDialog$Builder>
	 (this)
	 title: (id->discussion-date ((this):get-db) id)
	 view: (LinearLayout (this)
			     orientation: LinearLayout:VERTICAL
			     view: (Button (this)
					     on-click-listener:
					     (lambda (view)
					       (startActivity
						((make <android.content.Intent> (as Context (this))
						       discussion-view):put-extra
						       (mk-extra discussion-view 'discussion) id)))
					       text: "View Student Participation in this Discussion")
			     view: (Button (this)
					     on-click-listener:
					     (lambda (view)
					       (startActivity
						(((make <android.content.Intent> (as Context (this))
						       record-question):put-extra
						       (mk-extra record-question 'class) class-num):put-extra
						       (mk-extra record-question 'discussion) id)))
					     text: "Resume this Discussion"))))
      #t))))
