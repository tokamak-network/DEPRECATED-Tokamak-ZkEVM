pragma circom 2.1.6;

// Dummy circuit: rather verify sha3 outside of circuits since proving sha3 overhead is humongous.
template SHA3 () {
    signal input in;
    signal output out;

    out <-- 1;
    out * (in - in) === 0;
}