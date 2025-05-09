#+ private
package assimp

import "base:runtime"
import "core:fmt"
import "core:strings"
import "core:c/libc"

import rl "vendor:raylib"

import ai "import"

DATA_BANANA_FBX   :: #load("banana.fbx")

main :: proc() {
	mushroom := import_file_from_file("mushroom.fbx", auto_cast ai.aiProcessPreset_TargetRealtime_Quality)
	banana := import_file_from_memory(DATA_BANANA_FBX, auto_cast ai.aiProcessPreset_TargetRealtime_Quality, "fbx")
	defer {
		release_import(banana)
		release_import(mushroom)
		fmt.printf("Loaded scene has been released.")
	}

	if mushroom != nil do check_scene(mushroom, "mushroom.fbx")
	if banana   != nil do check_scene(banana, "banana.fbx")

	rl.InitWindow(800, 600, "Assimp Test")

	cam : rl.Camera3D
	cam.position = { 10.0, 10.0, 10.0 }
	cam.target = { 0.0, 0.0, 0.0 }
	cam.up = { 0.0, 1.0, 0.0 }
	cam.fovy = 45.0
	cam.projection = .PERSPECTIVE

	model_mush   := rl_load_model_from_aimesh(mushroom.mMeshes[0])
	model_banana := rl_load_model_from_aimesh(banana.mMeshes[0])

	for !rl.WindowShouldClose() {
		rl.UpdateCamera(&cam, .ORBITAL)
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		rl.BeginMode3D(cam)

		rl.DrawLine3D({0,0,-100}, {0,0,100}, rl.DARKGRAY)
		rl.DrawLine3D({-100,0,0}, {100,0,0}, rl.DARKGRAY)

		rl.DrawCube({}, 1,1,1, rl.RED)
		rl.DrawModel(model_mush, {}, 0.01, rl.GREEN)
		rl.DrawModelWires(model_mush, {}, 0.01, rl.BLUE)
		rl.DrawModel(model_banana, {}, 0.01, rl.YELLOW)
		rl.DrawModelWires(model_banana, {}, 0.01, rl.BLUE)

		for v in banana.mMeshes[0].mVertices[:banana.mMeshes[0].mNumVertices] {
			rl.DrawSphere(0.01*v, 0.1, rl.BLUE)
		}

		rl.EndMode3D()
		rl.EndDrawing()
	}

	rl.UnloadModel(model_mush)
	rl.UnloadModel(model_banana)

	rl.CloseWindow()
}

rl_load_model_from_aimesh :: proc(aimesh: ^Mesh) -> rl.Model {
	mesh : rl.Mesh; {
		mesh.vertexCount = auto_cast aimesh.mNumVertices
		indices := make([dynamic]u16, 0, aimesh.mNumFaces * 3)
		defer delete(indices)
		for i in 0..<aimesh.mNumFaces {
			face := aimesh.mFaces[i]
			mesh.triangleCount += auto_cast face.mNumIndices
			for idx in face.mIndices[:face.mNumIndices] {
				append(&indices, cast(u16)idx)
			}
		}
		mesh.indices       = auto_cast &indices[0]
		mesh.vertices      = auto_cast aimesh.mVertices
		mesh.normals       = auto_cast aimesh.mNormals
		rl.UploadMesh(&mesh, false)
	}
	return rl.LoadModelFromMesh(mesh)
}

check_scene :: proc(scene: ^Scene, name : string) {
	fmt.printf("==== Scene: {} ====\n", name)

	mesh_count := scene.mNumMeshes
	meshes := scene.mMeshes

	for i in 0..<mesh_count {
		mesh := meshes[i]
		name := string_clone_from_ai_string(&mesh.mName)
		uv_channel_count, color_channel_count := 0, 0
		for uv in mesh.mNumUVComponents do if uv != 0 do uv_channel_count += 1
		for c in mesh.mColors do if c != nil do color_channel_count += 1

		fmt.printf("Mesh `{}` has {} vertices, {} uv channels, {} color channels.\n", 
			name, mesh.mNumVertices, uv_channel_count, color_channel_count)
		uv_components := mesh.mNumUVComponents 
	}
}


example_copy_and_export :: proc() {
	// banana_copied : ^Scene
	// copy_scene(banana, &banana_copied)
	// {
	// 	node_name_ptr := &banana_copied.mRootNode.mChildren[0].mName
	// 	mesh := banana_copied.mMeshes[0]
	// 	for i in 0..<mesh.mNumVertices {
	// 		v := mesh.mVertices[i]
	// 		mesh.mVertices[i] = 3 * v
	// 	}
	// 	string_clone_to_ai_string("big_banana", &mesh.mName)
	// 	string_clone_to_ai_string("my_node", node_name_ptr)
	// 	export_result := export_scene(banana_copied, "fbx", "big_banana.fbx", 0x00)
	// 	fmt.printf("Export result: {}\n", export_result)
	// }
}
