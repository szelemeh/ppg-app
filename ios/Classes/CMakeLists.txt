cmake_minimum_required(VERSION 3.19)
project(ppg_cpp_app)

set(CMAKE_CXX_STANDARD 14)

set(OpenCV_DIR /usr/local/Cellar/opencv/4.5.2/lib/cmake/opencv4)
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})

add_library(ppg_cpp_app SHARED
        src/ppg.cpp
        include/ppg.h
        include/converter.h
        src/converter.cpp
        include/evaluator.h
        src/evaluator.cpp
        include/calibrator.h
        src/calibrator.cpp)

add_executable(main
        src/main.cpp
        src/ppg.cpp
        include/ppg.h
        include/converter.h
        src/converter.cpp
        src/ppg.cpp
        include/ppg.h
        )

target_link_libraries(main ${OpenCV_LIBS})