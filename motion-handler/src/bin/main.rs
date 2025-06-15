#![no_std]
#![no_main]

use esp_backtrace as _;
use esp_println::println;

#[esp_hal::main]
fn main() -> ! {
    println!("Hello, world!");

    loop { }
}
