use std::path::PathBuf;

pub struct Assembler {
    file_path: PathBuf,
    make_verilog: bool,
}

impl Assembler {
    pub fn new(args: Vec<String>) -> Assembler {
        let file_path = if args.len() > 1 {
            let file = &args[1];
            let file_path = PathBuf::from(&file);
            if let Some(extension) = file_path.extension() {
                if extension == "s" {
                    file_path
                } else {
                    panic!("Incorrect file type, expect assembly: .s");
                }
            } else {
                panic!("Incorrect file type, expect assembly: .s");
            }
        } else {
            panic!("No File Given");
        };

        let make_verilog = args.len() > 2 && args[2] == "-v";

        Assembler {
            file_path,
            make_verilog,
        }
    }
    pub fn assemble(&mut self) {}
}
