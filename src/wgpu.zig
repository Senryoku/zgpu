const std = @import("std");
const emscripten = @import("builtin").target.os.tag == .emscripten;
const c = @cImport(@cInclude("webgpu.h"));

test "extern struct ABI compatibility" {
    @setEvalBranchQuota(10_000);
    const wgpu = @cImport(@cInclude("webgpu.h"));
    inline for (comptime std.meta.declarations(@This())) |decl| {
        const ZigType = @field(@This(), decl.name);
        if (@TypeOf(ZigType) != type) {
            continue;
        }
        if (comptime std.meta.activeTag(@typeInfo(ZigType)) == .@"struct" and
            @typeInfo(ZigType).@"struct".layout == .@"extern")
        {
            const wgpu_name = "WGPU" ++ decl.name;
            const CType = @field(wgpu, wgpu_name);
            std.testing.expectEqual(@sizeOf(CType), @sizeOf(ZigType)) catch |err| {
                std.log.err("@sizeOf({s}) != @sizeOf({s})", .{ wgpu_name, decl.name });
                return err;
            };
            comptime var i: usize = 0;
            inline for (comptime std.meta.fieldNames(CType)) |c_field_name| {
                std.testing.expectEqual(
                    @offsetOf(CType, c_field_name),
                    @offsetOf(ZigType, std.meta.fieldNames(ZigType)[i]),
                ) catch |err| {
                    std.log.err(
                        "@offsetOf({s}, {s}) != @offsetOf({s}, {s})",
                        .{ wgpu_name, c_field_name, decl.name, std.meta.fieldNames(ZigType)[i] },
                    );
                    return err;
                };
                i += 1;
            }
        }
    }
}

pub const Status = enum(u32) {
    success = 0x00000001,
    err = 0x00000002,
};

pub const WaitStatus = enum(u32) {
    success = 0x00000001,
    timed_out = 0x00000002,
    err = 0x00000003,
};

pub const CallbackMode = enum(u32) {
    undef = 0x00000000,
    wait_any_only = 0x00000001,
    allow_process_events = 0x00000002,
    allow_spontaneous = 0x00000003,
};

pub const InstanceFeatureName = enum(u32) {
    timed_wait_any = 0x00000001,
    shader_source_spirv = 0x00000002,
    multiple_devices_per_adapter = 0x00000003,
};

pub const AdapterType = enum(u32) {
    undef = 0x00000000,
    discrete_gpu,
    integrated_gpu,
    cpu,
    unknown,
};

pub const AddressMode = enum(u32) {
    repeat = 0x00000000,
    mirror_repeat = 0x00000001,
    clamp_to_edge = 0x00000002,
};

pub const CompositeAlphaMode = enum(u32) {
    auto = 0x00000000,
    opaq = 0x00000001,
    premultiplied = 0x00000002,
    unpremultiplied = 0x00000003,
    inherit = 0x00000004,
};

pub const BackendType = enum(u32) {
    undef = 0x00000000,
    nul,
    webgpu,
    d3d11,
    d3d12,
    metal,
    vulkan,
    opengl,
    opengles,
};

pub const BlendFactor = switch (emscripten) {
    true => enum(u32) {
        undef = 0x00000000,
        zero = 0x00000001,
        one = 0x00000002,
        src = 0x00000003,
        one_minus_src = 0x00000004,
        src_alpha = 0x00000005,
        one_minus_src_alpha = 0x00000006,
        dst = 0x00000007,
        one_minus_dst = 0x00000008,
        dst_alpha = 0x00000009,
        one_minus_dst_alpha = 0x0000000A,
        src_alpha_saturated = 0x0000000B,
        constant = 0x0000000C,
        one_minus_constant = 0x0000000D,
    },
    false => enum(u32) {
        zero = 0x00000000,
        one = 0x00000001,
        src = 0x00000002,
        one_minus_src = 0x00000003,
        src_alpha = 0x00000004,
        one_minus_src_alpha = 0x00000005,
        dst = 0x00000006,
        one_minus_dst = 0x00000007,
        dst_alpha = 0x00000008,
        one_minus_dst_alpha = 0x00000009,
        src_alpha_saturated = 0x0000000A,
        constant = 0x0000000B,
        one_minus_constant = 0x0000000C,
    },
};

pub const BlendOperation = switch (emscripten) {
    true => enum(u32) {
        undef = 0x00000000,
        add = 0x00000001,
        subtract = 0x00000002,
        reverse_subtract = 0x00000003,
        min = 0x00000008,
        max = 0x00000004,
    },
    false => enum(u32) {
        add = 0x00000000,
        subtract = 0x00000001,
        reverse_subtract = 0x00000002,
        min = 0x00000003,
        max = 0x00000004,
    },
};

pub const BufferBindingType = enum(u32) {
    undef = 0x00000000,
    uniform = 0x00000001,
    storage = 0x00000002,
    read_only_storage = 0x00000003,
};

pub const MapAsyncStatus = enum(u32) {
    success = 0x00000001,
    callback_cancelled = 0x00000002,
    err = 0x00000003,
    aborted = 0x00000004,
};

// pub const BufferMapAsyncStatus = enum(u32) {
//     success = 0x00000000,
//     validation_error = 0x00000001,
//     unknown = 0x00000002,
//     device_lost = 0x00000003,
//     destroyed_before_callback = 0x00000004,
//     unmapped_before_callback = 0x00000005,
//     mappingAlreadyPending = 0x00000006,
//     offset_out_of_range = 0x00000007,
//     size_out_of_range = 0x00000008,
// };

pub const BufferMapState = switch (emscripten) {
    true => enum(u32) {
        unmapped = 0x00000001,
        pending = 0x00000002,
        mapped = 0x00000003,
    },
    false => enum(u32) {
        unmapped = 0x00000000,
        pending = 0x00000001,
        mapped = 0x00000002,
    },
};

pub const CompareFunction = enum(u32) {
    undef = 0x00000000,
    never = 0x00000001,
    less = 0x00000002,
    less_equal = 0x00000003,
    greater = 0x00000004,
    greater_equal = 0x00000005,
    equal = 0x00000006,
    not_equal = 0x00000007,
    always = 0x00000008,
};

pub const CompilationInfoRequestStatus = enum(u32) {
    success = 0x00000000,
    err = 0x00000001,
    device_lost = 0x00000002,
    unknown = 0x00000003,
};

pub const CompilationMessageType = enum(u32) {
    err = 0x00000000,
    warning = 0x00000001,
    info = 0x00000002,
};

pub const ComputePassTimestampLocation = enum(u32) {
    beginning = 0x00000000,
    end = 0x00000001,
};

pub const CreatePipelineAsyncStatus = enum(u32) {
    success = 0x00000000,
    validation_error = 0x00000001,
    internal_error = 0x00000002,
    device_lost = 0x00000003,
    device_destroyed = 0x00000004,
    unknown = 0x00000005,
};

pub const ExternalTextureRotation = enum(u32) {
    rotate_0_degrees = 0x00000000,
    rotate_90_degrees = 0x00000001,
    rotate_180_degrees = 0x00000002,
    rotate_270_degrees = 0x00000003,
};

pub const CullMode = enum(u32) {
    none = 0x00000000,
    front = 0x00000001,
    back = 0x00000002,
};

pub const DeviceLostReason = enum(u32) {
    // undef = 0x00000000,
    unknown = 0x00000001,
    destroyed = 0x00000002,
    callback_cancelled = 0x00000003,
    failed_creation = 0x00000004,
};

pub const ErrorFilter = enum(u32) {
    validation = 0x00000000,
    out_of_memory = 0x00000001,
    internal = 0x00000002,
};

pub const ErrorType = enum(u32) {
    no_error = 0x00000001,
    validation = 0x00000002,
    out_of_memory = 0x00000003,
    internal = 0x00000004,
    unknown = 0x00000005,
};

pub const FeatureLevel = enum(u32) {
    undef = 0x00000000,
    compatibility = 0x00000001,
    core = 0x00000002,
};

pub const FeatureName = enum(u32) {
    core_features_and_limits = 0x00000001,
    depth_clip_control = 0x00000002,
    depth_32_float_stencil_8 = 0x00000003,
    texture_compression_bc = 0x00000004,
    texture_compression_bc_sliced_3d = 0x00000005,
    texture_compression_etc2 = 0x00000006,
    texture_compression_astc = 0x00000007,
    texture_compression_astc_sliced_3d = 0x00000008,
    timestamp_query = 0x00000009,
    indirect_first_instance = 0x0000000A,
    shader_f16 = 0x0000000B,
    rg11b10_ufloat_renderable = 0x0000000C,
    bgra8_unorm_storage = 0x0000000D,
    float32_filterable = 0x0000000E,
    float32_blendable = 0x0000000F,
    clip_distances = 0x00000010,
    dual_source_blending = 0x00000011,
    subgroups = 0x00000012,
    texture_formats_tier1 = 0x00000013,
    texture_formats_tier2 = 0x00000014,
};

pub const FilterMode = enum(u32) {
    nearest = 0x00000000,
    linear = 0x00000001,
};

pub const MipmapFilterMode = enum(u32) {
    nearest = 0x00000000,
    linear = 0x00000001,
};

pub const FrontFace = enum(u32) {
    ccw = 0x00000000,
    cw = 0x00000001,
};

pub const IndexFormat = enum(u32) {
    undef = 0x00000000,
    uint16 = 0x00000001,
    uint32 = 0x00000002,
};

pub const LoadOp = enum(u32) {
    undef = 0x00000000,
    clear = 0x00000001,
    load = 0x00000002,
};

pub const LoggingType = enum(u32) {
    verbose = 0x00000000,
    info = 0x00000001,
    warning = 0x00000002,
    err = 0x00000003,
};

pub const PipelineStatisticName = enum(u32) {
    vertex_shader_invocations = 0x00000000,
    clipper_invocations = 0x00000001,
    clipper_primitives_out = 0x00000002,
    fragment_shader_invocations = 0x00000003,
    compute_shader_invocations = 0x00000004,
};

pub const PowerPreference = enum(u32) {
    undef = 0x00000000,
    low_power = 0x00000001,
    high_performance = 0x00000002,
};

pub const PresentMode = enum(u32) {
    undefined = 0x00000000,
    fifo = 0x00000001,
    fifo_relaxed = 0x00000002,
    immediate = 0x00000003,
    mailbox = 0x00000004,
};

pub const PrimitiveTopology = switch (emscripten) {
    true => enum(u32) {
        undefined = 0x00000000,
        point_list = 0x00000001,
        line_list = 0x00000002,
        line_strip = 0x00000003,
        triangle_list = 0x00000004,
        triangle_strip = 0x00000005,
    },
    false => enum(u32) {
        point_list = 0x00000000,
        line_list = 0x00000001,
        line_strip = 0x00000002,
        triangle_list = 0x00000003,
        triangle_strip = 0x00000004,
    },
};

pub const QueryType = enum(u32) {
    occlusion = 0x00000000,
    pipeline_statistics = 0x00000001,
    timestamp = 0x00000002,
};

pub const QueueWorkDoneStatus = enum(u32) {
    success = 0x00000000,
    err = 0x00000001,
    unknown = 0x00000002,
    device_lost = 0x00000003,
};

pub const RenderPassTimestampLocation = enum(u32) {
    beginning = 0x00000000,
    end = 0x00000001,
};

pub const RequestAdapterStatus = enum(u32) {
    success = 0x00000001,
    callback_cancelled = 0x00000002,
    unavailable = 0x00000003,
    err = 0x00000004,
};

pub const RequestDeviceStatus = enum(u32) {
    success = 0x00000001,
    callback_cancelled = 0x00000002,
    err = 0x00000003,
};

pub const SurfaceGetCurrentTextureStatus = enum(u32) {
    undefined = 0x00000000,
    success_optimal = 0x00000001,
    success_suboptimal = 0x00000002,
    timeout = 0x00000003,
    outdated = 0x00000004,
    lost = 0x00000005,
    err = 0x00000006,
};

pub const SurfaceSourceMetalLayer = extern struct {
    chain: ChainedStruct,
    layer: *anyopaque,
};

pub const SurfaceSourceWaylandSurface = extern struct {
    chain: ChainedStruct,
    display: *anyopaque,
    surface: *anyopaque,
};

pub const SurfaceSourceWindowsHWND = extern struct {
    chain: ChainedStruct,
    hinstance: *anyopaque,
    hwnd: *anyopaque,
};

pub const SurfaceSourceXlibWindow = extern struct {
    chain: ChainedStruct,
    display: *anyopaque,
    window: u32,
};

pub const SurfaceSourceWindowsCoreWindow = extern struct {
    chain: ChainedStruct,
    core_window: *anyopaque,
};

pub const SurfaceSourceWindowsSwapChainPanel = extern struct {
    chain: ChainedStruct,
    swap_chain_panel: *anyopaque,
};

pub const SurfaceSourceCanvasHTMLSelector = extern struct {
    chain: ChainedStruct,
    selector: c.WGPUStringView,
};

pub const StructType = enum(u32) {
    shader_source_spirv = 0x00000001,
    shader_source_wgsl = 0x00000002,
    render_pass_max_draw_count = 0x00000003,
    surface_source_metal_layer = 0x00000004,
    surface_source_windows_hwnd = 0x00000005,
    surface_source_xlib_window = 0x00000006,
    surface_source_wayland_surface = 0x00000007,
    surface_source_android_native_window = 0x00000008,
    surface_source_xcb_window = 0x00000009,
    surface_color_management = 0x0000000A,
    request_adapter_webxr_options = 0x0000000B,
};

pub const SamplerBindingType = enum(u32) {
    undef = 0x00000000,
    filtering = 0x00000001,
    non_filtering = 0x00000002,
    comparison = 0x00000003,
};

pub const StencilOperation = enum(u32) {
    keep = 0x00000000,
    zero = 0x00000001,
    replace = 0x00000002,
    invert = 0x00000003,
    increment_lamp = 0x00000004,
    decrement_clamp = 0x00000005,
    increment_wrap = 0x00000006,
    decrement_wrap = 0x00000007,
};

pub const StorageTextureAccess = enum(u32) {
    undef = 0x00000000,
    write_only = 0x00000001,
};

pub const StoreOp = enum(u32) {
    undef = 0x00000000,
    store = 0x00000001,
    discard = 0x00000002,
};

pub const TextureAspect = enum(u32) {
    all = 0x00000000,
    stencil_only = 0x00000001,
    depth_only = 0x00000002,
    plane0_only = 0x00000003,
    plane1_only = 0x00000004,
};

pub const TextureDimension = switch (emscripten) {
    true => enum(u32) {
        undef = 0x00000000,
        tdim_1d = 0x00000001,
        tdim_2d = 0x00000002,
        tdim_3d = 0x00000003,
    },
    false => enum(u32) {
        tdim_1d = 0x00000000,
        tdim_2d = 0x00000001,
        tdim_3d = 0x00000002,
    },
};

pub const TextureFormat = enum(u32) {
    undef = 0x00000000,
    r8_unorm = 0x00000001,
    r8_snorm = 0x00000002,
    r8_uint = 0x00000003,
    r8_sint = 0x00000004,
    r16_uint = 0x00000005,
    r16_sint = 0x00000006,
    r16_float = 0x00000007,
    rg8_unorm = 0x00000008,
    rg8_snorm = 0x00000009,
    rg8_uint = 0x0000000a,
    rg8_sint = 0x0000000b,
    r32_float = 0x0000000c,
    r32_uint = 0x0000000d,
    r32_sint = 0x0000000e,
    rg16_uint = 0x0000000f,
    rg16_sint = 0x00000010,
    rg16_float = 0x00000011,
    rgba8_unorm = 0x00000012,
    rgba8_unorm_srgb = 0x00000013,
    rgba8_snorm = 0x00000014,
    rgba8_uint = 0x00000015,
    rgba8_sint = 0x00000016,
    bgra8_unorm = 0x00000017,
    bgra8_unorm_srgb = 0x00000018,
    rgb10_a2_unorm = 0x00000019,
    rg11_b10_ufloat = 0x0000001a,
    rgb9_e5_ufloat = 0x0000001b,
    rg32_float = 0x0000001c,
    rg32_uint = 0x0000001d,
    rg32_sint = 0x0000001e,
    rgba16_uint = 0x0000001f,
    rgba16_sint = 0x00000020,
    rgba16_float = 0x00000021,
    rgba32_float = 0x00000022,
    rgba32_uint = 0x00000023,
    rgba32_sint = 0x00000024,
    stencil8 = 0x00000025,
    depth16_unorm = 0x00000026,
    depth24_plus = 0x00000027,
    depth24_plus_stencil8 = 0x00000028,
    depth32_float = 0x00000029,
    depth32_float_stencil8 = 0x0000002a,
    bc1_rgba_unorm = 0x0000002b,
    bc1_rgba_unorm_srgb = 0x0000002c,
    bc2_rgba_unorm = 0x0000002d,
    bc2_rgba_unorm_srgb = 0x0000002e,
    bc3_rgba_unorm = 0x0000002f,
    bc3_rgba_unorm_srgb = 0x00000030,
    bc4_runorm = 0x00000031,
    bc4_rsnorm = 0x00000032,
    bc5_rg_unorm = 0x00000033,
    bc5_rg_snorm = 0x00000034,
    bc6_hrgb_ufloat = 0x00000035,
    bc6_hrgb_float = 0x00000036,
    bc7_rgba_unorm = 0x00000037,
    bc7_rgba_unorm_srgb = 0x00000038,
    etc2_rgb8_unorm = 0x00000039,
    etc2_rgb8_unorm_srgb = 0x0000003a,
    etc2_rgb8_a1_unorm = 0x0000003b,
    etc2_rgb8_a1_unorm_srgb = 0x0000003c,
    etc2_rgba8_unorm = 0x0000003d,
    etc2_rgba8_unorm_srgb = 0x0000003e,
    eacr11_unorm = 0x0000003f,
    eacr11_snorm = 0x00000040,
    eacrg11_unorm = 0x00000041,
    eacrg11_snorm = 0x00000042,
    astc4x4_unorm = 0x00000043,
    astc4x4_unorm_srgb = 0x00000044,
    astc5x4_unorm = 0x00000045,
    astc5x4_unorm_srgb = 0x00000046,
    astc5x5_unorm = 0x00000047,
    astc5x5_unorm_srgb = 0x00000048,
    astc6x5_unorm = 0x00000049,
    astc6x5_unorm_srgb = 0x0000004a,
    astc6x6_unorm = 0x0000004b,
    astc6x6_unorm_srgb = 0x0000004c,
    astc8x5_unorm = 0x0000004d,
    astc8x5_unorm_srgb = 0x0000004e,
    astc8x6_unorm = 0x0000004f,
    astc8x6_unorm_srgb = 0x00000050,
    astc8x8_unorm = 0x00000051,
    astc8x8_unorm_srgb = 0x00000052,
    astc10x5_unorm = 0x00000053,
    astc10x5_unorm_srgb = 0x00000054,
    astc10x6_unorm = 0x00000055,
    astc10x6_unorm_srgb = 0x00000056,
    astc10x8_unorm = 0x00000057,
    astc10x8_unorm_srgb = 0x00000058,
    astc10x10_unorm = 0x00000059,
    astc10x10_unorm_srgb = 0x0000005a,
    astc12x10_unorm = 0x0000005b,
    astc12x10_unorm_srgb = 0x0000005c,
    astc12x12_unorm = 0x0000005d,
    astc12x12_unorm_srgb = 0x0000005e,
    r8_bg8_biplanar420_unorm = 0x0000005f,
};

pub const TextureSampleType = enum(u32) {
    undef = 0x00000000,
    float = 0x00000001,
    unfilterable_float = 0x00000002,
    depth = 0x00000003,
    sint = 0x00000004,
    uint = 0x00000005,
};

pub const TextureViewDimension = enum(u32) {
    undef = 0x00000000,
    tvdim_1d = 0x00000001,
    tvdim_2d = 0x00000002,
    tvdim_2d_array = 0x00000003,
    tvdim_cube = 0x00000004,
    tvdim_cube_array = 0x00000005,
    tvdim_3d = 0x00000006,
};

pub const VertexFormat = enum(u32) {
    undef = 0x00000000,
    uint8x2 = 0x00000001,
    uint8x4 = 0x00000002,
    sint8x2 = 0x00000003,
    sint8x4 = 0x00000004,
    unorm8x2 = 0x00000005,
    unorm8x4 = 0x00000006,
    snorm8x2 = 0x00000007,
    snorm8x4 = 0x00000008,
    uint16x2 = 0x00000009,
    uint16x4 = 0x0000000A,
    sint16x2 = 0x0000000B,
    sint16x4 = 0x0000000C,
    unorm16x2 = 0x0000000D,
    unorm16x4 = 0x0000000E,
    snorm16x2 = 0x0000000F,
    snorm16x4 = 0x00000010,
    float16x2 = 0x00000011,
    float16x4 = 0x00000012,
    float32 = 0x00000013,
    float32x2 = 0x00000014,
    float32x3 = 0x00000015,
    float32x4 = 0x00000016,
    uint32 = 0x00000017,
    uint32x2 = 0x00000018,
    uint32x3 = 0x00000019,
    uint32x4 = 0x0000001A,
    sint32 = 0x0000001B,
    sint32x2 = 0x0000001C,
    sint32x3 = 0x0000001D,
    sint32x4 = 0x0000001E,
};

pub const VertexStepMode = switch (emscripten) {
    true => enum(u32) {
        undefined = 0x00000000,
        vertex_buffer_not_used = 0x00000001,
        vertex = 0x00000002,
        instance = 0x00000003,
    },
    false => enum(u32) {
        vertex = 0x00000000,
        instance = 0x00000001,
        vertex_buffer_not_used = 0x00000002,
    },
};

pub const Flags = u64;

pub const BufferUsage = packed struct(Flags) {
    map_read: bool = false,
    map_write: bool = false,
    copy_src: bool = false,
    copy_dst: bool = false,
    index: bool = false,
    vertex: bool = false,
    uniform: bool = false,
    storage: bool = false,
    indirect: bool = false,
    query_resolve: bool = false,
    _padding: u54 = 0,
};

pub const ColorWriteMask = packed struct(Flags) {
    red: bool = false,
    green: bool = false,
    blue: bool = false,
    alpha: bool = false,
    _padding: u60 = 0,

    pub const all = ColorWriteMask{ .red = true, .green = true, .blue = true, .alpha = true };
};

pub const MapMode = packed struct(Flags) {
    read: bool = false,
    write: bool = false,
    _padding: u62 = 0,
};

pub const ShaderStage = packed struct(Flags) {
    vertex: bool = false,
    fragment: bool = false,
    compute: bool = false,
    _padding: u61 = 0,
};

pub const TextureUsage = packed struct(Flags) {
    copy_src: bool = false,
    copy_dst: bool = false,
    texture_binding: bool = false,
    storage_binding: bool = false,
    render_attachment: bool = false,
    transient_attachment: bool = false,
    _padding: u58 = 0,
};

//
// Section
//

pub const Future = extern struct {
    id: u64 = 0,
};

pub const FutureWaitInfo = extern struct {
    future: Future = .{},
    completed: bool = false,
};

pub const ChainedStruct = extern struct {
    next: ?*const ChainedStruct,
    struct_type: StructType,
};

pub const ChainedStructOut = extern struct {
    next: ?*ChainedStructOut,
    struct_type: StructType,
};

pub const StringView = extern struct {
    pub const C = c.WGPUStringView;
    data: ?[*]const u8,
    length: usize,

    pub fn initC() c.WGPUStringView {
        return c.WGPUStringView{
            .data = null,
            .length = 0,
        };
    }
    pub fn cFromZig(str: []const u8) c.WGPUStringView {
        return c.WGPUStringView{
            .data = str.ptr,
            .length = str.len,
        };
    }
    pub fn zigFromC(str: c.WGPUStringView) ?[]const u8 {
        if (str.length < 1) return null;
        return str.data[0..str.length];
    }
};

pub const AdapterInfo = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    vendor_name: c.WGPUStringView = .{},
    architecture: c.WGPUStringView = .{},
    device: c.WGPUStringView = .{},
    description: c.WGPUStringView = .{},
    backend_type: BackendType = .undef,
    adapter_type: AdapterType = .unknown,
    vendor_id: u32 = 0,
    device_id: u32 = 0,
    subgroup_min_size: u32 = 0,
    subgroup_max_size: u32 = 0,
};

pub const RequestAdapterCallbackInfo = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    mode: CallbackMode = .undef,
    callback: ?RequestAdapterCallback = null,
    userdata_1: ?*anyopaque = null,
    userdata_2: ?*anyopaque = null,
};

pub const RequestDeviceCallbackInfo = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    mode: CallbackMode = .undef,
    callback: ?RequestDeviceCallback = null,
    userdata_1: ?*anyopaque = null,
    userdata_2: ?*anyopaque = null,
};

pub const DeviceLostCallbackInfo = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    mode: CallbackMode = .undef,
    callback: ?DeviceLostCallback = null,
    userdata_1: ?*anyopaque = null,
    userdata_2: ?*anyopaque = null,
};

pub const UncapturedErrorCallbackInfo = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    callback: ?UncapturedErrorCallback = null,
    userdata_1: ?*anyopaque = null,
    userdata_2: ?*anyopaque = null,
};

pub const BufferMapCallbackInfo = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    mode: CallbackMode = .undef,
    callback: ?BufferMapCallback = null,
    userdata_1: ?*anyopaque = null,
    userdata_2: ?*anyopaque = null,
};

pub const CreateComputePipelineAsyncCallbackInfo = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    mode: CallbackMode = .undef,
    callback: ?CreateComputePipelineAsyncCallback = null,
    userdata_1: ?*anyopaque = null,
    userdata_2: ?*anyopaque = null,
};

pub const CreateRenderPipelineAsyncCallbackInfo = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    mode: CallbackMode = .undef,
    callback: ?CreateRenderPipelineAsyncCallback = null,
    userdata_1: ?*anyopaque = null,
    userdata_2: ?*anyopaque = null,
};

pub const SupportedFeatures = extern struct {
    feature_count: usize,
    features: ?[*]FeatureName,
};

pub const BindGroupEntry = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    binding: u32,
    buffer: ?Buffer = null,
    offset: u64 = 0,
    size: u64,
    sampler: ?Sampler = null,
    texture_view: ?TextureView = null,
};

pub const BindGroupDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: c.WGPUStringView = StringView.initC(),
    layout: BindGroupLayout,
    entry_count: usize,
    entries: ?[*]const BindGroupEntry,
};

pub const BufferBindingLayout = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    binding_type: BufferBindingType = .uniform,
    has_dynamic_offset: U32Bool = .false,
    min_binding_size: u64 = 0,
};

pub const SamplerBindingLayout = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    binding_type: SamplerBindingType = .filtering,
};

pub const TextureBindingLayout = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    sample_type: TextureSampleType = .float,
    view_dimension: TextureViewDimension = .tvdim_2d,
    multisampled: bool = false,
};

pub const StorageTextureBindingLayout = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    access: StorageTextureAccess = .write_only,
    format: TextureFormat,
    view_dimension: TextureViewDimension = .tvdim_2d,
};

pub const BindGroupLayoutEntry = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    binding: u32,
    visibility: ShaderStage,
    buffer: BufferBindingLayout = .{ .binding_type = .undef },
    sampler: SamplerBindingLayout = .{ .binding_type = .undef },
    texture: TextureBindingLayout = .{ .sample_type = .undef },
    storage_texture: StorageTextureBindingLayout = .{ .access = .undef, .format = .undef },
};

pub const BindGroupLayoutDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: c.WGPUStringView = StringView.initC(),
    entry_count: usize,
    entries: ?[*]const BindGroupLayoutEntry,
};

pub const U32Bool = enum(u32) {
    false = 0,
    true = 1,
};

pub const BufferDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: c.WGPUStringView = StringView.initC(),
    usage: BufferUsage,
    size: u64,
    mapped_at_creation: U32Bool = .false,
};

pub const CommandEncoderDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: c.WGPUStringView = StringView.initC(),
};

pub const ConstantEntry = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    key: c.WGPUStringView,
    value: f64,
};

pub const ProgrammableStageDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    module: ShaderModule,
    entry_point: c.WGPUStringView,
    constant_count: usize = 0,
    constants: ?[*]const ConstantEntry = null,
};

pub const ComputePipelineDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: c.WGPUStringView = StringView.initC(),
    layout: ?PipelineLayout = null,
    compute: ProgrammableStageDescriptor,
};

pub const ExternalTextureDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: c.WGPUStringView = StringView.initC(),
    plane0: TextureView,
    plane1: ?TextureView = null,
    visible_origin: Origin2D,
    visible_size: Extent2D,
    do_yuv_to_rgb_conversion_only: bool,
    yuv_to_rgb_conversion_matrix: ?[*]const f32,
    src_transfer_function_parameters: [*]const f32,
    dst_transfer_function_parameters: [*]const f32,
    gamut_conversion_matrix: [*]const f32,
    flip_y: bool,
    rotation: ExternalTextureRotation,
};

pub const PipelineLayoutDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: c.WGPUStringView = StringView.initC(),
    bind_group_layout_count: usize,
    bind_group_layouts: ?[*]const BindGroupLayout,
};

pub const QuerySetDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: c.WGPUStringView = StringView.initC(),
    query_type: QueryType,
    count: u32,
    pipeline_statistics: ?[*]const PipelineStatisticName,
    pipeline_statistics_count: usize,
};

pub const RenderBundleEncoderDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: c.WGPUStringView = StringView.initC(),
    color_formats_count: usize,
    color_formats: ?[*]const TextureFormat,
    depth_stencil_format: TextureFormat,
    sample_count: u32,
    depth_read_only: bool,
    stencil_read_only: bool,
};

pub const VertexAttribute = extern struct {
    format: VertexFormat,
    offset: u64,
    shader_location: u32,
};

pub const VertexBufferLayout = extern struct {
    array_stride: u64,
    step_mode: VertexStepMode = .vertex,
    attribute_count: usize,
    attributes: [*]const VertexAttribute,
};

pub const VertexState = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    module: ShaderModule,
    entry_point: c.WGPUStringView,
    constant_count: usize = 0,
    constants: ?[*]const ConstantEntry = null,
    buffer_count: usize = 0,
    buffers: ?[*]const VertexBufferLayout = null,
};

pub const BlendComponent = extern struct {
    operation: BlendOperation = .add,
    src_factor: BlendFactor = .one,
    dst_factor: BlendFactor = .zero,
};

pub const BlendState = extern struct {
    color: BlendComponent,
    alpha: BlendComponent,
};

pub const ColorTargetState = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    format: TextureFormat,
    blend: ?*const BlendState = null,
    write_mask: ColorWriteMask = ColorWriteMask.all,
};

pub const FragmentState = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    module: ShaderModule,
    entry_point: c.WGPUStringView,
    constant_count: usize = 0,
    constants: ?[*]const ConstantEntry = null,
    target_count: usize = 0,
    targets: ?[*]const ColorTargetState = null,
};

pub const PrimitiveState = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    topology: PrimitiveTopology = .triangle_list,
    strip_index_format: IndexFormat = .undef,
    front_face: FrontFace = .ccw,
    cull_mode: CullMode = .none,
};

pub const StencilFaceState = extern struct {
    compare: CompareFunction = .always,
    fail_op: StencilOperation = .keep,
    depth_fail_op: StencilOperation = .keep,
    pass_op: StencilOperation = .keep,
};

pub const DepthStencilState = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    format: TextureFormat,
    depth_write_enabled: bool = false,
    depth_compare: CompareFunction = .always,
    stencil_front: StencilFaceState = .{},
    stencil_back: StencilFaceState = .{},
    stencil_read_mask: u32 = 0xffff_ffff,
    stencil_write_mask: u32 = 0xffff_ffff,
    depth_bias: i32 = 0,
    depth_bias_slope_scale: f32 = 0.0,
    depth_bias_clamp: f32 = 0.0,
};

pub const MultisampleState = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    count: u32 = 1,
    mask: u32 = 0xffff_ffff,
    alpha_to_coverage_enabled: bool = false,
};

pub const RenderPipelineDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: c.WGPUStringView = StringView.initC(),
    layout: ?PipelineLayout = null,
    vertex: VertexState,
    primitive: PrimitiveState = .{},
    depth_stencil: ?*const DepthStencilState = null,
    multisample: MultisampleState = .{},
    fragment: ?*const FragmentState = null,
};

pub const SamplerDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: c.WGPUStringView = StringView.initC(),
    address_mode_u: AddressMode = .clamp_to_edge,
    address_mode_v: AddressMode = .clamp_to_edge,
    address_mode_w: AddressMode = .clamp_to_edge,
    mag_filter: FilterMode = .nearest,
    min_filter: FilterMode = .nearest,
    mipmap_filter: MipmapFilterMode = .nearest,
    lod_min_clamp: f32 = 0.0,
    lod_max_clamp: f32 = 32.0,
    compare: CompareFunction = .undef,
    max_anisotropy: u16 = 1,
};

pub const ShaderModuleDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: c.WGPUStringView = StringView.initC(),
};

pub const ShaderSourceWGSL = extern struct {
    chain: ChainedStruct,
    code: c.WGPUStringView,
};

pub const SurfaceConfiguration = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    device: Device,
    format: TextureFormat,
    usage: TextureUsage,
    width: u32,
    height: u32,
    view_format_count: usize = 0,
    view_formats: ?[*]TextureFormat = null,
    alpha_mode: CompositeAlphaMode = .auto,
    present_mode: PresentMode = .undefined,
};

pub const SurfaceTexture = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    texture: ?Texture = null,
    status: SurfaceGetCurrentTextureStatus = .undefined,
};

pub const Extent2D = extern struct {
    width: u32,
    height: u32 = 1,
};

pub const Extent3D = extern struct {
    width: u32,
    height: u32 = 1,
    depth_or_array_layers: u32 = 1,
};

pub const TextureDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: c.WGPUStringView = StringView.initC(),
    usage: TextureUsage,
    dimension: TextureDimension = .tdim_2d,
    size: Extent3D,
    format: TextureFormat,
    mip_level_count: u32 = 1,
    sample_count: u32 = 1,
    view_format_count: usize = 0,
    view_formats: ?[*]const TextureFormat = null,
};

pub const Limits = extern struct {
    const u32_undefined: u32 = 0xFFFFFFFF;
    const u64_undefined: u64 = 0xFFFFFFFFFFFFFFFF;

    next_in_chain: ?*const ChainedStruct = null,
    max_texture_dimension_1d: u32 = u32_undefined,
    max_texture_dimension_2d: u32 = u32_undefined,
    max_texture_dimension_3d: u32 = u32_undefined,
    max_texture_array_layers: u32 = u32_undefined,
    max_bind_groups: u32 = u32_undefined,
    max_bind_groups_plus_vertex_buffers: u32 = u32_undefined,
    max_bindings_per_bind_group: u32 = u32_undefined,
    max_dynamic_uniform_buffers_per_pipeline_layout: u32 = u32_undefined,
    max_dynamic_storage_buffers_per_pipeline_layout: u32 = u32_undefined,
    max_sampled_textures_per_shader_stage: u32 = u32_undefined,
    max_samplers_per_shader_stage: u32 = u32_undefined,
    max_storage_buffers_per_shader_stage: u32 = u32_undefined,
    max_storage_textures_per_shader_stage: u32 = u32_undefined,
    max_uniform_buffers_per_shader_stage: u32 = u32_undefined,
    max_uniform_buffer_binding_size: u64 = u64_undefined,
    max_storage_buffer_binding_size: u64 = u64_undefined,
    min_uniform_buffer_offset_alignment: u32 = u32_undefined,
    min_storage_buffer_offset_alignment: u32 = u32_undefined,
    max_vertex_buffers: u32 = u32_undefined,
    max_buffer_size: u64 = u64_undefined,
    max_vertex_attributes: u32 = u32_undefined,
    max_vertex_buffer_array_stride: u32 = u32_undefined,
    max_inter_stage_shader_variables: u32 = u32_undefined,
    max_color_attachments: u32 = u32_undefined,
    max_color_attachment_bytes_per_sample: u32 = u32_undefined,
    max_compute_workgroup_storage_size: u32 = u32_undefined,
    max_compute_invocations_per_workgroup: u32 = u32_undefined,
    max_compute_workgroup_size_x: u32 = u32_undefined,
    max_compute_workgroup_size_y: u32 = u32_undefined,
    max_compute_workgroup_size_z: u32 = u32_undefined,
    max_compute_workgroups_per_dimension: u32 = u32_undefined,
    max_immediate_size: u32 = u32_undefined,
};

pub const RequiredLimits = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    limits: Limits = .{},
};

pub const SupportedLimits = extern struct {
    next_in_chain: ?*ChainedStructOut = null,
    limits: Limits = .{},
};

pub const InstanceLimits = extern struct {
    next_in_chain: ?*ChainedStructOut = null,
    timed_wait_any_max_count: usize,
};

// Can be chained in InstanceDescriptor
// Can be chained in RequestAdapterOptions
// Can be chained in DeviceDescriptor
pub const DawnTogglesDescriptor = extern struct {
    chain: ChainedStruct,
    enabled_toggles_count: usize = 0,
    enabled_toggles: ?[*]const [*:0]const u8 = null,
    disabled_toggles_count: usize = 0,
    disabled_toggles: ?[*]const [*:0]const u8 = null,
};

pub const InstanceDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    required_feature_count: usize = 0,
    required_features: ?*const InstanceFeatureName = null,
    required_limits: ?*const InstanceLimits = null,
};

pub const DawnAdapterPropertiesPowerPreference = extern struct {
    chain: ChainedStructOut,
    power_preference: PowerPreference,
};

pub const QueueDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: c.WGPUStringView = StringView.initC(),
};

pub const DeviceDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: c.WGPUStringView = StringView.initC(),
    required_features_count: usize = 0,
    required_features: ?[*]const FeatureName = null,
    required_limits: ?[*]const RequiredLimits = null,
    default_queue: QueueDescriptor = .{},
    device_lost_callback_info: DeviceLostCallbackInfo = .{},
    uncaptured_error_callback_info: UncapturedErrorCallbackInfo = .{},
};

pub const SurfaceDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: c.WGPUStringView = StringView.initC(),
};

pub const RequestAdapterOptions = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    feature_level: FeatureLevel = .undef,
    power_preference: PowerPreference = .undef,
    force_fallback_adapter: bool = false,
    backend_type: BackendType = .undef,
    compatible_surface: ?Surface = null,
};

pub const ComputePassTimestampWrite = extern struct {
    query_set: QuerySet,
    query_index: u32,
    location: ComputePassTimestampLocation,
};

pub const RenderPassTimestampWrite = extern struct {
    query_set: QuerySet,
    query_index: u32,
    location: RenderPassTimestampLocation,
};

pub const ComputePassDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: c.WGPUStringView = StringView.initC(),
    timestamp_write_count: usize,
    timestamp_writes: ?[*]const ComputePassTimestampWrite,
};

pub const Color = extern struct {
    r: f64,
    g: f64,
    b: f64,
    a: f64,
};

pub const RenderPassColorAttachment = switch (emscripten) {
    true => extern struct {
        next_in_chain: ?*const ChainedStruct = null,
        view: ?TextureView,
        depth_slice: u32 = std.math.maxInt(u32),
        resolve_target: ?TextureView = null,
        load_op: LoadOp,
        store_op: StoreOp,
        clear_value: Color = .{ .r = 0.0, .g = 0.0, .b = 0.0, .a = 0.0 },
    },
    false => extern struct {
        next_in_chain: ?*const ChainedStruct = null,
        view: ?TextureView,
        resolve_target: ?TextureView = null,
        load_op: LoadOp,
        store_op: StoreOp,
        clear_value: Color = .{ .r = 0.0, .g = 0.0, .b = 0.0, .a = 0.0 },
    },
};

pub const RenderPassDepthStencilAttachment = extern struct {
    view: TextureView,
    depth_load_op: LoadOp = .undef,
    depth_store_op: StoreOp = .undef,
    depth_clear_value: f32 = 0.0,
    depth_read_only: U32Bool = .false,
    stencil_load_op: LoadOp = .undef,
    stencil_store_op: StoreOp = .undef,
    stencil_clear_value: u32 = 0,
    stencil_read_only: U32Bool = .false,
};

pub const RenderPassDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: c.WGPUStringView = StringView.initC(),
    color_attachment_count: usize,
    color_attachments: ?[*]const RenderPassColorAttachment,
    depth_stencil_attachment: ?*const RenderPassDepthStencilAttachment = null,
    occlusion_query_set: ?QuerySet = null,
    timestamp_write_count: usize = 0,
    timestamp_writes: ?[*]const RenderPassTimestampWrite = null,
};

pub const TextureDataLayout = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    offset: u64 = 0,
    bytes_per_row: u32,
    rows_per_image: u32,
};

pub const Origin2D = extern struct {
    x: u32 = 0,
    y: u32 = 0,
};

pub const Origin3D = extern struct {
    x: u32 = 0,
    y: u32 = 0,
    z: u32 = 0,
};

pub const ImageCopyBuffer = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    layout: TextureDataLayout,
    buffer: Buffer,
};

pub const ImageCopyTexture = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    texture: Texture,
    mip_level: u32 = 0,
    origin: Origin3D = .{},
    aspect: TextureAspect = .all,
};

pub const ImageCopyExternalTexture = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    external_texture: ExternalTexture,
    origin: Origin3D,
    natural_size: Extent2D,
};

pub const CommandBufferDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: c.WGPUStringView = StringView.initC(),
};

// pub const CopyTextureForBrowserOptions = extern struct {
//     next_in_chain: ?*const ChainedStruct = null,
//     flip_y: bool,
//     needs_color_space_conversion: bool,
//     src_alpha_mode: AlphaMode,
//     src_transfer_function_parameters: ?[*]const f32,
//     conversion_matrix: ?[*]const f32,
//     dst_transfer_function_parameters: ?[*]const f32,
//     dst_alpha_mode: AlphaMode,
//     internal_usage: bool,
// };

pub const TextureViewDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: c.WGPUStringView = StringView.initC(),
    format: TextureFormat = .undef,
    dimension: TextureViewDimension = .undef,
    base_mip_level: u32 = 0,
    mip_level_count: u32 = 0xffff_ffff,
    base_array_layer: u32 = 0,
    array_layer_count: u32 = 0xffff_ffff,
    aspect: TextureAspect = .all,
};

pub const CompilationMessage = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    message: c.WGPUStringView = StringView.initC(),
    message_type: CompilationMessageType,
    line_num: u64,
    line_pos: u64,
    offset: u64,
    length: u64,
    utf16_line_pos: u64,
    utf16_offset: u64,
    utf16_length: u64,
};

pub const CompilationInfo = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    message_count: usize,
    messages: ?[*]const CompilationMessage,
};

pub const RenderBundleDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct = null,
    label: c.WGPUStringView = StringView.initC(),
};

pub const CreateComputePipelineAsyncCallback = *const fn (
    status: CreatePipelineAsyncStatus,
    pipeline: ComputePipeline,
    message: c.WGPUStringView,
    userdata_1: ?*anyopaque,
    userdata_2: ?*anyopaque,
) callconv(.C) void;

pub const CreateRenderPipelineAsyncCallback = *const fn (
    status: CreatePipelineAsyncStatus,
    pipeline: RenderPipeline,
    message: c.WGPUStringView,
    userdata_1: ?*anyopaque,
    userdata_2: ?*anyopaque,
) callconv(.C) void;

pub const ErrorCallback = *const fn (
    err_type: ErrorType,
    message: c.WGPUStringView,
    userdata_1: ?*anyopaque,
    userdata_2: ?*anyopaque,
) callconv(.C) void;

pub const LoggingCallback = *const fn (
    log_type: LoggingType,
    message: c.WGPUStringView,
    userdata: ?*anyopaque,
) callconv(.C) void;

pub const DeviceLostCallback = *const fn (
    device: *const Device,
    reason: DeviceLostReason,
    message: c.WGPUStringView,
    userdata_1: ?*anyopaque,
    userdata_2: ?*anyopaque,
) callconv(.C) void;

pub const UncapturedErrorCallback = *const fn (
    device: *const Device,
    err_type: ErrorType,
    message: c.WGPUStringView,
    userdata_1: ?*anyopaque,
    userdata_2: ?*anyopaque,
) callconv(.C) void;

pub const RequestAdapterCallback = *const fn (
    status: RequestAdapterStatus,
    adapter: Adapter,
    message: c.WGPUStringView,
    userdata_1: ?*anyopaque,
    userdata_2: ?*anyopaque,
) callconv(.C) void;

pub const RequestDeviceCallback = *const fn (
    status: RequestDeviceStatus,
    device: Device,
    message: c.WGPUStringView,
    userdata_1: ?*anyopaque,
    userdata_2: ?*anyopaque,
) callconv(.C) void;

pub const BufferMapCallback = *const fn (
    status: MapAsyncStatus,
    message: c.WGPUStringView,
    userdata_1: ?*anyopaque,
    userdata_2: ?*anyopaque,
) callconv(.C) void;

pub const QueueWorkDoneCallback = *const fn (
    status: QueueWorkDoneStatus,
    message: c.WGPUStringView,
    userdata_1: ?*anyopaque,
    userdata_2: ?*anyopaque,
) callconv(.C) void;

pub const CompilationInfoCallback = *const fn (
    status: CompilationInfoRequestStatus,
    info: *const CompilationInfo,
    userdata_1: ?*anyopaque,
    userdata_2: ?*anyopaque,
) callconv(.C) void;

pub inline fn createInstance(desc: ?InstanceDescriptor) Instance {
    return @ptrCast(c.wgpuCreateInstance(if(desc) |d| @ptrCast(&d) else null));
}

pub const Instance = *opaque {
    pub fn createSurface(instance: Instance, descriptor: SurfaceDescriptor) Surface {
        return @ptrCast(c.wgpuInstanceCreateSurface(@ptrCast(instance), @ptrCast(&descriptor)));
    }

    pub fn requestAdapter(
        instance: Instance,
        options: RequestAdapterOptions,
        callback_info: RequestAdapterCallbackInfo,
    ) Future {
        return @bitCast(c.wgpuInstanceRequestAdapter(@ptrCast(instance), @ptrCast(&options), @bitCast(callback_info)));
    }

    pub fn waitAny(instance: Instance, futures: []FutureWaitInfo, timeout_ns: u64) WaitStatus {
        return @enumFromInt(c.wgpuInstanceWaitAny(@ptrCast(instance), futures.len, @ptrCast(futures.ptr), timeout_ns));
    }

    pub fn addRef(instance: Instance) void {
        c.wgpuInstanceAddRef(@ptrCast(instance));
    }

    pub fn release(instance: Instance) void {
        c.wgpuInstanceRelease(@ptrCast(instance));
    }
};

pub const Adapter = *opaque {
    pub fn getFeatures(adapter: Adapter, features: *SupportedFeatures) void {
        c.wgpuAdapterGetFeatures(@ptrCast(adapter), @ptrCast(features));
    }

    pub fn getLimits(adapter: Adapter, limits: *SupportedLimits) bool {
        return c.wgpuAdapterGetLimits(@ptrCast(adapter), @ptrCast(limits));
    }

    pub fn getInfo(adapter: Adapter, properties: *AdapterInfo) Status {
        return @enumFromInt(c.wgpuAdapterGetInfo(@ptrCast(adapter), @ptrCast(properties)));
    }

    pub fn hasFeature(adapter: Adapter, feature: FeatureName) bool {
        return c.wgpuAdapterHasFeature(@ptrCast(adapter), feature);
    }

    pub fn requestDevice(
        adapter: Adapter,
        descriptor: DeviceDescriptor,
        callback_info: RequestDeviceCallbackInfo,
    ) Future {
        return @bitCast(c.wgpuAdapterRequestDevice(@ptrCast(adapter), @ptrCast(&descriptor), @bitCast(callback_info)));
    }

    pub fn addRef(adapter: Adapter) void {
        c.wgpuAdapterAddRef(@ptrCast(adapter));
    }

    pub fn release(adapter: Adapter) void {
        c.wgpuAdapterRelease(@ptrCast(adapter));
    }
};

pub const Device = *opaque {
    pub fn createBindGroup(device: Device, descriptor: BindGroupDescriptor) BindGroup {
        return @ptrCast(c.wgpuDeviceCreateBindGroup(@ptrCast(device), @ptrCast(&descriptor)));
    }

    pub fn createBindGroupLayout(device: Device, descriptor: BindGroupLayoutDescriptor) BindGroupLayout {
        return @ptrCast(c.wgpuDeviceCreateBindGroupLayout(@ptrCast(device), @ptrCast(&descriptor)));
    }

    pub fn createBuffer(device: Device, descriptor: BufferDescriptor) Buffer {
        return @ptrCast(c.wgpuDeviceCreateBuffer(@ptrCast(device), @ptrCast(&descriptor)));
    }

    pub fn createCommandEncoder(device: Device, descriptor: ?CommandEncoderDescriptor) CommandEncoder {
        return @ptrCast(c.wgpuDeviceCreateCommandEncoder(@ptrCast(device), if (descriptor) |d| @ptrCast(&d) else null));
    }

    pub fn createComputePipeline(device: Device, descriptor: ComputePipelineDescriptor) ComputePipeline {
        return @ptrCast(c.wgpuDeviceCreateComputePipeline(@ptrCast(device), @ptrCast(&descriptor)));
    }

    pub fn createComputePipelineAsync(
        device: Device,
        descriptor: ComputePipelineDescriptor,
        callback_info: CreateComputePipelineAsyncCallbackInfo,
    ) Future {
        return @ptrCast(c.wgpuDeviceCreateComputePipelineAsync(
            @ptrCast(device),
            @ptrCast(&descriptor),
            @bitCast(callback_info),
        ));
    }

    // pub fn createErrorBuffer(device: Device) Buffer {
    //     return @ptrCast(c.wgpuDeviceCreateErrorBuffer(@ptrCast(device)));
    // }
    //
    // pub fn createExternalTexture(device: Device, descriptor: ExternalTextureDescriptor) ExternalTexture {
    //     return @ptrCast(c.wgpuDeviceCreateExternalTexture(@ptrCast(device), @ptrCast(&descriptor)));
    // }

    pub fn createPipelineLayout(device: Device, descriptor: PipelineLayoutDescriptor) PipelineLayout {
        return @ptrCast(c.wgpuDeviceCreatePipelineLayout(@ptrCast(device), @ptrCast(&descriptor)));
    }

    pub fn createQuerySet(device: Device, descriptor: QuerySetDescriptor) QuerySet {
        return @ptrCast(c.wgpuDeviceCreateQuerySet(@ptrCast(device), @ptrCast(&descriptor)));
    }

    pub fn createRenderBundleEncoder(
        device: Device,
        descriptor: RenderBundleEncoderDescriptor,
    ) RenderBundleEncoder {
        return @ptrCast(c.wgpuDeviceCreateRenderBundleEncoder(@ptrCast(device), @ptrCast(&descriptor)));
    }

    pub fn createRenderPipeline(device: Device, descriptor: RenderPipelineDescriptor) RenderPipeline {
        return @ptrCast(c.wgpuDeviceCreateRenderPipeline(@ptrCast(device), @ptrCast(&descriptor)));
    }

    pub fn createRenderPipelineAsync(
        device: Device,
        descriptor: RenderPipelineDescriptor,
        callback_info: CreateRenderPipelineAsyncCallbackInfo,
    ) Future {
        return @bitCast(c.wgpuDeviceCreateRenderPipelineAsync(
            @ptrCast(device),
            @ptrCast(&descriptor),
            @bitCast(callback_info),
        ));
    }

    pub fn createSampler(device: Device, descriptor: SamplerDescriptor) Sampler {
        return @ptrCast(c.wgpuDeviceCreateSampler(@ptrCast(device), @ptrCast(&descriptor)));
    }

    pub fn createShaderModule(device: Device, descriptor: ShaderModuleDescriptor) ShaderModule {
        return @ptrCast(c.wgpuDeviceCreateShaderModule(@ptrCast(device), @ptrCast(&descriptor)));
    }

    pub fn createTexture(device: Device, descriptor: TextureDescriptor) Texture {
        return @ptrCast(c.wgpuDeviceCreateTexture(@ptrCast(device), @ptrCast(&descriptor)));
    }

    pub fn destroy(device: Device) void {
        c.wgpuDeviceDestroy(@ptrCast(device));
    }

    // pub fn enumerateFeatures(device: Device, features: ?[*]FeatureName) usize {
    //     return c.wgpuDeviceEnumerateFeatures(@ptrCast(device), features);
    // }

    pub fn getLimits(device: Device, limits: *SupportedLimits) bool {
        return c.wgpuDeviceGetLimits(@ptrCast(device), limits);
    }

    pub fn getQueue(device: Device) Queue {
        return @ptrCast(c.wgpuDeviceGetQueue(@ptrCast(device)));
    }

    pub fn hasFeature(device: Device, feature: FeatureName) bool {
        return c.wgpuDeviceHasFeature(@ptrCast(device), feature);
    }

    // pub fn injectError(device: Device, err_type: ErrorType, message: []const u8) void {
    //     c.wgpuDeviceInjectError(@ptrCast(device), err_type, StringView.cFromZig(message));
    // }
    //
    // pub fn forceLoss(device: Device, reason: DeviceLostReason, message: []const u8) void {
    //     c.wgpuDeviceForceLoss(@ptrCast(device), reason, StringView.cFromZig(message));
    // }
    //
    // pub fn getAdapter(device: Device) Adapter {
    //     return c.wgpuDeviceGetAdapter(@ptrCast(device));
    // }

    pub fn popErrorScope(device: Device, callback: ErrorCallback, userdata: ?*anyopaque) bool {
        return c.wgpuDevicePopErrorScope(@ptrCast(device), callback, userdata);
    }

    pub fn pushErrorScope(device: Device, filter: ErrorFilter) void {
        c.wgpuDevicePushErrorScope(@ptrCast(device), filter);
    }

    // pub fn setDeviceLostCallback(
    //     device: Device,
    //     callback: DeviceLostCallback,
    //     userdata: ?*anyopaque,
    // ) void {
    //     c.wgpuDeviceSetDeviceLostCallback(@ptrCast(device), callback, userdata);
    // }

    pub fn setLabel(device: Device, label: []const u8) void {
        c.wgpuDeviceSetLabel(@ptrCast(device), StringView.cFromZig(label));
    }

    // pub fn setLoggingCallback(device: Device, callback: LoggingCallback, userdata: ?*anyopaque) void {
    //     c.wgpuDeviceSetLoggingCallback(@ptrCast(device), callback, userdata);
    // }
    //
    // pub fn setUncapturedErrorCallback(device: Device, callback: ErrorCallback, userdata: ?*anyopaque) void {
    //     c.wgpuDeviceSetUncapturedErrorCallback(@ptrCast(device), callback, userdata);
    // }
    //
    // pub fn tick(device: Device) void {
    //     c.wgpuDeviceTick(@ptrCast(device));
    // }

    pub fn addRef(device: Device) void {
        c.wgpuDeviceAddRef(@ptrCast(device));
    }

    pub fn release(device: Device) void {
        c.wgpuDeviceRelease(@ptrCast(device));
    }
};

pub const BindGroup = *opaque {
    pub fn setLabel(bind_group: BindGroup, label: []const u8) void {
        c.wgpuBindGroupSetLabel(@ptrCast(bind_group), StringView.cFromZig(label));
    }

    pub fn addRef(bind_group: BindGroup) void {
        c.wgpuBindGroupAddRef(@ptrCast(bind_group));
    }

    pub fn release(bind_group: BindGroup) void {
        c.wgpuBindGroupRelease(@ptrCast(bind_group));
    }
};

pub const BindGroupLayout = *opaque {
    pub fn setLabel(bind_group_layout: BindGroupLayout, label: []const u8) void {
        c.wgpuBindGroupLayoutSetLabel(@ptrCast(bind_group_layout), StringView.cFromZig(label));
    }

    pub fn addRef(bind_group_layout: BindGroupLayout) void {
        c.wgpuBindGroupLayoutAddRef(@ptrCast(bind_group_layout));
    }

    pub fn release(bind_group_layout: BindGroupLayout) void {
        c.wgpuBindGroupLayoutRelease(@ptrCast(bind_group_layout));
    }
};

pub const Buffer = *opaque {
    pub fn destroy(buffer: Buffer) void {
        c.wgpuBufferDestroy(@ptrCast(buffer));
    }

    // `offset` has to be a multiple of 8 (otherwise `null` will be returned).
    // `@sizeOf(T) * len` has to be a multiple of 4 (otherwise `null` will be returned).
    pub fn getConstMappedRange(buffer: Buffer, comptime T: type, offset: usize, len: usize) ?[]const T {
        if (len == 0) return null;
        const ptr = c.wgpuBufferGetConstMappedRange(@ptrCast(buffer), offset, @sizeOf(T) * len);
        if (ptr == null) return null;
        return @as([*]const T, @ptrCast(@alignCast(ptr)))[0..len];
    }

    // `offset` - in bytes, has to be a multiple of 8 (otherwise `null` will be returned).
    // `len` - length of slice to return, in elements of type T, `@sizeOf(T) * len` has to be a multiple of 4 (otherwise `null` will be returned).
    pub fn getMappedRange(buffer: Buffer, comptime T: type, offset: usize, len: usize) ?[]T {
        if (len == 0) return null;
        const ptr = c.wgpuBufferGetMappedRange(@ptrCast(buffer), offset, @sizeOf(T) * len);
        if (ptr == null) return null;
        return @as([*]T, @ptrCast(@alignCast(ptr)))[0..len];
    }

    pub fn getMapState(buffer: Buffer) BufferMapState {
        return c.wgpuBufferGetMapState(@ptrCast(buffer));
    }

    pub fn getSize(buffer: Buffer) usize {
        return @intCast(c.wgpuBufferGetSize(@ptrCast(buffer)));
    }

    pub fn getUsage(buffer: Buffer) BufferUsage {
        return c.wgpuBufferGetUsage(@ptrCast(buffer));
    }

    // `offset` - in bytes, has to be a multiple of 8 (Dawn's validation layer will warn).
    // `size` - size of buffer to map in bytes, has to be a multiple of 4 (Dawn's validation layer will warn).
    pub fn mapAsync(
        buffer: Buffer,
        mode: MapMode,
        offset: usize,
        size: usize,
        callback_info: BufferMapCallbackInfo,
    ) Future {
        return @bitCast(c.wgpuBufferMapAsync(@ptrCast(buffer), @bitCast(mode), offset, size, @bitCast(callback_info)));
    }

    pub fn setLabel(buffer: Buffer, label: []const u8) void {
        c.wgpuBufferSetLabel(@ptrCast(buffer), StringView.cFromZig(label));
    }

    pub fn unmap(buffer: Buffer) void {
        c.wgpuBufferUnmap(@ptrCast(buffer));
    }

    pub fn addRef(buffer: Buffer) void {
        c.wgpuBufferAddRef(@ptrCast(buffer));
    }

    pub fn release(buffer: Buffer) void {
        c.wgpuBufferRelease(@ptrCast(buffer));
    }
};

pub const CommandBuffer = *opaque {
    pub fn setLabel(command_buffer: CommandBuffer, label: []const u8) void {
        c.wgpuCommandBufferSetLabel(command_buffer, StringView.cFromZig(label));
    }

    pub fn addRef(command_buffer: CommandBuffer) void {
        c.wgpuCommandBufferAddRef(command_buffer);
    }

    pub fn release(command_buffer: CommandBuffer) void {
        c.wgpuCommandBufferRelease(@ptrCast(command_buffer));
    }
};

pub const CommandEncoder = *opaque {
    pub fn beginComputePass(
        encoder: CommandEncoder,
        descriptor: ?ComputePassDescriptor,
    ) ComputePassEncoder {
        return @ptrCast(c.wgpuCommandEncoderBeginComputePass(
            @ptrCast(encoder),
            if (descriptor) |d| @ptrCast(&d) else null,
        ));
    }

    pub fn beginRenderPass(
        command_encoder: CommandEncoder,
        descriptor: RenderPassDescriptor,
    ) RenderPassEncoder {
        return @ptrCast(c.wgpuCommandEncoderBeginRenderPass(@ptrCast(command_encoder), @ptrCast(&descriptor)));
    }

    pub fn clearBuffer(command_encoder: CommandEncoder, buffer: Buffer, offset: usize, size: usize) void {
        c.wgpuCommandEncoderClearBuffer(command_encoder, buffer, offset, size);
    }

    pub fn copyBufferToBuffer(
        command_encoder: CommandEncoder,
        source: Buffer,
        source_offset: u64,
        destination: Buffer,
        destination_offset: u64,
        size: u64,
    ) void {
        c.wgpuCommandEncoderCopyBufferToBuffer(
            @ptrCast(command_encoder),
            @ptrCast(source),
            source_offset,
            @ptrCast(destination),
            destination_offset,
            size,
        );
    }

    pub fn copyBufferToTexture(
        command_encoder: CommandEncoder,
        source: ImageCopyBuffer,
        destination: ImageCopyTexture,
        copy_size: Extent3D,
    ) void {
        c.wgpuCommandEncoderCopyBufferToTexture(@ptrCast(command_encoder), &source, &destination, &copy_size);
    }

    pub fn copyTextureToBuffer(
        command_encoder: CommandEncoder,
        source: ImageCopyTexture,
        destination: ImageCopyBuffer,
        copy_size: Extent3D,
    ) void {
        c.wgpuCommandEncoderCopyTextureToBuffer(@ptrCast(command_encoder), &source, &destination, &copy_size);
    }

    pub fn copyTextureToTexture(
        command_encoder: CommandEncoder,
        source: ImageCopyTexture,
        destination: ImageCopyTexture,
        copy_size: Extent3D,
    ) void {
        c.wgpuCommandEncoderCopyTextureToTexture(
            @ptrCast(command_encoder),
            @ptrCast(&source),
            @ptrCast(&destination),
            @ptrCast(&copy_size),
        );
    }

    pub fn finish(command_encoder: CommandEncoder, descriptor: ?CommandBufferDescriptor) CommandBuffer {
        return @ptrCast(c.wgpuCommandEncoderFinish(
            @ptrCast(command_encoder),
            if (descriptor) |d| @ptrCast(&d) else null,
        ));
    }

    pub fn injectValidationError(command_encoder: CommandEncoder, message: []const u8) void {
        c.wgpuCommandEncoderInjectValidationError(@ptrCast(command_encoder), StringView.cFromZig(message));
    }

    pub fn insertDebugMarker(command_encoder: CommandEncoder, marker_label: []const u8) void {
        c.wgpuCommandEncoderInsertDebugMarker(@ptrCast(command_encoder), StringView.cFromZig(marker_label));
    }

    pub fn popDebugGroup(command_encoder: CommandEncoder) void {
        c.wgpuCommandEncoderPopDebugGroup(@ptrCast(command_encoder));
    }

    pub fn pushDebugGroup(command_encoder: CommandEncoder, group_label: []const u8) void {
        c.wgpuCommandEncoderPushDebugGroup(@ptrCast(command_encoder), StringView.cFromZig(group_label));
    }

    pub fn resolveQuerySet(
        command_encoder: CommandEncoder,
        query_set: QuerySet,
        first_query: u32,
        query_count: u32,
        destination: Buffer,
        destination_offset: u64,
    ) void {
        c.wgpuCommandEncoderResolveQuerySet(
            @ptrCast(command_encoder),
            @ptrCast(query_set),
            first_query,
            query_count,
            @ptrCast(destination),
            destination_offset,
        );
    }

    pub fn setLabel(command_encoder: CommandEncoder, label: []const u8) void {
        c.wgpuCommandEncoderSetLabel(@ptrCast(command_encoder), StringView.cFromZig(label));
    }

    pub fn writeBuffer(
        command_encoder: CommandEncoder,
        buffer: Buffer,
        buffer_offset: u64,
        comptime T: type,
        data: []const T,
    ) void {
        c.wgpuCommandEncoderWriteBuffer(
            command_encoder,
            buffer,
            buffer_offset,
            @as([*]const u8, @ptrCast(data.ptr)),
            @as(u64, @intCast(data.len)) * @sizeOf(T),
        );
    }

    pub fn writeTimestamp(command_encoder: CommandEncoder, query_set: QuerySet, query_index: u32) void {
        c.wgpuCommandEncoderWriteTimestamp(@ptrCast(command_encoder), @ptrCast(query_set), query_index);
    }

    pub fn addRef(command_encoder: CommandEncoder) void {
        c.wgpuCommandEncoderAddRef(command_encoder);
    }

    pub fn release(command_encoder: CommandEncoder) void {
        c.wgpuCommandEncoderRelease(@ptrCast(command_encoder));
    }
};

pub const ComputePassEncoder = *opaque {
    pub fn dispatchWorkgroups(
        compute_pass_encoder: ComputePassEncoder,
        workgroup_count_x: u32,
        workgroup_count_y: u32,
        workgroup_count_z: u32,
    ) void {
        c.wgpuComputePassEncoderDispatchWorkgroups(
            @ptrCast(compute_pass_encoder),
            workgroup_count_x,
            workgroup_count_y,
            workgroup_count_z,
        );
    }

    pub fn dispatchWorkgroupsIndirect(
        compute_pass_encoder: ComputePassEncoder,
        indirect_buffer: Buffer,
        indirect_offset: u64,
    ) void {
        c.wgpuComputePassEncoderDispatchWorkgroupsIndirect(compute_pass_encoder, indirect_buffer, indirect_offset);
    }

    pub fn end(compute_pass_encoder: ComputePassEncoder) void {
        c.wgpuComputePassEncoderEnd(@ptrCast(compute_pass_encoder));
    }

    pub fn insertDebugMarker(compute_pass_encoder: ComputePassEncoder, marker_label: []const u8) void {
        c.wgpuComputePassEncoderInsertDebugMarker(compute_pass_encoder, StringView.cFromZig(marker_label));
    }

    pub fn popDebugGroup(compute_pass_encoder: ComputePassEncoder) void {
        c.wgpuComputePassEncoderPopDebugGroup(compute_pass_encoder);
    }

    pub fn pushDebugGroup(compute_pass_encoder: ComputePassEncoder, group_label: []const u8) void {
        c.wgpuComputePassEncoderPushDebugGroup(compute_pass_encoder, StringView.cFromZig(group_label));
    }

    pub fn setBindGroup(
        compute_pass_encoder: ComputePassEncoder,
        group_index: u32,
        bind_group: BindGroup,
        dynamic_offsets: ?[]const u32,
    ) void {
        c.wgpuComputePassEncoderSetBindGroup(
            @ptrCast(compute_pass_encoder),
            group_index,
            @ptrCast(bind_group),
            if (dynamic_offsets) |dynoff| @as(u32, @intCast(dynoff.len)) else 0,
            if (dynamic_offsets) |dynoff| dynoff.ptr else null,
        );
    }

    pub fn setLabel(compute_pass_encoder: ComputePassEncoder, label: []const u8) void {
        c.wgpuComputePassEncoderSetLabel(@ptrCast(compute_pass_encoder), StringView.cFromZig(label));
    }

    pub fn setPipeline(compute_pass_encoder: ComputePassEncoder, pipeline: ComputePipeline) void {
        c.wgpuComputePassEncoderSetPipeline(@ptrCast(compute_pass_encoder), @ptrCast(pipeline));
    }

    pub fn writeTimestamp(
        compute_pass_encoder: ComputePassEncoder,
        query_set: QuerySet,
        query_index: u32,
    ) void {
        c.wgpuComputePassEncoderWriteTimestamp(compute_pass_encoder, query_set, query_index);
    }

    pub fn addRef(compute_pass_encoder: ComputePassEncoder) void {
        c.wgpuComputePassEncoderAddRef(compute_pass_encoder);
    }

    pub fn release(compute_pass_encoder: ComputePassEncoder) void {
        c.wgpuComputePassEncoderRelease(@ptrCast(compute_pass_encoder));
    }
};

pub const ComputePipeline = *opaque {
    pub fn getBindGroupLayout(compute_pipeline: ComputePipeline, group_index: u32) BindGroupLayout {
        return c.wgpuComputePipelineGetBindGroupLayout(compute_pipeline, group_index);
    }

    pub fn setLabel(compute_pipeline: ComputePipeline, label: []const u8) void {
        c.wgpuComputePipelineSetLabel(compute_pipeline, StringView.cFromZig(label));
    }

    pub fn addRef(compute_pipeline: ComputePipeline) void {
        c.wgpuComputePipelineAddRef(compute_pipeline);
    }

    pub fn release(compute_pipeline: ComputePipeline) void {
        c.wgpuComputePipelineRelease(@ptrCast(compute_pipeline));
    }
};

pub const ExternalTexture = *opaque {
    pub fn destroy(external_texture: ExternalTexture) void {
        c.wgpuExternalTextureDestroy(external_texture);
    }

    pub fn setLabel(external_texture: ExternalTexture, label: []const u8) void {
        c.wgpuExternalTextureSetLabel(external_texture, StringView.cFromZig(label));
    }

    pub fn addRef(external_texture: ExternalTexture) void {
        c.wgpuExternalTextureAddRef(external_texture);
    }

    pub fn release(external_texture: ExternalTexture) void {
        c.wgpuExternalTextureRelease(external_texture);
    }
};

pub const PipelineLayout = *opaque {
    pub fn setLabel(pipeline_layout: PipelineLayout, label: []const u8) void {
        c.wgpuPipelineLayoutSetLabel(pipeline_layout, StringView.cFromZig(label));
    }

    pub fn addRef(pipeline_layout: PipelineLayout) void {
        c.wgpuPipelineLayoutAddRef(pipeline_layout);
    }

    pub fn release(pipeline_layout: PipelineLayout) void {
        c.wgpuPipelineLayoutRelease(@ptrCast(pipeline_layout));
    }
};

pub const QuerySet = *opaque {
    pub fn destroy(query_set: QuerySet) void {
        c.wgpuQuerySetDestroy(query_set);
    }

    pub fn setLabel(query_set: QuerySet, label: []const u8) void {
        c.wgpuQuerySetSetLabel(query_set, StringView.cFromZig(label));
    }

    pub fn addRef(query_set: QuerySet) void {
        c.wgpuQuerySetAddRef(query_set);
    }

    pub fn release(query_set: QuerySet) void {
        c.wgpuQuerySetRelease(@ptrCast(query_set));
    }
};

pub const Queue = *opaque {
    // pub fn copyExternalTextureForBrowser(
    //     queue: Queue,
    //     source: ImageCopyExternalTexture,
    //     destination: ImageCopyTexture,
    //     copy_size: Extent3D,
    //     options: CopyTextureForBrowserOptions,
    // ) void {
    //     wgpuQueueCopyExternalTextureForBrowser(queue, &source, &destination, &copy_size, &options);
    // }
    // extern fn wgpuQueueCopyExternalTextureForBrowser(
    //     queue: Queue,
    //     source: *const ImageCopyExternalTexture,
    //     destination: *const ImageCopyTexture,
    //     copy_size: *const Extent3D,
    //     options: *const CopyTextureForBrowserOptions,
    // ) void;
    //
    // pub fn copyTextureForBrowser(
    //     queue: Queue,
    //     source: ImageCopyTexture,
    //     destination: ImageCopyTexture,
    //     copy_size: Extent3D,
    //     options: CopyTextureForBrowserOptions,
    // ) void {
    //     wgpuQueueCopyTextureForBrowser(queue, &source, &destination, &copy_size, &options);
    // }
    // extern fn wgpuQueueCopyTextureForBrowser(
    //     queue: Queue,
    //     source: *const ImageCopyTexture,
    //     destination: *const ImageCopyTexture,
    //     copy_size: *const Extent3D,
    //     options: *const CopyTextureForBrowserOptions,
    // ) void;

    pub fn onSubmittedWorkDone(
        queue: Queue,
        signal_value: u64,
        callback: QueueWorkDoneCallback,
        userdata: ?*anyopaque,
    ) void {
        if (emscripten) {
            const oswd = @extern(
                *const fn (
                    queue: Queue,
                    callback: QueueWorkDoneCallback,
                    userdata: ?*anyopaque,
                ) callconv(.C) void,
                .{ .name = "wgpuQueueOnSubmittedWorkDone" },
            );
            oswd(queue, callback, userdata);
        } else {
            const oswd = @extern(
                *const fn (
                    queue: Queue,
                    signal_value: u64,
                    callback: QueueWorkDoneCallback,
                    userdata: ?*anyopaque,
                ) callconv(.C) void,
                .{ .name = "wgpuQueueOnSubmittedWorkDone" },
            );
            oswd(queue, signal_value, callback, userdata);
        }
    }
    pub fn setLabel(queue: Queue, label: []const u8) void {
        c.wgpuQueueSetLabel(queue, StringView.cFromZig(label));
    }

    pub fn submit(queue: Queue, commands: []const CommandBuffer) void {
        c.wgpuQueueSubmit(@ptrCast(queue), @as(u32, @intCast(commands.len)), commands.ptr);
    }

    pub fn writeBuffer(
        queue: Queue,
        buffer: Buffer,
        buffer_offset: usize,
        comptime T: type,
        data: []const T,
    ) void {
        c.wgpuQueueWriteBuffer(
            @ptrCast(queue),
            @ptrCast(buffer),
            @intCast(buffer_offset),
            @as(*const anyopaque, @ptrCast(data.ptr)),
            data.len * @sizeOf(T),
        );
    }

    pub fn writeTexture(
        queue: Queue,
        destination: ImageCopyTexture,
        data_layout: TextureDataLayout,
        write_size: Extent3D,
        comptime T: type,
        data: []const T,
    ) void {
        c.wgpuQueueWriteTexture(
            @ptrCast(queue),
            @ptrCast(&destination),
            @as(*const anyopaque, @ptrCast(data.ptr)),
            @as(usize, @intCast(data.len)) * @sizeOf(T),
            @ptrCast(&data_layout),
            @ptrCast(&write_size),
        );
    }

    pub fn addRef(queue: Queue) void {
        c.wgpuQueueAddRef(@ptrCast(queue));
    }

    pub fn release(queue: Queue) void {
        c.wgpuQueueRelease(@ptrCast(queue));
    }
};

pub const RenderBundle = *opaque {
    pub fn addRef(render_bundle: RenderBundle) void {
        c.wgpuRenderBundleAddRef(render_bundle);
    }

    pub fn release(render_bundle: RenderBundle) void {
        c.wgpuRenderBundleRelease(render_bundle);
    }
};

pub const RenderBundleEncoder = *opaque {
    pub fn draw(
        render_bundle_encoder: RenderBundleEncoder,
        vertex_count: u32,
        instance_count: u32,
        first_vertex: u32,
        first_instance: u32,
    ) void {
        c.wgpuRenderBundleEncoderDraw(
            render_bundle_encoder,
            vertex_count,
            instance_count,
            first_vertex,
            first_instance,
        );
    }

    pub fn drawIndexed(
        render_bundle_encoder: RenderBundleEncoder,
        index_count: u32,
        instance_count: u32,
        first_index: u32,
        base_vertex: i32,
        first_instance: u32,
    ) void {
        c.wgpuRenderBundleEncoderDrawIndexed(
            render_bundle_encoder,
            index_count,
            instance_count,
            first_index,
            base_vertex,
            first_instance,
        );
    }

    pub fn drawIndexedIndirect(
        render_bundle_encoder: RenderBundleEncoder,
        indirect_buffer: Buffer,
        indirect_offset: u64,
    ) void {
        c.wgpuRenderBundleEncoderDrawIndexedIndirect(render_bundle_encoder, indirect_buffer, indirect_offset);
    }

    pub fn drawIndirect(
        render_bundle_encoder: RenderBundleEncoder,
        indirect_buffer: Buffer,
        indirect_offset: u64,
    ) void {
        c.wgpuRenderBundleEncoderDrawIndirect(render_bundle_encoder, indirect_buffer, indirect_offset);
    }

    pub fn finish(
        render_bundle_encoder: RenderBundleEncoder,
        descriptor: RenderBundleDescriptor,
    ) RenderBundle {
        return c.wgpuRenderBundleEncoderFinish(render_bundle_encoder, &descriptor);
    }

    pub fn insertDebugMarker(
        render_bundle_encoder: RenderBundleEncoder,
        marker_label: []const u8,
    ) void {
        c.wgpuRenderBundleEncoderInsertDebugMarker(render_bundle_encoder, StringView.cFromZig(marker_label));
    }

    pub fn popDebugGroup(render_bundle_encoder: RenderBundleEncoder) void {
        c.wgpuRenderBundleEncoderPopDebugGroup(render_bundle_encoder);
    }

    pub fn pushDebugGroup(render_bundle_encoder: RenderBundleEncoder, group_label: []const u8) void {
        c.wgpuRenderBundleEncoderPushDebugGroup(render_bundle_encoder, StringView.cFromZig(group_label));
    }

    pub fn setBindGroup(
        render_bundle_encoder: RenderBundleEncoder,
        group_index: u32,
        group: BindGroup,
        dynamic_offsets: ?[]const u32,
    ) void {
        c.wgpuRenderBundleEncoderSetBindGroup(
            render_bundle_encoder,
            group_index,
            group,
            if (dynamic_offsets) |dynoff| @as(u32, @intCast(dynoff.len)) else 0,
            if (dynamic_offsets) |dynoff| dynoff.ptr else null,
        );
    }

    pub fn setIndexBuffer(
        render_bundle_encoder: RenderBundleEncoder,
        buffer: Buffer,
        format: IndexFormat,
        offset: u64,
        size: u64,
    ) void {
        c.wgpuRenderBundleEncoderSetIndexBuffer(render_bundle_encoder, buffer, format, offset, size);
    }

    pub fn setLabel(render_bundle_encoder: RenderBundleEncoder, label: []const u8) void {
        c.wgpuRenderBundleEncoderSetLabel(render_bundle_encoder, StringView.cFromZig(label));
    }

    pub fn setPipeline(render_bundle_encoder: RenderBundleEncoder, pipeline: RenderPipeline) void {
        c.wgpuRenderBundleEncoderSetPipeline(render_bundle_encoder, pipeline);
    }

    pub fn setVertexBuffer(
        render_bundle_encoder: RenderBundleEncoder,
        slot: u32,
        buffer: Buffer,
        offset: u64,
        size: u64,
    ) void {
        c.wgpuRenderBundleEncoderSetVertexBuffer(render_bundle_encoder, slot, buffer, offset, size);
    }

    pub fn addRef(render_bundle_encoder: RenderBundleEncoder) void {
        c.wgpuRenderBundleEncoderAddRef(render_bundle_encoder);
    }

    pub fn release(render_bundle_encoder: RenderBundleEncoder) void {
        c.wgpuRenderBundleEncoderRelease(render_bundle_encoder);
    }
};

pub const RenderPassEncoder = *opaque {
    pub fn beginOcclusionQuery(render_pass_encoder: RenderPassEncoder, query_index: u32) void {
        c.wgpuRenderPassEncoderBeginOcclusionQuery(render_pass_encoder, query_index);
    }

    pub fn draw(
        render_pass_encoder: RenderPassEncoder,
        vertex_count: u32,
        instance_count: u32,
        first_vertex: u32,
        first_instance: u32,
    ) void {
        c.wgpuRenderPassEncoderDraw(
            @ptrCast(render_pass_encoder),
            vertex_count,
            instance_count,
            first_vertex,
            first_instance,
        );
    }

    pub fn drawIndexed(
        render_pass_encoder: RenderPassEncoder,
        index_count: u32,
        instance_count: u32,
        first_index: u32,
        base_vertex: i32,
        first_instance: u32,
    ) void {
        c.wgpuRenderPassEncoderDrawIndexed(
            @ptrCast(render_pass_encoder),
            index_count,
            instance_count,
            first_index,
            base_vertex,
            first_instance,
        );
    }

    pub fn drawIndexedIndirect(
        render_pass_encoder: RenderPassEncoder,
        indirect_buffer: Buffer,
        indirect_offset: u64,
    ) void {
        c.wgpuRenderPassEncoderDrawIndexedIndirect(render_pass_encoder, indirect_buffer, indirect_offset);
    }

    pub fn drawIndirect(
        render_pass_encoder: RenderPassEncoder,
        indirect_buffer: Buffer,
        indirect_offset: u64,
    ) void {
        c.wgpuRenderPassEncoderDrawIndirect(render_pass_encoder, indirect_buffer, indirect_offset);
    }

    pub fn end(render_pass_encoder: RenderPassEncoder) void {
        c.wgpuRenderPassEncoderEnd(@ptrCast(render_pass_encoder));
    }

    pub fn endOcclusionQuery(render_pass_encoder: RenderPassEncoder) void {
        c.wgpuRenderPassEncoderEndOcclusionQuery(render_pass_encoder);
    }

    pub fn executeBundles(
        render_pass_encoder: RenderPassEncoder,
        bundle_count: u32,
        bundles: [*]const RenderBundle,
    ) void {
        c.wgpuRenderPassEncoderExecuteBundles(render_pass_encoder, bundle_count, bundles);
    }

    pub fn insertDebugMarker(render_pass_encoder: RenderPassEncoder, marker_label: []const u8) void {
        c.wgpuRenderPassEncoderInsertDebugMarker(render_pass_encoder, StringView.cFromZig(marker_label));
    }

    pub fn popDebugGroup(render_pass_encoder: RenderPassEncoder) void {
        c.wgpuRenderPassEncoderPopDebugGroup(render_pass_encoder);
    }

    pub fn pushDebugGroup(render_pass_encoder: RenderPassEncoder, group_label: []const u8) void {
        c.wgpuRenderPassEncoderPushDebugGroup(render_pass_encoder, StringView.cFromZig(group_label));
    }

    pub fn setBindGroup(
        render_pass_encoder: RenderPassEncoder,
        group_index: u32,
        group: BindGroup,
        dynamic_offsets: ?[]const u32,
    ) void {
        c.wgpuRenderPassEncoderSetBindGroup(
            @ptrCast(render_pass_encoder),
            group_index,
            group,
            if (dynamic_offsets) |dynoff| @as(u32, @intCast(dynoff.len)) else 0,
            if (dynamic_offsets) |dynoff| dynoff.ptr else null,
        );
    }

    pub fn setBlendConstant(render_pass_encoder: RenderPassEncoder, color: Color) void {
        c.wgpuRenderPassEncoderSetBlendConstant(render_pass_encoder, &color);
    }

    pub fn setIndexBuffer(
        render_pass_encoder: RenderPassEncoder,
        buffer: Buffer,
        format: IndexFormat,
        offset: u64,
        size: u64,
    ) void {
        c.wgpuRenderPassEncoderSetIndexBuffer(@ptrCast(render_pass_encoder), buffer, format, offset, size);
    }

    pub fn setLabel(render_pass_encoder: RenderPassEncoder, label: []const u8) void {
        c.wgpuRenderPassEncoderSetLabel(@ptrCast(render_pass_encoder), StringView.cFromZig(label));
    }

    pub fn setPipeline(render_pass_encoder: RenderPassEncoder, pipeline: RenderPipeline) void {
        c.wgpuRenderPassEncoderSetPipeline(@ptrCast(render_pass_encoder), pipeline);
    }

    pub fn setScissorRect(
        render_pass_encoder: RenderPassEncoder,
        x: u32,
        y: u32,
        width: u32,
        height: u32,
    ) void {
        c.wgpuRenderPassEncoderSetScissorRect(render_pass_encoder, x, y, width, height);
    }

    pub fn setStencilReference(render_pass_encoder: RenderPassEncoder, ref: u32) void {
        c.wgpuRenderPassEncoderSetStencilReference(render_pass_encoder, ref);
    }

    pub fn setVertexBuffer(
        render_pass_encoder: RenderPassEncoder,
        slot: u32,
        buffer: Buffer,
        offset: u64,
        size: u64,
    ) void {
        c.wgpuRenderPassEncoderSetVertexBuffer(@ptrCast(render_pass_encoder), slot, buffer, offset, size);
    }

    pub fn setViewport(
        render_pass_encoder: RenderPassEncoder,
        x: f32,
        y: f32,
        width: f32,
        height: f32,
        min_depth: f32,
        max_depth: f32,
    ) void {
        c.wgpuRenderPassEncoderSetViewport(render_pass_encoder, x, y, width, height, min_depth, max_depth);
    }

    pub fn writeTimestamp(
        render_pass_encoder: RenderPassEncoder,
        query_set: QuerySet,
        query_index: u32,
    ) void {
        c.wgpuRenderPassEncoderWriteTimestamp(render_pass_encoder, query_set, query_index);
    }

    pub fn addRef(render_pass_encoder: RenderPassEncoder) void {
        c.wgpuRenderPassEncoderAddRef(render_pass_encoder);
    }

    pub fn release(render_pass_encoder: RenderPassEncoder) void {
        c.wgpuRenderPassEncoderRelease(@ptrCast(render_pass_encoder));
    }
};

pub const RenderPipeline = *opaque {
    pub fn getBindGroupLayout(render_pipeline: RenderPipeline, group_index: u32) BindGroupLayout {
        return c.wgpuRenderPipelineGetBindGroupLayout(@ptrCast(render_pipeline), group_index);
    }

    pub fn setLabel(render_pipeline: RenderPipeline, label: []const u8) void {
        c.wgpuRenderPipelineSetLabel(@ptrCast(render_pipeline), StringView.cFromZig(label));
    }

    pub fn addRef(render_pipeline: RenderPipeline) void {
        c.wgpuRenderPipelineAddRef(@ptrCast(render_pipeline));
    }

    pub fn release(render_pipeline: RenderPipeline) void {
        c.wgpuRenderPipelineRelease(@ptrCast(render_pipeline));
    }
};

pub const Sampler = *opaque {
    pub fn setLabel(sampler: Sampler, label: []const u8) void {
        c.wgpuSamplerSetLabel(@ptrCast(sampler), StringView.cFromZig(label));
    }

    pub fn addRef(sampler: Sampler) void {
        c.wgpuSamplerAddRef(@ptrCast(sampler));
    }

    pub fn release(sampler: Sampler) void {
        c.wgpuSamplerRelease(@ptrCast(sampler));
    }
};

pub const ShaderModule = *opaque {
    pub fn getCompilationInfo(
        shader_module: ShaderModule,
        callback: CompilationInfoCallback,
        userdata: ?*anyopaque,
    ) void {
        c.wgpuShaderModuleGetCompilationInfo(@ptrCast(shader_module), callback, userdata);
    }

    pub fn setLabel(shader_module: ShaderModule, label: []const u8) void {
        c.wgpuShaderModuleSetLabel(@ptrCast(shader_module), StringView.cFromZig(label));
    }

    pub fn addRef(shader_module: ShaderModule) void {
        c.wgpuShaderModuleAddRef(@ptrCast(shader_module));
    }

    pub fn release(shader_module: ShaderModule) void {
        c.wgpuShaderModuleRelease(@ptrCast(shader_module));
    }
};

pub const Surface = *opaque {
    pub fn configure(
        surface: Surface,
        config: SurfaceConfiguration,
    ) void {
        c.wgpuSurfaceConfigure(@ptrCast(surface), @ptrCast(&config));
    }

    pub fn getCurrentTexture(surface: Surface, surface_texture: *SurfaceTexture) void {
        c.wgpuSurfaceGetCurrentTexture(@ptrCast(surface), @ptrCast(surface_texture));
    }

    pub fn present(surface: Surface) Status {
        return @enumFromInt(c.wgpuSurfacePresent(@ptrCast(surface)));
    }

    pub fn addRef(surface: Surface) void {
        c.wgpuSurfaceAddRef(@ptrCast(surface));
    }

    pub fn release(surface: Surface) void {
        c.wgpuSurfaceRelease(@ptrCast(surface));
    }
};

pub const Texture = *opaque {
    pub fn createView(texture: Texture, descriptor: TextureViewDescriptor) TextureView {
        return @ptrCast(c.wgpuTextureCreateView(@ptrCast(texture), @ptrCast(&descriptor)));
    }

    pub fn destroy(texture: Texture) void {
        c.wgpuTextureDestroy(@ptrCast(texture));
    }

    pub fn setLabel(texture: Texture, label: []const u8) void {
        c.wgpuTextureSetLabel(@ptrCast(texture), StringView.cFromZig(label));
    }

    pub fn getWidth(texture: Texture) u32 {
        return c.wgpuTextureGetWidth(@ptrCast(texture));
    }

    pub fn getHeight(texture: Texture) u32 {
        return c.wgpuTextureGetHeight(@ptrCast(texture));
    }

    pub fn addRef(texture: Texture) void {
        c.wgpuTextureAddRef(@ptrCast(texture));
    }

    pub fn release(texture: Texture) void {
        c.wgpuTextureRelease(@ptrCast(texture));
    }
};

pub const TextureView = *opaque {
    pub fn setLabel(texture_view: TextureView, label: []const u8) void {
        c.wgpuTextureViewSetLabel(@ptrCast(texture_view), StringView.cFromZig(label));
    }

    pub fn addRef(texture_view: TextureView) void {
        c.wgpuTextureViewAddRef(@ptrCast(texture_view));
    }

    pub fn release(texture_view: TextureView) void {
        c.wgpuTextureViewRelease(@ptrCast(texture_view));
    }
};
