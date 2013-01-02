(require alias "alias.scm")
(require base "base.scm")
(require database-utils "database-utils.scm")
(require class-view "class-view.scm")
(require utils "utils.scm")

(define-simple-class Prototype (base-activity)
  (cursor    ::Cursor)
  (class   ::ListView)
  (adapter   ::SimpleCursorAdapter)

  ((onCreateOptionsMenu (menu ::Menu))
   ((getMenuInflater):inflate R$menu:prototype_menu menu)
   #t)

  ((onOptionsItemSelected (item ::MenuItem))
   (let ((id (*:get-item-id item)))
     (cond 
      ((= R$id:createClass id) 
       (let ((name (EditText (this) hint: "Name"))
	     (time  (EditText (this) hint: "Time")))
	 (*:show
	  (*:set-negative-button
	   (*:set-positive-button
	    (make <android.app.AlertDialog$Builder>
	      (this)
	      title: "Add Class"
	      view: (LinearLayout (this)
				  orientation: LinearLayout:VERTICAL
				  view: name
				  view: time))
	    "add class"
	    (lambda (dialog ::Dialog button)
	      (*:dismiss dialog)
	      (add-class ((this):get-db) (*:get-text name) (*:get-text time))
	      (onResume)))
	   "cancel"
	   (lambda (dialog ::Dialog button)
	     (*:cancel dialog))))))))
   #t)

  ((onCreate (saved-instance-state ::Bundle))
   (invoke-special base-activity (this) 'onCreate saved-instance-state)
   (Log:d "Prototype" "Application started")
   (Log:d "Prototype" R$layout:class_list)
   (setContentView R$layout:class_list)
   (set! ((this):get-db):current-id ((getPreferences android.content.Context:MODE_PRIVATE):get-int (*:to-string 'current-id) 0))
   
   (set! class (Activity:find-view-by-id (this) R$id:listClasses))
   (class:set-on-item-long-click-listener
    (lambda (parent view pos id)
      (*:show
       (*:set-negative-button
	(*:set-positive-button
	 (make <android.app.AlertDialog$Builder>
	   (this)
	   title: "Delete Class"
	   view: (TextView
		  (this)
		  text: "would you like to remove this class and it's students?"))
	 "yes"
	 (lambda (dialog ::Dialog button)
	   (*:dismiss dialog)
	   (delete-class ((this):get-db) id)))
	"cancel"
	   (lambda (dialog ::Dialog button)
	     (*:cancel dialog))))
      #t))
   (ListView:set-on-item-click-listener class
    (lambda (adapter view pos ::int id)
      (*:move-to-first cursor)
      (*:move-to-position cursor pos)
      (startActivity ((make <android.content.Intent> (as Context (this)) class-view):put-extra
		      (mk-extra class-view 'class) (*:get-int cursor
							      (*:get-column-index
							       cursor
							       student-data:C_ID)))))))

  ((onStop)
   (invoke-special Activity (this) 'onStop)
   (let ((editor (((this):get-preferences android.content.Context:MODE_PRIVATE):edit)))
     (*:put-int editor (*:to-string 'current-id) ((this):get-db):current-id)
     (*:commit editor)))

  ((onResume)
   (invoke-special base-activity (this) 'onResume)
   (set! cursor (classes ((this):get-db)))
   (Activity:startManagingCursor (this) cursor)
   (set! adapter (SimpleCursorAdapter
		  (this) R$layout:row cursor
		  (String[] (mk-sql 'name) (mk-sql 'time))
		  (int[] R$id:rowClassName R$id:rowClassTime)))
   (class:set-adapter adapter)))


;;;; here on out does not use current db scheme
;;;; TODO: FIX THIS VIEW TO WORK WITH THE NEW DB SCHEME
;;
;;(define (ssh-connect server ::String)
;;  (try-catch ((lambda ()
;;		(let ((sshd ::ssh (ssh (android-config))))
;;		  (ssh:connect sshd (java.net.InetAddress:get-by-name server))
;;		  sshd)))
;;	     (e net.schmizz.sshj.transport.TransportException
;;		(let ((host-string ::String
;;				   (car (regex-match "([0123456789abcdef]{2}:?){16}" e:message)))
;;		      (sshd ::ssh (ssh (android-config))))
;;		  (Log:d "*****prototype*****" (string-append "host-fingerprint: " host-string))
;;		  (*:add-host-key-verifier sshd host-string)
;;		  (*:connect sshd (java.net.InetAddress:get-by-name server))
;;		  sshd))))
;;
;;(define (spawn-importer me ::base-activity server ::String u-name p-word ::String file)
;;  (Log:d "*****prototype*****" (string-append "spawning importer with server: " server
;;					      " u-name: " u-name " p-word: " p-word
;;					      " file: " file))
;;  (let ((dialog (ProgressDialog:show me "" "connecting" #t)))
;;    (try-finally (let ((sshd ::ssh (ssh-connect server)))
;;		   (Log:d "*****prototype*****" "connected")
;;		   (*:set-message dialog "authenticating")
;;		   (*:auth-password sshd u-name p-word)
;;		   (Log:d "*****prototype*****" "auth")
;;		   (*:set-message dialog "downloading")
;;		   (scp:download (*:newSCP-file-transfer sshd) file "/sdcard/import.temp")
;;		   (Log:d "*****prototype*****" "downladed file")
;;		   (*:set-message dialog "adding students to database")
;;		   (me:finish))
;;		 (dialog:dismiss))))
;;
;;(define-simple-class import (base-activity)
;;  (submit ::Button)
;;  (username ::EditText)
;;  (password ::EditText)
;;  (server ::EditText)
;;  (file ::EditText)
;;  ((on-create (bundle ::Bundle))
;;     (invoke-special base-activity (this) 'onCreate bundle)
;;     (Activity:setContentView (this) R$layout:import_layout)
;;     (set! username (Activity:find-view-by-id (this) R$id:UsernameEditText))
;;     (set! password (Activity:find-view-by-id (this) R$id:PasswordEditText))
;;     (set! file (Activity:find-view-by-id (this) R$id:FileEditText))
;;     (set! server (Activity:find-view-by-id (this) R$id:ServerEditText))
;;     (set! submit (Activity:find-view-by-id (this) R$id:buttonImport))
;;     (submit:set-on-click-listener
;;      (lambda (v)
;;	(Log:d "*****prototype*****" "import button pressed")
;;	(try-catch (spawn-importer (this) (*:get-text server) (*:get-text username) (*:get-text password) (*:get-text file))
;;		   (e java.net.UnknownHostException
;;		      ((Toast:make-text (this) "Could not connect to server"
;;				       Toast:LENGTH_SHORT):show))
;;		   (e net.schmizz.sshj.userauth.UserAuthException
;;		      ((Toast:make-text (this) "Incorrect Password"
;;				       Toast:LENGTH_SHORT):show))
;;		   (e java.net.ConnectException
;;		      ((Toast:make-text (this) "Could not connect to server"
;;				       Toast:LENGTH_SHORT):show)))))))
;;
