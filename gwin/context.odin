package gwin

import "base:runtime"
import "core:log"
import "wl"

WaylandContext :: struct {
	app_context:              runtime.Context,
	event_handler:            WindowEventHandler,
	display:                  ^wl.display,
	registry:                 ^wl.registry,
	compositor:               ^wl.compositor,
	wm_base:                  ^wl.wm_base,
	shm:                      ^wl.shm,
	seat:                     ^wl.seat,
	viewporter:               ^wl.viewporter,
	relative_pointer_manager: ^wl.relative_pointer_manager_v1,
	cursor_shape_manager:     ^wl.cursor_shape_manager_v1,
	pointer_constraints:      ^wl.pointer_constraints_v1,
	fractional_scale_manager: ^wl.fractional_scale_manager_v1,
	windows:                  map[^wl.surface]^WaylandWindow,
	keyboards:                map[^wl.keyboard]^WaylandKeyboard,
	pointers:                 map[^wl.pointer]^WaylandPointer,
}

create_wayland_context :: proc(ctx: ^WaylandContext, event_handler: WindowEventHandler) -> bool {
	ctx.app_context = context
	ctx.event_handler = event_handler

	ctx.display = wl.display_connect(nil)
	if ctx.display == nil {
		log.error("Failed to connect to Wayland display")
		return false
	}

	ctx.registry = wl.display_get_registry(ctx.display)
	if ctx.registry == nil {
		log.error("Failed to get Wayland registry")
		return false
	}
	wl.registry_add_listener(ctx.registry, &registry_listener, ctx)
	wl.display_roundtrip(ctx.display)

	if ctx.compositor == nil || ctx.wm_base == nil {
		log.error("Failed to bind required Wayland interfaces")
		return false
	}
	wl.wm_base_add_listener(ctx.wm_base, &wm_base_listener, ctx)

	ctx.windows = make(map[^wl.surface]^WaylandWindow)
	ctx.keyboards = make(map[^wl.keyboard]^WaylandKeyboard)
	ctx.pointers = make(map[^wl.pointer]^WaylandPointer)
	return true
}

destroy_wayland_context :: proc(ctx: ^WaylandContext) {
	for surf, win in ctx.windows {
		destroy_window(win)
	}
	for _, keyboard in ctx.keyboards {
		destroy_keyboard(keyboard)
	}
	for _, pointer in ctx.pointers {
		destroy_pointer(pointer)
	}
	delete(ctx.windows)
	delete(ctx.keyboards)
	delete(ctx.pointers)

	if ctx.relative_pointer_manager != nil {
		wl.relative_pointer_manager_v1_destroy(ctx.relative_pointer_manager)
	}
	if ctx.pointer_constraints != nil {
		wl.pointer_constraints_v1_destroy(ctx.pointer_constraints)
	}
	if ctx.cursor_shape_manager != nil {
		wl.cursor_shape_manager_v1_destroy(ctx.cursor_shape_manager)
	}
	if ctx.fractional_scale_manager != nil {
		wl.fractional_scale_manager_v1_destroy(ctx.fractional_scale_manager)
	}
	if ctx.viewporter != nil {
		wl.viewporter_destroy(ctx.viewporter)
	}
	if ctx.seat != nil {
		wl.seat_destroy(ctx.seat)
	}
	if ctx.shm != nil {
		wl.shm_destroy(ctx.shm)
	}
	if ctx.wm_base != nil {
		wl.wm_base_destroy(ctx.wm_base)
	}
	if ctx.compositor != nil {
		wl.compositor_destroy(ctx.compositor)
	}
	if ctx.registry != nil {
		wl.registry_destroy(ctx.registry)
	}
	if ctx.display != nil {
		wl.display_disconnect(ctx.display)
	}
}

get_display_fd :: proc(ctx: ^WaylandContext) -> int {
	return wl.display_get_fd(ctx.display)
}

dispatch_events :: proc(ctx: ^WaylandContext) -> bool {
	return wl.display_dispatch(ctx.display) > 0
}

@(private = "file")
registry_listener := wl.registry_listener {
	global        = on_registry_global,
	global_remove = on_registry_global_remove,
}

@(private = "file")
wm_base_listener := wl.wm_base_listener {
	ping = on_ping,
}

@(private = "file")
seat_listener := wl.seat_listener {
	capabilities = on_seat_capabilities,
	name         = on_seat_name,
}

@(private = "file")
on_registry_global :: proc "c" (
	data: rawptr,
	registry: ^wl.registry,
	name: uint,
	interface: cstring,
	version: uint,
) {
	ctx := cast(^WaylandContext)data
	switch interface {
	case wl.compositor_interface.name:
		ctx.compositor = cast(^wl.compositor)wl.registry_bind(
			registry,
			name,
			&wl.compositor_interface,
			4,
		)

	case wl.wm_base_interface.name:
		ctx.wm_base = cast(^wl.wm_base)wl.registry_bind(registry, name, &wl.wm_base_interface, 1)

	case wl.shm_interface.name:
		ctx.shm = cast(^wl.shm)wl.registry_bind(registry, name, &wl.shm_interface, 1)

	case wl.seat_interface.name:
		ctx.seat = cast(^wl.seat)wl.registry_bind(registry, name, &wl.seat_interface, 5)
		wl.seat_add_listener(ctx.seat, &seat_listener, data)

	case wl.viewporter_interface.name:
		ctx.viewporter = cast(^wl.viewporter)wl.registry_bind(
			registry,
			name,
			&wl.viewporter_interface,
			1,
		)

	case wl.relative_pointer_manager_v1_interface.name:
		ctx.relative_pointer_manager = cast(^wl.relative_pointer_manager_v1)wl.registry_bind(
			registry,
			name,
			&wl.relative_pointer_manager_v1_interface,
			1,
		)

	case wl.pointer_constraints_v1_interface.name:
		ctx.pointer_constraints = cast(^wl.pointer_constraints_v1)wl.registry_bind(
			registry,
			name,
			&wl.pointer_constraints_v1_interface,
			1,
		)

	case wl.fractional_scale_manager_v1_interface.name:
		ctx.fractional_scale_manager = cast(^wl.fractional_scale_manager_v1)wl.registry_bind(
			registry,
			name,
			&wl.fractional_scale_manager_v1_interface,
			1,
		)

	case wl.cursor_shape_manager_v1_interface.name:
		ctx.cursor_shape_manager = cast(^wl.cursor_shape_manager_v1)wl.registry_bind(
			registry,
			name,
			&wl.cursor_shape_manager_v1_interface,
			1,
		)
	}
}

@(private = "file")
on_registry_global_remove :: proc "c" (data: rawptr, registry: ^wl.registry, name: uint) {}

@(private = "file")
on_ping :: proc "c" (data: rawptr, wm: ^wl.wm_base, serial: uint) {
	wl.wm_base_pong(wm, serial)
}

@(private = "file")
on_seat_capabilities :: proc "c" (data: rawptr, seat_ptr: ^wl.seat, caps: wl.seat_capability) {
	ctx := cast(^WaylandContext)data
	if ctx == nil {
		return
	}
	context = ctx.app_context
	if (caps & .keyboard == .keyboard) {
		kb := wl.seat_get_keyboard(seat_ptr)
		ctx.keyboards[kb] = create_keyboard(ctx, kb)
	}
	if (caps & .pointer == .pointer) {
		pt := wl.seat_get_pointer(seat_ptr)
		ctx.pointers[pt] = create_pointer(ctx, pt)
	}
}

@(private = "file")
on_seat_name :: proc "c" (data: rawptr, seat_ptr: ^wl.seat, name: cstring) {}

