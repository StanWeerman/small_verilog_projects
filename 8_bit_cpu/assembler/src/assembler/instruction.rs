use std::{collections::HashMap, panic};

type Imm = u8;
type Addr = u8;
#[derive(Debug)]
pub enum Instruction {
    Mov(Reg, Imm),
    Add(Reg, Reg, Reg),
    Sub(Reg, Reg, Reg),
    And(Reg, Reg, Reg),
    Or(Reg, Reg, Reg),
    St(Reg, Addr),
    Ld(Reg, Addr),
    Jmp(Imm),
}

impl Instruction {
    pub fn from_str(instr: &str, label_map: &HashMap<String, u8>) -> Instruction {
        let parts: Vec<&str> = instr.split_whitespace().collect();
        match parts[0] {
            "mov" => {
                if parts.len() == 3 {
                    Instruction::Mov(Reg::from_str(parts[1]), imm_from_str(parts[2]))
                } else {
                    panic!("Invalid Mov: {}", instr);
                }
            }
            "add" => {
                if parts.len() == 4 {
                    Instruction::Add(
                        Reg::from_str(parts[1]),
                        Reg::from_str(parts[2]),
                        Reg::from_str(parts[3]),
                    )
                } else {
                    panic!("Invalid Add: {}", instr);
                }
            }
            "sub" => {
                if parts.len() == 4 {
                    Instruction::Sub(
                        Reg::from_str(parts[1]),
                        Reg::from_str(parts[2]),
                        Reg::from_str(parts[3]),
                    )
                } else {
                    panic!("Invalid Sub: {}", instr);
                }
            }
            "and" => {
                if parts.len() == 4 {
                    Instruction::And(
                        Reg::from_str(parts[1]),
                        Reg::from_str(parts[2]),
                        Reg::from_str(parts[3]),
                    )
                } else {
                    panic!("Invalid And: {}", instr);
                }
            }
            "or" => {
                if parts.len() == 4 {
                    Instruction::Or(
                        Reg::from_str(parts[1]),
                        Reg::from_str(parts[2]),
                        Reg::from_str(parts[3]),
                    )
                } else {
                    panic!("Invalid Or: {}", instr);
                }
            }
            "st" => {
                if parts.len() == 3 {
                    Instruction::St(Reg::from_str(parts[1]), imm_from_str(parts[2]))
                } else {
                    panic!("Invalid St: {}", instr);
                }
            }
            "ld" => {
                if parts.len() == 3 {
                    Instruction::Ld(Reg::from_str(parts[1]), imm_from_str(parts[2]))
                } else {
                    panic!("Invalid Ld: {}", instr);
                }
            }
            "jmp" => {
                if parts.len() == 2 {
                    if let Some(address) = label_map.get(&parts[1][1..]) {
                        Instruction::Jmp(*address)
                    } else {
                        println!("{:?}", label_map);
                        panic!("Invalid Label: {}", parts[1]);
                    }
                } else {
                    panic!("Invalid Jmp: {}", instr);
                }
            }
            _ => panic!("Unsupported instruction: {}", parts[0]),
        }
    }
    pub fn get_bytes(&self) -> [u8; 2] {
        let instr = self.get_u16();
        return instr.to_be_bytes();
    }
    pub fn get_u16(&self) -> u16 {
        let instr: u16 = match self {
            Instruction::Mov(reg, imm) => reg.get_bits(0) | imm_get_bits(imm) | 0b00011,
            Instruction::Add(reg0, reg1, reg2) => {
                reg0.get_bits(0) | reg1.get_bits(1) | reg2.get_bits(2) | 0b0000001
            }
            Instruction::Sub(reg0, reg1, reg2) => {
                reg0.get_bits(0) | reg1.get_bits(1) | reg2.get_bits(2) | 0b0000101
            }
            Instruction::And(reg0, reg1, reg2) => {
                reg0.get_bits(0) | reg1.get_bits(1) | reg2.get_bits(2) | 0b0001101
            }
            Instruction::Or(reg0, reg1, reg2) => {
                reg0.get_bits(0) | reg1.get_bits(1) | reg2.get_bits(2) | 0b0001001
            }
            Instruction::St(reg0, addr) => reg0.get_bits(0) | imm_get_bits(addr) | 0b00010,
            Instruction::Ld(reg0, addr) => reg0.get_bits(0) | imm_get_bits(addr) | 0b00100,
            Instruction::Jmp(imm) => imm_get_bits(imm) | 0b10000,
        };
        // println!("{:#018b} {:#06X}, {:05}", instr, instr, instr);
        return instr;
    }
}
#[derive(Debug)]
pub enum Reg {
    R(u8),
}
impl Reg {
    pub fn from_str(reg_str: &str) -> Reg {
        if let Some(char) = reg_str.chars().nth(0) {
            if char == 'r' {
                if let Some(val) = reg_str.chars().nth(1) {
                    if let Some(val) = val.to_digit(10) {
                        if val < 8 {
                            Reg::R(val as u8)
                        } else {
                            panic!("Invalid Register: {}", reg_str);
                        }
                    } else {
                        panic!("Invalid Register: {}", reg_str);
                    }
                } else {
                    panic!("Invalid Register: {}", reg_str);
                }
            } else {
                panic!("Invalid Register: {}", reg_str);
            }
        } else {
            panic!("Invalid Register: {}", reg_str);
        }
    }
    pub fn get_val(&self) -> u8 {
        match self {
            Reg::R(val) => *val,
        }
    }
    pub fn get_bits(&self, num: u8) -> u16 {
        (self.get_val() as u16)
            << match num {
                0 => 13,
                1 => 10,
                2 => 7,
                _ => panic!("Bad Reg Number in Encoding: {}", num),
            }
    }
}

pub fn imm_from_str(imm_str: &str) -> u8 {
    if let Some(char) = imm_str.chars().nth(0) {
        if char == '#' {
            if let Ok(val) = imm_str[1..].parse() {
                val
            } else {
                panic!("Invalid Immediate: {}", imm_str);
            }
        } else {
            panic!("Invalid Immediate: {}", imm_str);
        }
    } else {
        panic!("Invalid Immediate: {}", imm_str);
    }
}

pub fn imm_get_bits(imm: &u8) -> u16 {
    (*imm as u16) << 5
}
