cmake_minimum_required(VERSION 3.4.1)  # for example

set(CMAKE_CXX_STANDARD 14)

include_directories(../ios/Classes/include/)
add_library(lib_opencv SHARED IMPORTED)
set_target_properties(lib_opencv PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/app/src/main/cmakeLibs/${ANDROID_ABI}/libopencv_java4.so)

add_library(ppg_cpp SHARED 
    ../ios/Classes/src/ppg.cpp 
    ../ios/Classes/include/ppg.h 
    ../ios/Classes/include/converter.h 
    ../ios/Classes/src/converter.cpp 
    ../ios/Classes/include/evaluator.h 
    ../ios/Classes/src/evaluator.cpp
    ../ios/Classes/include/calibrator.h 
    ../ios/Classes/src/calibrator.cpp
    )


target_link_libraries(ppg_cpp lib_opencv)