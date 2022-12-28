package assimp

import "core:fmt"
import "core:runtime"
import "core:strings"

import "core:c/libc"

when ODIN_OS == .Windows {
    foreign import kernel32 "system:kernel32.lib"

    @(default_calling_convention="system")
    foreign kernel32 {
        @(link_name="SetConsoleOutputCP") set_console_output_cp :: proc(cp : u32) ---
    }
}

DATA_BANANA_FBX   :: #load("banana.fbx")

main :: proc() {
    when ODIN_OS == .Windows do set_console_output_cp(65001)

    mushroom := import_file_from_file("mushroom.fbx", .Triangulate)
    banana := import_file_from_memory(raw_data(DATA_BANANA_FBX), auto_cast len(DATA_BANANA_FBX), cast(u32)PostProcessSteps.Triangulate, "fbx")
    banana_copied : ^Scene
    copy_scene(banana, &banana_copied)
    defer {
        free_scene(banana_copied)
        release_import(banana)
        release_import(mushroom)
        fmt.printf("Loaded scene has been released.")
    }

    if mushroom != nil do check_scene(mushroom, "mushroom.fbx")
    if banana != nil do check_scene(banana, "banana.fbx")
    if banana_copied != nil do check_scene(banana_copied, "banana_copied")

    {
        node_name_ptr := &banana_copied.mRootNode.mChildren[0].mName
        mesh := banana_copied.mMeshes[0]
        for i in 0..<mesh.mNumVertices {
            v := mesh.mVertices[i]
            mesh.mVertices[i] = 3 * v
        }
        string_clone_to_ai_string("big_banana", &mesh.mName)
        string_clone_to_ai_string("my_node", node_name_ptr)
        export_result := export_scene(banana_copied, "fbx", "big_banana.fbx", 0x00)
        fmt.printf("Export result: {}\n", export_result)
    }

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