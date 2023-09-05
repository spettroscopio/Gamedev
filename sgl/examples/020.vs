#version 330 core

layout (location = 0) in vec4 vertex_position;
layout (location = 1) in vec4 vertex_color;

out vec4 v_vertex_color;

void main () {
	v_vertex_color = vertex_color;
	gl_Position = vertex_position;
}
