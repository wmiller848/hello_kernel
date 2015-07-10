#![feature(no_std)]
#![no_std]
#![no_main]

#![feature(intrinsics)]
#![feature(asm)]

// Include the 'core' type lib compiled
// for our target, this impl's target
// data type methods, like u8 + u8 or i32 / i32
// https://doc.rust-lang.org/core/
#![feature(core)]
extern crate core;

#[allow(dead_code)]
#[allow(missing_copy_implementations)]

// Arch specific
// If we wanted to impl data type methods like +, -, etc..
// for data types like u8, u16, etc..
// #![feature(lang_items)]
// #[lang = "sized"]
// trait Sized {}
//
// #[lang = "copy"]
// trait Copy {}
//
// #[lang = "add"]
// trait Add {}
//
// #[lang = "subtract"]
// trait Subtract {}
//
// #[lang = "multiply"]
// trait Multiply {}
//
// #[lang = "devide"]
// trait Devide {}

// These functions and traits are used by the compiler, but not
// for a bare-bones hello world. These are normally
// provided by libstd.
// #[lang = "stack_exhausted"] extern fn stack_exhausted() {}
// #[lang = "eh_personality"] extern fn eh_personality() {}
// #[lang = "panic_fmt"] fn panic_fmt() -> ! { loop {} }

static COLOR_BLACK: u16 = 0;
static COLOR_BLUE: u16 = 1;
static COLOR_GREEN: u16 = 2;
static COLOR_CYAN: u16 = 3;
static COLOR_RED: u16 = 4;
static COLOR_MAGENTA: u16 = 5;
static COLOR_BROWN: u16 = 6;
static COLOR_LIGHT_GREY: u16 = 7;
static COLOR_DARK_GREY: u16 = 8;
static COLOR_LIGHT_BLUE: u16 = 9;
static COLOR_LIGHT_GREEN: u16 = 10;
static COLOR_LIGHT_CYAN: u16 = 11;
static COLOR_LIGHT_RED: u16 = 12;
static COLOR_LIGHT_MAGENTA: u16 = 13;
static COLOR_LIGHT_BROWN: u16 = 14;
static COLOR_WHITE: u16 = 15;


static VGA_WIDTH: usize = 80;
static VGA_HEIGHT: usize = 25;

static VGA_ADDRESS: usize = 0xB8000;

struct VGA;


fn make_vga_color(fg: u16, bg: u16) -> u16 {
    return fg | bg << 4;
}

fn make_vga_entry(ch: u8, color: u16) -> u16 {
    let char16 = ch as u16;
    return char16 | color << 8;
}

fn write(chars: &[u8], size: usize) {
    let mut x: usize = 0;
    let mut y: usize = 1;
    // C
    // terminal_buffer = (uint16_t*) 0xB8000;
    // terminal_buffer[0] and terminal_buffer[1]
    // C lang calculates the correct number of bytes per index
    // for you based off the type (uint16_t)
    let num_bytes_per_index: usize = 2;

    for i in 0..size {
        let color = make_vga_color(COLOR_GREEN, COLOR_BLACK);
        let index: usize = ((y * VGA_WIDTH) + x) * num_bytes_per_index;
        unsafe {
            // let char_bytes = transmute::<&str, &[u8]>(chars);
            let entry = make_vga_entry(chars[i], color);
            let mut entry_ptr = (VGA_ADDRESS + index) as *mut u16;
            *(entry_ptr) = entry
        }
        x += 1;
    }
}

#[no_mangle]
#[no_stack_check]
pub fn kernel_main() {
    // let chars = "Hello World";
    let tt = exchange_malloc(2);
    let chars:&[u8] = b"Hello World";
    write(chars, 10  as usize);
    loop {}
}

fn get_ptr<T>(buf: &str) -> (*mut T, u8) {
    unsafe { transmute(buf) }
}

extern "rust-intrinsic" {
    pub fn transmute<T,U>(val: T) -> U;
}
