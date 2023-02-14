# UniGro16js

Universial Groth16 for EVM implemented in js and MATLAB

## What is the universal Groth16 for EVM?

Universal Groth16 (UniGro16) for EVM is a new zk-SNARK that inherits the succinctness of [original Groth16](https://eprint.iacr.org/2016/260.pdf) while adding universality for EVM-based applications. The universality of UniGro16 can be said as EVM-specific universality, meaning that a trust setup only need to be executed when an EVM is newly- or re-defined. A universal reference string file generated by a trust setup contains proving and verifying keys for each instuction of an EVM. Thus, the universal reference string can be used for all kinds of EVM applications made of the predefined instructions.

The key idea of UniGro16 is Derive algorithm, which linearly combines the proving and verifying keys in a universal reference string according to the combination of instructions forming an EVM application. As the result, Derive outputs a circuit-specific reference string, which is specialized to an EVM application. The execution of Derive does not need a trust, so anyone can be an executor. Derive needs to be executed when an EVM-application is newly developed or updated. The structure of a circuit-specific reference string is almost equivalent with a common reference string of original Groth16's setup except only that UniGro16 uses bivarate QAP polynomials instead of univarte ones. This enables us to use prove and verify algorithms of the original Groth16, which is the fastest among all zk-SNARKs.

Based on the same application, UniGro16 might be a bit slower than the original Groth16 at the cost of universality. This is because we add redundant constraints to the circuits of EVM instructions to make room for combining them later.

## Problem formulation and contributions

Our goal is to find a compromise between the universality and performance of pairing-based SNARKs. We relax the definition of universal setup from supporting any (NP) program in the world to supporting Ethereum virtual machine (EVM) applications. EVM is a stack machine with a small instruction set of opcodes. Examples of EVM applications are transactions in the Ethereum blockchain, each just a permutation of the opcodes. With the relaxed definition of universal setup, we design a pairing-based SNARK and universal to EVM applications with better performance than existing strictly-universal SNARKs.

We propose UniGro16 as a solution to the problem. The main idea of UniGro16 is a derive algorithm that derives circuit-specific public keys from EVM-specific public keys. A trusted third party, through the setup, generates the public keys containing a commitment to every arithmetic opcode of EVM. Then, through a derive algorithm, anyone including not only a prover and verifier but also untrusted helpers derives circuit-specific public keys committing to an EVM application. The derived public keys can be applied to Groth16’s prove and verify algorithms. As a result, UniGro16 has two advantages: 1) No trusted third parties are required when outsourcing new EVM applications. 2) The complexity of the prover and verifier inherits the complexity of Groth16, which is known to be the lowest.

Our contributions can be summarized as follows:

- We have designed UniGro16 which consists of five algorithms: setup, decode, derive, prove and verify,
- We have implemented UniGro16 and tested it with practical EVM applications,
- We have shown that the security of UniGroth16 remains unchanged from Groth16 even with the derived public keys,
- We have shown that the public keys derived by helpers are secure, and
- We have shown that the prover and verifier complexity of UniGro16 is lower than that of strictly-universal SNARKs.

## Demo. version implementations

### Protocol composition

UniGro16 consists of eight algorithms: compile, buildQAP, generateWitness, decode, setup, derive, prove, and verify.

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
     git clone https://github.com/tokamak-network/UniGro16js.git
     cd UniGro16js
     npm install
     ```

- Compatibility with EVM (in the current version)
  - [compile](https://github.com/tokamak-network/circom-ethereum-opcodes/blob/main/README.md)
  - [decode](https://github.com/tokamak-network/UniGroth16_Decode/blob/master/Decode/readme.md)

- Parameters
  - \[sD]: The number of instructions defined in an EVM.
  - \[sMax]: The maximum number of arithmetic opcodes (might be defined by an EVM system) that can be contained in an EVM application (p-code).
  - \[rsName]: The file name (string) for a universal reference string.
  - \[crsName]: The file name for a circuit-specific reference string.
  - \[circuitName]: The directory name for a circuit (EVM application).
  - \[instanceId]: The index for an instance of a circuit.
  <!-- - \[prfName]: The file name for a proof. -->
  <!-- - \[anyNumber]: Any number for a seed of random number generation. -->

### How to use

<!-- All file names used in the following commands does not include the file name extensions (e.g., for "refstr.rs", just type "refstr") -->

You can use the interactive command by adding the following commands to your terminal

```bash
# build
$ npm run buildcli

# You can execute the interactive CLI app by adding one of the following commands to your terminal.

# 1. use the command anywhere in your terminal
$ npm link
$ unigroth

# 2. use the build file
$ node build/cli.cjs

# 3. run the following command in the project directory
$ node . 
```

- **compile**

  ![compile](/examples/compile.gif)
  
  <!-- - Be sure that the input [circom scripts](https://github.com/tokamak-network/circom-ethereum-opcodes/blob/main/README.md) are placed in ```./resource/subcircuits/circom/[instruction name]\_test.circom```. -->
  <!-- - Go to the directory ```./resource/subcircuits```.
  - Enter the command ```./compile.sh```. -->
  - Find the output EVM information in ```./resource/subcircuits/wire_list.json```, where the index for each instruction is numbered.
  - Find the output R1CSs in ```./resources/subcircuits/R1CS/subcircuit#.r1cs``` for all indices # of instructions upto sD-1.
  - Find the output wasms ```./resources/subcircuits/wasm/subcircuit#.wasm``` for all indices # of instructions upto sD-1.

- **buildQAP**

  ![build-qap](/examples/qap.gif)

  - Be sure that the R1CSs generated by compile are placed in the proper directory.
  <!-- - Enter the command ```node  .  qap-all  bn128  [sD]  [sMax]```. -->
  - Find an output QAP parameter in ```./resource/subcircuits/param_[sD]_[sMax].dat```.
  - Find the output QAPs in ```./resource/subcircuits/QAP_[sD]_[sMax]/subcircuit#.qap``` for all indices # of instructions upto sD-1.
  
- **setup**

  ![setup](/examples/setup.gif)

  - Be sure that the R1CSs generated by compile are placed in the proper directory.
  <!-- - Enter the command ```node . setup param_[sD]_[sMax] [rsName] QAP\_sD\_s_max [anyNumber]```. -->
  - Find the output universal reference string in ```./resource/universal_rs/[rsName].urs```.

- **decode**
  - [How to run decode](https://github.com/tokamak-network/UniGroth16_Decode/blob/master/Decode/readme.md)
  - Copy and paste the output circuit information into ```./resource/circuits/[circuitName]/{OpList.bin, Set_I_P.bin, Set_I_V.bin, WireList.bin}```.
  - Copy and paste the output instances into ```./resource/circuits/[circuitName]/instance[instanceId]/{input_opcode#.json, output_opcode#.json}``` for all indices # of opcodes used in an EVM application less than sMax.

- **derive**

  ![derive](/examples/derive.gif)

  - Be sure that the circuit information generated by decode are placed in the proper directory.
  <!-- - Enter the command ```node . derive [input rs file name] [crsName] [circuitName] QAP\_sD\_s_max```. -->
  - Find the output circuit-specific reference string in ```./resource/circuits/[circuitName]/[crsName].crs```.

- **generateWitness**

  - In the current version, generatedWitness is called during the run of prove (will be updated to be separately executed).
  - Find the output witnesses in ```./resource/circuits/[circuitName]/witness[instanceId]/witness#.wtns``` for all indices # of opcodes used in an EVM application less than sMax.

- **prove**

  ![prove](/examples/prove.gif)

  <!-- - Be sure that all the outputs of the above algorithms are placed in the proper directories. -->
  <!-- - Enter the command ```node . prove [crsName] [prfName] [circuitName] [instanceId] [anyNumber]```. -->
  - Find the output proof in ```./resource/circuits/[circuitName]/[prfName].proof```.

- **verify**

  ![verify](/examples/verify.gif)

  <!-- - Be sure that all the outputs of the above algorithms are placed in the proper directories. -->
  <!-- - Enter the command ```node . verify [prfName] [crsName] [circuitName] [instanceId]```. -->
  - Check the verification results displayed in terminal.

### Test run example

- An example EVM system
  
  - [Circom scripts](https://github.com/tokamak-network/UniGro16js/tree/master/resource/subcircuits/circom) of [12 instructions](https://github.com/tokamak-network/UniGro16js/blob/master/resource/subcircuits/subcircuit_info.json).
  
  - This system supports applications with instances of length 16 (this number can be modified in [here](https://github.com/tokamak-network/UniGro16js/blob/master/resource/subcircuits/circom/circuits/load.circom)).

- Two EVM application examples
  
  - Application-1: [A prove implementation of Schnorr protocol](https://github.com/tokamak-network/UniGro16js/blob/master/resource/circuits/schnorr_prove/readme.md)

    - [p-code](https://github.com/tokamak-network/UniGro16js/blob/master/resource/circuits/schnorr_prove/bytes_schnorr_prove.txt)

    - Two instance sets are prepared: [instance-1-1](https://github.com/tokamak-network/UniGro16js/blob/master/resource/circuits/schnorr_prove/instance1/scenario.txt), [instance-1-2](https://github.com/tokamak-network/UniGro16js/blob/master/resource/circuits/schnorr_prove/instance2/scenario.txt)

  - Application-2: [A verify implementation of Schnorr protocol](https://github.com/tokamak-network/UniGro16js/blob/master/resource/circuits/schnorr_verify/readme.md)

    - [p-code](https://github.com/tokamak-network/UniGro16js/blob/master/resource/circuits/schnorr_verify/bytes_schnorr_verify.txt)

    - [Instance-2-1](https://github.com/tokamak-network/UniGro16js/blob/master/resource/circuits/schnorr_verify/instance1/scenario.txt)
  
  - Both applications use less than 18 arithmetic instructions (i.e., sMax = 18).

- As **decode** has no build currently, we provide the outputs of **decode** that have been created in advance.

- Test run commands

  1. **Compile**

      choose *compile* command

  2. **Build QAP**

      Select the following options.

      - What is the name of curve?: `BN128`

      - How many instructions are defined in the EVM?: `12`

      - The maximum number of arithmetic instructions in the EVM application? `18`

  3. **Setup**

      Select the following options.

      - Which parameter file will you use?: `[Workspace]/UniGro16js/resource/subcircuits/param_12_18.dat`

      - Which QAP will you use? `[Workspace]/UniGro16js/resource/subcircuits/QAP_12_18`

      - What is the name of the universial reference string file? `rs_18`
  
  4. **Derive**

      a. Select the following options for application-1.

      - Which circuit will you use? `[Workspace]/UniGro16js/resource/circuits/schnorr_prove`

      - Which reference string file will you use? `[Workspace]/UniGro16js/resource/universal_rs/rs_18.urs`

      - Which QAP will you use? `[Workspace]/UniGro16js/resource/subcircuits/QAP_12_18`

      - What is the name of the circuit-specific reference string file? `crs_schnorr_prove`

      b. Select the following options for application-2

      - Which circuit will you use? `[Workspace]/UniGro16js/resource/circuits/schnorr_verify`

      - Which reference string file will you use? `[Workspace]/UniGro16js/resource/universal_rs/rs_18.urs`

      - Which QAP will you use? `[Workspace]/UniGro16js/resource/subcircuits/QAP_12_18`

      - What is the name of the circuit-specific reference string file? `crs_schnorr_verify`

  5. **Prove**

      a. Select the following options for the instance-1-1 of the application-1.

      - Which circuit-specific reference string will you use? `[Workspace]/UniGro16js/resource/circuits/schnorr_prove/crs_schnorr_prove.crs`

      - Which circuit will you use? `[Workspace]/UniGro16js/resource/circuits/schnorr_prove`

      - What is the index of the instance of the circuit? `1`

      - What is the name of the proof? `proof1`
  
      b. Select the following options for the instance-1-2 of the application-1.

      - Which circuit-specific reference string will you use? `[Workspace]/UniGro16js/resource/circuits/schnorr_prove/crs_schnorr_prove.crs`

      - Which circuit will you use? `[Workspace]/UniGro16js/resource/circuits/schnorr_prove`

      - What is the index of the instance of the circuit? `2`

      - What is the name of the proof? `proof2`

      c. Select the following options for the instance-2-1 of the application-2.

      - Which circuit-specific reference string will you use? `[Workspace]/UniGro16js/resource/circuits/schnorr_verify/crsSchnorr_verify.crs`

      - Which circuit will you use? `[Workspace]/UniGro16js/resource/circuits/schnorr_verify`

      - What is the index of the instance of the circuit? `1`

      - What is the name of the proof? `proof`

  6. **Verify**

      a. Select the following options for the instance-1-1 of the application-1.

      - Which circuit-specific reference string will you use? `[Workspace]/UniGro16js/resource/circuits/schnorr_prove/crs_schnorr_prove.crs`

      - Which circuit will you use? `[Workspace]/UniGro16js/resource/circuits/schnorr_prove`

      - What is the index of the instance of the circuit? `1`

      - Which proof will you use? `[Workspace]/UniGro16js/resource/circuits/schnorr_prove/proof1.proof`
  
      b. Select the following options for the instance-1-2 of the application-1.

      - Which circuit-specific reference string will you use? `[Workspace]/UniGro16js/resource/circuits/schnorr_prove/crs_schnorr_prove.crs`

      - Which circuit will you use? `[Workspace]/UniGro16js/resource/circuits/schnorr_prove`

      - What is the index of the instance of the circuit? `2`

      - Which proof will you use? `[Workspace]/UniGro16js/resource/circuits/schnorr_prove/proof2.proof`

      c. Select the following options for the instance-2-1 of the application-2.

      - Which circuit-specific reference string will you use? `[Workspace]/UniGro16js/resource/circuits/schnorr_verify/crsSchnorr_verify.crs`

      - Which circuit will you use? `[Workspace]/UniGro16js/resource/circuits/schnorr_verify`

      - What is the index of the instance of the circuit? `1`

      - Which proof will you use? `[Workspace]/UniGro16js/resource/circuits/schnorr_verify/proof.proof`
  
  Since this is under construction, you can set `TEST_MODE` environment variable to true for testing

- Summary of input parameters used for the test run

|Parameters |Application-1 with instance-1-1  |Application-1 with instance-1-2  |Application-2 with instance-2-1|
|:---------:|:---------:|:---------:|:-------:|
|sD        |12|12|12|
|sMax      |18|18|18|
|rsName     |"rs_18"|"rs_18"|"rs_18"|
|crsName    |"crsSchnorr_prove"|"crsSchnorr_prove"|"crsSchnorr_verify"|
|circuitName|"schnorr_prove"|"schnorr_prove"|"schnorr_verify"|
|instanceId|    1|    2|    1|
|prfName|"proof1"|"proof2"|"proof"|
|anyNumber|1|1|1|

## Performance test

- [A report on performance test](https://github.com/tokamak-network/UniGro16js/blob/master/Performance.md)

## Technical specification

- [The technical specification of UniGroth16](https://drive.google.com/file/d/1DTEWbiKalPe3l1ohniP60jlyr-vIUiuH/view?usp=sharing)

## Contact

- [jake.j@onther.io](jake.j@onther.io)

## Licence

- [GPLv3](https://github.com/tokamak-network/UniGro16js/blob/master/COPYING.md)
