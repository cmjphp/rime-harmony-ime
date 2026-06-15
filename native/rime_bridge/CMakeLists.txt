cmake_minimum_required(VERSION 3.5)
project(rime_bridge)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(RIME_BRIDGE_USE_REAL_RIME "Build native bridge with real librime instead of stub" OFF)

set(RIME_REAL_ENGINE_ENABLED OFF)
if(RIME_BRIDGE_USE_REAL_RIME)
    if(NOT DEFINED RIME_THIRD_PARTY_PREFIX)
        if(DEFINED OHOS_ARCH)
            set(RIME_THIRD_PARTY_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/ohos/${OHOS_ARCH}")
        else()
            set(RIME_THIRD_PARTY_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/ohos/arm64-v8a")
        endif()
    endif()

    set(RIME_INCLUDE_DIR "${RIME_THIRD_PARTY_PREFIX}/include")
    set(RIME_LIBRARY_DIR "${RIME_THIRD_PARTY_PREFIX}/lib")
    set(RIME_STATIC_LIBS
        "${RIME_LIBRARY_DIR}/librime.a"
        "${RIME_LIBRARY_DIR}/libboost_regex.a"
        "${RIME_LIBRARY_DIR}/libyaml-cpp.a"
        "${RIME_LIBRARY_DIR}/libleveldb.a"
        "${RIME_LIBRARY_DIR}/libmarisa.a"
        "${RIME_LIBRARY_DIR}/libopencc.a"
        "${RIME_LIBRARY_DIR}/libglog.a"
    )

    set(RIME_MISSING_LIBS "")
    foreach(lib_path ${RIME_STATIC_LIBS})
        if(NOT EXISTS "${lib_path}")
            list(APPEND RIME_MISSING_LIBS "${lib_path}")
        endif()
    endforeach()

    if(EXISTS "${RIME_INCLUDE_DIR}/rime_api.h" AND RIME_MISSING_LIBS STREQUAL "")
        set(RIME_REAL_ENGINE_ENABLED ON)
    else()
        message(WARNING "Real librime bridge requested, but dependencies are missing. Falling back to stub. Missing: ${RIME_MISSING_LIBS}")
    endif()
endif()

add_library(rime_bridge SHARED
    napi_init.cpp
    rime_bridge.cpp
    rime_engine_stub.cpp
)

if(RIME_REAL_ENGINE_ENABLED)
    target_sources(rime_bridge PRIVATE rime_engine_real.cpp)
    target_compile_definitions(rime_bridge PRIVATE RIME_BRIDGE_USE_REAL_RIME=1)
    target_include_directories(rime_bridge PRIVATE ${RIME_INCLUDE_DIR})
    target_compile_definitions(rime_bridge PRIVATE BOOST_DISABLE_THREADS)
    target_link_libraries(rime_bridge PRIVATE ${RIME_STATIC_LIBS})
endif()

target_include_directories(rime_bridge PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(rime_bridge PUBLIC libace_napi.z.so)
