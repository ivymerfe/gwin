package gwin

import "wl"

WaylandPointer :: struct {
	ctx:                 ^WaylandContext,
	pt:                  ^wl.pointer,
	focused_window:      ^WaylandWindow,
	locked:              bool,
	serial:              uint,
	axis_discrete_x:     int,
	axis_discrete_y:     int,
	cursor_shape_device: ^wl.cursor_shape_device_v1,
	relative_pointer:    ^wl.relative_pointer_v1,
	locked_pointer:      ^wl.locked_pointer_v1,
}

create_pointer :: proc(ctx: ^WaylandContext, pt: ^wl.pointer) -> ^WaylandPointer {
	pointer := new(WaylandPointer)
	pointer.ctx = ctx
	pointer.pt = pt
	wl.pointer_add_listener(pt, &pointer_listener, pointer)

	if ctx.cursor_shape_manager != nil {
		pointer.cursor_shape_device = wl.cursor_shape_manager_v1_get_pointer(
			ctx.cursor_shape_manager,
			pt,
		)
	}
	if ctx.relative_pointer_manager != nil {
		relative_pointer := wl.relative_pointer_manager_v1_get_relative_pointer(
			ctx.relative_pointer_manager,
			pt,
		)
		if relative_pointer != nil {
			pointer.relative_pointer = relative_pointer
			wl.relative_pointer_v1_add_listener(
				relative_pointer,
				&relative_pointer_listener,
				pointer,
			)
		}
	}

	return pointer
}

destroy_pointer :: proc(pointer: ^WaylandPointer) {
	if pointer.locked_pointer != nil {
		wl.locked_pointer_v1_destroy(pointer.locked_pointer)
	}
	if pointer.relative_pointer != nil {
		wl.relative_pointer_v1_destroy(pointer.relative_pointer)
	}
	if pointer.cursor_shape_device != nil {
		wl.cursor_shape_device_v1_destroy(pointer.cursor_shape_device)
	}
	wl.pointer_destroy(pointer.pt)
	free(pointer)
}

lock_pointer :: proc(pointer: ^WaylandPointer, lock: bool, win: ^WaylandWindow) {
	if lock == pointer.locked {
		return
	}
	ctx := pointer.ctx
	if lock {
		if pointer.serial != 0 {
			wl.pointer_set_cursor(pointer.pt, pointer.serial, nil, 0, 0)
		}
		if ctx.pointer_constraints != nil && pointer.locked_pointer == nil {
			pointer.locked_pointer = wl.pointer_constraints_v1_lock_pointer(
				ctx.pointer_constraints,
				win.surface,
				pointer.pt,
				nil,
				.persistent,
			)
			if pointer.locked_pointer != nil {
				wl.locked_pointer_v1_add_listener(
					pointer.locked_pointer,
					&locked_pointer_listener,
					pointer,
				)
			}
		}
	} else {
		if pointer.locked_pointer != nil {
			wl.locked_pointer_v1_destroy(pointer.locked_pointer)
			pointer.locked_pointer = nil
		}
		pointer.locked = false
		if pointer.cursor_shape_device != nil && pointer.serial != 0 {
			wl.cursor_shape_device_v1_set_shape(
				pointer.cursor_shape_device,
				pointer.serial,
				u32(wl.cursor_shape_v1_shape.default),
			)
		}
	}
}

@(private = "file")
pointer_listener := wl.pointer_listener {
	enter         = on_enter,
	leave         = on_leave,
	motion        = on_motion,
	button        = on_button,
	axis          = on_axis,
	frame         = on_frame,
	axis_source   = on_axis_source,
	axis_stop     = on_axis_stop,
	axis_discrete = on_axis_discrete,
}

@(private = "file")
relative_pointer_listener := wl.relative_pointer_v1_listener {
	relative_motion = relative_pointer_motion,
}

@(private = "file")
locked_pointer_listener := wl.locked_pointer_v1_listener {
	locked   = locked_pointer_locked,
	unlocked = locked_pointer_unlocked,
}

@(private = "file")
on_enter :: proc "c" (
	data: rawptr,
	pt: ^wl.pointer,
	serial: uint,
	surface: ^wl.surface,
	sx: i32,
	sy: i32,
) {
	pointer := cast(^WaylandPointer)data
	if pointer == nil {
		return
	}
	context = pointer.ctx.app_context
	pointer.serial = serial
	pointer.focused_window = pointer.ctx.windows[surface]

	if pointer.focused_window != nil {
		pointer.ctx.event_handler(
			pointer.focused_window,
			EventPointerEnter{pointer = pointer, x = f32(sx) / 256.0, y = f32(sy) / 256.0},
		)
	}
}

@(private = "file")
on_leave :: proc "c" (data: rawptr, pt: ^wl.pointer, serial: uint, surface: ^wl.surface) {
	pointer := cast(^WaylandPointer)data
	if pointer == nil {
		return
	}
	context = pointer.ctx.app_context
	win := pointer.ctx.windows[surface]
	if win == pointer.focused_window {
		pointer.ctx.event_handler(win, EventPointerLeave{pointer = pointer})
		pointer.focused_window = nil
	}
}

@(private = "file")
on_motion :: proc "c" (data: rawptr, pt: ^wl.pointer, time: uint, sx: i32, sy: i32) {
	pointer := cast(^WaylandPointer)data
	if pointer == nil || pointer.focused_window == nil {
		return
	}
	context = pointer.ctx.app_context
	x := f32(sx) / 256.0
	y := f32(sy) / 256.0
	pointer.ctx.event_handler(
		pointer.focused_window,
		EventPointerMotion{pointer = pointer, x = x, y = y},
	)
}

@(private = "file")
on_button :: proc "c" (
	data: rawptr,
	pt: ^wl.pointer,
	serial: uint,
	time: uint,
	button: uint,
	state: wl.pointer_button_state,
) {
	pointer := cast(^WaylandPointer)data
	if pointer == nil || pointer.focused_window == nil {
		return
	}
	context = pointer.ctx.app_context
	pointer.ctx.event_handler(
		pointer.focused_window,
		EventPointerButton{pointer = pointer, button = u32(button), pressed = state == .pressed},
	)
}

@(private = "file")
relative_pointer_motion :: proc "c" (
	data: rawptr,
	relative_pointer: ^wl.relative_pointer_v1,
	utime_hi: uint,
	utime_lo: uint,
	dx: wl.fixed_t,
	dy: wl.fixed_t,
	dx_unaccel: wl.fixed_t,
	dy_unaccel: wl.fixed_t,
) {
	pointer := cast(^WaylandPointer)data
	if pointer == nil || pointer.focused_window == nil {
		return
	}
	context = pointer.ctx.app_context
	pointer.ctx.event_handler(
		pointer.focused_window,
		EventPointerRelative {
			pointer = pointer,
			dx = f32(dx_unaccel) / 256.0,
			dy = f32(dy_unaccel) / 256.0,
		},
	)
}

@(private = "file")
locked_pointer_locked :: proc "c" (data: rawptr, locked_pointer: ^wl.locked_pointer_v1) {
	pointer := cast(^WaylandPointer)data
	if pointer == nil {
		return
	}
	pointer.locked = true
}

@(private = "file")
locked_pointer_unlocked :: proc "c" (data: rawptr, locked_pointer: ^wl.locked_pointer_v1) {
	pointer := cast(^WaylandPointer)data
	if pointer == nil {
		return
	}
	context = pointer.ctx.app_context
	pointer.locked = false
	if pointer.locked_pointer == locked_pointer {
		wl.locked_pointer_v1_destroy(pointer.locked_pointer)
		pointer.locked_pointer = nil
	}
}

@(private = "file")
on_axis :: proc "c" (
	data: rawptr,
	pt: ^wl.pointer,
	time: uint,
	axis: wl.pointer_axis,
	value: i32,
) {
	pointer := cast(^WaylandPointer)data
	if pointer == nil || pointer.focused_window == nil {
		return
	}
	context = pointer.ctx.app_context

	dx := f32(0)
	dy := f32(0)
	#partial switch axis {
	case .horizontal_scroll:
		if pointer.axis_discrete_x != 0 {
			dx = f32(pointer.axis_discrete_x)
			pointer.axis_discrete_x = 0
		} else {
			dx = f32(value) / 256.0
		}
	case .vertical_scroll:
		if pointer.axis_discrete_y != 0 {
			dy = f32(pointer.axis_discrete_y)
			pointer.axis_discrete_y = 0
		} else {
			dy = f32(value) / 256.0
		}
	}

	if dx != 0 || dy != 0 {
		pointer.ctx.event_handler(
			pointer.focused_window,
			EventPointerScroll{pointer = pointer, dx = dx, dy = dy},
		)
	}
}

@(private = "file")
on_frame :: proc "c" (data: rawptr, pt: ^wl.pointer) {}

@(private = "file")
on_axis_source :: proc "c" (data: rawptr, pt: ^wl.pointer, axis_source: wl.pointer_axis_source) {}

@(private = "file")
on_axis_stop :: proc "c" (data: rawptr, pt: ^wl.pointer, time: uint, axis: wl.pointer_axis) {}

@(private = "file")
on_axis_discrete :: proc "c" (
	data: rawptr,
	pt: ^wl.pointer,
	axis: wl.pointer_axis,
	discrete: int,
) {
	pointer := cast(^WaylandPointer)data
	if pointer == nil {
		return
	}
	#partial switch axis {
	case .horizontal_scroll:
		pointer.axis_discrete_x = discrete
	case .vertical_scroll:
		pointer.axis_discrete_y = discrete
	}
}

