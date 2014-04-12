//
//  ShaderUtility.h
//  Blood Flow Simulator
//
//  Created by Wenzhong Zhang on 2014-04-11.
//  Copyright (c) 2014 Wenzhong Zhang. All rights reserved.
//

#ifndef Blood_Flow_Simulator_ShaderUtility_h
#define Blood_Flow_Simulator_ShaderUtility_h

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

// shader compiler
GLint glueCompileShader(GLenum target,
                        GLsizei count,
                        const GLchar **sources,
                        GLuint *shader);

GLint glueLinkProgram(GLuint program);
GLint glueValidateProgram(GLuint program);
GLint glueGetUniformLocation(GLuint program, const GLchar *name);

GLint glueCreateProgram(const GLchar *vertSource,
                        const GLchar *fragSource,
                        GLsizei attribNameCt,
                        const GLchar **attribNames,
                        const GLint *attribLocations,
                        GLsizei uniformNameCt,
                        const GLchar **uniformNames,
                        GLint *uniformLocations,
                        GLuint *program);

#endif
