#Search for VTK
find_package(VTK NO_MODULE)

if(NOT VTK_FOUND)
    return()
endif()

#Exit if version is below
if("${VTK_VERSION}" VERSION_LESS 6.2)
  message(WARNING "The minimum required version of VTK is 6.2, but found ${VTK_VERSION}")
  set(VTK_FOUND FALSE)
  return()
endif()

# assume VTK version >= 9.0
set(PCL_VTK_COMPONENTS
    CommonColor
    ChartsCore
    CommonCore
    CommonDataModel
    CommonExecutionModel
    FiltersCore
    FiltersExtraction
    FiltersGeometry
    FiltersModeling
    ImagingCore
    ImagingSources
    InteractionStyle
    InteractionWidgets
    IOCore
    IOGeometry
    IOImage
    IOLegacy
    IOPLY
    RenderingAnnotation
    RenderingLOD
    ViewsContext2D
  )

  # If not prepend vtk to names
  if(${VTK_VERSION} VERSION_LESS 9.0)
    list(TRANSFORM PCL_VTK_COMPONENTS PREPEND vtk PCL_VTK_COMPONENTS)
  endif()

if(NOT DEFINED VTK_RENDERING_BACKEND)
# Use OpenGL backend pre 8.1, else use OpenGL2
if(${VTK_VERSION} VERSION_LESS 8.1)
    set(VTK_RENDERING_BACKEND "OpenGL")
  else()
    set(VTK_RENDERING_BACKEND "OpenGL2")
  endif()
endif()

list(APPEND PCL_VTK_COMPONENTS RenderingContext${VTK_RENDERING_BACKEND})

if(WITH_QT)
  if(";${VTK_MODULES_ENABLED};" MATCHES ";vtkGUISupportQt;" AND ";${VTK_MODULES_ENABLED};" MATCHES ";vtkRenderingQt;")
    set(QVTK_FOUND ON)
    list(APPEND PCL_VTK_COMPONENTS RenderingQt GUISupportQt)
  else()
    unset(QVTK_FOUND)
  endif()
endif()

find_package(VTK NO_MODULE COMPONENTS ${PCL_VTK_COMPONENTS})

message(STATUS "VTK_MAJOR_VERSION ${VTK_MAJOR_VERSION}, rendering backend: ${VTK_RENDERING_BACKEND}")

if(PCL_SHARED_LIBS OR (NOT (PCL_SHARED_LIBS) AND NOT (VTK_BUILD_SHARED_LIBS)))
  if(${VTK_VERSION} VERSION_LESS 9.0)
    if(VTK_USE_FILE)
      include(${VTK_USE_FILE})
    endif()
    
    message(STATUS "VTK found (include: ${VTK_INCLUDE_DIRS}, libs: ${VTK_LIBRARIES}")
  endif()
  
  if(APPLE)
    option(VTK_USE_COCOA "Use Cocoa for VTK render windows" ON)
    mark_as_advanced(VTK_USE_COCOA)
  endif()
  
  if(${VTK_RENDERING_BACKEND} STREQUAL "OpenGL")
    set(VTK_RENDERING_BACKEND_OPENGL_VERSION "1")
    message(DEPRECATION "The rendering backend OpenGL is deprecated and not available anymore since VTK 8.2."
                        "Please switch to the OpenGL2 backend instead, which is available since VTK 6.2."
                        "Support of the deprecated backend will be dropped with PCL 1.13.")
  elseif(${VTK_RENDERING_BACKEND} STREQUAL "OpenGL2")
    set(VTK_RENDERING_BACKEND_OPENGL_VERSION "2")
  endif()

else()
  set(VTK_FOUND OFF)
  message("Warning: You are to build PCL in STATIC but VTK is SHARED!")
  message("Warning: VTK disabled!")
endif()
