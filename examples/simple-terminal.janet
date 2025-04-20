(use jfltk)

(Fl_init_all)
(Fl_register_images)
(Fl_lock)

(def *terminal-height* 120)

(var G_win nil)
(var G_box nil)
(var G_tty nil)

(defn timer_fn [data]
  (def current (os/strftime "%c"))
  (var lbl "Timer tick")
  (when data
    (set lbl data))
  (def msg (string/format "%s: \e[32m%s\e[0m\n" lbl current))
  (Fl_Terminal_printf G_tty msg)
  (Fl_repeat_timeout 2.0 (make_timer_callback timer_fn data)))

(defn main [&]
  (Fl_init_all)
  (Fl_register_images)
  (Fl_lock)

  (set G_win (Fl_Double_Window_new 100 100 500 (+ 200 *terminal-height*) "Terminal"))
  (Fl_Double_Window_begin G_win)

  (set G_box (Fl_Box_new 0 0
                         (Fl_Double_Window_width G_win) 200
                         "App GUI in this area.\nDebugging output below."))

  (set G_tty (Fl_Terminal_new 0 200
                              (Fl_Double_Window_width G_win) *terminal-height* "Console"))
  (Fl_Terminal_set_ansi G_tty 1)
  (Fl_Terminal_set_align G_tty (bor Fl_Align_Top Fl_Align_Left))

  (Fl_Double_Window_end G_win)
  (Fl_Double_Window_resizable G_win G_win)
  (Fl_Double_Window_show G_win)
  (Fl_add_timeout 2.0 (make_timer_callback timer_fn "Ticker"))
  (Fl_run))