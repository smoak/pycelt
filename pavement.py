from paver.easy import *
from paver.setuputils import setup

setup(
        name="pycelt",
        version="0.0.1",
        author="Scott Moak",
        author_email="scott.moak@gmail.com"
)

@task
def build():
    sh("python2 setup.py build_ext -i")

@task
def clean():
    path("build").rmtree()
    path("celt.c").remove()
