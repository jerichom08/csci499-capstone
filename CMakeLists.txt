cmake_minimum_required(VERSION 3.21)
project(csci499-capstone LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Disable raylib extras
set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(BUILD_GAMES OFF CACHE BOOL "" FORCE)

add_subdirectory(external/raylib)

add_executable(csci499-capstone src/main.cpp)
target_link_libraries(csci499-capstone PRIVATE raylib)
