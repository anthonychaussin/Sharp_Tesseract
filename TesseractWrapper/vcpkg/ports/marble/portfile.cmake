
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/marble
    REF "v${VERSION}"
    SHA512 06d2c9f4c85a5ab66825701fa949f35756ff2f09acc65c2ac5c367bd245ee1b674214070a01f828124d8add3f9cdd06e68e0e93091e47501210c5686ae68f29f
    HEAD_REF master
    PATCHES 
        qtfix.patch
        protobuf.patch
        cpack.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_I18n=ON
        -DWITH_KF5=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)

# Install  plugins and data files
file(GLOB_RECURSE PLUGINS "${CURRENT_PACKAGES_DIR}/plugins/*")
file(GLOB_RECURSE PLUGINS_DESIGNER "${CURRENT_PACKAGES_DIR}/lib/plugins/*")
file(GLOB_RECURSE PLUGINS_DEBUG "${CURRENT_PACKAGES_DIR}/debug/lib/plugins/*")
file(GLOB_RECURSE MKSPECS "${CURRENT_PACKAGES_DIR}/mkspecs/*")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(COPY ${PLUGINS} ${PLUGINS_DESIGNER} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/plugins")
file(COPY ${PLUGINS_DEBUG} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}/plugins")
file(COPY "${CURRENT_PACKAGES_DIR}/data" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}") # have to keep folder structure here
file(COPY ${MKSPECS} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/mkspecs")

# remove plugin folder
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/plugins" "${CURRENT_PACKAGES_DIR}/debug/plugins"
    "${CURRENT_PACKAGES_DIR}/data"    "${CURRENT_PACKAGES_DIR}/debug/data"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/mkspecs" "${CURRENT_PACKAGES_DIR}/debug/mkspecs"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/lib/plugins"   "${CURRENT_PACKAGES_DIR}/lib/plugins"
    "${CURRENT_PACKAGES_DIR}/debug/marble-qt.exe"
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
file(RENAME "${CURRENT_PACKAGES_DIR}/astro.dll" "${CURRENT_PACKAGES_DIR}/bin/astro.dll")
file(RENAME "${CURRENT_PACKAGES_DIR}/marbledeclarative.dll" "${CURRENT_PACKAGES_DIR}/bin/marbledeclarative.dll")
file(RENAME "${CURRENT_PACKAGES_DIR}/marblewidget-qt5.dll" "${CURRENT_PACKAGES_DIR}/bin/marblewidget-qt5.dll")
file(RENAME "${CURRENT_PACKAGES_DIR}/marble-qt.exe" "${CURRENT_PACKAGES_DIR}/tools/marble/marble-qt.exe")

if(NOT VCPKG_BUILD_TYPE)
  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
  file(RENAME "${CURRENT_PACKAGES_DIR}/debug/astrod.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/astrod.dll")
  file(RENAME "${CURRENT_PACKAGES_DIR}/debug/marbledeclaratived.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/marbledeclaratived.dll")
  file(RENAME "${CURRENT_PACKAGES_DIR}/debug/marblewidget-qt5d.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/marblewidget-qt5d.dll")
endif()

vcpkg_copy_pdbs()

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
