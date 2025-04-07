import os
import sys
import clang.cindex
from clang.cindex import CursorKind, TypeKind

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


TEMPLATE = '''
JANET_FN(cfun_{name},
         "(jfltk/{name}{arg_string})",
         "") {{
    janet_fixarity(argc, {len_args});'''

ARG_TEMPLATE = '''    if (!janet_checktype(argv[{N}], {jtype})) {{
        janet_panicf("expected {argtype}, got %%q", argv[{N}]);
    }}
    {argtype} arg{N} = {jfunc}(argv, {N});
'''

# FUNCPTR_TEMPLATE = '''    if (!janet_checktype(argv[{N}], {jtype})) {{
#         janet_panicf("expected {argtype}, got %%q", argv[{N}]);
#     }}
#     {argtype} arg{N} = {jfunc}(argv, {N});
# '''

PTR_TEMPLATE  = '''    if (!janet_checktype(argv[{N}], {jtype})) {{
        janet_panicf("expected {argtype}, got %%q", argv[{N}]);
    }}
    {argtype} arg{N} = ({argtype}){jfunc}(argv, {N});
    if (!arg{N}) {{
        janet_panicf("expected {argtype}, got nil");
    }}
'''

CALL_TEMPLATE = '''    {return_val} out = ({return_val}){name}({arg_string});
    return {wrap_func}(out);'''

FUNC_RETURN_TEMPLATE = '''    {return_val} out = ({return_val}){name}({arg_string});
    return {wrap_func}((JanetCFunction)out);'''

def print_arg(N, arg):
    argtype = arg.type.spelling
    type_kind = arg.type.kind
    jtype = None
    jfunc = None
    result = None
    template = ARG_TEMPLATE

    # special case for Fl_Callback for now
    if argtype.find("Fl_Callback") >= 0:
        print("  CB", argtype, type_kind)
        return None

    if type_kind == TypeKind.POINTER:
        if argtype == "const char *":
            template = PTR_TEMPLATE
            jtype = "JANET_STRING"
            jfunc = "janet_getcstring"
        elif argtype.endswith("*"):
            template = PTR_TEMPLATE
            jtype = "JANET_POINTER"
            jfunc = "janet_getpointer"
        else:
            print(" ** UNKNOWN POINTER TYPE", type_kind, argtype)
            return None
    elif type_kind == TypeKind.INT:
        jtype = "JANET_NUMBER"
        jfunc = "janet_getinteger"
    elif argtype in ["float", "double", "unsigned int", "unsigned char", "char", "unsigned short"]:
        jtype = "JANET_NUMBER"
        jfunc = "janet_getnumber"
    elif type_kind == TypeKind.ELABORATED:
        # if arg.is_definition():
        #     sys.stderr.write("%s %s %s\n" % (arg.spelling, arg.type.spelling, arg.result_type.kind,))
        print(" ** UNKNOWN type", type_kind, arg.type.spelling)
        return None
        # template = PTR_TEMPLATE
        # jtype = "JANET_POINTER"
        # jfunc = "janet_getpointer"
    else:
        print(" ** UNKNOWN type", type_kind, arg.type.spelling)
        print(N, arg.spelling, arg.type.spelling)
        return None

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
    elif return_val in ["unsigned int", "unsigned char", "char", "float", "double", "unsigned short"]:
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

def print_janet_function(c, defs):
    result = None
    if c.kind != CursorKind.FUNCTION_DECL:
        return result
    name = c.spelling
    args = [(x.spelling, x.type.spelling) for x in c.get_arguments()]
    arg_types = ",".join([x.type.spelling for x in c.get_arguments()])
    arg_string = ""
    len_args = len(args)
    if len(args) > 0:
        arg_string = " " + " ".join([x[0] for x in args])

    return_type = c.result_type.spelling
    table = {k: str(v) for k, v in vars().items()}
    result = TEMPLATE.format(**table)
    result += "\n"
    if len(args) == 0:
        result += "    (void) argv;\n"

    # cast all the args
    cargs = []
    for (i, arg) in enumerate(c.get_arguments()):
        cargs.append(f"arg{i}")
        res = print_arg(i, arg)
        if res is None:
            print("unable to handle arg", arg.spelling, arg.type.spelling)
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

    # defs[name] = f"cfun_{name}"
    cname = f"cfun_{name}"

    if cname.find("_set_callback") > 0:
        print("CB", cname, res)

    if cname not in defs.keys():
        defs[cname] = name
    else:
        print("Warning, duplicate function name", cname)
        return None
    return result


def parse_header(fname, ofp, defs):
    args = f"-c++-11 -I{dirname}/../cfltk/include".split()
    # print(args)
    idx = clang.cindex.Index.create()
    tu = idx.parse(fname, args=args)
    for c in tu.cursor.walk_preorder():
        if c.kind == CursorKind.FUNCTION_DECL:
            res = print_janet_function(c, defs)
            if res is not None and not "None" in res:
                ofp.write(res)
            # else:
            #     print(res)


if __name__ == "__main__":
    import glob
    if len(sys.argv) < 3:
        print("usage: wrap_fltk.py <dirname> <outfile>")
        sys.exit(0)

    defs = dict()
    dirname = sys.argv[1]
    if not os.path.isdir(dirname):
        print("usage: wrap_fltk.py <dirname> <outfile>")
        sys.exit(1)

    with open(sys.argv[2], "w") as ofp:
        ofp.write("#include <janet.h>\n")
        ofp.write("#include <cfl.h>\n")

        headers = glob.glob(os.path.join(dirname, "*.h"))
        # headers = ["cfltk/include/cfl.h", "cfltk/include/cfl_widget.h", "cfltk/include/cfl_window.h"]

        for h in headers:
            basename = os.path.basename(h)
            if "_" in basename:
                ofp.write(f"#include <{basename}>\n")

        for header in headers:
            print(header)
            parse_header(os.path.abspath(header), ofp, defs)

        ofp.write('''JANET_MODULE_ENTRY(JanetTable *env) {
        JanetRegExt cfuns[] = {\n''')
        for cname in defs.keys():
            ofp.write(f'        JANET_REG("{defs[cname]}", {cname}),\n')
        ofp.write("        JANET_REG_END\n    };\n")
        ofp.write('    janet_cfuns_ext(env, "jfltk", cfuns);\n}\n')