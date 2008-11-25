// -*- lsst-c++ -*-

// This SWIG file provides generally useful functionality, macros,
// and includes to all LSST packages.
//
// Any types or SWIG typemaps added to this file will therefore
// affect a lot of code, and should be _very_ carefully considered.


#if defined(SWIGPYTHON)

// Don't allow user to add attributes to C-defined classes; catches a variety of
// typos when the user _thinks_ that they're setting a C-level object, but in
// reality they're adding a new (and irrelevent) member to the class
%pythonnondynamic;
#endif

%naturalvar;  // use const reference typemaps

%include "cpointer.i"
%include "exception.i"
%include "std_list.i"
%include "std_map.i"
%include "std_string.i"
%include "std_set.i"
%include "std_vector.i"
%include "std_iostream.i"
%include "boost_shared_ptr.i"
%include "carrays.i"
%include "typemaps.i"

// N.b. these may interfere with the use of e.g. std_list.i for primitive types;
// you will have to say e.g.
// %clear int &;
//    %template(listInt)   std::list<int>;
//    %template(mapIntInt) std::map<int,int>;
// %apply int &OUTPUT { int & };

// Removed by ktl 2007-11-06 due to interference with other code.
// No methods visible to Python are expected to return values through argument
// references; if they do, they should be appropriately handled locally.
//
// %apply int &OUTPUT { int & };
// %apply float &OUTPUT { float & };
// %apply double &OUTPUT { double & };

// %array_class(float, floatArray);
// %array_class(double, doubleArray);


// Mapping C++ exceptions to Python

#if !defined(NO_SWIG_LSST_EXCEPTIONS)

%pythoncode %{
    import lsst.pex.exceptions
%}

%{
#include <new>
#include "lsst/pex/exceptions/Exception.h"
#include "lsst/pex/exceptions/Runtime.h"
%}

// Use the Python C API to create the constructor argument tuple (a message string and a
// DataProperty corresponding to an ExceptionStack) for a Python exception class assumed to
// be derived from lsst.pex.exceptions.LsstExceptionStack. Also obtain a class object for
// the desired exception type. Use the class object and tuple to raise a Python exception.
%{
static void raiseLsstException(lsst::pex::exceptions::Exception& ex) {
    PyObject* pyex = 0;
    swig_type_info* tinfo = SWIG_TypeQuery(ex.ctype());
    if (tinfo != 0) {
	lsst::pex::exceptions::Exception* e =
            new lsst::pex::exceptions::Exception(ex);
        pyex = SWIG_NewPointerObj(static_cast<void*>(e), tinfo,
            SWIG_POINTER_OWN);
    } else {
        pyex = Py_None;
    }

    PyErr_SetObject(PyObject_Type(pyex), pyex);
}

%}

#endif

// Turns on the default C++ to python exception handling interface
%define %lsst_exceptions()
    %exception {
        try {
            $action
        } catch (lsst::pex::exceptions::Exception &e) {
            raiseLsstException(e);
            SWIG_fail;
        } catch (std::exception & e) {
            PyErr_SetString(PyExc_Exception, e.what());
            SWIG_fail;
        }
    }
%enddef


// Throw an exception if func returns NULL
%define NOTNULL(func)
    %exception func {
        $action;
        if (result == NULL) {
            $cleanup;
        }
    }
%enddef

// Throw an exception if func returns a negative value
%define NOTNEGATIVE(func)
    %exception func {
        $action;
        if (result < 0) {
            $cleanup;
        }
    }
%enddef

// convert void pointer to (TYPE *)
%define CAST(TYPE)
    %pointer_cast(void *, TYPE *, cast_ ## TYPE ## Ptr);
%enddef

