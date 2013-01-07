(require 'srfi-1)
(require 'regex)
(require 'syntax-utils)

(provide 'alias)
(module-export Log
	       Application Activity Service ProgressDialog ActivityGroup Dialog
	       Bitmap Canvas Color Drawable 
	       Context Intent Resources SharedPreferences ContentValues 
	       Handler Bundle IBinder 
	       KeyEvent OnClickListener SurfaceHolder View ViewGroup Menu MenuItem Window
	       Button EditText ListView SimpleCursorAdapter TextView Toast Spinner ViewBinder TabHost TabSpec LinearLayout
	       DateUtils Editable TextWatcher 
 	       PreferenceActivity PreferenceManager BaseColumns 
	       Cursor cursor-window SQLCursor SQLiteDatabase SQLiteOpenHelper 
	       String Integer 
	       File FileReader BufferedReader BufferedWriter FileWriter
	       Random 
	       FVector 
	       R
	       debug)

(define-namespace Log "class:android.util.Log")

(define-alias Application		android.app.Application)
(define-alias Activity			android.app.Activity)
(define-alias ActivityGroup		android.app.ActivityGroup)
(define-alias Dialog		        android.app.Dialog)
(define-alias Service			android.app.Service)
(define-alias ProgressDialog            android.app.ProgressDialog)

(define-alias Bitmap			android.graphics.Bitmap)
(define-alias Canvas			android.graphics.Canvas)
(define-alias Color			android.graphics.Color)
(define-alias Drawable			android.graphics.drawable.Drawable)

(define-alias Context			android.content.Context)
(define-alias Intent			android.content.Intent)
(define-alias Resources			android.content.res.Resources)
(define-alias SharedPreferences		android.content.SharedPreferences)
(define-alias ContentValues		android.content.ContentValues)

(define-alias Handler			android.os.Handler)
(define-alias Bundle			android.os.Bundle)
(define-alias IBinder			android.os.IBinder)

(define-alias KeyEvent			android.view.KeyEvent)
(define-alias OnClickListener		android.view.View$OnClickListener)
(define-alias SurfaceHolder		android.view.SurfaceHolder)
(define-alias View			android.view.View)
(define-alias ViewGroup			android.view.ViewGroup)
(define-alias Window			android.view.Window)
(define-alias Menu			android.view.Menu)
(define-alias MenuItem			android.view.MenuItem)

(define-alias Button			android.widget.Button)
(define-alias EditText			android.widget.EditText)
(define-alias ListView			android.widget.ListView)
(define-alias LinearLayout		android.widget.LinearLayout)
(define-alias SimpleCursorAdapter       android.widget.SimpleCursorAdapter)
(define-alias TextView			android.widget.TextView)
(define-alias Toast			android.widget.Toast)
(define-alias Spinner			android.widget.Spinner)
(define-alias TabHost			android.widget.TabHost)
(define-alias TabSpec			android.widget.TabHost$TabSpec)
(define-alias ViewBinder                android.widget.SimpleCursorAdapter$ViewBinder)

(define-alias DateUtils 		android.text.format.DateUtils)
(define-alias Editable			android.text.Editable)
(define-alias TextWatcher		android.text.TextWatcher)

(define-alias PreferenceActivity	android.preference.PreferenceActivity)
(define-alias PreferenceManager		android.preference.PreferenceManager)
(define-alias BaseColumns		android.provider.BaseColumns)

(define-alias Cursor			android.database.Cursor)
(define-alias cursor-window             android.database.CursorWindow)
(define-alias SQLCursor                 android.database.sqlite.SQLiteCursor)
(define-alias SQLiteDatabase		android.database.sqlite.SQLiteDatabase)
(define-alias SQLiteOpenHelper		android.database.sqlite.SQLiteOpenHelper)

(define-alias String                    java.lang.String)
(define-alias Integer                   java.lang.Integer)

(define-alias File                      java.io.File)
(define-alias FileReader                java.io.FileReader)
(define-alias FileWriter                java.io.FileWriter)
(define-alias BufferedReader            java.io.BufferedReader)
(define-alias BufferedWriter            java.io.BufferedWriter)
 
(define-alias Random                    java.util.Random)

(define-alias FVector                   gnu.lists.FVector)

(define-alias R                         kawa.prototype.R)

;; aliases for the sshj library; unused

;;(define-alias android-config            net.schmizz.sshj.AndroidConfig)
;;(define-alias ssh                       net.schmizz.sshj.SSHClient)
;;(define-alias scp                       net.schmizz.sshj.xfer.scp.SCPFileTransfer)
;;(define-alias local-dest-file           net.schmizz.sshj.xfer.LocalDestFile)
;;(define-alias in-mem-file               net.schmizz.sshj.xfer.InMemoryDestFile)
;;(define-alias file-system-file          net.schmizz.sshj.xfer.FileSystemFile)

(define debug #f)
