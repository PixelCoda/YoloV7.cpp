
# yolov7.cpp
Simple JSON Object Detection using YOLOv7 and OpenCV DNN C++

### Prepare custom weight
Download my pre converted weights
```shell
wget https://www.dropbox.com/s/yaxcikpiq9v6i1d/yolov7.onnx -O ./data/yolov7.onnx
```

### To compile and run cpp version
```bash
# In root of repo directory
cd cpp
mkdir build
cd build
cmake ..
make
./app "../../data/me.jpeg" "../../data/yolov7.onnx" 640 640
{
 "objects": [ 
  {"class_id":0, "name":"person", "coordinates":{"x":72, "y":84, "width":842, "height":603}, "confidence":0.825500}  {"class_id":67, "name":"cell phone", "coordinates":{"x":15, "y":122, "width":247, "height":345}, "confidence":0.825312}  {"class_id":0, "name":"person", "coordinates":{"x":0, "y":233, "width":154, "height":456}, "confidence":0.449767}
 ] 
}
```

:information_source: If you got following error, you must install [opencv](https://github.com/opencv/opencv) on your system.
```
CMake Error at CMakeLists.txt:7 (find_package):
  By not providing "FindOpenCV.cmake" in CMAKE_MODULE_PATH this project has
  asked CMake to find a package configuration file provided by "OpenCV", but
  CMake did not find one.

  Could not find a package configuration file provided by "OpenCV" with any
  of the following names:

    OpenCVConfig.cmake
    opencv-config.cmake

  Add the installation prefix of "OpenCV" to CMAKE_PREFIX_PATH or set
  "OpenCV_DIR" to a directory containing one of the above files.  If "OpenCV"
  provides a separate development package or SDK, be sure it has been
  installed.
```