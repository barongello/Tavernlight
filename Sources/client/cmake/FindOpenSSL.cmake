# Try to find the OpenSSL library
#  OPENSSL_FOUND - system has OpenSSL
#  OPENSSL_INCLUDE_DIR - the OpenSSL include directory
#  OPENSSL_LIBRARY - the OpenSSL library

FIND_PATH(OPENSSL_INCLUDE_DIR NAMES openssl/ssl.h PATH_SUFFIXES include openssl-1.0)
SET(_OPENSSL_STATIC_LIBS libssl.a ssl.a)
SET(_OPENSSL_SHARED_LIBS libssl ssl)
SET(_OPENSSL_CRYPTO_STATIC_LIBS libcrypto.a crypto.a)
SET(_OPENSSL_CRYPTO_SHARED_LIBS libcrypto crypto)
IF(USE_STATIC_LIBS)
    FIND_LIBRARY(OPENSSL_LIBRARY NAMES ${_OPENSSL_STATIC_LIBS} ${_OPENSSL_SHARED_LIBS} PATH_SUFFIXES openssl-1.0)
    FIND_LIBRARY(OPENSSL_CRYPTO_LIBRARY NAMES ${_OPENSSL_CRYPTO_STATIC_LIBS} ${_OPENSSL_CRYPTO_SHARED_LIBS} PATH_SUFFIXES openssl-1.0)
ELSE()
    FIND_LIBRARY(OPENSSL_LIBRARY NAMES ${_OPENSSL_SHARED_LIBS} ${_OPENSSL_STATIC_LIBS} PATH_SUFFIXES openssl-1.0)
    FIND_LIBRARY(OPENSSL_CRYPTO_LIBRARY NAMES ${_OPENSSL_CRYPTO_SHARED_LIBS} ${_OPENSSL_CRYPTO_STATIC_LIBS} PATH_SUFFIXES openssl-1.0)
ENDIF()
SET(OPENSSL_LIBRARIES ${OPENSSL_LIBRARY} ${OPENSSL_CRYPTO_LIBRARY})
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(OpenSSL DEFAULT_MSG OPENSSL_LIBRARIES OPENSSL_INCLUDE_DIR)
MARK_AS_ADVANCED(OPENSSL_LIBRARIES OPENSSL_LIBRARY OPENSSL_CRYPTO_LIBRARY OPENSSL_INCLUDE_DIR)
