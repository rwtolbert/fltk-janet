(use jfltk)

(defn main [&]
  (Fl_init_all)

  (def w (Fl_Double_Window_new 100 100 410 40 "Flex demo"))
  (def flex (Fl_Flex_new 5 5 400 30 ""))
  (Fl_Flex_set_type flex 1)

  (def b1 (Fl_Button_new 0 0 0 0 "File"))
  (def b2 (Fl_Button_new 0 0 0 0 "Save"))
  (def bx (Fl_Box_new 0 0 0 0 ""))
  (def b3 (Fl_Button_new 0 0 0 0 "Exit"))

  (Fl_Flex_end flex)

  (Fl_Window_resizable w flex)
  (Fl_Window_end w)
  (Fl_Window_show w)
  (Fl_run))