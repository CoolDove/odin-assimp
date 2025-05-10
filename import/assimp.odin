package assimp_import

import linalg "core:math/linalg"

when ODIN_OS == .Windows {
	when ODIN_DEBUG do foreign import assimp "../lib/assimp-vc143-mtd.lib"
	else do foreign import assimp "../lib/assimp-vc143-mt.lib"
} else when ODIN_OS == .Linux {
	// foreign import assimp "../compiled/libassimp.so"
	foreign import assimp "system:assimp"
} else {
	#panic(true)
}

ASSIMP_BUILD_NO_ARMATUREPOPULATE_PROCESS :: #config(ASSIMP_BUILD_NO_ARMATUREPOPULATE_PROCESS, true)

@(default_calling_convention = "c")
foreign assimp {
	@(link_name = "aiGetErrorString")
	get_error_string :: proc() -> cstring ---

	@(link_name = "aiImportFile")
	import_file :: proc(file: cstring, postprocessFlags: u32) -> ^aiScene ---
	// --------------------------------------------------------------------------------
	/** Reads the given file from a given memory buffer,
     *
     * If the call succeeds, the contents of the file are returned as a pointer to an
     * aiScene object. The returned data is intended to be read-only, the importer keeps
     * ownership of the data and will destroy it upon destruction. If the import fails,
     * NULL is returned.
     * A human-readable error description can be retrieved by calling aiGetErrorString().
     * @param pBuffer Pointer to the file data
     * @param pLength Length of pBuffer, in bytes
     * @param pFlags Optional post processing steps to be executed after
     *   a successful import. Provide a bitwise combination of the
     *   #aiPostProcessSteps flags. If you wish to inspect the imported
     *   scene first in order to fine-tune your post-processing setup,
     *   consider to use #aiApplyPostProcessing().
     * @param pHint An additional hint to the library. If this is a non empty string,
     *   the library looks for a loader to support the file extension specified by pHint
     *   and passes the file to the first matching loader. If this loader is unable to
     *   completely the request, the library continues and tries to determine the file
     *   format on its own, a task that may or may not be successful.
     *   Check the return value, and you'll know ...
     * @return A pointer to the imported data, NULL if the import failed.
     *
     * @note This is a straightforward way to decode models from memory
     * buffers, but it doesn't handle model formats that spread their
     * data across multiple files or even directories. Examples include
     * OBJ or MD3, which outsource parts of their material info into
     * external scripts. If you need full functionality, provide
     * a custom IOSystem to make Assimp find these files and use
     * the regular aiImportFileEx()/aiImportFileExWithProperties() API.
     */
	@(link_name = "aiImportFileFromMemory")
	import_file_from_memory :: proc(buffer: [^]byte, pLength, pFlags: u32, pHint: cstring) -> ^aiScene ---

	@(link_name = "aiReleaseImport")
	release_import :: proc(pScene: ^aiScene) ---
	// --------------------------------------------------------------------------------
	/** Create a modifiable copy of a scene.
     *  This is useful to import files via Assimp, change their topology and
     *  export them again. Since the scene returned by the various importer functions
     *  is const, a modifiable copy is needed.
     *  @param pIn Valid scene to be copied
     *  @param pOut Receives a modifiable copy of the scene. Use aiFreeScene() to
     *    delete it again.
     */
	@(link_name = "aiCopyScene")
	copy_scene :: proc(pIn: ^aiScene, pOut: ^^aiScene) ---

	// --------------------------------------------------------------------------------
	/** Frees a scene copy created using aiCopyScene() */
	@(link_name = "aiFreeScene")
	free_scene :: proc(pScene: ^aiScene) ---

	// --------------------------------------------------------------------------------
	/** Exports the given scene to a chosen file format and writes the result file(s) to disk.
    * @param pScene The scene to export. Stays in possession of the caller, is not changed by the function.
    *   The scene is expected to conform to Assimp's Importer output format as specified
    *   in the @link data Data Structures Page @endlink. In short, this means the model data
    *   should use a right-handed coordinate systems, face winding should be counter-clockwise
    *   and the UV coordinate origin is assumed to be in the upper left. If your input data
    *   uses different conventions, have a look at the last parameter.
    * @param pFormatId ID string to specify to which format you want to export to. Use
    * aiGetExportFormatCount() / aiGetExportFormatDescription() to learn which export formats are available.
    * @param pFileName Output file to write
    * @param pPreprocessing Accepts any choice of the #aiPostProcessSteps enumerated
    *   flags, but in reality only a subset of them makes sense here. Specifying
    *   'preprocessing' flags is useful if the input scene does not conform to
    *   Assimp's default conventions as specified in the @link data Data Structures Page @endlink.
    *   In short, this means the geometry data should use a right-handed coordinate systems, face
    *   winding should be counter-clockwise and the UV coordinate origin is assumed to be in
    *   the upper left. The #aiProcess_MakeLeftHanded, #aiProcess_FlipUVs and
    *   #aiProcess_FlipWindingOrder flags are used in the import side to allow users
    *   to have those defaults automatically adapted to their conventions. Specifying those flags
    *   for exporting has the opposite effect, respectively. Some other of the
    *   #aiPostProcessSteps enumerated values may be useful as well, but you'll need
    *   to try out what their effect on the exported file is. Many formats impose
    *   their own restrictions on the structure of the geometry stored therein,
    *   so some preprocessing may have little or no effect at all, or may be
    *   redundant as exporters would apply them anyhow. A good example
    *   is triangulation - whilst you can enforce it by specifying
    *   the #aiProcess_Triangulate flag, most export formats support only
    *   triangulate data so they would run the step anyway.
    *
    *   If assimp detects that the input scene was directly taken from the importer side of
    *   the library (i.e. not copied using aiCopyScene and potentially modified afterwards),
    *   any post-processing steps already applied to the scene will not be applied again, unless
    *   they show non-idempotent behavior (#aiProcess_MakeLeftHanded, #aiProcess_FlipUVs and
    *   #aiProcess_FlipWindingOrder).
    * @return a status code indicating the result of the export
    * @note Use aiCopyScene() to get a modifiable copy of a previously
    *   imported scene.
    */
	@(link_name = "aiExportScene")
	export_scene :: proc(pScene: ^aiScene, pFormatId, pFileName: cstring, pPreprocessing: u32) -> aiReturn ---

	@(link_name = "aiApplyPostProcessing")
	apply_post_processing :: proc(pScene: ^aiScene, pFlags: u32) -> ^aiScene ---
	@(link_name = "aiIsExtensionSupported")
	is_extension_supported :: proc(szExtension: cstring) -> aiBool ---
	@(link_name = "aiGetExtensionList")
	get_extension_list :: proc(szOut: ^aiString) ---
	@(link_name = "aiGetMemoryRequirements")
	get_memory_requirements :: proc(pIn: ^aiScene, info: ^aiMemoryInfo) ---
	@(link_name = "aiSetImportPropertyInteger")
	set_import_property_integer :: proc(szName: cstring, value: int) ---
	@(link_name = "aiSetImportPropertyFloat")
	set_import_property_float :: proc(szName: cstring, value: f64) ---
	@(link_name = "aiSetImportPropertyString")
	set_import_property_string :: proc(szName: cstring, st: ^aiString) ---
	@(link_name = "aiCreateQuaternionFromMatrix")
	create_quaternion_from_matrix :: proc(quat: ^aiQuaternion, mat: ^aiMatrix3x3) ---
	@(link_name = "aiDecomposeMatrix")
	decompose_matrix :: proc(mat: ^aiMatrix4x4, scaling: ^aiVector3D, rotation: ^aiQuaternion, position: ^aiVector3D) ---
	@(link_name = "aiTransposeMatrix4")
	transpose_matrix4 :: proc(mat: ^aiMatrix4x4) ---
	@(link_name = "aiTransposeMatrix3")
	transpose_matrix3 :: proc(mat: ^aiMatrix3x3) ---
	@(link_name = "aiTransformVecByMatrix3")
	transform_vec_by_matrix3 :: proc(vec: ^aiVector3D, mat: ^aiMatrix3x3) ---
	@(link_name = "aiTransformVecByMatrix4")
	transform_vec_by_matrix4 :: proc(vec: ^aiVector3D, mat: ^aiMatrix4x4) ---
	@(link_name = "aiMultiplyMatrix4")
	multiply_matrix4 :: proc(dst: ^aiMatrix4x4, src: ^aiMatrix4x4) ---
	@(link_name = "aiMultiplyMatrix3")
	multiply_matrix3 :: proc(dst: ^aiMatrix3x3, src: ^aiMatrix3x3) ---
	@(link_name = "aiIdentityMatrix3")
	identity_matrix3 :: proc(mat: ^aiMatrix3x3) ---
	@(link_name = "aiIdentityMatrix4")
	identity_matrix4 :: proc(mat: ^aiMatrix4x4) ---
	@(link_name = "aiGetMaterialProperty")
	get_material_property :: proc(pMat: ^aiMaterial, pKey: cstring, type: u32, index: u32, pPropOut: ^^aiMaterialProperty) -> aiReturn ---
	@(link_name = "aiGetMaterialFloatArray")
	get_material_floatArray :: proc(pMat: ^aiMaterial, pKey: cstring, type: u32, index: u32, pOut: ^f64, pMax: ^u32) -> aiReturn ---
	@(link_name = "aiGetMaterialIntegerArray")
	get_material_integerArray :: proc(pMat: ^aiMaterial, pKey: cstring, type: u32, index: u32, pOut: ^int, pMax: ^u32) -> aiReturn ---
	@(link_name = "aiGetMaterialColor")
	get_material_color :: proc(pMat: ^aiMaterial, pKey: cstring, type: u32, index: u32, pOut: ^aiColor4D) -> aiReturn ---
	@(link_name = "aiGetMaterialString")
	get_material_string :: proc(pMat: ^aiMaterial, pKey: cstring, type: u32, index: u32, pOut: ^aiString) -> aiReturn ---
	@(link_name = "aiGetMaterialTextureCount")
	get_material_textureCount :: proc(pMat: ^aiMaterial, type: aiTextureType) -> u32 ---
	@(link_name = "aiGetMaterialTexture")
	get_material_texture :: proc(mat: ^aiMaterial, type: aiTextureType, index: u32, path: ^aiString, mapping: ^aiTextureMapping, uvindex: ^u32, blend: ^f64, op: ^aiTextureOp, mapmode: ^aiTextureMapMode) -> aiReturn ---

	// @(link_name="aiImportFileEx")              import_fileex :: proc(pFile:cstring,pFlags: u32,pFS: ^aiFileIO) -> ^aiScene ---;
	// @(link_name="aiGetPredefinedLogStream")    get_predefined_log_stream :: proc(pStreams: aiDefaultLogStream,file:cstring) -> aiLogStream ---;
	// @(link_name="aiAttachLogStream")           attach_log_stream :: proc(stream: ^aiLogStream) ---;
	// @(link_name="aiEnableVerboseLogging")      enable_verbose_logging :: proc(d: aiBool) ---;
	// @(link_name="aiDetachLogStream")           detach_log_stream :: proc(stream: ^aiLogStream) -> aiReturn ---;

}

AI_MAX_FACE_INDICES :: 0x7fff
AI_MAX_BONE_WEIGHTS :: 0x7fffffff
AI_MAX_VERTICES :: 0x7fffffff
AI_MAX_FACES :: 0x7fffffff
AI_MAX_NUMBER_OF_COLOR_SETS :: 0x8
AI_MAX_NUMBER_OF_TEXTURECOORDS :: 0x8

AI_MAX_STRING_LENGTH :: 1024

aiVectorKey :: struct {
	mTime:  f64,
	mValue: aiVector3D,
}
aiQuatKey :: struct {
	mTime:  f64,
	mValue: aiQuaternion,
}
aiAnimBehaviour :: enum u32 {
	DEFAULT  = 0x0,
	CONSTANT = 0x1,
	LINEAR   = 0x2,
	REPEAT   = 0x3,
}

aiNodeAnim :: struct {
	mNodeName:        aiString,
	mNumPositionKeys: u32,
	mPositionKeys:    [^]aiVectorKey,
	mNumRotationKeys: u32,
	mRotationKeys:    [^]aiQuatKey,
	mNumScalingKeys:  u32,
	mScalingKeys:     [^]aiVectorKey,
	mPreState:        aiAnimBehaviour,
	mPostState:       aiAnimBehaviour,
}

aiAnimation :: struct {
	mName:           aiString,
	mDuration:       f64,
	mTicksPerSecond: f64,
	mNumChannels:    u32,
	mChannels:       [^]^aiNodeAnim,
}

aiBool :: enum int {
	FALSE = 0,
	TRUE  = 1,
}

aiString :: struct {
	length: u32,
	data:   [AI_MAX_STRING_LENGTH]u8,
}

aiReturn :: enum u32 {
	SUCCESS     = 0x0,
	FAILURE     = 0x1,
	OUTOFMEMORY = 0x3,
}

aiOrigin :: enum u32 {
	SET = 0x0,
	CUR = 0x1,
	END = 0x2,
}

aiDefaultLogStream :: enum {
	FILE     = 0x1,
	STDOUT   = 0x2,
	STDERR   = 0x4,
	DEBUGGER = 0x8,
}

aiMemoryInfo :: struct {
	textures:   u32,
	materials:  u32,
	meshes:     u32,
	nodes:      u32,
	animations: u32,
	cameras:    u32,
	lights:     u32,
	total:      u32,
}

aiCamera :: struct {
	mName:          aiString,
	mPosition:      aiVector3D,
	mUp:            aiVector3D,
	mLookAt:        aiVector3D,
	mHorizontalFOV: f32,
	mClipPlaneNear: f32,
	mClipPlaneFar:  f32,
	mAspect:        f32,
}

aiTextureOp :: enum u32 {
	Multiply  = 0x0,
	Add       = 0x1,
	Subtract  = 0x2,
	Divide    = 0x3,
	SmoothAdd = 0x4,
	SignedAdd = 0x5,
}
aiTextureMapMode :: enum u32 {
	Wrap   = 0x0,
	Clamp  = 0x1,
	Decal  = 0x3,
	Mirror = 0x2,
}
aiTextureMapping :: enum u32 {
	UV       = 0x0,
	SPHERE   = 0x1,
	CYLINDER = 0x2,
	BOX      = 0x3,
	PLANE    = 0x4,
	OTHER    = 0x5,
}

aiTextureType :: enum u32 {
	NONE         = 0x0,
	DIFFUSE      = 0x1,
	SPECULAR     = 0x2,
	AMBIENT      = 0x3,
	EMISSIVE     = 0x4,
	HEIGHT       = 0x5,
	NORMALS      = 0x6,
	SHININESS    = 0x7,
	OPACITY      = 0x8,
	DISPLACEMENT = 0x9,
	LIGHTMAP     = 0xA,
	REFLECTION   = 0xB,
	UNKNOWN      = 0xC,
}

aiShadingMode :: enum u32 {
	Flat         = 0x1,
	Gouraud      = 0x2,
	Phong        = 0x3,
	Blinn        = 0x4,
	Toon         = 0x5,
	OrenNayar    = 0x6,
	Minnaert     = 0x7,
	CookTorrance = 0x8,
	NoShading    = 0x9,
	Fresnel      = 0xa,
}

aiTextureFlags :: enum u32 {
	Invert      = 0x1,
	UseAlpha    = 0x2,
	IgnoreAlpha = 0x4,
}

aiBlendMode :: enum {
	Default  = 0x0,
	Additive = 0x1,
}

aiUVTransform :: struct {
	mTranslation: aiVector2D,
	mScaling:     aiVector2D,
	mRotation:    f32,
}

aiPropertyTypeInfo :: enum u32 {
	Float   = 0x1,
	String  = 0x3,
	Integer = 0x4,
	Buffer  = 0x5,
}

aiMaterialProperty :: struct {
	mKey:        aiString,
	mSemantic:   u32,
	mIndex:      u32,
	mDataLength: u32,
	mType:       aiPropertyTypeInfo,
	mData:       cstring,
}
aiMaterial :: struct {
	mProperties:    [^]^aiMaterialProperty,
	mNumProperties: u32,
	mNumAllocated:  u32,
}

aiLightSourceType :: enum u32 {
	UNDEFINED   = 0x0,
	DIRECTIONAL = 0x1,
	POINT       = 0x2,
	SPOT        = 0x3,
}

aiLight :: struct {
	mName:                 aiString,
	mType:                 aiLightSourceType,
	mPosition:             aiVector3D,
	mDirection:            aiVector3D,
	mAttenuationConstant:  f32,
	mAttenuationLinear:    f32,
	mAttenuationQuadratic: f32,
	mColorDiffuse:         aiColor3D,
	mColorSpecular:        aiColor3D,
	mColorAmbient:         aiColor3D,
	mAngleInnerCone:       f32,
	mAngleOuterCone:       f32,
}

// aiFileIO :: struct {
//     OpenProc : aiFileOpenProc,
//     CloseProc : aiFileCloseProc,
//     UserData : aiUserData,
// }
// aiFile :: struct {
//     ReadProc : aiFileReadProc,
//     WriteProc : aiFileWriteProc,
//     TellProc : aiFileTellProc,
//     FileSizeProc : aiFileTellProc,
//     SeekProc : aiFileSeek,
//     FlushProc : aiFileFlushProc,
//     UserData : aiUserData,
// }

aiFace :: struct {
	mNumIndices: u32,
	mIndices:    [^]u32,
}

aiReal :: f32

aiVertexWeight :: struct {
	mVertexId: u32,
	mWeight:   aiReal,
}

when ASSIMP_BUILD_NO_ARMATUREPOPULATE_PROCESS {
	aiBone :: struct {
		mName:         aiString,
		mNumWeights:   u32,
		mArmature:     ^aiNode,
		mNode:         ^aiNode,
		mWeights:      [^]aiVertexWeight,
		mOffsetMatrix: aiMatrix4x4,
	}
} else {
	aiBone :: struct {
		mName:         aiString,
		mNumWeights:   u32,
		mWeights:      [^]aiVertexWeight,
		mOffsetMatrix: aiMatrix4x4,
	}
}

aiPrimitiveType :: enum u32 {
	POINT    = 0x1,
	LINE     = 0x2,
	TRIANGLE = 0x4,
	POLYGON  = 0x8,
}

aiAnimMesh :: struct {
	mVertices:      [^]aiVector3D,
	mNormals:       [^]aiVector3D,
	mTangents:      [^]aiVector3D,
	mBitangents:    [^]aiVector3D,
	mColors:        [AI_MAX_NUMBER_OF_COLOR_SETS][^]aiColor4D,
	mTextureCoords: [AI_MAX_NUMBER_OF_TEXTURECOORDS][^]aiVector3D,
	mNumVertices:   u32,
}

aiMesh :: struct {
	mPrimitiveTypes:  u32,
	mNumVertices:     u32,
	mNumFaces:        u32,
	mVertices:        [^]aiVector3D,
	mNormals:         [^]aiVector3D,
	mTangents:        [^]aiVector3D,
	mBitangents:      [^]aiVector3D,
	/** Vertex color sets.
    * A mesh may contain 0 to #AI_MAX_NUMBER_OF_COLOR_SETS vertex
    * colors per vertex. nullptr if not present. Each array is
    * mNumVertices in size if present.
    */
	mColors:          [AI_MAX_NUMBER_OF_COLOR_SETS][^]aiColor4D,
	/** Vertex texture coordinates, also known as UV channels.
    * A mesh may contain 0 to AI_MAX_NUMBER_OF_TEXTURECOORDS per
    * vertex. nullptr if not present. The array is mNumVertices in size.
    */
	mTextureCoords:   [AI_MAX_NUMBER_OF_TEXTURECOORDS][^]aiVector3D,
	/** Specifies the number of components for a given UV channel.
    * Up to three channels are supported (UVW, for accessing volume
    * or cube maps). If the value is 2 for a given channel n, the
    * component p.z of mTextureCoords[n][p] is set to 0.0f.
    * If the value is 1 for a given channel, p.y is set to 0.0f, too.
    * @note 4D coordinates are not supported
    */
	mNumUVComponents: [AI_MAX_NUMBER_OF_TEXTURECOORDS]u32,
	mFaces:           [^]aiFace,
	mNumBones:        u32,
	mBones:           [^]^aiBone,
	mMaterialIndex:   u32,
	mName:            aiString,
	mNumAnimMeshes:   u32,
	mAnimMeshes:      [^]^aiAnimMesh,
	mMethod:          u32,
}

aiVector2D :: linalg.Vector2f32

aiVector3D :: linalg.Vector3f32

// aiQuaternion :: linalg.Quaternionf32
aiQuaternion :: struct {
	w, x, y, z: f32,
}

aiMatrix3x3 :: struct {
	a1, a2, a3: f32,
	b1, b2, b3: f32,
	c1, c2, c3: f32,
}

aiMatrix4x4 :: struct {
	a1, a2, a3, a4: f32,
	b1, b2, b3, b4: f32,
	c1, c2, c3, c4: f32,
	d1, d2, d3, d4: f32,
}

// aiMatrix3x3 :: linalg.Matrix3x3f32
// aiMatrix4x4 :: linalg.Matrix4x4f32

aiPlane :: linalg.Vector4f32

aiRay :: struct {
	pos: aiVector3D,
	dir: aiVector3D,
}

aiColor3D :: linalg.Vector3f32

aiColor4D :: linalg.Vector4f32

aiTexel :: struct {
	b: byte,
}

aiTexture :: struct {
	mWidth:        u32,
	mHeight:       u32,
	achFormatHint: [4]u8,
	pcData:        ^aiTexel,
}

aiNode :: struct {
	mName:           aiString,
	mTransformation: aiMatrix4x4,
	mParent:         ^aiNode,
	mNumChildren:    u32,
	mChildren:       [^]^aiNode,
	mNumMeshes:      u32,
	mMeshes:         [^]u32,
	mMetaData:       rawptr, // TODO: aiNode.mMetaData
}

aiSceneFlags :: enum u32 {
	INCOMPLETE         = 0x1,
	VALIDATED          = 0x2,
	VALIDATION_WARNING = 0x4,
	NON_VERBOSE_FORMAT = 0x8,
	FLAGS_TERRAIN      = 0x10,
}

aiScene :: struct {
	mFlags:         u32,
	mRootNode:      ^aiNode,
	mNumMeshes:     u32,
	mMeshes:        [^]^aiMesh,
	mNumMaterials:  u32,
	mMaterials:     [^]^aiMaterial,
	mNumAnimations: u32,
	mAnimations:    [^]^aiAnimation,
	mNumTextures:   u32,
	mTextures:      [^]^aiTexture,
	mNumLights:     u32,
	mLights:        [^]^aiLight,
	mNumCameras:    u32,
	mCameras:       [^]^aiCamera,
}

aiSkeletons :: struct {} // TODO: aiSkeletons

aiMetaData :: struct {} // TODO: aiMetaData


// flags
aiPostProcessSteps :: enum u32 {
	CalcTangentSpace         = 0x1,
	JoinIdenticalVertices    = 0x2,
	MakeLeftHanded           = 0x4,
	Triangulate              = 0x8,
	RemoveComponent          = 0x10,
	GenNormals               = 0x20,
	GenSmoothNormals         = 0x40,
	SplitLargeMeshes         = 0x80,
	PreTransformVertices     = 0x100,
	LimitBoneWeights         = 0x200,
	ValidateDataStructure    = 0x400,
	ImproveCacheLocality     = 0x800,
	RemoveRedundantMaterials = 0x1000,
	FixInfacingNormals       = 0x2000,
	SortByPType              = 0x8000,
	FindDegenerates          = 0x10000,
	FindInvalidData          = 0x20000,
	GenUVCoords              = 0x40000,
	TransformUVCoords        = 0x80000,
	FindInstances            = 0x100000,
	OptimizeMeshes           = 0x200000,
	OptimizeGraph            = 0x400000,
	FlipUVs                  = 0x800000,
	FlipWindingOrder         = 0x1000000,
}

aiProcessPreset_TargetRealtime_Quality ::
	aiPostProcessSteps.CalcTangentSpace |
	aiPostProcessSteps.GenSmoothNormals |
	aiPostProcessSteps.JoinIdenticalVertices |
	aiPostProcessSteps.ImproveCacheLocality |
	aiPostProcessSteps.LimitBoneWeights |
	aiPostProcessSteps.RemoveRedundantMaterials |
	aiPostProcessSteps.SplitLargeMeshes |
	aiPostProcessSteps.Triangulate |
	aiPostProcessSteps.GenUVCoords |
	aiPostProcessSteps.SortByPType |
	aiPostProcessSteps.FindDegenerates |
	aiPostProcessSteps.FindInvalidData

aiProcessPreset_TargetRealtime_MaxQuality ::
	aiProcessPreset_TargetRealtime_Quality |
	aiPostProcessSteps.FindInstances |
	aiPostProcessSteps.ValidateDataStructure |
	aiPostProcessSteps.OptimizeMeshes
