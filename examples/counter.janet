(use jfltk)

(def *WIDTH* 600)
(def *HEIGHT* 400)
(def *SEL-BLUE* 0x3f51b500)
(def *BLUE* 0x42A5F500)
(def *GRAY* 0x75757500)

(defn click-cb [w counter]
  (def val (inc (scan-number (fl-box-label counter))))
  (fl-box-set-label counter (string/format "%d" val)))

(defn draw-shadow [w data]
  (fl-set-color-rgb 211 211 211)
  (fl-rectf 0 (fl-widget-height w) (fl-widget-width w) 3))

(defn main [&]
  (fl-init-all)
  (fl-register-images)
  (fl-lock)

  (def w (fl-window-new 100 100 *WIDTH* *HEIGHT* "flutter-like"))
  (def col (fl-flex-new 0 0 *WIDTH* *HEIGHT* ""))
  (def bar (fl-box-new 0 0 0 0 "  FLTK App!"))
  (fl-flex-set-size col bar 60)
  (fl-box-set-align bar (bor Fl-Align-Left Fl-Align-Inside))

  (def text (fl-box-new 0 0 0 0 "You have pushed the button this many times:"))
  (fl-box-set-align text (bor Fl-Align-Bottom Fl-Align-Inside))

  (def counter (fl-box-new 0 0 0 0 "0"))
  (fl-box-set-align counter (bor Fl-Align-Top Fl-Align-Inside))

  (def row (fl-flex-new 0 0 0 0 ""))
  (fl-flex-set-type row 1)
  (fl-flex-set-size col row 60)

  (fl-box-new 0 0 0 0 "")
  (def but (fl-button-new (- *WIDTH* 100) (- *HEIGHT* 100) 60 60 "@+6plus"))
  (fl-flex-set-size row but 60)
  (def spacing1 (fl-box-new 0 0 0 0 ""))
  (fl-flex-set-size row spacing1 20)
  (fl-flex-end row)

  (def spacing2 (fl-box-new 0 0 0 0 ""))
  (fl-flex-set-size col spacing2 20)

  (fl-flex-end col)
  (fl-window-end w)
  (fl-window-resizable w w)
  (fl-window-show w)

  (fl-background 255 255 255)
  (fl-set-visible-focus 0)

  (fl-box-set-box bar Fl-BoxType-FlatBox)
  (fl-box-set-label-size bar 22)
  (fl-box-set-label-color bar Fl-Color-White)
  (fl-box-set-color bar Fl-Color-Blue)
  (fl-box-draw bar (make-draw-callback draw-shadow))

  (fl-box-set-label-size text 18)
  (fl-box-set-label-font text Fl-Font-Times)

  (fl-box-set-label-size counter 36)
  (fl-box-set-label-color counter *GRAY*)

  (fl-button-set-color but *BLUE*)
  (fl-button-set-selection-color but *SEL-BLUE*)
  (fl-button-set-label-color but Fl-Color-White)
  (fl-button-set-box but Fl-BoxType-OFlatBox)
  (fl-button-set-callback but (make-callback click-cb counter))

  (fl-run))
