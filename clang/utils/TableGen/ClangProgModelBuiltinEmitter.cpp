//===- ClangProgModelBuiltinEmitter.cpp - Generate Clang Builtin handling
//
//                     The LLVM Compiler Infrastructure
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This tablegen backend emits code for checking whether a function is a
// builtin function of a programming model. If so, all overloads of this
// function are added to the LookupResult. The generated include file is
// used by SemaLookup.cpp
//
// For a successful lookup of e.g. the "cos" builtin, isBuiltin("cos")
// returns a pair <Index, Len>.
// BuiltinTable[Index] to BuiltinTable[Index + Len] contains the pairs
// <SigIndex, SigLen> of the overloads of "cos".
// SignatureTable[SigIndex] to SignatureTable[SigIndex + SigLen] contains
// one of the signatures of "cos". The SignatureTable entry can be
// referenced by other functions, e.g. "sin", to exploit the fact that
// many builtins may share the same signature.
//
// The file generated by this TableGen emitter contains the following:
//
//  * Structs and enums to represent types and function signatures.
//
//  * const char *FunctionExtensionTable[]
//    List of space-separated OpenCL extensions.  A builtin references an
//    entry in this table when the builtin requires a particular (set of)
//    extension(s) to be enabled.
//
//  * ProgModelTypeStruct TypeTable[]
//    Type information for return types and arguments.
//
//  * unsigned SignatureTable[]
//    A list of types representing function signatures.  Each entry is an index
//    into the above TypeTable.  Multiple entries following each other form a
//    signature, where the first entry is the return type and subsequent
//    entries are the argument types.
//
//  * BuiltinStruct BuiltinTable[]
//    Each entry represents one overload of a builtin function and
//    consists of an index into the SignatureTable and the number of arguments.
//
//  * std::pair<unsigned, unsigned> isBuiltin(llvm::StringRef Name)
//    Find out whether a string matches an existing builtin function
//    name and return an index into BuiltinTable and the number of overloads.
//
//  * void Bultin2Qual(ASTContext&, ProgModelTypeStruct, std::vector<QualType>&)
//    Convert an ProgModelTypeStruct type to a list of QualType instances.
//    One ProgModelTypeStruct can represent multiple types, primarily when using
//    GenTypes.
//
//===----------------------------------------------------------------------===//

#include "TableGenBackends.h"
#include "llvm/ADT/MapVector.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/StringSet.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/TableGen/Error.h"
#include "llvm/TableGen/Record.h"
#include "llvm/TableGen/StringMatcher.h"
#include "llvm/TableGen/TableGenBackend.h"
#include <set>

using namespace llvm;

namespace {

// A list of signatures that are shared by one or more builtin functions.
struct BuiltinTableEntries {
  SmallVector<StringRef, 4> Names;
  std::vector<std::pair<const Record *, unsigned>> Signatures;
};

class BuiltinNameEmitter {
public:
  BuiltinNameEmitter(RecordKeeper &Records, raw_ostream &OS,
                     llvm::StringRef Family)
      : Records(Records), OS(OS), Family(Family),
        ClassName((Family + "Builtin").str()) {}

  // Entrypoint to generate the functions and structures for checking
  // whether a function is a builtin function.
  void Emit();

private:
  // A list of indices into the builtin function table.
  using BuiltinIndexListTy = SmallVector<unsigned, 11>;

  // Contains builtin functions and related information, stored as
  // Record instances. They are coming from the associated TableGen file.
  RecordKeeper &Records;

  // The output file.
  raw_ostream &OS;

  // Family for which the builtin are for.
  llvm::StringRef Family;

  // Family for which the builtin are for.
  std::string ClassName;

  // Helper function for BuiltinNameEmitter::EmitDeclarations.  Generate enum
  // definitions in the Output string parameter, and save their Record instances
  // in the List parameter.
  // \param Types (in) List containing the Types to extract.
  // \param TypesSeen (inout) List containing the Types already extracted.
  // \param Output (out) String containing the enums to emit in the output file.
  // \param List (out) List containing the extracted Types, except the Types in
  //        TypesSeen.
  void ExtractEnumTypes(std::vector<Record *> &Types,
                        StringMap<bool> &TypesSeen, std::string &Output,
                        std::vector<const Record *> &List);

  // Emit the enum or struct used in the generated file.
  // Populate the TypeList at the same time.
  void EmitDeclarations();

  // Parse the Records generated by TableGen to populate the SignaturesList,
  // FctOverloadMap and TypeMap.
  void GetOverloads();

  // Compare two lists of signatures and check that e.g. the version,
  // function attributes, and extension are equal for each signature.
  // \param Candidate (in) Entry in the SignatureListMap to check.
  // \param SignatureList (in) List of signatures of the considered function.
  // \returns true if the two lists of signatures are identical.
  bool CanReuseSignature(
      BuiltinIndexListTy *Candidate,
      std::vector<std::pair<const Record *, unsigned>> &SignatureList);

  // Group functions with the same list of signatures by populating the
  // SignatureListMap.
  // Some builtin functions have the same list of signatures, for example the
  // "sin" and "cos" functions. To save space in the BuiltinTable, the
  // "isBuiltin" function will have the same output for these two
  // function names.
  void GroupBySignature();

  // Emit the FunctionExtensionTable that lists all function extensions.
  void EmitExtensionTable();

  // Emit the TypeTable containing all types used by the builtins.
  void EmitTypeTable();

  // Emit the SignatureTable. This table contains all the possible signatures.
  // A signature is stored as a list of indexes of the TypeTable.
  // The first index references the return type (mandatory), and the followings
  // reference its arguments.
  // E.g.:
  // 15, 2, 15 can represent a function with the signature:
  // int func(float, int)
  // The "int" type being at the index 15 in the TypeTable.
  void EmitSignatureTable();

  // Emit the BuiltinTable table. This table contains all the overloads of
  // each function, and is a struct BuiltinDecl.
  // E.g.:
  // // 891 convert_float2_rtn
  //   { 58, 2, 3, 100, 0 },
  // This means that the signature of this convert_float2_rtn overload has
  // 1 argument (+1 for the return type), stored at index 58 in
  // the SignatureTable.  This prototype requires extension "3" in the
  // FunctionExtensionTable.  The last two values represent the minimum (1.0)
  // and maximum (0, meaning no max version) version in which this
  // overload is supported.
  void EmitBuiltinTable();

  // Emit a StringMatcher function to check whether a function name is a
  // builtin function name.
  void EmitStringMatcher();

  // Emit a function returning the clang QualType instance associated with
  // the TableGen Record Type.
  void EmitQualTypeFinder();

  // Contains a list of the available signatures, without the name of the
  // function. Each pair consists of a signature and a cumulative index.
  // E.g.:  <<float, float>, 0>,
  //        <<float, int, int, 2>>,
  //        <<float>, 5>,
  //        ...
  //        <<double, double>, 35>.
  std::vector<std::pair<std::vector<Record *>, unsigned>> SignaturesList;

  // Map the name of a builtin function to its prototypes (instances of the
  // TableGen "Builtin" class).
  // Each prototype is registered as a pair of:
  //   <pointer to the "Builtin" instance,
  //    cumulative index of the associated signature in the SignaturesList>
  // E.g.:  The function cos: (float cos(float), double cos(double), ...)
  //        <"cos", <<ptrToPrototype0, 5>,
  //                 <ptrToPrototype1, 35>,
  //                 <ptrToPrototype2, 79>>
  // ptrToPrototype1 has the following signature: <double, double>
  MapVector<StringRef, std::vector<std::pair<const Record *, unsigned>>>
      FctOverloadMap;

  // Contains the map of types to their index in the TypeTable.
  MapVector<const Record *, unsigned> TypeMap;

  // List of function extensions mapping extension strings to
  // an index into the FunctionExtensionTable.
  StringMap<unsigned> FunctionExtensionIndex;

  // List of type names in the same order as in enum TypeID.
  // This list does not contain generic types.
  std::vector<const Record *> TypeList;

  // Same as TypeList, but for generic types only.
  std::vector<const Record *> GenTypeList;

  // Map an ordered vector of signatures to their original Record instances,
  // and to a list of function names that share these signatures.
  //
  // For example, suppose the "cos" and "sin" functions have only three
  // signatures, and these signatures are at index Ix in the SignatureTable:
  //          cos         |         sin         |  Signature    | Index
  //  float   cos(float)  | float   sin(float)  |  Signature1   | I1
  //  double  cos(double) | double  sin(double) |  Signature2   | I2
  //  half    cos(half)   | half    sin(half)   |  Signature3   | I3
  //
  // Then we will create a mapping of the vector of signatures:
  // SignatureListMap[<I1, I2, I3>] = <
  //                  <"cos", "sin">,
  //                  <Signature1, Signature2, Signature3>>
  // The function "tan", having the same signatures, would be mapped to the
  // same entry (<I1, I2, I3>).
  MapVector<BuiltinIndexListTy *, BuiltinTableEntries> SignatureListMap;
};
} // namespace

void BuiltinNameEmitter::Emit() {
  std::string Banner = (Family + " Builtin handling").str();
  emitSourceFileHeader(Banner, OS);

  OS << "#include \"llvm/ADT/StringRef.h\"\n";
  OS << "using namespace clang;\n\n";

  // Emit enums and structs.
  EmitDeclarations();

  // Parse the Records to populate the internal lists.
  GetOverloads();
  GroupBySignature();

  // Emit tables.
  EmitExtensionTable();
  EmitTypeTable();
  EmitSignatureTable();
  EmitBuiltinTable();

  // Emit functions.
  EmitStringMatcher();
  EmitQualTypeFinder();
}

void BuiltinNameEmitter::ExtractEnumTypes(std::vector<Record *> &Types,
                                          StringMap<bool> &TypesSeen,
                                          std::string &Output,
                                          std::vector<const Record *> &List) {
  raw_string_ostream SS(Output);

  for (const auto *T : Types) {
    if (TypesSeen.find(T->getValueAsString("Name")) == TypesSeen.end()) {
      SS << "  TID_" + T->getValueAsString("Name") << ",\n";
      // Save the type names in the same order as their enum value. Note that
      // the Record can be a VectorType or something else, only the name is
      // important.
      List.push_back(T);
      TypesSeen.insert(std::make_pair(T->getValueAsString("Name"), true));
    }
  }
  SS.flush();
}

void BuiltinNameEmitter::EmitDeclarations() {
  OS << "class " << ClassName << " {\n\n"
     << "public:\n\n";

  // Enum of scalar type names (float, int, ...) and generic type sets.
  OS << "enum TypeID {\n";

  StringMap<bool> TypesSeen;
  std::string GenTypeEnums;
  std::string TypeEnums;

  // Extract generic types and non-generic types separately, to keep
  // gentypes at the end of the enum which simplifies the special handling
  // for gentypes in SemaLookup.
  std::vector<Record *> GenTypes =
      Records.getAllDerivedDefinitions("GenericType");
  ExtractEnumTypes(GenTypes, TypesSeen, GenTypeEnums, GenTypeList);

  std::vector<Record *> Types = Records.getAllDerivedDefinitions("Type");
  ExtractEnumTypes(Types, TypesSeen, TypeEnums, TypeList);

  OS << TypeEnums;
  OS << GenTypeEnums;
  OS << "};\n";

  // Structure definitions.
  OS << R"(
// Image access qualifier.
enum AccessQual : unsigned char {
  AQ_None,
  AQ_ReadOnly,
  AQ_WriteOnly,
  AQ_ReadWrite
};

// Represents a return type or argument type.
struct ProgModelTypeStruct {
  // A type (e.g. float, int, ...).
  const TypeID ID;
  // Vector size (if applicable; 0 for scalars and generic types).
  const unsigned VectorWidth;
  // 0 if the type is not a pointer.
  const bool IsPointer : 1;
  // 0 if the type is not const.
  const bool IsConst : 1;
  // 0 if the type is not volatile.
  const bool IsVolatile : 1;
  // Access qualifier.
  const AccessQual AccessQualifier;
  // Address space of the pointer (if applicable).
  const LangAS AS;
};

// One overload of a builtin function.
struct BuiltinStruct {
  // Index of the signature in the ProgModelTypeStruct table.
  const unsigned SigTableIndex;
  // Entries between index SigTableIndex and (SigTableIndex + NumTypes - 1) in
  // the SignatureTable represent the complete signature.  The first type at
  // index SigTableIndex is the return type.
  const unsigned NumTypes;
  // Function attribute __attribute__((pure))
  const bool IsPure : 1;
  // Function attribute __attribute__((const))
  const bool IsConst : 1;
  // Function attribute __attribute__((convergent))
  const bool IsConv : 1;
  // 0 if the function is not variadic.
  const bool IsVariadic : 1;
  // OpenCL extension(s) required for this overload.
  const unsigned short Extension;
  // First version in which this overload was introduced (e.g. CL20).
  const unsigned short MinVersion;
  // First version in which this overload was removed (e.g. CL20).
  const unsigned short MaxVersion;
};

static const char *FunctionExtensionTable[];
static const ProgModelTypeStruct TypeTable[];
static const unsigned short SignatureTable[];
static const BuiltinStruct BuiltinTable[];

static std::pair<unsigned, unsigned> isBuiltin(llvm::StringRef Name);
static void Bultin2Qual(ASTContext &Context, const ProgModelTypeStruct &Ty,
                        llvm::SmallVectorImpl<QualType> &QT);

)";

  OS << "};  // class " << ClassName << "\n";
}

// Verify that the combination of GenTypes in a signature is supported.
// To simplify the logic for creating overloads in SemaLookup, only allow
// a signature to contain different GenTypes if these GenTypes represent
// the same number of actual scalar or vector types.
//
// Exit with a fatal error if an unsupported construct is encountered.
static void VerifySignature(const std::vector<Record *> &Signature,
                            const Record *BuiltinRec) {
  unsigned GenTypeVecSizes = 1;
  unsigned GenTypeTypes = 1;

  for (const auto *T : Signature) {
    // Check all GenericType arguments in this signature.
    if (T->isSubClassOf("GenericType")) {
      // Check number of vector sizes.
      unsigned NVecSizes =
          T->getValueAsDef("VectorList")->getValueAsListOfInts("List").size();
      if (NVecSizes != GenTypeVecSizes && NVecSizes != 1) {
        if (GenTypeVecSizes > 1) {
          // We already saw a gentype with a different number of vector sizes.
          PrintFatalError(BuiltinRec->getLoc(),
              "number of vector sizes should be equal or 1 for all gentypes "
              "in a declaration");
        }
        GenTypeVecSizes = NVecSizes;
      }

      // Check number of data types.
      unsigned NTypes =
          T->getValueAsDef("TypeList")->getValueAsListOfDefs("List").size();
      if (NTypes != GenTypeTypes && NTypes != 1) {
        if (GenTypeTypes > 1) {
          // We already saw a gentype with a different number of types.
          PrintFatalError(BuiltinRec->getLoc(),
              "number of types should be equal or 1 for all gentypes "
              "in a declaration");
        }
        GenTypeTypes = NTypes;
      }
    }
  }
}

void BuiltinNameEmitter::GetOverloads() {
  // Populate the TypeMap.
  std::vector<Record *> Types = Records.getAllDerivedDefinitions("Type");
  unsigned I = 0;
  for (const auto &T : Types) {
    TypeMap.insert(std::make_pair(T, I++));
  }

  // Populate the SignaturesList and the FctOverloadMap.
  unsigned CumulativeSignIndex = 0;
  std::vector<Record *> Builtins = Records.getAllDerivedDefinitions("Builtin");
  for (const auto *B : Builtins) {
    StringRef BName = B->getValueAsString("Name");
    if (FctOverloadMap.find(BName) == FctOverloadMap.end()) {
      FctOverloadMap.insert(std::make_pair(
          BName, std::vector<std::pair<const Record *, unsigned>>{}));
    }

    auto Signature = B->getValueAsListOfDefs("Signature");
    // Reuse signatures to avoid unnecessary duplicates.
    auto it =
        std::find_if(SignaturesList.begin(), SignaturesList.end(),
                     [&](const std::pair<std::vector<Record *>, unsigned> &a) {
                       return a.first == Signature;
                     });
    unsigned SignIndex;
    if (it == SignaturesList.end()) {
      VerifySignature(Signature, B);
      SignaturesList.push_back(std::make_pair(Signature, CumulativeSignIndex));
      SignIndex = CumulativeSignIndex;
      CumulativeSignIndex += Signature.size();
    } else {
      SignIndex = it->second;
    }
    FctOverloadMap[BName].push_back(std::make_pair(B, SignIndex));
  }
}

void BuiltinNameEmitter::EmitExtensionTable() {
  OS << "const char * " << ClassName << "::FunctionExtensionTable[] = {\n";
  unsigned Index = 0;
  std::vector<Record *> FuncExtensions =
      Records.getAllDerivedDefinitions("FunctionExtension");

  for (const auto &FE : FuncExtensions) {
    // Emit OpenCL extension table entry.
    OS << "  // " << Index << ": " << FE->getName() << "\n"
       << "  \"" << FE->getValueAsString("ExtName") << "\",\n";

    // Record index of this extension.
    FunctionExtensionIndex[FE->getName()] = Index++;
  }
  OS << "};\n\n";
}

void BuiltinNameEmitter::EmitTypeTable() {
  OS << "const " << ClassName << "::ProgModelTypeStruct " << ClassName
     << "::TypeTable[] = {\n";
  for (const auto &T : TypeMap) {
    const char *AccessQual =
        StringSwitch<const char *>(T.first->getValueAsString("AccessQualifier"))
            .Case("RO", "AQ_ReadOnly")
            .Case("WO", "AQ_WriteOnly")
            .Case("RW", "AQ_ReadWrite")
            .Default("AQ_None");

    OS << "  // " << T.second << "\n"
       << "  {TID_" << T.first->getValueAsString("Name") << ", "
       << T.first->getValueAsInt("VecWidth") << ", "
       << T.first->getValueAsBit("IsPointer") << ", "
       << T.first->getValueAsBit("IsConst") << ", "
       << T.first->getValueAsBit("IsVolatile") << ", " << AccessQual << ", "
       << T.first->getValueAsString("AddrSpace") << "},\n";
  }
  OS << "};\n\n";
}

void BuiltinNameEmitter::EmitSignatureTable() {
  // Store a type (e.g. int, float, int2, ...). The type is stored as an index
  // of a struct ProgModelTypeStruct table. Multiple entries following each
  // other form a signature.
  OS << "const unsigned short " << ClassName << "::SignatureTable[] = {\n";
  for (const auto &P : SignaturesList) {
    OS << "  // " << P.second << "\n  ";
    for (const Record *R : P.first) {
      unsigned Entry = TypeMap.find(R)->second;
      if (Entry > USHRT_MAX) {
        // Report an error when seeing an entry that is too large for the
        // current index type (unsigned short).  When hitting this, the type
        // of SignatureTable will need to be changed.
        PrintFatalError("Entry in SignatureTable exceeds limit.");
      }
      OS << Entry << ", ";
    }
    OS << "\n";
  }
  OS << "};\n\n";
}

void BuiltinNameEmitter::EmitBuiltinTable() {
  unsigned Index = 0;

  OS << "const " << ClassName << "::BuiltinStruct " << ClassName
     << "::BuiltinTable[] = {\n";
  for (const auto &SLM : SignatureListMap) {

    OS << "  // " << (Index + 1) << ": ";
    for (const auto &Name : SLM.second.Names) {
      OS << Name << ", ";
    }
    OS << "\n";

    for (const auto &Overload : SLM.second.Signatures) {
      StringRef ExtName = Overload.first->getValueAsDef("Extension")->getName();
      OS << "  { " << Overload.second << ", "
         << Overload.first->getValueAsListOfDefs("Signature").size() << ", "
         << (Overload.first->getValueAsBit("IsPure")) << ", "
         << (Overload.first->getValueAsBit("IsConst")) << ", "
         << (Overload.first->getValueAsBit("IsConv")) << ", "
         << (Overload.first->getValueAsBit("IsVariadic")) << ", "
         << FunctionExtensionIndex[ExtName] << ", "
         << Overload.first->getValueAsDef("MinVersion")->getValueAsInt("ID")
         << ", "
         << Overload.first->getValueAsDef("MaxVersion")->getValueAsInt("ID")
         << " },\n";
      Index++;
    }
  }
  OS << "};\n\n";
}

bool BuiltinNameEmitter::CanReuseSignature(
    BuiltinIndexListTy *Candidate,
    std::vector<std::pair<const Record *, unsigned>> &SignatureList) {
  assert(Candidate->size() == SignatureList.size() &&
         "signature lists should have the same size");

  auto &CandidateSigs =
      SignatureListMap.find(Candidate)->second.Signatures;
  for (unsigned Index = 0; Index < Candidate->size(); Index++) {
    const Record *Rec = SignatureList[Index].first;
    const Record *Rec2 = CandidateSigs[Index].first;
    if (Rec->getValueAsBit("IsPure") == Rec2->getValueAsBit("IsPure") &&
        Rec->getValueAsBit("IsConst") == Rec2->getValueAsBit("IsConst") &&
        Rec->getValueAsBit("IsConv") == Rec2->getValueAsBit("IsConv") &&
        Rec->getValueAsBit("IsVariadic") == Rec2->getValueAsBit("IsVariadic") &&
        Rec->getValueAsDef("MinVersion")->getValueAsInt("ID") ==
            Rec2->getValueAsDef("MinVersion")->getValueAsInt("ID") &&
        Rec->getValueAsDef("MaxVersion")->getValueAsInt("ID") ==
            Rec2->getValueAsDef("MaxVersion")->getValueAsInt("ID") &&
        Rec->getValueAsDef("Extension")->getName() ==
            Rec2->getValueAsDef("Extension")->getName()) {
      return true;
    }
  }
  return false;
}

void BuiltinNameEmitter::GroupBySignature() {
  // List of signatures known to be emitted.
  std::vector<BuiltinIndexListTy *> KnownSignatures;

  for (auto &Fct : FctOverloadMap) {
    bool FoundReusableSig = false;

    // Gather all signatures for the current function.
    auto *CurSignatureList = new BuiltinIndexListTy();
    for (const auto &Signature : Fct.second) {
      CurSignatureList->push_back(Signature.second);
    }
    // Sort the list to facilitate future comparisons.
    std::sort(CurSignatureList->begin(), CurSignatureList->end());

    // Check if we have already seen another function with the same list of
    // signatures.  If so, just add the name of the function.
    for (auto *Candidate : KnownSignatures) {
      if (Candidate->size() == CurSignatureList->size() &&
          *Candidate == *CurSignatureList) {
        if (CanReuseSignature(Candidate, Fct.second)) {
          SignatureListMap.find(Candidate)->second.Names.push_back(Fct.first);
          FoundReusableSig = true;
        }
      }
    }

    if (FoundReusableSig) {
      delete CurSignatureList;
    } else {
      // Add a new entry.
      SignatureListMap[CurSignatureList] = {
          SmallVector<StringRef, 4>(1, Fct.first), Fct.second};
      KnownSignatures.push_back(CurSignatureList);
    }
  }

  for (auto *I : KnownSignatures) {
    delete I;
  }
}

void BuiltinNameEmitter::EmitStringMatcher() {
  std::vector<StringMatcher::StringPair> ValidBuiltins;
  unsigned CumulativeIndex = 1;

  for (const auto &SLM : SignatureListMap) {
    const auto &Ovl = SLM.second.Signatures;

    // A single signature list may be used by different builtins.  Return the
    // same <index, length> pair for each of those builtins.
    for (const auto &FctName : SLM.second.Names) {
      std::string RetStmt;
      raw_string_ostream SS(RetStmt);
      SS << "return std::make_pair(" << CumulativeIndex << ", " << Ovl.size()
         << ");";
      SS.flush();
      ValidBuiltins.push_back(
          StringMatcher::StringPair(std::string(FctName), RetStmt));
    }
    CumulativeIndex += Ovl.size();
  }

  OS << R"(
// Find out whether a string matches an existing builtin function name.
// Returns: A pair <0, 0> if no name matches.
//          A pair <Index, Len> indexing the BuiltinTable if the name is
//          matching a builtin function.
)";

  OS << "std::pair<unsigned, unsigned> " << ClassName
     << "::isBuiltin(llvm::StringRef Name) {\n\n";

  StringMatcher("Name", ValidBuiltins, OS).Emit(0, true);

  OS << "  return std::make_pair(0, 0);\n";
  OS << "} // isBuiltin\n";
}

void BuiltinNameEmitter::EmitQualTypeFinder() {
  OS << R"(

// Convert an ProgModelTypeStruct type to a list of QualTypes.
// Generic types represent multiple types and vector sizes, thus a vector
// is returned. The conversion is done in two steps:
// Step 1: A switch statement fills a vector with scalar base types for the
//         Cartesian product of (vector sizes) x (types) for generic types,
//         or a single scalar type for non generic types.
// Step 2: Qualifiers and other type properties such as vector size are
//         applied.
)";

  OS << "void " << ClassName
     << "::Bultin2Qual(ASTContext &Context, const ProgModelTypeStruct &Ty, "
        "llvm::SmallVectorImpl<QualType> &QT) {\n";

  OS << R"(
  // Number of scalar types in the GenType.
  unsigned GenTypeNumTypes;
  // Pointer to the list of vector sizes for the GenType.
  llvm::ArrayRef<unsigned> GenVectorSizes;
)";

  // Generate list of vector sizes for each generic type.
  for (const auto *VectList : Records.getAllDerivedDefinitions("IntList")) {
    OS << "  constexpr unsigned List"
       << VectList->getValueAsString("Name") << "[] = {";
    for (const auto V : VectList->getValueAsListOfInts("List")) {
      OS << V << ", ";
    }
    OS << "};\n";
  }

  // Step 1.
  // Start of switch statement over all types.
  OS << "\n  switch (Ty.ID) {\n";

  // Switch cases for image types (Image2d, Image3d, ...)
  std::vector<Record *> ImageTypes =
      Records.getAllDerivedDefinitions("ImageType");

  // Map an image type name to its 3 access-qualified types (RO, WO, RW).
  std::map<StringRef, SmallVector<Record *, 3>> ImageTypesMap;
  for (auto *IT : ImageTypes) {
    auto Entry = ImageTypesMap.find(IT->getValueAsString("Name"));
    if (Entry == ImageTypesMap.end()) {
      SmallVector<Record *, 3> ImageList;
      ImageList.push_back(IT);
      ImageTypesMap.insert(
          std::make_pair(IT->getValueAsString("Name"), ImageList));
    } else {
      Entry->second.push_back(IT);
    }
  }

  // Emit the cases for the image types.  For an image type name, there are 3
  // corresponding QualTypes ("RO", "WO", "RW").  The "AccessQualifier" field
  // tells which one is needed.  Emit a switch statement that puts the
  // corresponding QualType into "QT".
  for (const auto &ITE : ImageTypesMap) {
    OS << "    case TID_" << ITE.first.str() << ":\n"
       << "      switch (Ty.AccessQualifier) {\n"
       << "        case AQ_None:\n"
       << "          llvm_unreachable(\"Image without access qualifier\");\n";
    for (const auto &Image : ITE.second) {
      OS << StringSwitch<const char *>(
                Image->getValueAsString("AccessQualifier"))
                .Case("RO", "        case AQ_ReadOnly:\n")
                .Case("WO", "        case AQ_WriteOnly:\n")
                .Case("RW", "        case AQ_ReadWrite:\n")
         << "          QT.push_back(Context."
         << Image->getValueAsDef("QTName")->getValueAsString("Name") << ");\n"
         << "          break;\n";
    }
    OS << "      }\n"
       << "      break;\n";
  }

  // Switch cases for generic types.
  for (const auto *GenType : Records.getAllDerivedDefinitions("GenericType")) {
    OS << "    case TID_" << GenType->getValueAsString("Name") << ":\n";
    OS << "      QT.append({";

    // Build the Cartesian product of (vector sizes) x (types).  Only insert
    // the plain scalar types for now; other type information such as vector
    // size and type qualifiers will be added after the switch statement.
    for (unsigned I = 0; I < GenType->getValueAsDef("VectorList")
                                 ->getValueAsListOfInts("List")
                                 .size();
         I++) {
      for (const auto *T :
           GenType->getValueAsDef("TypeList")->getValueAsListOfDefs("List")) {
        OS << "Context."
           << T->getValueAsDef("QTName")->getValueAsString("Name") << ", ";
      }
    }
    OS << "});\n";
    // GenTypeNumTypes is the number of types in the GenType
    // (e.g. float/double/half).
    OS << "      GenTypeNumTypes = "
       << GenType->getValueAsDef("TypeList")->getValueAsListOfDefs("List")
              .size()
       << ";\n";
    // GenVectorSizes is the list of vector sizes for this GenType.
    // QT contains GenTypeNumTypes * #GenVectorSizes elements.
    OS << "      GenVectorSizes = List"
       << GenType->getValueAsDef("VectorList")->getValueAsString("Name")
       << ";\n";
    OS << "      break;\n";
  }

  // Switch cases for non generic, non image types (int, int4, float, ...).
  // Only insert the plain scalar type; vector information and type qualifiers
  // are added in step 2.
  std::vector<Record *> Types = Records.getAllDerivedDefinitions("Type");
  StringMap<bool> TypesSeen;

  for (const auto *T : Types) {
    // Check this is not an image type
    if (ImageTypesMap.find(T->getValueAsString("Name")) != ImageTypesMap.end())
      continue;
    // Check we have not seen this Type
    if (TypesSeen.find(T->getValueAsString("Name")) != TypesSeen.end())
      continue;
    TypesSeen.insert(std::make_pair(T->getValueAsString("Name"), true));

    // Check the Type does not have an "abstract" QualType
    auto QT = T->getValueAsDef("QTName");
    if (QT->getValueAsBit("IsAbstract") == 1)
      continue;
    // Emit the cases for non generic, non image types.
    OS << "    case TID_" << T->getValueAsString("Name") << ":\n";
    OS << "      QT.push_back(Context." << QT->getValueAsString("Name")
       << ");\n";
    OS << "      break;\n";
  }

  // End of switch statement.
  OS << "  } // end of switch (Ty.ID)\n\n";

  // Step 2.
  // Add ExtVector types if this was a generic type, as the switch statement
  // above only populated the list with scalar types.  This completes the
  // construction of the Cartesian product of (vector sizes) x (types).
  OS << "  // Construct the different vector types for each generic type.\n";
  OS << "  if (Ty.ID >= " << TypeList.size() << ") {";
  OS << R"(
    for (unsigned I = 0; I < QT.size(); I++) {
      // For scalars, size is 1.
      if (GenVectorSizes[I / GenTypeNumTypes] != 1) {
        QT[I] = Context.getExtVectorType(QT[I],
                          GenVectorSizes[I / GenTypeNumTypes]);
      }
    }
  }
)";

  // Assign the right attributes to the types (e.g. vector size).
  OS << R"(
  // Set vector size for non-generic vector types.
  if (Ty.VectorWidth > 1) {
    for (unsigned Index = 0; Index < QT.size(); Index++) {
      QT[Index] = Context.getExtVectorType(QT[Index], Ty.VectorWidth);
    }
  }

  if (Ty.IsVolatile != 0) {
    for (unsigned Index = 0; Index < QT.size(); Index++) {
      QT[Index] = Context.getVolatileType(QT[Index]);
    }
  }

  if (Ty.IsConst != 0) {
    for (unsigned Index = 0; Index < QT.size(); Index++) {
      QT[Index] = Context.getConstType(QT[Index]);
    }
  }

  // Transform the type to a pointer as the last step, if necessary.
  // Builtin functions only have pointers on [const|volatile], no
  // [const|volatile] pointers, so this is ok to do it as a last step.
  if (Ty.IsPointer != 0) {
    for (unsigned Index = 0; Index < QT.size(); Index++) {
      QT[Index] = Context.getAddrSpaceQualType(QT[Index], Ty.AS);
      QT[Index] = Context.getPointerType(QT[Index]);
    }
  }
)";

  // End of the "Bultin2Qual" function.
  OS << "\n} // Bultin2Qual\n";
}

void clang::EmitClangOpenCLBuiltins(RecordKeeper &Records, raw_ostream &OS) {
  BuiltinNameEmitter NameChecker(Records, OS, "OpenCL");
  NameChecker.Emit();
}

void clang::EmitClangSPIRVBuiltins(RecordKeeper &Records, raw_ostream &OS) {
  BuiltinNameEmitter NameChecker(Records, OS, "SPIRV");
  NameChecker.Emit();
}
