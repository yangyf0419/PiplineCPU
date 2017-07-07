# -*- coding: utf-8 -*-
"""
Created on Mon Jul  3 18:11:22 2017

@author: Yang YiFei
"""

import sys
import os.path
import re

assert len(sys.argv) > 1, "No file designated"

class FileNameError(Exception):
    def __init__(self, msg):
        Exception.__init__(self)
        self.message = msg

register = {
    '$zero': "5'b00000",
    '$at': "5'b00001", 
    '$v0': "5'b00010", 
    '$v1': "5'b00011",
    '$a0': "5'b00100",
    '$a1': "5'b00101",
    '$a2': "5'b00110",
    '$a3': "5'b00111",
    '$t0': "5'b01000",
    '$t1': "5'b01001",
    '$t2': "5'b01010",
    '$t3': "5'b01011",
    '$t4': "5'b01100",
    '$t5': "5'b01101",
    '$t6': "5'b01110",
    '$t7': "5'b01111",
    '$s0': "5'b10000",
    '$s1': "5'b10001",
    '$s2': "5'b10010",
    '$s3': "5'b10011",
    '$s4': "5'b10100",
    '$s5': "5'b10101",
    '$s6': "5'b10110",
    '$s7': "5'b10111",
    '$t8': "5'b11000",
    '$t9': "5'b11001",
    '$k0': "5'b11010",
    '$k1': "5'b11011",
    '$gp': "5'b11100",
    '$sp': "5'b11101",
    '$fp': "5'b11110",
    '$ra': "5'b11111"
}

number = {
    '$0': "5'b00000",
    '$1': "5'b00001", 
    '$2': "5'b00010", 
    '$3': "5'b00011",
    '$4': "5'b00100",
    '$5': "5'b00101",
    '$6': "5'b00110",
    '$7': "5'b00111",
    '$8': "5'b01000",
    '$9': "5'b01001",
    '$10': "5'b01010",
    '$11': "5'b01011",
    '$12': "5'b01100",
    '$13': "5'b01101",
    '$14': "5'b01110",
    '$15': "5'b01111",
    '$16': "5'b10000",
    '$17': "5'b10001",
    '$18': "5'b10010",
    '$19': "5'b10011",
    '$20': "5'b10100",
    '$21': "5'b10101",
    '$22': "5'b10110",
    '$23': "5'b10111",
    '$24': "5'b11000",
    '$25': "5'b11001",
    '$26': "5'b11010",
    '$27': "5'b11011",
    '$28': "5'b11100",
    '$29': "5'b11101",
    '$30': "5'b11110",
    '$31': "5'b11111"
}

opcode = {
    

}

line_pattern = re.compile(r'^(.*:)?(.*)$')
def processLines(lines:[str]): # abandon remarks
    lines = list(map(lambda ln: ln.split('#')[0], lines)) 
    lines_without_label = [] # lines without label
    labelindex = {} # record label index
    for line in lines:
        match_group = line_pattern.match(line).groups()
        if match_group[0]: # label exists
            if labelindex.get(match_group[0][:-1].strip()) != None:
                raise Exception("Label "+match_group[0][:-1].strip()+" already exists!")
            labelindex[match_group[0][:-1].strip()] = len(lines_without_label)
        if match_group[1].strip():
            lines_without_label.append(match_group[1].strip())
            
    return lines_without_label, labelindex
    
def getOpr(line:str): # generate a tuple to seperate oprations
    try:
        seperater = line.index(' ')
    except ValueError as e:
        if line == 'nop':
            instruction = ('sll','$zero, $zero, 0')
        else:
            raise e
    else:
        instruction = (line[:seperater], line[seperater + 1:].strip())
    finally: return instruction
    
def dec2bin(numstr: str, bitnum: int): # convert decimal number into binary one
    num = int(numstr)
    if (num >= 0):
        binnum = bin(num)[2:]
        if len(binnum) > bitnum:
            binnum = binnum[-bitnum:]
        else:
            binnum = '0' * (bitnum - len(binnum)) + binnum
    else:
        binnum = bin(~num)[2:]
        binnum = ''.join(list(map(lambda bit: str(int(bit == '0')), binnum)))
        if len(binnum) > bitnum:
            binnum = binnum[-bitnum:]
        else:
            binnum = '1' * (bitnum - len(binnum)) + binnum
    return str(bitnum) + "'b" + binnum

word_inst_pattern = re.compile('^(\d*)\s*\((.*)\)$') # sw & lw patterns 
def analyzeGrammar(line:(int, (str, str)), label:dict): #generate machine code
    index = line[0]
    opr = line[1][0]
    ins = list(map(lambda x: x.strip(), line[1][1].split(',')))
    mcode = ''
    
    if opr == 'lui':
        opcode = "6'b001111"
        rs = "5'b00000"
        rt = register.get(ins[0], number.get(ins[0]))
        if not rt:
            raise KeyError('unknown register ' + ins[0])
        immediate = dec2bin(ins[1], 16)
        mcode = '{' + ', '.join([opcode, rs, rt, immediate]) + '}'
        
    elif opr == 'add':
        opcode = "6'b000000"
        rd = register.get(ins[0], number.get(ins[0]))
        if not rd:
            raise KeyError('unknown register ' + ins[0])
        rs = register.get(ins[1], number.get(ins[1]))
        if not rs:
            raise KeyError('unknown register ' + ins[1])
        rt = register.get(ins[2], number.get(ins[2]))
        if not rt:
            raise KeyError('unknown register ' + ins[2])
        shamt = "5'b00000"
        funct = "6'b100000"
        mcode = '{' + ', '.join([opcode, rs, rt, rd, shamt, funct]) + '}'
    
    elif opr == 'addi':
        opcode = "6'b001000"
        rt = register.get(ins[0], number.get(ins[0]))
        if not rt:
            raise KeyError('unknown register ' + ins[0])
        rs = register.get(ins[1], number.get(ins[1]))
        if not rs:
            raise KeyError('unknown register ' + ins[1])
        immediate = dec2bin(ins[2], 16)
        mcode = '{' + ', '.join([opcode, rs, rt, immediate]) + '}'
        
    elif opr == 'addiu':
        opcode = "6'b001001"
        rt = register.get(ins[0], number.get(ins[0]))
        if not rt:
            raise KeyError('unknown register ' + ins[0])
        rs = register.get(ins[1], number.get(ins[1]))
        if not rs:
            raise KeyError('unknown register ' + ins[1])
        immediate = dec2bin(ins[2], 16)
        mcode = '{' + ', '.join([opcode, rs, rt, immediate]) + '}'
        
    elif opr == 'addu':
        opcode = "6'b000000"
        rd = register.get(ins[0], number.get(ins[0]))
        if not rd:
            raise KeyError('unknown register ' + ins[0])
        rs = register.get(ins[1], number.get(ins[1]))
        if not rs:
            raise KeyError('unknown register ' + ins[1])
        rt = register.get(ins[2], number.get(ins[2]))
        if not rt:
            raise KeyError('unknown register ' + ins[2])
        shamt = "5'b00000"
        funct = "6'b100001"
        mcode = '{' + ', '.join([opcode, rs, rt, rd, shamt, funct]) + '}'
    
    elif opr == 'sub':
        opcode = "6'b000000"
        rd = register.get(ins[0], number.get(ins[0]))
        if not rd:
            raise KeyError('unknown register ' + ins[0])
        rs = register.get(ins[1], number.get(ins[1]))
        if not rs:
            raise KeyError('unknown register ' + ins[1])
        rt = register.get(ins[2], number.get(ins[2]))
        if not rt:
            raise KeyError('unknown register ' + ins[2])
        shamt = "5'b00000"
        funct = "6'b100010"
        mcode = '{' + ', '.join([opcode, rs, rt, rd, shamt, funct]) + '}'
    
    elif opr == 'subu':
        opcode = "6'b000000"
        rd = register.get(ins[0], number.get(ins[0]))
        if not rd:
            raise KeyError('unknown register ' + ins[0])
        rs = register.get(ins[1], number.get(ins[1]))
        if not rs:
            raise KeyError('unknown register ' + ins[1])
        rt = register.get(ins[2], number.get(ins[2]))
        if not rt:
            raise KeyError('unknown register ' + ins[2])
        shamt = "5'b00000"
        funct = "6'b100011"
        mcode = '{' + ', '.join([opcode, rs, rt, rd, shamt, funct]) + '}'
    
    elif opr == 'and':
        opcode = "6'b000000"
        rd = register.get(ins[0], number.get(ins[0]))
        if not rd:
            raise KeyError('unknown register ' + ins[0])
        rs = register.get(ins[1], number.get(ins[1]))
        if not rs:
            raise KeyError('unknown register ' + ins[1])
        rt = register.get(ins[2], number.get(ins[2]))
        if not rt:
            raise KeyError('unknown register ' + ins[2])
        shamt = "5'b00000"
        funct = "6'b100100"
        mcode = '{' + ', '.join([opcode, rs, rt, rd, shamt, funct]) + '}'
        
    elif opr == 'andi':
        opcode = "6'b001100"
        rt = register.get(ins[0], number.get(ins[0]))
        if not rt:
            raise KeyError('unknown register ' + ins[0])
        rs = register.get(ins[1], number.get(ins[1]))
        if not rs:
            raise KeyError('unknown register ' + ins[1])
        immediate = dec2bin(ins[2], 16)
        mcode = '{' + ', '.join([opcode, rs, rt, immediate]) + '}'
        
    elif opr == 'or':
        opcode = "6'b000000"
        rd = register.get(ins[0], number.get(ins[0]))
        if not rd:
            raise KeyError('unknown register ' + ins[0])
        rs = register.get(ins[1], number.get(ins[1]))
        if not rs:
            raise KeyError('unknown register ' + ins[1])
        rt = register.get(ins[2], number.get(ins[2]))
        if not rt:
            raise KeyError('unknown register ' + ins[2])
        shamt = "5'b00000"
        funct = "6'b100101"
        mcode = '{' + ', '.join([opcode, rs, rt, rd, shamt, funct]) + '}'
    
    elif opr == 'xor':
        opcode = "6'b000000"
        rd = register.get(ins[0], number.get(ins[0]))
        if not rd:
            raise KeyError('unknown register ' + ins[0])
        rs = register.get(ins[1], number.get(ins[1]))
        if not rs:
            raise KeyError('unknown register ' + ins[1])
        rt = register.get(ins[2], number.get(ins[2]))
        if not rt:
            raise KeyError('unknown register ' + ins[2])
        shamt = "5'b00000"
        funct = "6'b100110"
        mcode = '{' + ', '.join([opcode, rs, rt, rd, shamt, funct]) + '}'
        
    elif opr == 'nor':
        opcode = "6'b000000"
        rd = register.get(ins[0], number.get(ins[0]))
        if not rd:
            raise KeyError('unknown register ' + ins[0])
        rs = register.get(ins[1], number.get(ins[1]))
        if not rs:
            raise KeyError('unknown register ' + ins[1])
        rt = register.get(ins[2], number.get(ins[2]))
        if not rt:
            raise KeyError('unknown register ' + ins[2])
        shamt = "5'b00000"
        funct = "6'b100111"
        mcode = '{' + ', '.join([opcode, rs, rt, rd, shamt, funct]) + '}'
        
    elif opr == 'sll':
        opcode = "6'b000000"
        rd = register.get(ins[0], number.get(ins[0]))
        if not rd:
            raise KeyError('unknown register ' + ins[0])
        rs = "5'b00000"
        rt = register.get(ins[1], number.get(ins[1]))
        if not rt:
            raise KeyError('unknown register ' + ins[2])
        shamt = dec2bin(ins[2], 5)
        funct = "6'b000000"
        mcode = '{' + ', '.join([opcode, rs, rt, rd, shamt, funct]) + '}'
        
    elif opr == 'srl':
        opcode = "6'b000000"
        rd = register.get(ins[0], number.get(ins[0]))
        if not rd:
            raise KeyError('unknown register ' + ins[0])
        rs = "5'b00000"
        rt = register.get(ins[1], number.get(ins[1]))
        if not rt:
            raise KeyError('unknown register ' + ins[2])
        shamt = dec2bin(ins[2], 5)
        funct = "6'b000010"
        mcode = '{' + ', '.join([opcode, rs, rt, rd, shamt, funct]) + '}'
    
    elif opr == 'sra':
        opcode = "6'b000000"
        rd = register.get(ins[0], number.get(ins[0]))
        if not rd:
            raise KeyError('unknown register ' + ins[0])
        rs = "5'b00000"
        rt = register.get(ins[1], number.get(ins[1]))
        if not rt:
            raise KeyError('unknown register ' + ins[2])
        shamt = dec2bin(ins[2], 5)
        funct = "6'b000011"
        mcode = '{' + ', '.join([opcode, rs, rt, rd, shamt, funct]) + '}'
    
    elif opr == 'slt':
        opcode = "6'b000000"
        rd = register.get(ins[0], number.get(ins[0]))
        if not rd:
            raise KeyError('unknown register ' + ins[0])
        rs = register.get(ins[1], number.get(ins[1]))
        if not rs:
            raise KeyError('unknown register ' + ins[1])
        rt = register.get(ins[2], number.get(ins[2]))
        if not rt:
            raise KeyError('unknown register ' + ins[2])
        shamt = "5'b00000"
        funct = "6'b101010"
        mcode = '{' + ', '.join([opcode, rs, rt, rd, shamt, funct]) + '}'
        
    elif opr == 'sltu':
        opcode = "6'b000000"
        rd = register.get(ins[0], number.get(ins[0]))
        if not rd:
            raise KeyError('unknown register ' + ins[0])
        rs = register.get(ins[1], number.get(ins[1]))
        if not rs:
            raise KeyError('unknown register ' + ins[1])
        rt = register.get(ins[2], number.get(ins[2]))
        if not rt:
            raise KeyError('unknown register ' + ins[2])
        shamt = "5'b00000"
        funct = "6'b101011"
        mcode = '{' + ', '.join([opcode, rs, rt, rd, shamt, funct]) + '}'
        
    elif opr == 'slti':
        opcode = "6'b001010"
        rt = register.get(ins[0], number.get(ins[0]))
        if not rt:
            raise KeyError('unknown register ' + ins[0])
        rs = register.get(ins[1], number.get(ins[1]))
        if not rs:
            raise KeyError('unknown register ' + ins[1])
        immediate = dec2bin(ins[2], 16)
        mcode = '{' + ', '.join([opcode, rs, rt, immediate]) + '}'
        
    elif opr == 'sltiu':
        opcode = "6'b001011"
        rt = register.get(ins[0], number.get(ins[0]))
        if not rt:
            raise KeyError('unknown register ' + ins[0])
        rs = register.get(ins[1], number.get(ins[1]))
        if not rs:
            raise KeyError('unknown register ' + ins[1])
        immediate = dec2bin(ins[2], 16)
        mcode = '{' + ', '.join([opcode, rs, rt, immediate]) + '}'
        
    elif opr == 'j':
        opcode = "6'b000010"
        label_index = str(label.get(ins[0]))
        if label_index == 'None':
            raise KeyError('unknown label ' + ins[0])
        instr_index = dec2bin(label_index, 26)
        mcode = '{' + ', '.join([opcode, instr_index]) + '}'
        
    elif opr == 'jal':
        opcode = "6'b000011"
        label_index = str(label.get(ins[0]))
        if label_index == 'None':
            raise KeyError('unknown label ' + ins[0])
        instr_index = dec2bin(label_index, 26)
        mcode = '{' + ', '.join([opcode, instr_index]) + '}'
        
    elif opr == 'jalr':
        opcode = "6'b000000"
        if (len(ins) == 1):
            rd = register.get('$ra')
            rs = register.get(ins[0], number.get(ins[0]))
            if not rs:
                raise KeyError('unknown register ' + ins[0])
        else:
            rd = register.get(ins[0], number.get(ins[0]))
            if not rd:
                raise KeyError('unknown register ' + ins[0])
            rs = register.get(ins[1], number.get(ins[1]))
            if not rs:
                raise KeyError('unknown register ' + ins[1])
        rt = "5'b00000"
        shamt = "5'b00000"
        funct = "6'b001001"
        mcode = '{' + ', '.join([opcode, rs, rt, rd, shamt, funct]) + '}' 
        
    elif opr == 'jr':
        opcode = "6'b000000"
        rs = register.get(ins[0], number.get(ins[0]))
        if not rs:
            raise KeyError('unknown register ' + ins[0])
        rt = "5'b00000"
        rd = "5'b00000"
        shamt = "5'b00000"
        funct = "6'b001000"
        mcode = '{' + ', '.join([opcode, rs, rt, rd, shamt, funct]) + '}' 
    
    elif opr == 'beq':
        opcode = "6'b000100"
        rs = register.get(ins[0], number.get(ins[0]))
        if not rs:
            raise KeyError('unknown register ' + ins[0])
        rt = register.get(ins[1], number.get(ins[1]))
        if not rt:
            raise KeyError('unknown register ' + ins[1])
        label_index = label.get(ins[2])
        if label_index == None:
            raise KeyError('unknown label ' + ins[2])
        offset = dec2bin(str(label_index - index - 1), 16)
        mcode = '{' + ', '.join([opcode, rs, rt, offset]) + '}'
    
    elif opr == 'bne':
        opcode = "6'b000101"
        rs = register.get(ins[0], number.get(ins[0]))
        if not rs:
            raise KeyError('unknown register ' + ins[0])
        rt = register.get(ins[1], number.get(ins[1]))
        if not rt:
            raise KeyError('unknown register ' + ins[1])
        label_index = label.get(ins[2])
        if label_index == None:
            raise KeyError('unknown label ' + ins[2])
        offset = dec2bin(str(label_index - index - 1), 16)
        mcode = '{' + ', '.join([opcode, rs, rt, offset]) + '}'    
    
    elif opr == 'blez':
        opcode = "6'b000110"
        rs = register.get(ins[0], number.get(ins[0]))
        if not rs:
            raise KeyError('unknown register ' + ins[0])
        rt = "5'b00000"
        label_index = label.get(ins[1])
        if label_index == None:
            raise KeyError('unknown label ' + ins[1])
        offset = dec2bin(str(label_index - index - 1), 16)
        mcode = '{' + ', '.join([opcode, rs, rt, offset]) + '}' 
        
    elif opr == 'bgtz':
        opcode = "6'b000111"
        rs = register.get(ins[0], number.get(ins[0]))
        if not rs:
            raise KeyError('unknown register ' + ins[0])
        rt = "5'b00000"
        label_index = label.get(ins[1])
        if label_index == None:
            raise KeyError('unknown label ' + ins[1])
        offset = dec2bin(str(label_index - index - 1), 16)
        mcode = '{' + ', '.join([opcode, rs, rt, offset]) + '}' 
        
    elif opr == 'bltz':
        opcode = "6'b000001"
        rs = register.get(ins[0], number.get(ins[0]))
        if not rs:
            raise KeyError('unknown register ' + ins[0])
        rt = "5'b00000"
        label_index = label.get(ins[1])
        if label_index == None:
            raise KeyError('unknown label ' + ins[1])
        offset = dec2bin(str(label_index - index - 1), 16)
        mcode = '{' + ', '.join([opcode, rs, rt, offset]) + '}' 
        
    elif opr == 'sw':
        opcode = "6'b101011"
        rt = register.get(ins[0], number.get(ins[0]))
        if not rt:
            raise KeyError('unknown register ' + ins[0])
        offset_base = word_inst_pattern.match(ins[1])
        if not offset_base:
            raise Exception('invalid statement of instruction SW')
        offset_base = offset_base.groups()
        base = offset_base[1].strip()
        base = register.get(base, number.get(base))
        if not base:
            raise KeyError('unknown register ' + base)
        offset = dec2bin(offset_base[0], 16)
        mcode = '{' + ', '.join([opcode, base, rt, offset]) + '}'
    
    elif opr == 'lw':
        opcode = "6'b100011"
        rt = register.get(ins[0], number.get(ins[0]))
        if not rt:
            raise KeyError('unknown register ' + ins[0])
        offset_base = word_inst_pattern.match(ins[1])
        if not offset_base:
            raise Exception('invalid statement of instruction LW')
        offset_base = offset_base.groups()
        base = offset_base[1].strip()
        base = register.get(base, number.get(base))
        if not base:
            raise KeyError('unknown register ' + base)
        offset = dec2bin(offset_base[0], 16)
        mcode = '{' + ', '.join([opcode, base, rt, offset]) + '}'
        
    else:
        raise Exception('undefined instruction ' + opr)
        
    return mcode
    
for path in sys.argv[1:]:
    if os.path.splitext(path)[1] == '.asm':
        name = os.path.splitext(path)[0]
        with open(path, 'r') as f:
            lines = f.readlines()
        lines, index = processLines(lines)
        lines = list(map(getOpr, lines))
        lines = list(map(lambda x: analyzeGrammar(x, index), list(enumerate(lines))))
        lines = ["16'd" + str(index) + ": data <= " + line + ";" for index, line in enumerate(lines)]
        with open(name + '.mcc', 'w') as f:
            f.write('\n'.join(lines))
    else:
        raise FileNameError("Invalid Suffix(only .asm is valid)") 

