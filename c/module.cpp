#include <janet.h>
#include <cfl.h>
#include <cfl_image.h>
#include <cfl_window.h>

/***************/
/* C Functions */
/***************/

JANET_FN(cfun_hello_native,
         "(jfltk/hello-native)",
         "Evaluate to \"Hello!\". but implemented in C++.") {
    janet_fixarity(argc, 0);
    (void) argv;
    return janet_cstringv("Hello!");
}

JANET_FN(cfun_Fl_init_all,
         "(jfltk/Fl_init_all)",
         "Init all the things") {
    janet_fixarity(argc, 0);
    (void) argv;
    Fl_init_all();
    return janet_wrap_nil();
}

JANET_FN(cfun_Fl_register_images,
        "(jfltk/Fl_register_images)",
        "Register images") {
    janet_fixarity(argc, 0);
    (void) argv;
    Fl_register_images();
    return janet_wrap_nil();
}

JANET_FN(cfun_Fl_lock,
         "(jfltk/Fl_lock)",
         "Allow threads") {
    janet_fixarity(argc, 0);
    (void) argv;
    return janet_wrap_integer(Fl_lock());
}

JANET_FN(cfun_Fl_run,
    "(jfltk/Fl_run)",
    "Run the app") {
    janet_fixarity(argc, 0);
    (void) argv;
    Fl_run();
    return janet_wrap_nil();
}

JANET_FN(cfun_Fl_Window_new_wh,
        "(jfltk/Fl_Window_newwh w h &opt title)",
        "Make a new Fl_Window") {
    janet_arity(argc, 2, 3);
    int w = janet_getinteger(argv, 0);
    int h = janet_getinteger(argv, 1);
    const char* title = nullptr;
    if (argc == 3 && janet_checktype(argv[2], JANET_STRING))
        title = janet_getcstring(argv, 2);
    return janet_wrap_pointer(Fl_Window_new_wh(w, h, title));
}

JANET_FN(cfun_Fl_Window_end,
         "(jfltk/Fl_Window_end Window)",
         "Stop adding widgets to window") {
    janet_fixarity(argc, 1);
    Fl_Window* w = (Fl_Window*)janet_getpointer(argv, 0);
    if (w) {
        Fl_Window_end(w);
    }
    return janet_wrap_nil();
}

JANET_FN(cfun_Fl_Window_show,
    "(jfltk/Fl_Window_show Window)",
    "Show window") {
    janet_fixarity(argc, 1);
    Fl_Window* w = (Fl_Window*)janet_getpointer(argv, 0);
    if (w) {
        Fl_Window_show(w);
    }
    return janet_wrap_nil();
}

// JANET_FN(cfun_Fl_Overlay_Window_draw_overlay,
//         "(jfltk/Fl_Overlay_Window_draw_overlay)",
//         "") {
//     janet_fixarity(argc, 3);
//     Fl_Overlay_Window* w = (Fl_Overlay_Window*)janet_getpointer(argv, 0);
//     custom_draw_callback cb = (custom_draw_callback)janet_getpointer(argv, 1);
//     void *data = janet_getpointer(argv, 2);
//     (void) argv;
//     Fl_Overlay_Window_draw_overlay(w, cb, data);
//     return janet_wrap_nil();
// }

JANET_FN(cfun_Fl_Overlay_Window_draw_overlay,
    "(fltk/Fl_Overlay_Window_draw_overlay self cb data)",
    "") {
    janet_fixarity(argc, 3);
    if (!janet_checktype(argv[0], JANET_POINTER)) {
    janet_panicf("expected Fl_Overlay_Window *, got %%q", argv[0]);
    }
    Fl_Overlay_Window * arg0 = (Fl_Overlay_Window *)janet_getpointer(argv, 0);
    if (!arg0) {
    janet_panicf("expected Fl_Overlay_Window *, got nil");
    }

    if (!janet_checktype(argv[1], JANET_POINTER)) {
    janet_panicf("expected custom_draw_callback, got %%q", argv[1]);
    }
    custom_draw_callback arg1 = (custom_draw_callback)janet_getpointer(argv, 1);
    if (!arg1) {
    janet_panicf("expected custom_draw_callback, got nil");
    }

    if (!janet_checktype(argv[2], JANET_POINTER)) {
    janet_panicf("expected void *, got %%q", argv[2]);
    }
    void * arg2 = (void *)janet_getpointer(argv, 2);
    if (!arg2) {
    janet_panicf("expected void *, got nil");
    }

    Fl_Overlay_Window_draw_overlay(arg0, arg1, arg2);
    return janet_wrap_nil();
}


/****************/
/* Module Entry */
/****************/

JANET_MODULE_ENTRY(JanetTable *env) {
    JanetRegExt cfuns[] = {
        JANET_REG("hello-native", cfun_hello_native),
        JANET_REG("Fl_init_all", cfun_Fl_init_all),
        JANET_REG("Fl_register_images", cfun_Fl_register_images),
        JANET_REG("Fl_run", cfun_Fl_run),
        JANET_REG("Fl_lock", cfun_Fl_lock),
        JANET_REG("Fl_Window_new_wh", cfun_Fl_Window_new_wh),
        JANET_REG("Fl_Window_end", cfun_Fl_Window_end),
        JANET_REG("Fl_Window_show", cfun_Fl_Window_show),
        JANET_REG_END
    };
    janet_cfuns_ext(env, "jfltk", cfuns);
}