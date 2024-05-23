#!/bin/bash
cd "$(dirname "$0")"
# circuit nums: 27
names=("load" "add" "mul" "sub" "div" "sha3" "sdiv" "mod" "smod" "addmod" "mulmod" "exp" "lt" "gt" "slt" "sgt" "eq" "iszero" "and" "or" "xor" "not" "shl" "shr" "sar" "signextend" "byte")
# large constraints(EXP,SDIV,SMOD) removed version
# names=("load" "add" "mul" "sub" "div" "sha3" "mod" "addmod" "mulmod" "lt" "gt" "slt" "sgt" "eq" "iszero" "and" "or" "xor" "not" "shl" "shr" "sar" "signextend" "byte")


for (( i = 0 ; i < ${#names[@]} ; i++ )) ; do
  echo "id[$i] = ${names[$i]}" >> temp.txt && \
  circom circom/circuit_test/${names[$i]}_test.circom --r1cs -o r1cs >> temp.txt && \
  mv r1cs/${names[$i]}_test.r1cs r1cs/subcircuit$i.r1cs

  circom circom/circuit_test/${names[$i]}_test.circom --wasm -o wasm && \
  mv wasm/${names[$i]}_test_js/${names[$i]}_test.wasm wasm/subcircuit$i.wasm && \
  if [ $i -eq 0 ]
  then
    cp wasm/${names[$i]}_test_js/witness_calculator.js ../../src/witness_calculator.cjs
  fi
  rm -rf wasm/${names[$i]}_test_js
done
node parse.js
rm temp.txt