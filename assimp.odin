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


import "core:math/linalg"
import "core:strings"
import ai "import"


import_file :: proc {
	import_file_from_memory,
	import_file_from_file,
}

// assimp procs
get_error_string :: ai.get_error_string

import_file_from_file :: proc(file: string, postprocess_flags: u32) -> ^Scene {
	file_cstr := strings.clone_to_cstring(file, context.temp_allocator)
	return ai.import_file(file_cstr, postprocess_flags)
}
import_file_from_memory :: proc(
	buffer: []byte,
	postprocess_flags: u32,
	format_hint: string,
) -> ^Scene {
	hint_cstr := strings.clone_to_cstring(format_hint, context.temp_allocator)
	return ai.import_file_from_memory(
		raw_data(buffer),
		cast(u32)len(buffer),
		postprocess_flags,
		hint_cstr,
	)
}
release_import :: ai.release_import

copy_scene :: ai.copy_scene
free_scene :: ai.free_scene
export_scene :: ai.export_scene

apply_post_processing :: ai.apply_post_processing
is_extension_supported :: ai.is_extension_supported
get_extension_list :: ai.get_extension_list
get_memory_requirements :: ai.get_memory_requirements
set_import_property_integer :: ai.set_import_property_integer
set_import_property_float :: ai.set_import_property_float
set_import_property_string :: ai.set_import_property_string
create_quaternion_from_matrix :: ai.create_quaternion_from_matrix
decompose_matrix :: ai.decompose_matrix
transpose_matrix4 :: ai.transpose_matrix4
transpose_matrix3 :: ai.transpose_matrix3
transform_vec_by_matrix3 :: ai.transform_vec_by_matrix3
transform_vec_by_matrix4 :: ai.transform_vec_by_matrix4
multiply_matrix4 :: ai.multiply_matrix4
multiply_matrix3 :: ai.multiply_matrix3
identity_matrix3 :: ai.identity_matrix3
identity_matrix4 :: ai.identity_matrix4
get_material_property :: ai.get_material_property
get_material_floatArray :: ai.get_material_floatArray
get_material_integerArray :: ai.get_material_integerArray
get_material_color :: ai.get_material_color
get_material_string :: ai.get_material_string
get_material_textureCount :: ai.get_material_textureCount
get_material_texture :: ai.get_material_texture

// assimp types
VectorKey :: ai.aiVectorKey
QuatKey :: ai.aiQuatKey
AnimBehaviour :: ai.aiAnimBehaviour
NodeAnim :: ai.aiNodeAnim
Animation :: ai.aiAnimation
Bool :: ai.aiBool
String :: ai.aiString
Return :: ai.aiReturn
Origin :: ai.aiOrigin
DefautLogStream :: ai.aiDefaultLogStream
MemoryInfo :: ai.aiMemoryInfo
Camera :: ai.aiCamera
TextureOp :: ai.aiTextureOp
TextureMapMode :: ai.aiTextureMapMode
TextureMapping :: ai.aiTextureMapping
TextureType :: ai.aiTextureType
ShadingMode :: ai.aiShadingMode
TextureFlags :: ai.aiTextureFlags
BlendMode :: ai.aiBlendMode
Transform :: ai.aiUVTransform
PropeyTypeInfo :: ai.aiPropertyTypeInfo
MaterlProperty :: ai.aiMaterialProperty
Material :: ai.aiMaterial
LightSourceType :: ai.aiLightSourceType
Light :: ai.aiLight
Face :: ai.aiFace
VertexWeight :: ai.aiVertexWeight
Bone :: ai.aiBone
PrimitiveType :: ai.aiPrimitiveType
AnimMesh :: ai.aiAnimMesh
Mesh :: ai.aiMesh
Vector2D :: ai.aiVector2D
Vector3D :: ai.aiVector3D
Quaternion :: ai.aiQuaternion
Matrix3x3 :: ai.aiMatrix3x3
Matrix4x4 :: ai.aiMatrix4x4
Plane :: ai.aiPlane
Ray :: ai.aiRay
Color3D :: ai.aiColor3D
Color4D :: ai.aiColor4D
Texel :: ai.aiTexel
Texture :: ai.aiTexture
Node :: ai.aiNode
SceneFlags :: ai.aiSceneFlags
Scene :: ai.aiScene
PostProcessSteps :: ai.aiPostProcessSteps


PostProcessPreset_Quality :: ai.aiProcessPreset_TargetRealtime_Quality
PostProcessPreset_MaxQuality :: ai.aiProcessPreset_TargetRealtime_MaxQuality


// helper procs
string_clone_from_ai_string :: proc(aistr: ^String, allocator := context.allocator) -> string {
	return strings.clone_from_bytes(aistr.data[:aistr.length], allocator)
}

string_clone_to_ai_string :: proc(text: string, aistr: ^String) {
	assert(aistr != nil, "You are clone to a nil aiString.")
	data := raw_data(text)
	copy(aistr.data[:], text)
	aistr.length = cast(u32)len(text)
}

matrix_convert :: proc {
	matrix_convert_3,
	matrix_convert_4,
}

matrix_convert_4 :: proc(using ai_matrix: Matrix4x4) -> linalg.Matrix4f32 {
	return linalg.Matrix4f32{a1, a2, a3, a4, b1, b2, b3, b4, c1, c2, c3, c4, d1, d2, d3, d4}
}
matrix_convert_3 :: proc(using ai_matrix: Matrix3x3) -> linalg.Matrix3f32 {
	return linalg.Matrix3f32{a1, a2, a3, b1, b2, b3, c1, c2, c3}
}

quaterion_convert :: proc(quat: Quaternion) -> linalg.Quaternionf32 {
	return quaternion(x = quat.x, y = quat.y, z = quat.z, w = quat.w)
}
