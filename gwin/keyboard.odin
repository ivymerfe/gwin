package gwin

import "core:c"
import "core:log"
import "core:sys/linux"

import "wl"
import "xkb"

WaylandKeyboard :: struct {
	ctx:            ^WaylandContext,
	kb:             ^wl.keyboard,
	focused_window: ^WaylandWindow,
	xkb:            xkb.KeyboardContext,
	repeat_rate:    int,
	repeat_delay:   int,
}

create_keyboard :: proc(ctx: ^WaylandContext, kb: ^wl.keyboard) -> ^WaylandKeyboard {
	keyboard := new(WaylandKeyboard)
	keyboard.ctx = ctx
	keyboard.kb = kb
	keyboard.xkb = xkb.keyboard_context_create()
	wl.keyboard_add_listener(kb, &kb_listener, keyboard)
	return keyboard
}

destroy_keyboard :: proc(keyboard: ^WaylandKeyboard) {
	xkb.keyboard_context_destroy(&keyboard.xkb)
	wl.keyboard_destroy(keyboard.kb)
	free(keyboard)
}

@(private = "file")
kb_listener := wl.keyboard_listener {
	enter       = on_enter,
	leave       = on_leave,
	keymap      = on_keymap,
	key         = on_key,
	modifiers   = on_modifiers,
	repeat_info = on_repeat_info,
}

@(private = "file")
on_enter :: proc "c" (
	data: rawptr,
	kb: ^wl.keyboard,
	serial: uint,
	surface: ^wl.surface,
	keys: wl.array,
) {
	keyboard := cast(^WaylandKeyboard)data
	if keyboard == nil {
		return
	}
	context = keyboard.ctx.app_context
	keyboard.focused_window = keyboard.ctx.windows[surface]
	if keyboard.focused_window != nil {
		keyboard.ctx.event_handler(
			keyboard.focused_window,
			EventKeyboardEnter{keyboard = keyboard},
		)
	}
}

@(private = "file")
on_leave :: proc "c" (data: rawptr, kb: ^wl.keyboard, serial: uint, surface: ^wl.surface) {
	keyboard := cast(^WaylandKeyboard)data
	if keyboard == nil {
		return
	}
	ctx := keyboard.ctx
	context = ctx.app_context
	win := ctx.windows[surface]
	if win != nil {
		ctx.event_handler(win, EventKeyboardLeave{keyboard = keyboard})
		if win == keyboard.focused_window {
			keyboard.focused_window = nil
		}
	}
}

@(private = "file")
on_keymap :: proc "c" (
	data: rawptr,
	kb: ^wl.keyboard,
	format: wl.keyboard_keymap_format,
	fd: int,
	size: uint,
) {
	keyboard := cast(^WaylandKeyboard)data
	if keyboard == nil {
		return
	}
	context = keyboard.ctx.app_context
	ptr, err := linux.mmap({}, size, {.READ}, {.SHARED}, linux.Fd(fd), 0)
	if err != .NONE {
		log.errorf("Failed to mmap keymap file descriptor: %v", err)
		return
	}
	success := xkb.keyboard_context_set_keymap(&keyboard.xkb, cast(cstring)ptr, cast(c.size_t)size)
	if !success {
		log.error("Failed to set keyboard keymap")
	}
	linux.munmap(ptr, size)
	linux.close(linux.Fd(fd))
}

@(private = "file")
on_key :: proc "c" (
	data: rawptr,
	kb: ^wl.keyboard,
	serial: uint,
	time: uint,
	key: uint,
	state: wl.keyboard_key_state,
) {
	keyboard := cast(^WaylandKeyboard)data
	if keyboard == nil || keyboard.focused_window == nil {
		return
	}
	context = keyboard.ctx.app_context
	key_code := u32(key + 8)
	pressed := state == .pressed
	keysym := xkb.keyboard_context_get_keysym(&keyboard.xkb, key_code)
	buf: [8]u8
	len := xkb.keyboard_context_get_utf8(&keyboard.xkb, key_code, buf[:])
	str := transmute(string)buf[:len]
	if pressed {
		keyboard.ctx.event_handler(
			keyboard.focused_window,
			EventKeyDown{keyboard = keyboard, key = keysym, str = str},
		)
	} else {
		keyboard.ctx.event_handler(
			keyboard.focused_window,
			EventKeyUp{keyboard = keyboard, key = keysym, str = str},
		)
	}
}

@(private = "file")
on_modifiers :: proc "c" (
	data: rawptr,
	kb: ^wl.keyboard,
	serial: uint,
	mods_depressed: uint,
	mods_latched: uint,
	mods_locked: uint,
	group: uint,
) {
	keyboard := cast(^WaylandKeyboard)data
	if keyboard == nil {
		return
	}
	context = keyboard.ctx.app_context
	xkb.keyboard_context_update_modifiers(
		&keyboard.xkb,
		u32(mods_depressed),
		u32(mods_latched),
		u32(mods_locked),
		0,
		0,
		u32(group),
	)
}

@(private = "file")
on_repeat_info :: proc "c" (data: rawptr, kb: ^wl.keyboard, rate: int, delay: int) {
	keyboard := cast(^WaylandKeyboard)data
	if keyboard == nil {
		return
	}
	keyboard.repeat_rate = rate
	keyboard.repeat_delay = delay
}

