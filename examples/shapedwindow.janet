(use ../_build/release/jfltk)

(Fl_init_all)
(Fl_register_images)
(Fl_lock)

(def dim 200)

(def win (Fl_Double_Window_new 100 100 dim dim "Testing1"))

(Fl_Double_Window_end win)
# (Fl_Double_Window_resizable win)
(Fl_Double_Window_show win)

(def ret (Fl_run))

(pp ret)