Task: Fix mise-tools config file discovery in Earthfile
=========================================================

Context
-------

The ``mise-tools`` stage in the Earthfile copies ``mise.tools.toml`` to ``/mise.tools.toml`` inside the container.
``mise install`` only looks for standard filenames (``mise.toml``, ``.mise.toml``, etc.) so it finds no tools to install, causing the subsequent ``find`` command to fail.

Objective
---------

Make ``mise install`` discover the tools config by renaming the file on copy.

Scope
-----

``Earthfile``, line 64: change ``COPY mise.tools.toml /`` to ``COPY mise.tools.toml /mise.toml``.
Also update line 65 (``mise trust``) to reference ``/mise.toml`` instead of ``/mise.tools.toml``.

Non-goals
---------

- Do not rename the source file in the repo.
- Do not touch any other stages or files.
