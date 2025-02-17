# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/sort
    REF boost-${VERSION}
    SHA512 6c6257bc3c7fc12cbef19e0a96390683d6f8a1cd293beafe86ad9b1d425bb58d00a5788bb45bf7b666ab8259f5934db9c07dd862662ec89f16c170f75c75bc1e
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
