# Try to find the OPENAL library
#  OPENAL_FOUND - system has OPENAL
#  OPENAL_INCLUDE_DIR - the OPENAL include directory
#  OPENAL_LIBRARY - the OPENAL library

SET(OPENAL_APPLE_PATHS ~/Library/Frameworks /Library/Frameworks)
FIND_PATH(OPENAL_INCLUDE_DIR al.h PATH_SUFFIXES AL OpenAL PATHS ${OPENAL_APPLE_PATHS})
SET(_OPENAL_STATIC_LIBS libOpenAL.a libal.a libopenal.a libOpenAL32.a)
SET(_OPENAL_SHARED_LIBS libOpenAL.dll.a libal.dll.a libopenal.dll.a libOpenAL32.dll.a OpenAL al openal OpenAL32)
IF(USE_STATIC_LIBS)
    FIND_LIBRARY(OPENAL_LIBRARY NAMES ${_OPENAL_STATIC_LIBS} ${_OPENAL_SHARED_LIBS} PATHS ${OPENAL_APPLE_PATHS})
ELSE()
    FIND_LIBRARY(OPENAL_LIBRARY NAMES ${_OPENAL_SHARED_LIBS} ${_OPENAL_STATIC_LIBS} PATHS ${OPENAL_APPLE_PATHS})
ENDIF()
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(OpenAL DEFAULT_MSG OPENAL_LIBRARY OPENAL_INCLUDE_DIR)
MARK_AS_ADVANCED(OPENAL_LIBRARY OPENAL_INCLUDE_DIR)
