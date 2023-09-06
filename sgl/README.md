# SGL (Simple GL)
SGL for PureBasic.<br>
SGL is a module built on top of GLFW (3.3.8), and it is intended to take care of all the recurring tasks required when writing OpenGL code in PureBasic.<br>
Some of the things it can help with are: windowing, context creation, importing of OpenGL functions, debugging, timers, mouse, keyboard, monitors, system info, images and textures, font loading, shaders.<br>

It works on Windows (32/64 bits) and Linux (64 bits).<br>

The sub-repository is organized this way:

| directory | contents |
| ------ | ------ |
| glfw | The import of the GLFW library. |
| gl | A module used to dynamically import all the OpenGL functions up to version 4.6. |
| extras | Extra code beyond the scope of the library but instructive and/or useful. |
| extensions | A template to show how to implement specific extensions support. |
| examples | Short examples to demonstrates the use of SGL commands in practice. |
| demos | Longer examples, to experiment with specific OpenGL features. |
| inc | Supporting includes of various nature, for example debugging, matrices, vectors, etc. |

### What you need to run this ?
Just PureBasic. The only dependency is the GLFW library and it's included.<br>
All the test code should work inside the IDE without the need of altering paths, looking for libraries around, etc.<br>

### What you have to do to distribute something using this ?
The binaries of the GLFW library are under glfw/lib.<br>
Static linking is supported only on Windows.<br>
If you build an executable and select dinamic linking in your configuration file (sgl.pbi) or in your private copy of it, then the correct dinamic library must be copied to the same directory of the executable, or under ./lib or ./bin below that directory.<br>
The initialization of the library will look there.<br>

### That's all !
This is a work in progress even if it has all the features I seem to require at the moment.<br>
I will probably keep adding examples and demos to this repository when I need to experiment with some code or idea.<br>
For example right now this contains simple implementations of font rendering, FPS and ArcBall cameras, a Batch Renderer for quads, a basic IMGUI, etc.<br>

My idea is now to start using this to build a simple 2D game engine, to learn something more about game programming while writing all the base functionalities myself.<br>
In the future even a 3D one perhaps, who knows !<br>

For announcements, comments, questions please go [here](https://www.purebasic.fr/english/viewtopic.php?t=81764).
