package assimp

import "core:fmt"

main :: proc() {
    fmt.printf("Hello world.\n")

    file :cstring= "mushroom.fbx"

    get_error_string()
    scene := import_file(file, cast(u32)PostProcessSteps.Triangulate)
    defer release_import(scene)
    fmt.printf("number of meshes in file {}: {}", file, scene.mNumMeshes)

    meshes := cast([^][^]Mesh)scene.mMeshes
    mesh := meshes[0][0]

    fmt.printf("mushroom vertex count: {}\n", mesh.mNumVertices)
}