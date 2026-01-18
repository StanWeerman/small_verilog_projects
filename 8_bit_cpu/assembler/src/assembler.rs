pub mod instruction;

use std::{
    collections::HashMap,
    fs::{self, File},
    io::{BufRead, BufReader, BufWriter, Write},
    path::PathBuf,
};

use crate::assembler::instruction::Instruction;

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
    pub fn assemble(&mut self) {
        let file = File::open(&self.file_path).expect(&format!(
            "No file found {}",
            self.file_path.as_os_str().to_str().expect("Bad OS str")
        ));
        let reader = BufReader::new(file);

        let mut address = 0;
        let mut label_map = HashMap::new();
        let mut instructions = Vec::new();

        for line in reader.lines() {
            let line = line.unwrap();
            if line.contains(":") {
                label_map.insert(line[0..line.len() - 1].to_string(), address);
            } else {
                instructions.push(Instruction::from_str(&line, &label_map));
                address += 1;
            }
        }

        for instruction in &instructions {
            println!("{:?}", instruction);
        }

        self.write_executable(&instructions);
        if self.make_verilog {
            self.write_verilog(&instructions);
        }
    }
    pub fn write_executable(&self, instructions: &Vec<Instruction>) {
        fs::create_dir_all(self.file_path.with_file_name(&format!("build")))
            .expect("Couldn't make directory");
        let file = File::create(
            self.file_path
                .with_file_name(&format!(
                    "build/{}",
                    self.file_path
                        .file_name()
                        .expect("Couldn't Get File Name")
                        .to_str()
                        .expect("Couldn't Make File")
                ))
                .with_extension(""),
        )
        .expect("Should be able to make file");
        let mut file_writer = BufWriter::new(&file);
        for instruction in instructions {
            file_writer
                .write(&instruction.get_bytes())
                .expect(&format!("Failed to write to File"));
        }
    }
    pub fn write_verilog(&self, instructions: &Vec<Instruction>) {
        let file = File::create(
            self.file_path
                .with_file_name(&format!(
                    "build/{}_v",
                    self.file_path
                        .file_name()
                        .expect("Couldn't Get File Name")
                        .to_str()
                        .expect("Couldn't Make File")
                ))
                .with_extension("txt"),
        )
        .expect("Should be able to make file");
        let mut file_writer = BufWriter::new(&file);
        for (index, instruction) in instructions.iter().enumerate() {
            file_writer
                .write(
                    format!(
                        "ins_mem.memory[{}] = 16'{};\n",
                        index,
                        &format!("{:#018b}", instruction.get_u16())[1..]
                    )
                    .as_bytes(),
                )
                .expect(&format!("Failed to write to File"));
        }
    }
}
