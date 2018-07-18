cmake_minimum_required(VERSION 2.8.12)  

SET(FS_BUILD_BINARY_PREFIX "Yfs")  
#set extern libraries  
SET(LIBRARIES  
libm.so  
)  


ADD_EXECUTABLE(Main
				src/main.c
				src/a.c
				)  

#add link library  
TARGET_LINK_LIBRARIES(${FS_BUILD_BINARY_PREFIX}sqrt ${LIBRARIES}) 