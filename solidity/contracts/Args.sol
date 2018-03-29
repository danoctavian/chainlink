pragma solidity ^0.4.18;

contract Args {
  string constant stringType = "string,";

  bytes types;
  bytes names;
  uint16[] lengths;
  bytes values; // all implied to be [disk] storage.

  // do we need to do lengths for every bytes array?
  event Data(
    bytes types,
    uint16[] lengths,
    bytes names,
    bytes values
  );

  function add(string _key, string _value) public {
    types = concat(types, bytes(stringType));
    bytes memory value = bytes(_value);
    lengths.push(uint16(value.length));
    names = concat(names, bytes(_key));
    names = concat(names, ",");
    values = concat(values, value);
  }

  function fireEvent() public {
    Data(types, lengths, names, values);
  }

  // https://ethereum.stackexchange.com/a/40456/24978
  function concat(bytes memory a, bytes memory b) internal pure returns (bytes memory c) {
      // Store the length of the first array
      uint alen = a.length;
      // Store the length of BOTH arrays
      uint totallen = alen + b.length;
      // Count the loops required for array a (sets of 32 bytes)
      uint loopsa = (a.length + 31) / 32;
      // Count the loops required for array b (sets of 32 bytes)
      uint loopsb = (b.length + 31) / 32;
      assembly {
          let m := mload(0x40)
          // Load the length of both arrays to the head of the new bytes array
          mstore(m, totallen)
          // Add the contents of a to the array
          for {  let i := 0 } lt(i, loopsa) { i := add(1, i) } { mstore(add(m, mul(32, add(1, i))), mload(add(a, mul(32, add(1, i))))) }
          // Add the contents of b to the array
          for {  let i := 0 } lt(i, loopsb) { i := add(1, i) } { mstore(add(m, add(mul(32, add(1, i)), alen)), mload(add(b, mul(32, add(1, i))))) }
          mstore(0x40, add(m, add(32, totallen)))
          c := m
      }
  }
}