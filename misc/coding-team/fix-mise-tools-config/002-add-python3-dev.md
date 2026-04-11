Task: Add python3-dev to mise stage for sqlglotc compilation
=============================================================

Context
-------

The ``mise-pipx`` stage installs ``mycli`` via ``uv``.
``mycli`` depends on ``sqlglot[c]`` which pulls in ``sqlglotc``, a C extension requiring ``Python.h``.
The ``mise`` stage (which ``mise-pipx`` inherits from) has ``build-base`` and ``uv`` but not ``python3-dev``, so the compilation fails.

Objective
---------

Add ``python3-dev`` to the ``apk add`` in the ``mise`` stage so ``Python.h`` is available.

Scope
-----

``Earthfile``, lines 53-58: add ``python3-dev`` to the existing ``apk add --no-cache`` list in the ``mise`` target.

Non-goals
---------

- Do not touch any other stage.
- Do not restructure the multi-stage build.
- Do not optimize image size.

Verification
------------

Run ``earthly +deploy`` and confirm the build completes successfully.
