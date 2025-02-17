vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DragonJoker/Ashes
    REF c532e8ff5b6f64150d24348ef40a02df4e692017
    HEAD_REF master
    SHA512 1c5833ce898532b3ae87961743a921223e08bd80c25ef33155ee11c241f2eaca9047f2cfca8d2661bd3302d22acabc4cf13ccccd2f25a48c4ebc9976ad193c24
)

vcpkg_from_github(
    OUT_SOURCE_PATH CMAKE_SOURCE_PATH
    REPO DragonJoker/CMakeUtils
    REF 988f2aab2257175e8fb15a33a3a350ff92d25b89
    HEAD_REF master
    SHA512 961370c110e77f67ed6f426d410335636ca3b5812ba1837662cc5fea403791cafa443c1a25144b92aed5edfc5928eb6e706883ea7f1e68de1123845cb89acb86
)

file(REMOVE_RECURSE "${SOURCE_PATH}/CMake")
file(COPY "${CMAKE_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/CMake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        direct3d11 ASHES_BUILD_RENDERER_D3D11
        opengl     ASHES_BUILD_RENDERER_OGL
        vulkan     ASHES_BUILD_RENDERER_VKN
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DVCPKG_PACKAGE_BUILD=ON
        -DASHES_BUILD_TEMPLATES=OFF
        -DASHES_BUILD_TESTS=OFF
        -DASHES_BUILD_INFO=OFF
        -DASHES_BUILD_SAMPLES=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ashes)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
