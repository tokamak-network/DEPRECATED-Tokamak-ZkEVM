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
- WILL BE UPDATED

### Prerequisites and preparation for use

- Implementing circoms and generating R1CSs and wasms needs to install Circom package by Iden3.
  - [How to install Circom](https://docs.circom.io/getting-started/installation/)
- Some of libraries by Iden3 are used.
  - How to install Iden3 libraries

      ```bash
     git clone https://github.com/Onther-Tech/UniGro16js.git
     cd UniGro16js
     npm install
     ```

- Compatibility with EVM (in the current version)
  - [compile](https://github.com/Onther-Tech/circom-ethereum-opcodes/blob/main/README.md)
  - [decode](https://github.com/Onther-Tech/UniGroth16_Decode/blob/master/Decode/readme.md)
- User input parameters
  - \[sD]: The number of instructions defined in an EVM.
  - \[sMax]: The maximum number of arithmetic opcodes (might be defined by an EVM system) that can be contained in an EVM application (p-code).
  - \[rsName]: The file name (string) for a universal reference string.
  - \[crsName]: The file name for a circuit-specific reference string.
  - \[circuitName]: The directory name for a circuit (EVM application).
  - \[instanceId]: The index for an instance of a circuit.
  - \[prfName]: The file name for a proof.
  - \[anyNumber]: Any number for a seed of random number generation.

### How to use

All file names used in the following commands does not include the file name extensions (e.g., for "refstr.rs", just type "refstr")

- **compile**
  - Be sure that the input [circom scripts](https://github.com/Onther-Tech/circom-ethereum-opcodes/blob/main/README.md) are placed in ```./resource/subcircuits/circom/[instruction name]\_test.circom```.
  - Go to the directory ```./resource/subcircuits```.
  - Enter the command ```./compile```.
  - Find the output EVM information in ```./resource/subcircuits/wire_list.json```, where the index for each instruction is numbered.
  - Find the output R1CSs in ```./resources/subcircuits/R1CS/subcircuit#.r1cs``` for all indices # of instructions upto s_D-1.
  - Find the output wasms ```./resources/subcircuits/wasm/subcircuit#.wasm``` for all indices # of instructions upto s_D-1.
- **buildQAP**
  - Be sure that the R1CSs generated by compile are placed in the proper directory.
  - Enter the command ```node  build/cli.cjs  qap-all  bn128  [s_D]  [s_max]```.
  - Find an output QAP parameter in ```./resource/subcircuits/param_[s_D]_[s_max].dat```.
  - Find the output QAPs in ```./resource/subcircuits/QAP_[s_D]_[s_max]/subcircuit#.qap``` for all indices # of instructions upto s_D-1.
- **setup**
  - Be sure that the R1CSs generated by compile are placed in the proper directory.
  - Enter the command ```node build/cli.cjs setup param_[s_D]_[s_max] [rsName] QAP\_s_D\_s_max [anyNumber]```.
  - Find the output universal reference string in ```./resource/universal_rs/[rsName].urs```.
- **decode**
  - [How to run decode](https://github.com/Onther-Tech/UniGroth16_Decode/blob/master/Decode/readme.md)
  - Copy and paste the output circuit information into ```./resource/circuits/[circuitName]/{OpList.bin, Set_I_P.bin, Set_I_V.bin, WireList.bin}```.
  - Copy and paste the output instances into ```./resource/circuits/[circuitName]/instance[instanceId]/{input_opcode#.json, output_opcode#.json}``` for all indices # of opcodes used in an EVM application less than s_max.
- **derive**
  - Be sure that the circuit information generated by decode are placed in the proper directory.
  - Enter the command ```node build/cli.cjs derive [input rs file name] [crsName] [circuitName] QAP\_s_D\_s_max```.
  - Find the output circuit-specific reference string in ```./resource/circuits/[circuitName]/[crsName].crs```.
- **generateWitness**
  - In the current version, generatedWitness is called during the run of prove (will be updated to be separately executed).
  - Find the output witnesses in ```./resource/circuits/[circuitName]/witness[instanceId]/witness#.wtns``` for all indices # of opcodes used in an EVM application less than s_max.
- **prove**
  - Be sure that all the outputs of the above algorithms are placed in the proper directories.
  - Enter the command ```node build/cli.cjs prove [crsName] [prfName] [circuitName] [instanceId] [anyNumber]```.
  - Find the output proof in ```./resource/circuits/[circuitName]/[prfName].proof```.
- **verify**
  - Be sure that all the outputs of the above algorithms are placed in the proper directories.
  - Enter the command ```node build/cli.cjs verify [prfName] [crsName] [circuitName] [instanceId]```.
  - Check the verification results displayed in terminal.

### Test run example

- An example EVM system
  - [Circom scripts](https://github.com/Onther-Tech/UniGro16js/tree/master/resource/subcircuits/circom) of [12 instructions](https://github.com/Onther-Tech/UniGro16js/blob/master/resource/subcircuits/subcircuit_info.json).
  - This system supports applications with instances of length 16 (this number can be modified in [here](https://github.com/Onther-Tech/UniGro16js/blob/master/resource/subcircuits/circom/circuits/load.circom)).
- Two EVM application examples
  - Application-1: [A prove implementation of Schnorr protocol](https://github.com/Onther-Tech/UniGro16js/blob/master/resource/circuits/schnorr_prove/readme.md)
    - [p-code](https://github.com/Onther-Tech/UniGro16js/blob/master/resource/circuits/schnorr_prove/bytes_schnorr_prove.txt)
    - Two instance sets are prepared: [instance-1-1](https://github.com/Onther-Tech/UniGro16js/blob/master/resource/circuits/schnorr_prove/instance1/scenario.txt), [instance-1-2](https://github.com/Onther-Tech/UniGro16js/blob/master/resource/circuits/schnorr_prove/instance2/scenario.txt)
  - Application-2: [A verify implementation of Schnorr protocol](https://github.com/Onther-Tech/UniGro16js/blob/master/resource/circuits/schnorr_verify/readme.md)
    - [p-code](https://github.com/Onther-Tech/UniGro16js/blob/master/resource/circuits/schnorr_verify/bytes_schnorr_verify.txt)
    - [Instance-2-1](https://github.com/Onther-Tech/UniGro16js/blob/master/resource/circuits/schnorr_verify/instance1/scenario.txt)
  - Both applications use less than 18 arithmetic instructions (i.e., s_max = 18).
- As **decode** has no build currently, we provide the outputs of **decode** that have been created in advance.
- Test run commands
  1. To build sources, go to the main directory and enter ```npm run buildcli```.
  2. To **compile**, go to the directory ```./resource/subcircuits``` and enter ```./compile``` .
  3. Go back to the main directory and enter ```node build/cli.cjs QAP_all bn128 12 18``` to run **buildQAP**.
  4. Enter ```node build/cli.cjs setup param_12_18 rs_18 QAP_12_18 1``` to run **setup**.
  5. Enter ```node build/cli.cjs derive rs_18 crsSchnorr_prove schnorr_prove QAP_12_18``` to run **derive** for the application-1.
  6. Enter ```node build/cli.cjs derive rs_18 crsSchnorr_verify schnorr_verify QAP_12_18``` to run **derive** for the application-2.
  7. Enter ```node build/cli.cjs prove crsSchnorr_prove proof1 schnorr_prove 1 1``` to run **prove** for the instance-1-1 of the application-1.
  8. Enter ```node build/cli.cjs prove crsSchnorr_prove proof2 schnorr_prove 2 1``` to run **prove** for the instance-1-2 of the application-1.
  9. Enter ```node build/cli.cjs prove crsSchnorr_verify proof schnorr_verify 1 1``` to run **prove** for the instance-2-1 of the application-2.
  10. Enter ```node build/cli.cjs verify proof1 crsSchnorr_prove schnorr_prove 1``` to run **verify** for the instance-1-1 of the application-1.
  11. Enter ```node build/cli.cjs verify proof2 crsSchnorr_prove schnorr_prove 2``` to run **verify** for the instance-1-2 of the application-1.
  12. Enter ```node build/cli.cjs verify proof crsSchnorr_verify schnorr_verify 1``` to run **verify** for the instance-2-1 of the application-2.

- Summary of input parameters used for the test run

|Parameters |Application-1 with instance-1-1  |Application-1 with instance-1-2  |Application-2 with instance-2-1|
|:---------:|:---------:|:---------:|:-------:|
|s_D        |12|12|12|
|s_max      |18|18|18|
|rsName     |"rs_18"|"rs_18"|"rs_18"|
|crsName    |"crsSchnorr_prove"|"crsSchnorr_prove"|"crsSchnorr_verify"|
|circuitName|"schnorr_prove"|"schnorr_prove"|"schnorr_verify"|
|instanceId|    1|    2|    1|
|prfName|"proof1"|"proof2"|"proof"|
|anyNumber|1|1|1|

## Performance test

- [A report on performance test](https://github.com/Onther-Tech/UniGro16js/edit/master/benchmark.md)

## Paper

- will be uploaded.

## Contact

- [jake.j@onther.io](jake.j@onther.io)

## Licence

- [GPLv3](https://github.com/Onther-Tech/UniGro16js/blob/master/COPYING.md)
