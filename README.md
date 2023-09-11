# Gamedev stuff for PureBasic
This repository contains the stuff I'm writing while experimenting with OpenGL and game development using Purebasic.<br>
Maybe some of this can be useful to someone else so here it is.<br>
<br>
At the moment the repo contains:<br>

### SGL
SGL is a module built on top of GLFW (https://www.glfw.org/), and it is intended to take care of all the recurring tasks required when writing OpenGL code in PureBasic.<br>
You can find the module under the directory "./sgl", and the binding to the GLFW library under "./sgl/glfw".<br>
The binding can be used by itself if you are interested in only that.<br>
More info [here](https://github.com/spettroscopio/gamedev/blob/main/sgl/README.md).<br>

### AUDIO
AUDIO is a module built on top of OpenAL Soft (https://openal-soft.org/) and LibSndFile (http://libsndfile.github.io/libsndfile/), and as the name suggests it offers an alternative way to play sounds in PureBasic.<br> 
You can find the module under the directory "./audio", the binding to the OpenAl Soft library under "./audio/openal-soft" and the binding to the LibSndFile under "./audio/libsndfile".<br> 
The bindings can be used by themselves if you are interested in only those.<br> 
More info [here](https://github.com/spettroscopio/gamedev/blob/main/audio/README.md).<br>
<br>
Plus various supporting code under the "inc" directory wich is shared by the main modules.<br>
