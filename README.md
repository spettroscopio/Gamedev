# Gamedev stuff for PureBasic
This repository contains the code I'm writing while experimenting with OpenGL and game development using Purebasic.<br>
<br>
At the moment the repo contains:<br>

### SGL
SGL is a module built on top of GLFW.<br>
You can find the module under the directory "./sgl", and the bindings to the GLFW library under "./sgl/glfw".<br>
The bindings can be used by themselves if you are interested only in [GLFW](https://www.glfw.org/).<br> 
Description [here](https://github.com/spettroscopio/gamedev/blob/main/sgl/README.md).<br>

### AUDIO
AUDIO is a module built on top of OpenAL Soft and LibSndFile.<br>
You can find the module under the directory "./audio", the binding to the OpenAl Soft library under "./audio/openal-soft" and the binding to the LibSndFile under "./audio/libsndfile".<br> 
The bindings can be used by themselves if you are interested only in [OpenAL Soft](https://openal-soft.org/) or [LibSndFile](http://libsndfile.github.io/libsndfile/).<br> 
Description [here](https://github.com/spettroscopio/gamedev/blob/main/audio/README.md).<br>
<br>
Plus various supporting code under the "./inc" directory shared among the main modules.<br>
