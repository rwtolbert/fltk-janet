import os
import sys

try:
    import clang.cindex
    from clang.cindex import CursorKind, TypeKind
except ImportError:
    print("Wrapper generation requires `libclang` to be installed.")
    sys.exit(1)

dirname = os.path.abspath(os.path.dirname(__file__))


def fully_qualified(c):
    if c is None:
        return ''
    elif c.kind == CursorKind.TRANSLATION_UNIT:
        return ''
    else:
        res = fully_qualified(c.semantic_parent)
        if res != '':
            return res + '::' + c.spelling
    return c.spelling


def to_kebob_case(name):
    result = name.lower()
    return result.replace("_", "-")


CALLBACK = '''

class Callbacker {
private:
    JanetFunction* _func = nullptr;
    Janet _data;

public:
    Callbacker(JanetFunction* fn) : _func(fn) {
        _data = janet_wrap_nil();
    }
    Callbacker(JanetFunction* fn, Janet data) : _func(fn), _data(data) {
    }
    Callbacker() = delete;
    Callbacker(const Callbacker& rhs) = delete;
    Callbacker(const Callbacker&& rhs) = delete;
    Callbacker& operator=(const Callbacker& rhs) = delete;
    Callbacker& operator=(const Callbacker&& rhs) = delete;

    void static static_fl_callback(Fl_Widget* w, void *data) {
        static_cast<Callbacker*>(data)->fl_callback(w);
    }
    void fl_callback(Fl_Widget* w) {
        Janet args[2] = { janet_wrap_pointer(w), _data };
        if (_func) {
            janet_call(_func, 2, args);
        }
    }
    int static static_custom_handler_callback(Fl_Widget* w, int x, void *data) {
        return static_cast<Callbacker*>(data)->custom_handler_callback(w, x);
    }
    int custom_handler_callback(Fl_Widget* w, int x) {
        Janet args[3] = { janet_wrap_pointer(w), janet_wrap_integer(x), _data };
        if (_func) {
            return janet_unwrap_integer(janet_call(_func, 3, args));
        }
        return 0;
    }
    void static static_custom_draw_callback(Fl_Widget* w, void *data) {
        static_cast<Callbacker*>(data)->custom_draw_callback(w);
    }
    void custom_draw_callback(Fl_Widget* w) {
        Janet args[2] = { janet_wrap_pointer(w), _data };
        if (_func) {
            janet_call(_func, 2, args);
        }
    }
    static void static_timer_callback(void *data) {
        static_cast<Callbacker*>(data)->timer_callback();
    }
    void timer_callback() {
        Janet args[1] = { _data };
        if (_func) {
            janet_call(_func, 1, args);
        }
    }

    ~Callbacker() {
        if (_func)
            janet_mark(janet_wrap_function(_func));
    }
};

struct JanetFlCallback {
  JanetGCObject gc;
  Callbacker* cb = nullptr;
};

int callback_set_gc(void *data, size_t len) {
  (void)len;
  if (data) {
    JanetFlCallback *self = (JanetFlCallback *)data;
    delete(self->cb);
    self->cb = nullptr;
  }
  return 0;
}

int callback_set_gcmark(void *data, size_t len) {
  (void)len;
  return 0;
}

void callback_set_tostring(void *data, JanetBuffer *buffer) {
  if (data) {
    JanetFlCallback *self = (JanetFlCallback *)data;
    janet_buffer_push_cstring(buffer, "<JanetFlCallback>");
  }
}

JanetAbstractType callbacker_type = {};

void initialize_callbacker_type() {
  if (!callbacker_type.name) {
    callbacker_type.name = "callbacker";
    callbacker_type.gc = callback_set_gc;
    callbacker_type.gcmark = callback_set_gcmark;
    callbacker_type.tostring = callback_set_tostring;
  }
}

JanetFlCallback *new_abstract_callback(JanetFunction *fn, const Janet *argv,
                                       int32_t flag_start, int32_t argc) {
  initialize_callbacker_type();
  JanetFlCallback *cb = (JanetFlCallback *)janet_abstract(&callbacker_type, sizeof(Callbacker));

  Callbacker* callbacker = nullptr;
  if (argc == 2) {
    callbacker = new Callbacker(fn, argv[1]);
  } else {
    callbacker = new Callbacker(fn);
  }

  cb->cb = callbacker;
  return cb;
}

JANET_FN(cfun_new_fl_callback, "(jfltk/new-fl-callback fn &opt data)", "Create new Fl_Callback") {
    janet_arity(argc, 1, 2);
    JanetFlCallback* cb = nullptr;
    if (!janet_checktype(argv[0], JANET_FUNCTION)) {
        janet_panicf("expected function, got %q", argv[0]);
    }
    JanetFunction * jarg1 = (JanetFunction *)janet_getfunction(argv, 0);

    cb = new_abstract_callback(jarg1, argv, 1, argc);
    return janet_wrap_abstract(cb);
}

JANET_FN(cfun_new_custom_callback, "(jfltk/new-custom-callback fn &opt data)", "Create new custom_handler_callback") {
    janet_arity(argc, 1, 2);
    JanetFlCallback* cb = nullptr;
    if (!janet_checktype(argv[0], JANET_FUNCTION)) {
        janet_panicf("expected function, got %q", argv[0]);
    }
    JanetFunction * jarg1 = (JanetFunction *)janet_getfunction(argv, 0);

    cb = new_abstract_callback(jarg1, argv, 1, argc);
    return janet_wrap_abstract(cb);
}

JANET_FN(cfun_new_draw_callback, "(jfltk/new-draw-callback fn &opt data)", "Create new custom_draw_callback") {
    janet_arity(argc, 1, 2);
    JanetFlCallback* cb = nullptr;
    if (!janet_checktype(argv[0], JANET_FUNCTION)) {
        janet_panicf("expected function, got %q", argv[0]);
    }
    JanetFunction * jarg1 = (JanetFunction *)janet_getfunction(argv, 0);

    cb = new_abstract_callback(jarg1, argv, 1, argc);
    return janet_wrap_abstract(cb);
}

JANET_FN(cfun_new_timer_callback, "(jfltk/new-timer-callback fn &opt data)", "Create new custom_handlder_callback") {
    janet_arity(argc, 1, 2);
    JanetFlCallback* cb = nullptr;
    if (!janet_checktype(argv[0], JANET_FUNCTION)) {
        janet_panicf("expected function, got %q", argv[0]);
    }
    JanetFunction * jarg1 = (JanetFunction *)janet_getfunction(argv, 0);

    cb = new_abstract_callback(jarg1, argv, 1, argc);
    return janet_wrap_abstract(cb);
}

'''

TEMPLATE = '''
JANET_FN(cfun_{name},
         "(jfltk/{name}{arg_string})",
         "") {{
    janet_fixarity(argc, {arity});'''

ARG_TEMPLATE = '''    if (!janet_checktype(argv[{M}], {jtype})) {{
        janet_panicf("expected {argtype}, got %q", argv[{M}]);
    }}
    {argtype} arg{N} = {jfunc}(argv, {M});
'''

PTR_TEMPLATE  = '''    if (!janet_checktype(argv[{M}], {jtype})) {{
        janet_panicf("expected {argtype}, got %q", argv[{M}]);
    }}
    {argtype} arg{N} = ({argtype}){jfunc}(argv, {M});
    if (!arg{N}) {{
        janet_panicf("expected {argtype}, got nil");
    }}
'''

JANET_TEMPLATE = '''    if (!janet_checktype(argv[{M}], {jtype})) {{
        janet_panicf("expected {argtype}, got %q", argv[{M}]);
    }}
    {argtype} arg{N} = {jfunc}(argv, {M});
'''

JANET_FUNC_TEMPLATE  = '''    if (!janet_checktype(argv[{M}], {jtype})) {{
        janet_panicf("expected {argtype}, got %q", argv[{M}]);
    }}
    {argtype} jarg{N} = ({argtype}){jfunc}(argv, {M}, &callbacker_type);
    if (!jarg{N}) {{
        janet_panicf("expected {argtype}, got nil");
    }}
    auto arg{N} = jarg{N}->cb->static_fl_callback;
    void* arg{N_next} = (void*)jarg{N}->cb;
'''

CUSTOM_DRAW_TEMPLATE  = '''    if (!janet_checktype(argv[{M}], {jtype})) {{
        janet_panicf("expected {argtype}, got %q", argv[{M}]);
    }}
    {argtype} jarg{N} = ({argtype}){jfunc}(argv, {M}, &callbacker_type);
    if (!jarg{N}) {{
        janet_panicf("expected {argtype}, got nil");
    }}
    auto arg{N} = jarg{N}->cb->static_custom_draw_callback;
    void* arg{N_next} = (void*)jarg{N}->cb;
'''

CUSTOM_HANDLER_TEMPLATE  = '''    if (!janet_checktype(argv[{M}], {jtype})) {{
        janet_panicf("expected {argtype}, got %q", argv[{M}]);
    }}
    {argtype} jarg{N} = ({argtype}){jfunc}(argv, {M}, &callbacker_type);
    if (!jarg{N}) {{
        janet_panicf("expected {argtype}, got nil");
    }}
    auto arg{N} = jarg{N}->cb->static_custom_handler_callback;
    void* arg{N_next} = (void*)jarg{N}->cb;
'''

TIMER_TEMPLATE  = '''    if (!janet_checktype(argv[{M}], {jtype})) {{
        janet_panicf("expected {argtype}, got %q", argv[{M}]);
    }}
    {argtype} jarg{N} = ({argtype}){jfunc}(argv, {M}, &callbacker_type);
    if (!jarg{N}) {{
        janet_panicf("expected {argtype}, got nil");
    }}
    auto arg{N} = jarg{N}->cb->static_timer_callback;
    void* arg{N_next} = (void*)jarg{N}->cb;
'''

CALL_TEMPLATE = '''    {return_val} out = ({return_val}){name}({arg_string});
    return {wrap_func}(out);'''

FUNC_RETURN_TEMPLATE = '''    {return_val} out = ({return_val}){name}({arg_string});
    return {wrap_func}((JanetCFunction)out);'''

def print_arg(N, arg, M):
    argtype = arg.type.spelling
    type_kind = arg.type.kind
    jtype = None
    jfunc = None
    result = None
    template = ARG_TEMPLATE

    # special case for Fl_Callback for now
    if argtype == "Fl_Callback *":
        template = JANET_FUNC_TEMPLATE
        argtype = "JanetFlCallback *"
        jtype = "JANET_ABSTRACT"
        jfunc = "janet_getabstract"

    elif argtype == "custom_draw_callback" or argtype == "void (*)(Fl_Widget *, void *)":
        template = CUSTOM_DRAW_TEMPLATE
        argtype = "JanetFlCallback *"
        jtype = "JANET_ABSTRACT"
        jfunc = "janet_getabstract"

    elif argtype == "custom_handler_callback":
        template = CUSTOM_HANDLER_TEMPLATE
        argtype = "JanetFlCallback *"
        jtype = "JANET_ABSTRACT"
        jfunc = "janet_getabstract"

    elif argtype == "void (*)(void *)":
        template = TIMER_TEMPLATE
        argtype = "JanetFlCallback *"
        jtype = "JANET_ABSTRACT"
        jfunc = "janet_getabstract"

    elif argtype == "void *":
        template = PTR_TEMPLATE
        jtype = "JANET_POINTER"
        jfunc = "janet_getpointer"

    elif type_kind == TypeKind.POINTER:
        if argtype == "const char *":
            template = PTR_TEMPLATE
            jtype = "JANET_STRING"
            jfunc = "janet_getcstring"
        elif argtype.endswith("*"):
            template = PTR_TEMPLATE
            jtype = "JANET_POINTER"
            jfunc = "janet_getpointer"
        else:
            # print(" ** UNKNOWN POINTER TYPE", type_kind, argtype)
            return None
    elif type_kind == TypeKind.INT:
        jtype = "JANET_NUMBER"
        jfunc = "janet_getinteger"
    elif argtype in ["float", "double",
                     "unsigned int", "const unsigned int",
                     "unsigned char", "char", "short", "long",
                     "unsigned short", "unsigned long",
                     "const unsigned long"]:
        jtype = "JANET_NUMBER"
        jfunc = "janet_getnumber"
    elif type_kind == TypeKind.ELABORATED:
        # if arg.is_definition():
        #     sys.stderr.write("%s %s %s\n" % (arg.spelling, arg.type.spelling, arg.result_type.kind,))
        # print(" ** UNKNOWN type", type_kind, arg.type.spelling)
        return None
        # template = PTR_TEMPLATE
        # jtype = "JANET_POINTER"
        # jfunc = "janet_getpointer"
    else:
        # print(" ** UNKNOWN type", type_kind, arg.type.spelling)
        print(N, arg.spelling, arg.type.spelling)
        return None

    N_next = N + 1
    table = {k: str(v) for k, v in vars().items()}
    result = template.format(**table)
    return result


def call_function(name, args, return_val):
    # result = "### now call the function\n"
    result = ""
    arg_string = ", ".join(args)
    wrap_func = None
    template = CALL_TEMPLATE

    if return_val == "void":
        call = f"    {name}({arg_string});\n"
        result += call
        result += "    return janet_wrap_nil();"
        return result
    elif return_val == "int":
        wrap_func = "janet_wrap_integer"
    elif return_val in ["unsigned int", "unsigned char", "char", "float", "double", "short", "long", "unsigned short", "unsigned long"]:
        wrap_func = "janet_wrap_number"
    elif return_val == "const char *":
        wrap_func = "janet_cstringv"
    elif return_val in ["float", "double"]:
        wrap_func = "janet_wrap_number"
    elif return_val == "Fl_Callback *":
        print("Unknown return val", return_val)
        return None
        # wrap_func = "janet_wrap_cfunction"
        # template = FUNC_RETURN_TEMPLATE
    elif return_val.endswith("*"):
        return_val = return_val.replace("const", "")
        wrap_func = "janet_wrap_pointer"
    else:
        print("Unknown return val", return_val)
        return None

    if wrap_func:
        table = {k: str(v) for k, v in vars().items()}
        result += template.format(**table)

    return result

from dataclasses import dataclass

@dataclass
class Arg:
    arg: clang.cindex.Cursor
    name: str
    argtype: str
    num: int
    argv_num: int = 0
    skip: bool = False


SKIP_NEXT_VOID_ARG = [
    "Fl_Callback *",
    "custom_handler_callback",
    "custom_draw_callback",
    "void (*)(void *)",
    "void (*)(Fl_Widget *, void *)"
]

def print_janet_function(c, defs):
    result = None
    if c.kind != CursorKind.FUNCTION_DECL:
        return result
    name = c.spelling

    arity = 0
    args = []
    for i, arg in enumerate(c.get_arguments()):
        this_arg = Arg(arg=arg, name=arg.spelling, argtype=arg.type.spelling, num=i)
        args.append(this_arg)
        arity += 1

    # filter out void* after Fl_Callback*
    previous_arg_type = None
    for arg in args:
        if previous_arg_type in SKIP_NEXT_VOID_ARG and arg.argtype == "void *":
            arity -= 1
            arg.skip = True
        previous_arg_type = arg.argtype

    num_counter = 0
    for arg in args:
        if not arg.skip:
            arg.argv_num = num_counter
            num_counter += 1

    arg_types = ",".join([x.argtype for x in args])

    arg_string = ""
    len_args = len(args)
    if len(args) > 0:
        arg_string = " " + " ".join([x.name for x in args])

    return_type = c.result_type.spelling
    table = {k: str(v) for k, v in vars().items()}
    result = TEMPLATE.format(**table)
    result += "\n"
    if len(args) == 0:
        result += "    (void) argv;\n"

    cargs = []
    for arg in args:
        cargs.append(f"arg{arg.num}")

    # cast all the args
    for arg in args:
        if not arg.skip:
            res = print_arg(arg.num, arg.arg, arg.argv_num)
            if res is None:
                print("unable to handle arg", arg.name, arg.argtype)
                return None
            else:
                result += res

    # call the function
    res = call_function(name, cargs, return_type)
    if res is None:
        return None
    else:
        result += res

    result += "\n}\n"

    cname = f"cfun_{name}"

    if cname not in defs.keys():
        defs[cname] = name
    else:
        print("Warning, duplicate function name", cname)
        return None
    return result


def to_int(x):
    val = x
    if type(x) == str:
        if x.find("|") >= 0:
            parts = x.split("|")
            val = 0
            for p in parts:
                val |= to_int(p)
        elif x.find("+") >= 0:
            parts = x.split("+")
            val = 0
            for p in parts:
                val |= to_int(p)
    if type(val) == str and val.startswith("0x"):
        return int(val, 0)
    else:
        return int(val)


def handle_enum(c, ofp):
    # print(c.spelling, c.kind)
    first = True
    initial_value = -1
    for child in c.get_children():
        val = None
        for node in child.get_children():
            parts = [x.spelling for x in node.get_tokens()]
            val = "".join(parts)
            if first:
                initial_value = to_int(val)
                first = False
        if val is None and initial_value is not None:
            val = to_int(initial_value) + 1
            initial_value = val
        if val is None:
            print(f"unable to handle enum: {child.spelling}")
            sys.exit(1)
        jname = to_kebob_case(child.spelling)
        jname = child.spelling.replace("_", "-")
        ofp.write(f"(def {jname} {to_int(val)})\n")


def parse_header(fname, ofp, defs, enums):
    args = f"-c++-11 -I{dirname}/../cfltk/include".split()
    # print(args)
    idx = clang.cindex.Index.create()
    tu = idx.parse(fname, args=args)
    for c in tu.cursor.walk_preorder():
        if c.kind == CursorKind.FUNCTION_DECL:
            res = print_janet_function(c, defs)
            if res is not None and not "None" in res:
                ofp.write(res)
        elif c.kind == CursorKind.ENUM_DECL:
            handle_enum(c, enums)

if __name__ == "__main__":
    import glob

    parent_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    print(parent_dir)

    defs = dict()
    dirname = os.path.join(parent_dir, "cfltk/include")
    if not os.path.isdir(dirname):
        print("usage: wrap_fltk.py")
        sys.exit(1)

    module_file = os.path.join(parent_dir, "c/module.cpp")
    constants_file = os.path.join(parent_dir, "jfltk/constants.janet")
    with open(module_file, "w") as ofp, open(constants_file, "w") as enums:
        ofp.write("#include <iostream>\n")
        ofp.write("#include <string>\n")
        ofp.write("#include <janet.h>\n")
        ofp.write("#include <cfl.h>\n")

        headers = glob.glob(os.path.join(dirname, "*.h"))

        for h in headers:
            basename = os.path.basename(h)
            if "_" in basename:
                ofp.write(f"#include <{basename}>\n")

        ofp.write(CALLBACK)

        for header in headers:
            print(header)
            parse_header(os.path.abspath(header), ofp, defs, enums)

        ofp.write('''JANET_MODULE_ENTRY(JanetTable *env) {
        JanetRegExt cfuns[] = {\n''')
        for cname in defs.keys():
            jname = to_kebob_case(defs[cname])
            ofp.write(f'        JANET_REG("{jname}", {cname}),\n')
        ofp.write('        JANET_REG("make-callback", cfun_new_fl_callback),\n')
        ofp.write('        JANET_REG("make-custom-callback", cfun_new_custom_callback),\n')
        ofp.write('        JANET_REG("make-draw-callback", cfun_new_draw_callback),\n')
        ofp.write('        JANET_REG("make-timer-callback", cfun_new_timer_callback),\n')
        ofp.write("        JANET_REG_END\n    };\n")
        ofp.write('    janet_cfuns_ext(env, "jfltk", cfuns);\n}\n')
