==============================
CAENVME.PY :: Python wrapper for CAENVMElib
==============================

caenvme.py is a thin wrapper module for the CAENVMElib library, which is used
to communicate with VME modules via USB or optical interface (CAEN A2818).

Requirements
---------------------
	python 2.x
	CAENVMElib
	cython

Installation
----------------
	Installation should work with 'make', 'make install' there is no 'configure' 
	script.

Usage
---------
	If the module is installed in a global Python path, then you should be able 
	to import it via 'import caenvme'. Further infos on the individual functions 
	can be found in docstrings or in the CAEN v2718 manual.

Notes
--------
	- to install CAENVMElib follow the directions in the corresponding Readme
	- the location of the CAENVMElib headers is currently hardcoded in the 'pxd'
	  file
	- only a subset of the CAENVMElib functionality is implemented at the
	  moment, if you need additional functions feel free to implement them ;)
	- in order to communicate with the VME controller the driver for the optical
	  interface (CAEN A2818) must be loaded, instructions how to do this can be
	  found in the corresponding Readme

Authors
------------
	Christian Strandhagen - strandhagen _at_ pit.physik.uni-tuebingen.de


