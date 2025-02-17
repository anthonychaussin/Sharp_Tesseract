vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO itay-grudev/SingleApplication
    REF "v${VERSION}"
    SHA512 48b6365d593c3a21ab81cffc22f017ee3af62f140da5a3fcc4b4aa4389272207ec11027188460135250939524a881291f33e17b5ee7cbdba23f891315d66424e
    HEAD_REF master
)

set(QAPPLICATION_CLASS QGuiApplication)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQT_DEFAULT_MAJOR_VERSION=6
        -DQAPPLICATION_CLASS=${QAPPLICATION_CLASS}
)

vcpkg_cmake_build(TARGET SingleApplication)

if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
  file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${VCPKG_TARGET_STATIC_LIBRARY_PREFIX}SingleApplication${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
endif()
if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
  file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${VCPKG_TARGET_STATIC_LIBRARY_PREFIX}SingleApplication${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()
file(INSTALL "${SOURCE_PATH}/singleapplication.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

configure_file("${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake" @ONLY)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")