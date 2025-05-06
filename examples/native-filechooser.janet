(use jfltk)
(import spork/path)
(import spork/sh)

(def *terminal-height* 120)

(var *main-window* nil)
(var *console* nil)

(def- *fc* (fl-native-file-chooser-new Fl-NativeFileChooserType-BrowseFile))

(var default-filename nil)
(defn- untitled-default []
  (unless default-filename
    (when (os/getenv "HOME")
      (set default-filename (path/join (os/getenv "HOME") "untitled.txt")))
    (when (os/getenv "HOME_PATH")
      (set default-filename (path/join (os/getenv "HOME_PATH") "untitled.txt")))
    (when (nil? default-filename)
      (set default-filename (path/join "." "untitled.txt"))))
  default-filename)

(defn- make-shortcut [mod char]
  (bor mod (get (string/bytes char) 0)))

(defn- save-file [fname]
  "Save some data to a file, but only if it doesn't already exist"
  (fl-terminal-printf *console* (string/format "Saving %s\n" fname))
  (unless (sh/exists? fname)
    (def fp (file/open fname :w))
    (file/write fp "Hello world\n")
    (file/close fp)))

(defn- file-open [w data]
  (fl-native-file-chooser-set-title *fc* "Open")
  (fl-native-file-chooser-set-type *fc* Fl-NativeFileChooserType-BrowseFile)
  (case (fl-native-file-chooser-show *fc*)
    -1 return # error
    1 return  # cancel
    0 (do
        (def fname (fl-native-file-chooser-filename *fc*))
        (when fname 
          (fl-native-file-chooser-set-preset-file *fc* fname)
          (fl-terminal-printf *console* (string/format "Open: %s\n" fname))))))

(defn- file-save-as [w data]
  (fl-native-file-chooser-set-title *fc* "Save As")
  (fl-native-file-chooser-set-type *fc* Fl-NativeFileChooserType-SaveFile)
  (case (fl-native-file-chooser-show *fc*)
    -1 return # error
    1 return  # cancel
    0 (do
        (def fname (fl-native-file-chooser-filename *fc*))
        (when fname 
          (fl-native-file-chooser-set-preset-file *fc* fname)
          (save-file fname)))))

(defn- file-save [w data]
  (def fname (fl-native-file-chooser-filename *fc*))
  (if fname
    (save-file fname)
    (file-save-as w data)))

(defn- file-quit [w data]
  (fl-double-window-hide data))

(defn main [&]
  (fl-init-all)
  (fl-register-images)
  (fl-lock)

  (set *main-window* (fl-double-window-new 100 100 500 (+ 200 *terminal-height*) "Terminal"))
  (fl-double-window-begin *main-window*)

  (def menubar (fl-menu-bar-new 0 0 500 25 ""))
  (def open-cb (make-callback file-open menubar))
  (fl-menu-bar-add menubar "&File/&Open"
                   (make-shortcut Fl-Shortcut-Ctrl "o") open-cb 0)
  (def save-cb (make-callback file-save menubar))
  (fl-menu-bar-add menubar "&File/&Save"
                   (make-shortcut Fl-Shortcut-Ctrl "s") save-cb 0)
  (def save-as-cb (make-callback file-save-as menubar))
  (fl-menu-bar-add menubar "&File/Save &As" 0 save-as-cb 0)
  (def quit-cb (make-callback file-quit *main-window*))
  (fl-menu-bar-add menubar "&File/&Quit"
                   (make-shortcut Fl-Shortcut-Ctrl "q") quit-cb 0)

  (def- message ``This demo shows an example of implementing
               common 'File' menu operations like:
                   File/Open, File/Save, File/Save As
               ... using the fl-native-file-chooser widget.
               Note 'Save' and 'Save As' really *do* create files! 
               This is to show how behavior differs when 
               files exist vs. do not.``)
  (def box1 (fl-box-new 0 0
                        (fl-double-window-width *main-window*) 200
                        message))
  (fl-box-set-align box1
                    (bor Fl-Align-Center Fl-Align-Inside Fl-Align-Wrap))

  (set *console* (fl-terminal-new 0 200
                                  (fl-double-window-width *main-window*) *terminal-height*
                                  "Console"))
  (fl-terminal-set-ansi *console* true)
  (fl-terminal-set-align *console* (bor Fl-Align-Top Fl-Align-Left))

  (fl-double-window-end *main-window*)
  (fl-double-window-resizable *main-window* *main-window*)
  (fl-double-window-show *main-window*)

  (fl-native-file-chooser-set-filter *fc* "Text\t*.txt\n")
  (fl-native-file-chooser-set-preset-file *fc* (untitled-default))
  
  (fl-run))
