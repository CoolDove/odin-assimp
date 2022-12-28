package assimp

/*
Assimp

TIPS:
- Assimp doesnt support the latest .blend file format.

TODO:
- Animation(Confirm)
- Matrix(Confirm)
- Node(Confirm)
- Load...Ex
*/



import ai "import"
import "core:strings"


import_file :: proc {
    import_file_from_memory,
    import_file_from_file,
}

// assimp procs
get_error_string                :: ai.get_error_string

import_file_from_memory         :: ai.import_file_from_memory
import_file_from_file           :: ai.import_file
release_import                  :: ai.release_import

copy_scene                      :: ai.copy_scene
free_scene                      :: ai.free_scene
export_scene                    :: ai.export_scene

apply_post_processing           :: ai.apply_post_processing
is_extension_supported          :: ai.is_extension_supported
get_extension_list              :: ai.get_extension_list
get_memory_requirements         :: ai.get_memory_requirements
set_import_property_integer     :: ai.set_import_property_integer
set_import_property_float       :: ai.set_import_property_float
set_import_property_string      :: ai.set_import_property_string
create_quaternion_from_matrix   :: ai.create_quaternion_from_matrix
decompose_matrix                :: ai.decompose_matrix
transpose_matrix4               :: ai.transpose_matrix4
transpose_matrix3               :: ai.transpose_matrix3
transform_vec_by_matrix3        :: ai.transform_vec_by_matrix3
transform_vec_by_matrix4        :: ai.transform_vec_by_matrix4
multiply_matrix4                :: ai.multiply_matrix4
multiply_matrix3                :: ai.multiply_matrix3
identity_matrix3                :: ai.identity_matrix3
identity_matrix4                :: ai.identity_matrix4
get_material_property           :: ai.get_material_property
get_material_floatArray         :: ai.get_material_floatArray
get_material_integerArray       :: ai.get_material_integerArray
get_material_color              :: ai.get_material_color
get_material_string             :: ai.get_material_string
get_material_textureCount       :: ai.get_material_textureCount
get_material_texture            :: ai.get_material_texture

// assimp types
VectorKey           :: ai.aiVectorKey
QuatKey             :: ai.aiQuatKey
AnimBehaviour       :: ai.aiAnimBehaviour
NodeAnim            :: ai.aiNodeAnim
Animation           :: ai.aiAnimation
Bool                :: ai.aiBool
String              :: ai.aiString
Return              :: ai.aiReturn
Origin              :: ai.aiOrigin
DefautLogStream     :: ai.aiDefaultLogStream
MemoryInfo          :: ai.aiMemoryInfo
Camera              :: ai.aiCamera
TextureOp           :: ai.aiTextureOp
TextureMapMode      :: ai.aiTextureMapMode
TextureMapping      :: ai.aiTextureMapping
TextureType         :: ai.aiTextureType
ShadingMode         :: ai.aiShadingMode
TextureFlags        :: ai.aiTextureFlags
BlendMode           :: ai.aiBlendMode
Transform           :: ai.aiUVTransform
PropeyTypeInfo      :: ai.aiPropertyTypeInfo
MaterlProperty      :: ai.aiMaterialProperty
Material            :: ai.aiMaterial
LightSourceType     :: ai.aiLightSourceType
Light               :: ai.aiLight
Face                :: ai.aiFace
VertexWeight        :: ai.aiVertexWeight
Bone                :: ai.aiBone
PrimitiveType       :: ai.aiPrimitiveType
AnimMesh            :: ai.aiAnimMesh
Mesh                :: ai.aiMesh
Vector2D            :: ai.aiVector2D
Vector3D            :: ai.aiVector3D
Quaternion          :: ai.aiQuaternion
Matrix3x3           :: ai.aiMatrix3x3
Matrix4x4           :: ai.aiMatrix4x4
Plane               :: ai.aiPlane
Ray                 :: ai.aiRay
Color3D             :: ai.aiColor3D
Color4D             :: ai.aiColor4D
Texel               :: ai.aiTexel
Texture             :: ai.aiTexture
Node                :: ai.aiNode
SceneFlags          :: ai.aiSceneFlags
Scene               :: ai.aiScene
PostProcessSteps    :: ai.aiPostProcessSteps

// helper procs
string_clone_from_ai_string :: proc(aistr : ^String, allocator := context.allocator) -> string {
    return strings.clone_from_bytes(aistr.data[:aistr.length], allocator)
}

string_clone_to_ai_string :: proc(text: string, aistr: ^String) {
    assert(aistr != nil, "You are clone to a nil aiString.")
    data := raw_data(text)
    copy(aistr.data[:], text)
    aistr.length = cast(u32)len(text)
}