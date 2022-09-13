# UniGro16js
Universial Groth16 for EVM implemented in js and MATLAB

## What is the universal Groth16 for EVM?


Universal Groth16 (UGro16) for EVM is a new zk-SNARK that inherits the succinctness of [original Groth16](https://eprint.iacr.org/2016/260.pdf) while adding universality for EVM-based applications. The universality of UGro16 can be said as EVM-specific universality, meaning that a trust setup only need to be executed when an EVM is newly- or re-defined. A universal reference string file generated by a trust setup contains proving and verifying keys for each instuction of an EVM. Thus, the universal reference string can be used for all kinds of EVM applications made of the predefined instructions.

The key idea of UGro16 is Derive algorithm, which linearly combines the proving and verifying keys in a universal reference string according to the combination of instructions forming an EVM application. As the result, Derive outputs a circuit-specific reference string, which is specialized to an EVM application. The execution of Derive does not need a trust, so anyone can be an executor. Derive needs to be executed when an EVM-application is newly developed or updated. The structure of a circuit-specific reference string is almost equivalent with a common reference string of original Groth16's setup except only that UGro16 uses bivarate QAP polynomials instead of univarte ones. This enables us to use prove and verify algorithms of the original Groth16, which is the fastest among all zk-SNARKs.

Based on the same application, UGro16 might be a bit slower than the original Groth16 at the cost of universality. This is because we add redundant constraints to the circuits of EVM instructions to make room for combining.

## Demo. version implementations

### Protocol composition

UGro16 consists of eight algorithms: compile, buildQAP, generateWitness, decode, setup, derive, prove, and verify.
- **compile** takes circom implementations of all EVM instructions as inputs and outputs respective R1CSs and wasms and metadata.
- **buildQAP** takes R1CSs and an EVM parameter as inputs and outputs respective QAP polynomials
- **decode (written in MATLAB script)** takes a p-code(bytecode) of an EVM application, initial storage data, and the EVM instruction metadata as inputs and outputs instances for all instructions used in a p-code and a wire map that contaning circuit information of an EVM application.
- **setup** takes the R1CSs and EVM parameters as inputs and outputs a universal reference string.
- **derive** takes the universal reference string and the wire map as inputs and outputs a circuit-specific reference string.
- **generateWitness** takes instances and the wasms for all instructions used in a p-code as inputs and outputs respective witnesses. Each witness includes the instance as well.
- **prove** takes the circuit-specific reference string, the witnesses, the QAPs and the wire map as inputs and outputs a proof.
- **verify** takes the proof, the circuit-specific reference string, the instances, and the wire map as inputs and prints out whether the proof is valid or not.

### Explanation for the inputs and outputs

- EVM instructions: Arithmetic opcodes including keccak256 in EVM from 0x01 to 0x20
- Circom implementation: A circom script to execute an opcode and build its (sub)circuit.
- R1CS: A set of wires and constraints forming the (sub)circuit of a circom implementation (called subcircuit)
- wasm: A script of executing an opcode ported in wasm
- 

### Prerequisites and preparation for use

- Implementing circoms and generating R1CSs and wasms needs to install Circom package by Iden3.
  - [How to install Circom](https://docs.circom.io/getting-started/installation/)
- Some of libraries by Iden3 are used.
  - How to install Iden3 libraries
      ```
     $ git clone https://github.com/Onther-Tech/UniGro16js.git
     $ cd UniGro16js
     $ npm install
     ```
- Compatibility with EVM (in the current version)
  - [compile](https://github.com/Onther-Tech/circom-ethereum-opcodes/blob/main/README.md)
  - [decode](https://github.com/Onther-Tech/UniGro16js/edit/master/Decode/readme.md)
- User input parameters
  - $s_D$: The number of instructions defined in an EVM.
  - $s_{max}$: The maximum number of arithmetic opcodes (might be defined by an EVM system) that can be contained in an EVM application (p-code).
  - 

### How to use

All file names used in the following commands does not include the file name extensions (e.g., for "refstr.rs", just type "refstr")
- **compile**
  - Be sure that the input [circom scripts](https://github.com/Onther-Tech/circom-ethereum-opcodes/blob/main/README.md) are in "./resource/subcircuits/circom/\[instruction name]\_test.circom".
  - [How to run compile](https://github.com/Onther-Tech/circom-ethereum-opcodes/blob/main/test/TEST.md) and [the compatibility with EVM in the current version](https://github.com/Onther-Tech/circom-ethereum-opcodes/blob/main/README.md#circuit-design)
  - Find the output EVM information in "./resource/subcircuits/wire_list.json", where the indices of instructions are numbered.
  - Find the output R1CSs in "./resources/subcircuits/R1CS/subcircuit#.r1cs" for all indices # of instructions upto $s_D-1$.
  - Find the output wasms "./resources/subcircuits/wasm/subcircuit#.wasm" for all indices # of instructions upto $s_D-1$.
- **buildQAP**
  - Be sure that the R1CSs generated by compile are in the proper directory.
  - Enter the command "node  build/cli.cjs  QAP_all  bn128  $s_D$  $s_{max}$"
  - Find an output QAP parameter in "./resource/subcircuits/param$s_D$\_$s_{max}$.dat".
  - Find the output QAPs in "./resource/subcircuits/QAP\_$s_D$\_$s_{max}$/subcircuit#.qap" for all indices # of instructions upto $s_D-1$.
- **setup**
  - Be sure that the R1CSs generated by compile are in the proper directory.
  - Enter the command "node build/cli.cjs setup param\_$s_D$\_$s_{max}$ \[output rs file name] \[any number for the seed of random generation]".
  - Find the output universal reference string in "./resource/universal_rs/\[output rs file name].urs".
- **decode**
  - [How to run decode and the compatibility with EVM in the current version](https://github.com/Onther-Tech/UniGro16js/edit/master/Decode/readme.md)
  - Copy and paste the output circuit information into "./resource/circuits/\[circuit (EVM application) directory name]/{OpList.bin, Set_I_P.bin, Set_I_V.bin, WireList.bin}".
  - Copy and paste the output instances into "./resource/circuits/\[circuit (EVM application) directory name]/instance\[the index of circuit instance set]/{input_opcode#.json, output_opcode#.json}" for for all indices # of opcodes used in an EVM application less than $s_{max}$.
- **derive**
  - Be sure that the circuit information generated by decode are in the proper directory.
  - Enter the command "node build/cli.cjs derive \[input rs file name] \[output crs file name] \[circuit directory name] QAP\_$s_D$\_$s_{max}$".
  - Find the output circuit-specific reference string in "./resource/circuits/\[circuit directory name]/\[output crs file name].crs".
- **generateWitness**
  - In the current version, generatedWitness is called during executing prove (will be updated to be separately executed).
  - Find the output witnesses in "./resource/circuits/\[circuit directory name]/witness\[the index of circuit instance set]/witness#.wtns" for all indices # of opcodes used in an EVM application less than s_max.
- **prove**
  - Be sure that all the outputs of the above algorithms are in the proper directories.
  - Enter the command "node build/cli.cjs prove \[input crs file name] \[output proof file name] QAP\_$s_D$\_$s_{max}$ \[circuit (EVM application) directory name] \[any number for the seed of random generation] \[the index of circuit instance set]".
  - Find the output proof in "./resource/circuits/\[circuit directory name]/\[output proof file name].proof".
- **verify**
   - Be sure that all the outputs of the above algorithms are in the proper directories.
   - Enter the command "node build/cli.cjs verify \[input proof file name] \[input crs file name] \[circuit directory name] \[the index of circuit instance set]".
   - Check the verification results in terminal.

## Paper
- will be uploaded.

## Contact
- [jake.j@onther.io](jake.j@onther.io)

## Licence
- will be updated.

