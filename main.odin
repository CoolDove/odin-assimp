package assimp

import "base:runtime"
import "core:fmt"
import "core:strings"
import "core:math"
import "core:math/rand"
import "core:math/linalg"
import "core:c/libc"

import rl "vendor:raylib"

import ai "import"

@private
main :: proc() {
	rl.SetTargetFPS(60)
	rl.InitWindow(800, 600, "Assimp Test")

	cam : rl.Camera3D
	cam.position = { 100.0, 100.0, 100.0 }
	cam.target = { 0.0, 0.0, 0.0 }
	cam.up = { 0.0, 1.0, 0.0 }
	cam.fovy = 45.0
	cam.projection = .PERSPECTIVE

	model_duck   := rl_assimp_load("models/animals/DuckWhite.fbx")

	for !rl.WindowShouldClose() {
		rl.UpdateCamera(&cam, .ORBITAL)
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		rl.BeginMode3D(cam)
			rl.DrawLine3D({0,0,-100}, {0,0,100}, rl.DARKGRAY)
			rl.DrawLine3D({-100,0,0}, {100,0,0}, rl.DARKGRAY)

			rl.DrawCube({}, 1,1,1, rl.RED)

			rl.DrawModel(model_duck, {}, 1, rl.WHITE)
			rl.DrawModelWires(model_duck, {}, 1, {0,0,0,12})

		rl.EndMode3D()
		rl.EndDrawing()
	}

	rl.UnloadModel(model_duck)

	rl.CloseWindow()
}

// only load the first mesh in a scene
@private
rl_assimp_load :: proc {
	rl_assimp_load_from_file,
	rl_assimp_load_from_data,
}
@private
rl_assimp_load_from_file :: proc(file: string) -> rl.Model {
	scene := import_file_from_file(file, auto_cast ai.aiProcessPreset_TargetRealtime_Quality)
	defer release_import(scene)
	return _rl_assimp_process_scene(scene)
}
@private
rl_assimp_load_from_data :: proc(buffer: []byte, format_hint: string) -> rl.Model {
	scene := import_file_from_memory(buffer, auto_cast ai.aiProcessPreset_TargetRealtime_Quality, format_hint)
	defer release_import(scene)
	return _rl_assimp_process_scene(scene)
}
@private
_rl_assimp_process_scene :: proc(scene : ^Scene) -> rl.Model {
	check_scene(scene)
	return rl_load_model_from_aimesh(scene.mMeshes[0])
}

@private
rl_load_model_from_aimesh :: proc(aimesh: ^Mesh) -> rl.Model {
	aicolors := aimesh.mColors[0]
	mesh : rl.Mesh; {
		mesh.vertexCount = auto_cast aimesh.mNumVertices
		indices := cast([^]u16)rl.MemAlloc(auto_cast ( size_of(u16) * aimesh.mNumFaces * 3 ))
		for i in 0..<aimesh.mNumFaces {
			face := aimesh.mFaces[i]
			mesh.triangleCount += 1
			assert(face.mNumIndices == 3, "None-triangle face!")
			indices[i*3+0] = cast(u16)face.mIndices[0]
			indices[i*3+1] = cast(u16)face.mIndices[1]
			indices[i*3+2] = cast(u16)face.mIndices[2]
		}
		vertices :[^]Vector3D= auto_cast rl.MemAlloc(auto_cast (size_of(Vector3D) * mesh.vertexCount))
		normals  :[^]Vector3D= auto_cast rl.MemAlloc(auto_cast (size_of(Vector3D) * mesh.vertexCount))
		colors   :[^][4]u8   = nil
		if aicolors != nil {
			colors = auto_cast rl.MemAlloc(auto_cast (4 * mesh.vertexCount))
		}
		for v in 0..<aimesh.mNumVertices {
			vertices[v] = aimesh.mVertices[v]
			normals[v] = aimesh.mNormals[v]
			if aicolors != nil {
				col := aicolors[v]
				colors[v] = {
					auto_cast(col.r*255),
					auto_cast(col.g*255),
					auto_cast(col.b*255),
					auto_cast(col.a*255)
				}
			}
		}

		mesh.indices  = auto_cast indices
		mesh.vertices = auto_cast vertices
		mesh.normals  = auto_cast normals
		mesh.colors   = auto_cast colors
		rl.UploadMesh(&mesh, false)
	}
	rlmodel := rl.LoadModelFromMesh(mesh)
	return rlmodel
}

@private
check_scene :: proc(scene: ^Scene) {
	fmt.printf("==== Scene ====\n")
	mesh_count := scene.mNumMeshes
	meshes := scene.mMeshes
	for i in 0..<mesh_count {
		mesh := meshes[i]
		name := string_clone_from_ai_string(&mesh.mName)
		uv_channel_count, color_channel_count := 0, 0
		for uv in mesh.mNumUVComponents do if uv != 0 do uv_channel_count += 1
		for c in mesh.mColors do if c != nil do color_channel_count += 1
		fmt.printf("- Mesh: [{}] has {} vertices, {} uv channels, {} color channels.\n", 
			name, mesh.mNumVertices, uv_channel_count, color_channel_count)
		uv_components := mesh.mNumUVComponents 
	}
}
