/// Operation code used by compiler.
abstract class OpCode {
  static const endOfCode = -1;
  static const local = 0;
  static const register = 1;
  static const copy = 2;
  static const skip = 3;
  static const anchor = 4;
  static const clearAnchor = 5;
  static const goto = 6;
  static const moveReg = 7;
  static const leftValue = 8;
  static const assertion = 9;
  static const throws = 10;
  static const loopPoint = 11;
  static const breakLoop = 12;
  static const continueLoop = 13;
  static const ifStmt = 14;
  static const whileStmt = 15;
  static const doStmt = 16;
  static const switchStmt = 17;
  static const codeBlock = 18;
  static const library = 19;
  static const file = 20;
  static const endOfStmt = 21;
  static const endOfCodeBlock = 22;
  static const endOfExec = 23;
  static const endOfFunc = 24;
  static const endOfFile = 25;
  static const endOfModule = 26;
  static const createStackFrame = 27;
  static const retractStackFrame = 28;
  static const constIntTable = 30;
  static const constFloatTable = 31;
  static const constStringTable = 32;
  static const constDecl = 33;
  static const importExportDecl = 34;
  static const typeAliasDecl = 35;
  static const varDecl = 36;
  static const destructuringDecl = 37;
  static const funcDecl = 38;
  static const externalEnumDecl = 39;
  static const structDecl = 40;

  static const namespaceDecl = 41;
  static const namespaceDeclEnd = 42;
  static const classDecl = 43;
  static const classDeclEnd = 44;

  static const delete = 49;
  static const assign = 50;
  static const memberSet = 51;
  static const subSet = 52;
  static const logicalOr = 53;
  static const logicalAnd = 54;
  static const equal = 55;
  static const notEqual = 56;
  static const lesser = 57;
  static const greater = 58;
  static const lesserOrEqual = 59;
  static const greaterOrEqual = 60;
  static const add = 61;
  static const subtract = 62;
  static const multiply = 63;
  static const devide = 64;
  static const truncatingDevide = 65;
  static const modulo = 66;
  static const ifNull = 67;
  static const negative = 68;
  static const logicalNot = 69;
  static const isIn = 70;
  static const isNotIn = 71;

  static const memberGet = 75;
  static const subGet = 76;
  static const call = 77;

  static const typeIs = 81;
  static const typeIsNot = 82;
  static const typeAs = 83;
  static const typeOf = 84;
  static const decltypeOf = 85;

  static const awaitedValue = 90;

  static const lineInfo = 205;
}

/// Following [OpCode.local], tells the value type, used by compiler.
abstract class HTValueTypeCode {
  static const nullValue = 0;
  static const boolean = 1;
  static const constInt = 2;
  static const constFloat = 3;
  static const constString = 4;
  static const string = 5;
  static const stringInterpolation = 6;
  static const identifier = 7;
  static const tuple = 8;
  static const list = 9;
  static const group = 10;
  static const struct = 11;
  static const function = 12;
  static const intrinsicType = 13;
  static const nominalType = 14;
  static const functionType = 15;
  static const structuralType = 16;
  static const future = 17;
}

abstract class HTDeletingTypeCode {
  static const local = 0;
  static const member = 1;
  static const sub = 2;
}

abstract class HTSwitchCaseTypeCode {
  static const equals = 0;
  static const eigherEquals = 1;
  static const elementIn = 2;
}

abstract class HTListItemTypeCode {
  static const normal = 0;
  static const spread = 1;
}

enum HTConstantType {
  boolean,
  integer,
  float,
  string,
}

// Get a dart runtime type by mapping.
Type getConstantType(HTConstantType type) {
  switch (type) {
    case HTConstantType.boolean:
      return bool;
    case HTConstantType.integer:
      return int;
    case HTConstantType.float:
      return double;
    case HTConstantType.string:
      return String;
  }
}

/// Register values exists as groups, and the index determines a certain value within this group.
class HTRegIdx {
  static const value = 0;
  static const identifier = 1;
  static const typeArgs = 2;
  static const loopCount = 3;
  static const anchorCount = 4;
  static const assignRight = 7;
  static const orLeft = 8;
  static const andLeft = 9;
  static const equalLeft = 10;
  static const relationLeft = 11;
  static const addLeft = 12;
  static const multiplyLeft = 13;
  static const postfixObject = 14;
  static const postfixKey = 15;
  static const length = 16;
}
