use std::env;

use crate::assembler::Assembler;

pub mod assembler;

fn main() {
    let args: Vec<String> = env::args().collect();
    let mut assembler = Assembler::new(args);
    assembler.assemble();
}
