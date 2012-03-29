from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

ext_modules = [
        Extension("celt",
            sources = ["celt.pyx"],
            include_dirs = ["/usr/include/celt"],
            library_dirs = ["/usr/lib"],
            libraries = ["celt0"])
]

setup(
        cmdclass = {"build_ext": build_ext},
        ext_modules = ext_modules
)
