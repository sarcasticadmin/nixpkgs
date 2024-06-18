{ pkgs
, lib
, buildPythonPackage
, pytestCheckHook
, python
,
}:
let
  grammarToPythonPkg = name: grammarDrv:
    let
      inherit (grammarDrv) version;

      # `name`: grammar derivation pname in the format of `tree-sitter-<lang>`

      snakeCaseName = lib.replaceStrings [ "-" ] [ "_" ] name;
      drvPrefix = "python-${name}";
      # TODO:
      # - tree-sitter language identifier kebab-case <lang>
      langIdent = lib.removePrefix "tree-sitter-" name;
    in
    buildPythonPackage {
      inherit version;
      pname = drvPrefix;

      src = pkgs.symlinkJoin {
        name = "${drvPrefix}-source";
        paths = [
          (pkgs.writeTextFile {
            name = "${drvPrefix}-init";
            text = ''
              from ._binding import language

              __all__ = ["language"]
            '';
            destination = "/${snakeCaseName}/__init__.py";
          })
          (pkgs.writeTextFile {
            name = "${drvPrefix}-binding";
            text = ''
              #include <Python.h>

              typedef struct TSLanguage TSLanguage;

              TSLanguage *${snakeCaseName}(void);

              static PyObject* _binding_language(PyObject *self, PyObject *args) {
                  return PyLong_FromVoidPtr(${snakeCaseName}());
              }

              static PyMethodDef methods[] = {
                  {"language", _binding_language, METH_NOARGS,
                  "Get the tree-sitter language for this grammar."},
                  {NULL, NULL, 0, NULL}
              };

              static struct PyModuleDef module = {
                  .m_base = PyModuleDef_HEAD_INIT,
                  .m_name = "_binding",
                  .m_doc = NULL,
                  .m_size = -1,
                  .m_methods = methods
              };

              PyMODINIT_FUNC PyInit__binding(void) {
                  return PyModule_Create(&module);
              }
            '';
            destination = "/${snakeCaseName}/binding.c";
          })
          (pkgs.writeTextFile {
            name = "${drvPrefix}-setup.py";
            text = ''
              from platform import system
              from setuptools import Extension, setup


              setup(
                name="${snakeCaseName}",
                version="${version}",
                packages=["${snakeCaseName}"],
                ext_package="${snakeCaseName}",
                ext_modules=[
                  Extension(
                    name="_binding",
                    sources=["${snakeCaseName}/binding.c"],
                    extra_objects = ["${grammarDrv}/parser"],
                    extra_compile_args=(
                      ["-std=c11"] if system() != 'Windows' else []
                    ),
                    define_macros=[
                      ("Py_LIMITED_API", "0x03080000"),
                      ("PY_SSIZE_T_CLEAN", None)
                    ],
                    py_limited_api=True,
                  )
                ],
              )
            '';
            destination = "/setup.py";
          })
          (pkgs.writeTextFile {
            name = "${drvPrefix}-test";
            text = ''
              from ${snakeCaseName} import language
              from tree_sitter import Language, Parser


              def test_language():
                lang = Language(language(), "${langIdent}")
                assert lang is not None
                parser = Parser()
                parser.set_language(lang)
                tree = parser.parse(bytes("", "utf-8"))
                assert tree is not None
            '';
            destination = "/tests/test_language.py";
          })
        ];
      };

      preCheck = ''
        rm -r ${snakeCaseName}
      '';

      nativeCheckInputs = [ python.pkgs.tree-sitter pytestCheckHook ];
      pythonImportsCheck = [ snakeCaseName ];

      meta = {
        description = "Python bindings for ${langIdent} tree-sitter grammar";
        maintainers = with lib.maintainers; [ a-jay98 adfaure mightyiam stepbrobd ];
        license = lib.licenses.mit;
      };
    };
in
# TODO pkgset or flattened?
lib.mapAttrs grammarToPythonPkg (builtins.removeAttrs pkgs.tree-sitter.builtGrammars [
  "tree-sitter-perl"
  "tree-sitter-ql-dbscheme"
  "tree-sitter-org-nvim"
])
