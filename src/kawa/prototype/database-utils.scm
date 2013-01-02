
(require alias "alias.scm")

(provide 'database-utils)

(define (mk-sql . args)
  (*:to-string (apply string-append (map *:to-string args))))

(define-simple-class dbHelper (SQLiteOpenHelper)
 ((*init* (context_ ::Context))
  (invoke-special android.database.sqlite.SQLiteOpenHelper
 		  (this) '*init* context_ student-data:DATABASE
 		  #!null student-data:VERSION))
 ((onCreate (db ::SQLiteDatabase))
  (*:execSQL db (mk-sql "CREATE TABLE "
			'classes " ("
			student-data:C_ID " INT PRIMARY KEY, "
			'name " TEXT, "
			'time " TEXT)"))
  (*:execSQL db (mk-sql "CREATE TABLE "
			'students " ("
			student-data:C_ID " INT PRIMARY KEY, "
			'name  " TEXT, "
			'eid " TEXT, "
			'class " INT)"))
  (*:execSQL db (mk-sql "CREATE TABLE "
			'discussions " ("
			student-data:C_ID " INT PRIMARY KEY, "
			'date " TEXT, "
			'endid " INT, "
			'class " INT)"))
  (*:execSQL db (mk-sql "CREATE TABLE "
			'log " ("
			student-data:C_ID " INT PRIMARY KEY, "
			'correct " INT,"
			'incorrect " INT,"
			'pass " INT,"
			'student " INT, "
			'discussion " INT, "
			'class " INT)")))
 ((onUpgrade (db ::SQLiteDatabase) (oldVersion ::int) (newVersion ::int))
  (*:execSQL db (mk-sql "DROP TABLE IF EXISTS " 'students))
  (onCreate db)))

(define-simple-class student-data ()
 (DATABASE     ::String   allocation: 'static access: 'final init: "classes.db")
 (VERSION      ::int      allocation: 'static access: 'final init: 3)
 (C_ID         ::String   allocation: 'static access: 'final init: BaseColumns:_ID)
 (db-helper    ::dbHelper allocation: 'static access: '(private final))
 (current-id ::int  init: 0 access: 'public)
 ((*init* (context_ ::Context))
  (set! db-helper (make dbHelper context_)))
 ((close) (db-helper:close))
 ((delete table where) 
  (let ((db ::SQLiteDatabase (db-helper:getWritableDatabase)))
   (db:delete table where [])
    (db:close)))
 ((insert-or-ignore table (values ::ContentValues))
  (values:put C_ID
	      (java.lang.Integer current-id))
  (Log:d "student-data insert or ignore" values)
  (set! current-id (+ 1 current-id))
  (let ((db ::SQLiteDatabase (db-helper:getWritableDatabase)))
   (try-finally
    (try-catch (db:insertWithOnConflict table #!null values
 					SQLiteDatabase:CONFLICT_IGNORE)
 	       (e android.database.SQLException
 		  (Log:e "student-data SQL" e)
 		  #f))
    (db:close))))
 ((query distinct? table columns selection group-by having order-by limit) ::Cursor
  ((db-helper:get-writable-database):query
   distinct? table columns selection #!null group-by having order-by limit))
 ((raw-query query)
  ((db-helper:get-writable-database):raw-query query #!null))
 ((update-row table column id new-value)
  (let ((pos 
	 ((db-helper:get-writable-database):raw-query
	  (mk-sql  
	   "UPDATE " table
	   " SET " column " = '" new-value "'"  
	   " WHERE " C_ID " = '" (as java.lang.Integer id) "'")
	  #!null)))
    (pos:move-to-first)
    (Log:d "student-data updated" (string-append
				   "table: "table ", column:" column ", id:" (*:to-string (as java.lang.Integer id)) ", new-value: " (*:to-string new-value))))))

(define (classes db ::student-data)
  (db:query #t
	    (mk-sql 'classes) #!null #!null #!null #!null 
	    (mk-sql 'name " ASC") #!null))

(define (students db ::student-data class)
  (db:query #f
	    (mk-sql 'students) #!null (mk-sql 'class " = " class) #!null #!null 
	    (mk-sql 'name " ASC") #!null))

(define (discussions db ::student-data class)
  (db:query #f
	    (mk-sql 'discussions) #!null (mk-sql 'class " = " class) #!null #!null 
	    (mk-sql 'date " ASC") #!null))

(define (stats db ::student-data table id)
  (db:raw-query
   (mk-sql "SELECT " student-data:C_ID ", SUM" '(correct) ", SUM" '(incorrect) ", SUM" '(pass) " FROM " 'log " WHERE " table " = " id)))

(define (stats-list db ::student-data rename table id group)
  (db:raw-query
   (mk-sql "SELECT " group "s." student-data:C_ID " AS _id , " group "s." rename " AS " 'name " , SUM(" 'log "." 'correct ") AS " 'correct " , SUM(" 'log "." 'incorrect ") AS " 'incorrect " , SUM(" 'log "." 'pass ") AS " 'pass " FROM " 'log " JOIN " group "s ON " 'log "." group "=" group "s." student-data:C_ID " WHERE " 'log "." table " = " id  " GROUP BY " 'log "." group " ORDER BY " group "s." rename " ASC")))

(define (id->student-name db ::student-data id)
  (let ((pos (db:query
	      #t (mk-sql 'students) #!null (mk-sql student-data:C_ID " = " id) #!null
	      #!null (mk-sql 'name " ASC") #!null)))
    (pos:move-to-first)
    (pos:get-string (pos:get-column-index (mk-sql 'name)))))

(define (add-student db ::student-data name eid (class ::int))
  (let ((values ::ContentValues (make ContentValues)))
    (values:clear)
    (values:put (mk-sql 'name) (as String name))
    (values:put (mk-sql 'eid) (as String eid))
    (values:put (mk-sql 'class) (Integer class))
    (*:insert-or-ignore db (mk-sql 'students) values)
    db))

(define (delete-student db ::student-data id)
  (db:delete (mk-sql 'students) (mk-sql student-data:C_ID "=" id)))
				       
(define (add-class db ::student-data name time)
  (let ((values ::ContentValues (make ContentValues)))
    (values:clear)
    (values:put (mk-sql 'name) (as String name))
    (values:put (mk-sql 'time) (as String time))
    (*:insert-or-ignore db (mk-sql 'classes) values)
    db))

(define (delete-class db ::student-data id)
  (db:delete (mk-sql 'students) (mk-sql 'class "=" id))
  (db:delete (mk-sql 'classes) (mk-sql student-data:C_ID "=" id)))

(define (open-discussion db ::student-data class ::int)
  (let ((values ::ContentValues (make ContentValues))
	(id ::int db:current-id))
    (values:clear)
    (values:put (mk-sql 'class) (Integer class))
    (values:put (mk-sql 'date) (let ((time (android.text.format.Time)))
				      (*:set-to-now time)
				      (*:format time "%Y %m %d")))
    (*:insert-or-ignore db (mk-sql 'discussions) values)
    id))

(define (close-discussion db ::student-data id)
  (db:update-row (mk-sql 'discussions) (mk-sql 'endid) id db:current-id))

(define (add-to-log db ::student-data student-num ::int class-num ::int discussion-num ::int answer) 
  (let ((values ::ContentValues (make ContentValues)))
    (values:clear)
    (values:put (mk-sql 'student) (Integer student-num))
    (values:put (mk-sql 'class) (Integer class-num))
    (values:put (mk-sql 'discussion) (Integer discussion-num))
    (values:put (mk-sql 'correct) (Integer (as int (if (symbol=? answer 'correct) 1 0))))
    (values:put (mk-sql 'incorrect) (Integer (as int (if (symbol=? answer 'incorrect) 1 0))))
    (values:put (mk-sql 'pass) (Integer (as int (if (symbol=? answer 'pass) 1 0))))
    (*:insert-or-ignore db (*:to-string 'log) values)
    db))

(define (init-fake-db db)
  (add-class db "Operating systems CS372" "5-6:30 TTh") ;0
  (add-class db "Operating systems CS372" "5-6:30 TTh") ;1
  (add-class db "Operating systems CS372" "5-6:30 TTh") ;2
  (add-student db "Jimmy" "Brisson" 0) ;3
  (add-student db "Jimmy" "Brisson" 0) ;4
  (add-student db "Jimmy" "Brisson" 0) ;5
  (add-student db "Jimmy" "Brisson" 0) ;6
  (add-student db "Jimmy" "Brisson" 0) ;7
  (add-student db "Jimmy" "Brisson" 0) ;8
  (add-student db "Jimmy" "Brisson" 0) ;9
  (add-student db "Jimmy" "Brisson" 0) ;10
  (add-student db "Jimmy" "Brisson" 0) ;11
  (add-student db "Jimmy" "Brisson" 0) ;12
  (add-student db "Jimmy" "Brisson" 0) ;13
  (add-student db "Jimmy" "Brisson" 0) ;14
  (let ((discussion (open-discussion db 0)))
    (add-to-log db 3 0 discussion 'pass)
    (add-to-log db 3 0 discussion 'pass)
    (add-to-log db 3 0 discussion 'pass)
    (add-to-log db 3 0 discussion 'pass)
    (add-to-log db 3 0 discussion 'pass)
    (add-to-log db 3 0 discussion 'correct)
    (add-to-log db 3 0 discussion 'pass)
    (add-to-log db 3 0 discussion 'pass)
    (add-to-log db 3 0 discussion 'pass)
    (add-to-log db 3 0 discussion 'incorrect)
    (add-to-log db 3 0 discussion 'pass)
    (add-to-log db 3 0 discussion 'pass)
    (add-to-log db 3 0 discussion 'pass)
    (add-to-log db 3 0 discussion 'pass)
    (add-to-log db 3 0 discussion 'pass)
    (add-to-log db 3 0 discussion 'pass)
    (close-discussion db discussion))) 


