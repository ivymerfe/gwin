package gwin

import "core:log"
import "wl"

WaylandWindow :: struct {
	ctx:              ^WaylandContext,
	id:               u32,
	app_id:           cstring,
	title:            cstring,
	width:            int,
	height:           int,
	buffer_width:     f32,
	buffer_height:    f32,
	scale:            f32,
	configured:       bool,
	fullscreen:       bool,
	visible:          bool,
	surface:          ^wl.surface,
	xdg_surface:      ^wl.xdg_surface,
	toplevel:         ^wl.toplevel,
	viewport:         ^wl.viewport,
	fractional_scale: ^wl.fractional_scale_v1,
}

create_window :: proc(
	ctx: ^WaylandContext,
	id: u32,
	app_id: cstring,
	title: cstring,
	width: int,
	height: int,
	buffer_width: f32,
	buffer_height: f32,
) -> (
	window: ^WaylandWindow,
	success: bool,
) {
	surface := wl.compositor_create_surface(ctx.compositor)
	if surface == nil {
		log.error("Failed to create Wayland surface")
		return
	}
	window = new(WaylandWindow)
	window.id = id
	window.ctx = ctx
	window.surface = surface
	window.app_id = app_id
	window.title = title
	window.width = width
	window.height = height
	window.buffer_width = buffer_width
	window.buffer_height = buffer_height
	window.scale = 1.0
	window.visible = false

	ctx.windows[surface] = window

	show_window(window)
	success = true
	return
}

destroy_window :: proc(win: ^WaylandWindow) {
	if win == nil {
		return
	}
	if win.fractional_scale != nil {
		wl.fractional_scale_v1_destroy(win.fractional_scale)
	}
	if win.viewport != nil {
		wl.viewport_destroy(win.viewport)
	}
	if win.toplevel != nil {
		wl.toplevel_destroy(win.toplevel)
	}
	if win.xdg_surface != nil {
		wl.xdg_surface_destroy(win.xdg_surface)
	}
	if win.surface != nil {
		wl.surface_destroy(win.surface)
	}
	delete_key(&win.ctx.windows, win.surface)
	free(win)
}

@(private = "file")
show_window :: proc(win: ^WaylandWindow) {
	if win.visible {
		return
	}
	win.configured = false

	xdg_surface := wl.wm_base_get_xdg_surface(win.ctx.wm_base, win.surface)
	if xdg_surface == nil {
		log.error("Failed to create XDG surface")
		wl.surface_destroy(win.surface)
		return
	}

	toplevel := wl.xdg_surface_get_toplevel(xdg_surface)
	if toplevel == nil {
		log.error("Failed to create XDG toplevel")
		wl.xdg_surface_destroy(xdg_surface)
		wl.surface_destroy(win.surface)
		return
	}
	win.xdg_surface = xdg_surface
	win.toplevel = toplevel

	wl.xdg_surface_add_listener(xdg_surface, &xdg_surface_listener, win)
	wl.toplevel_add_listener(toplevel, &toplevel_listener, win)

	wl.toplevel_set_min_size(toplevel, 320, 180)
	wl.toplevel_set_max_size(
		toplevel,
		int(win.buffer_width / win.scale),
		int(win.buffer_height / win.scale),
	)
	wl.toplevel_set_app_id(toplevel, win.app_id)
	wl.toplevel_set_title(toplevel, win.title)

	if win.ctx.viewporter != nil {
		win.viewport = wl.viewporter_get_viewport(win.ctx.viewporter, win.surface)
		if win.viewport != nil {
			wl.viewport_set_destination(
				win.viewport,
				int(win.buffer_width / win.scale),
				int(win.buffer_height / win.scale),
			)
		}
	}
	if win.ctx.fractional_scale_manager != nil {
		win.fractional_scale = wl.fractional_scale_manager_v1_get_fractional_scale(
			win.ctx.fractional_scale_manager,
			win.surface,
		)
		if win.fractional_scale != nil {
			wl.fractional_scale_v1_add_listener(
				win.fractional_scale,
				&fractional_scale_listener,
				win,
			)
		}
	}

	wl.surface_commit(win.surface)
	wl.display_roundtrip(win.ctx.display)

	win.visible = true
}

@(private = "file")
hide_window :: proc(win: ^WaylandWindow) {
	if !win.visible {
		return
	}
	wl.surface_attach(win.surface, nil, 0, 0)
	wl.surface_commit(win.surface)

	if win.viewport != nil {
		wl.viewport_destroy(win.viewport)
		win.viewport = nil
	}

	if win.fractional_scale != nil {
		wl.fractional_scale_v1_destroy(win.fractional_scale)
		win.fractional_scale = nil
	}

	wl.toplevel_destroy(win.toplevel)
	wl.xdg_surface_destroy(win.xdg_surface)

	win.toplevel = nil
	win.xdg_surface = nil
	win.visible = false
	win.configured = false
}

set_window_visible :: proc(win: ^WaylandWindow, visible: bool) {
	if win == nil {
		return
	}
	if visible && !win.visible {
		show_window(win)
	} else if !visible && win.visible {
		hide_window(win)
	}
}

set_window_fullscreen :: proc(win: ^WaylandWindow, fullscreen: bool) {
	if win == nil {
		return
	}
	if fullscreen == win.fullscreen {
		return
	}
	if fullscreen {
		wl.toplevel_set_fullscreen(win.toplevel, nil)
	} else {
		wl.toplevel_unset_fullscreen(win.toplevel)
	}
	win.fullscreen = fullscreen
}

@(private = "file")
toplevel_listener := wl.toplevel_listener {
	configure = on_toplevel_configure,
	close     = on_toplevel_close,
}

@(private = "file")
xdg_surface_listener := wl.xdg_surface_listener {
	configure = on_surface_configure,
}

@(private = "file")
fractional_scale_listener := wl.fractional_scale_v1_listener {
	preferred_scale = on_preferred_scale,
}

@(private = "file")
on_surface_configure :: proc "c" (data: rawptr, surface: ^wl.xdg_surface, serial: uint) {
	wl.xdg_surface_ack_configure(surface, serial)
	win := cast(^WaylandWindow)data
	if win != nil {
		context = win.ctx.app_context
		win.configured = true
	}
}

@(private = "file")
on_toplevel_configure :: proc "c" (
	data: rawptr,
	toplevel: ^wl.toplevel,
	width: int,
	height: int,
	states: ^wl.array,
) {
	win := cast(^WaylandWindow)data
	if win == nil {
		return
	}
	context = win.ctx.app_context
	if width > 0 && height > 0 && (win.width != width || win.height != height) {
		if width < win.width || height < win.height {
			win.fullscreen = false
		}
		win.width = width
		win.height = height
		win.ctx.event_handler(win, EventWindowResize{width = width, height = height})
	}
	win.fullscreen = false
	state_bytes := cast([^]u8)states.data
	for i: i64 = 0; i < states.size; i += 1 {
		state := wl.toplevel_state(state_bytes[i])
		if state == .fullscreen {
			win.fullscreen = true
		}
	}
}

@(private = "file")
on_toplevel_close :: proc "c" (data: rawptr, toplevel: ^wl.toplevel) {
	win := cast(^WaylandWindow)data
	if win == nil {
		return
	}
	context = win.ctx.app_context
	win.ctx.event_handler(win, EventWindowClose{})
}

@(private = "file")
on_preferred_scale :: proc "c" (
	data: rawptr,
	fractional_scale: ^wl.fractional_scale_v1,
	scale_120: u32,
) {
	win := cast(^WaylandWindow)data
	if win == nil {
		return
	}
	context = win.ctx.app_context
	// Scale is encoded as 120ths (e.g., 120 = 1.0, 240 = 2.0, 180 = 1.5)
	win.scale = f32(scale_120) / 120.0
	wl.toplevel_set_max_size(
		win.toplevel,
		int(win.buffer_width / win.scale),
		int(win.buffer_height / win.scale),
	)
	if win.viewport != nil {
		wl.viewport_set_destination(
			win.viewport,
			int(win.buffer_width / win.scale),
			int(win.buffer_height / win.scale),
		)
	}
}

