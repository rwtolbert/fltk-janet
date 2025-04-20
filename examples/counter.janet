(use jfltk)

(def *WIDTH* 600)
(def *HEIGHT* 400)
(def *SEL-BLUE* 0x3f51b500)
(def *BLUE* 0x42A5F500)
(def *GRAY* 0x75757500)

(defn click-cb [w counter]
  (def val (inc (scan-number (Fl_Box_label counter))))
  (Fl_Box_set_label counter (string/format "%d" val)))

(defn draw-shadow [w data]
  (Fl_set_color_rgb 211 211 211)
  (Fl_rectf 0 (Fl_Widget_height w) (Fl_Widget_width w) 3))

(defn main [&]
  (Fl_init_all)
  (Fl_register_images)
  (Fl_lock)

  (def w (Fl_Window_new 100 100 *WIDTH* *HEIGHT* "Flutter-like"))
  (def col (Fl_Flex_new 0 0 *WIDTH* *HEIGHT* ""))
  (def bar (Fl_Box_new 0 0 0 0 "  FLTK App!"))
  (Fl_Flex_set_size col bar 60)
  (Fl_Box_set_align bar (bor Fl_Align_Left Fl_Align_Inside))

  (def text (Fl_Box_new 0 0 0 0 "You have pushed the button this many times:"))
  (Fl_Box_set_align text (bor Fl_Align_Bottom Fl_Align_Inside))

  (def counter (Fl_Box_new 0 0 0 0 "0"))
  (Fl_Box_set_align counter (bor Fl_Align_Top Fl_Align_Inside))

  (def row (Fl_Flex_new 0 0 0 0 ""))
  (Fl_Flex_set_type row 1)
  (Fl_Flex_set_size col row 60)

  (Fl_Box_new 0 0 0 0 "")
  (def but (Fl_Button_new (- *WIDTH* 100) (- *HEIGHT* 100) 60 60 "@+6plus"))
  (Fl_Flex_set_size row but 60)
  (def spacing1 (Fl_Box_new 0 0 0 0 ""))
  (Fl_Flex_set_size row spacing1 20)
  (Fl_Flex_end row)

  (def spacing2 (Fl_Box_new 0 0 0 0 ""))
  (Fl_Flex_set_size col spacing2 20)

  (Fl_Flex_end col)
  (Fl_Window_end w)
  (Fl_Window_resizable w w)
  (Fl_Window_show w)

  (Fl_background 255 255 255)
  (Fl_set_visible_focus 0)

  (Fl_Box_set_box bar Fl_BoxType_FlatBox)
  (Fl_Box_set_label_size bar 22)
  (Fl_Box_set_label_color bar Fl_Color_White)
  (Fl_Box_set_color bar Fl_Color_Blue)
  (Fl_Box_draw bar (make_draw_callback draw-shadow))

  (Fl_Box_set_label_size text 18)
  (Fl_Box_set_label_font text Fl_Font_Times)

  (Fl_Box_set_label_size counter 36)
  (Fl_Box_set_label_color counter *GRAY*)

  (Fl_Button_set_color but *BLUE*)
  (Fl_Button_set_selection_color but *SEL-BLUE*)
  (Fl_Button_set_label_color but Fl_Color_White)
  (Fl_Button_set_box but Fl_BoxType_OFlatBox)
  (Fl_Button_set_callback but (make_callback click-cb counter))

  (Fl_run))