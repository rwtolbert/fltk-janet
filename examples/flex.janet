(use jfltk)

(defn main [&]
  (fl-init-all)

  (def w (fl-double-window-new 100 100 410 40 "Flex demo"))
  (def flex (fl-flex-new 5 5 400 30 ""))
  (fl-flex-set-type flex Fl-FlexType-Row)

  (def b1 (fl-button-new 0 0 0 0 "File"))
  (def b2 (fl-button-new 0 0 0 0 "Save"))
  (def bx (fl-box-new 0 0 0 0 ""))
  (def b3 (fl-button-new 0 0 0 0 "Exit"))

  (fl-flex-end flex)

  (fl-window-resizable w flex)
  (fl-window-end w)
  (fl-window-show w)
  (fl-run))
