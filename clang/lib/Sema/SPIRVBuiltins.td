//==--- OpenCLBuiltins.td - OpenCL builtin declarations -------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains TableGen definitions for OpenCL builtin function
// declarations.  In case of an unresolved function name in OpenCL, Clang will
// check for a function described in this file when -fdeclare-opencl-builtins
// is specified.
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//              Definitions of miscellaneous basic entities.
//===----------------------------------------------------------------------===//
// Versions of OpenCL
class Version<int _Version> {
  int ID = _Version;
}
def CLAll : Version<  0>;
def CL10  : Version<100>;
def CL11  : Version<110>;
def CL12  : Version<120>;
def CL20  : Version<200>;

// Address spaces
// Pointer types need to be assigned an address space.
class AddressSpace<string _AS> {
  string Name = _AS;
}
def DefaultAS    : AddressSpace<"clang::LangAS::Default">;
def PrivateAS    : AddressSpace<"clang::LangAS::opencl_private">;
def GlobalAS     : AddressSpace<"clang::LangAS::opencl_global">;
def ConstantAS   : AddressSpace<"clang::LangAS::opencl_constant">;
def LocalAS      : AddressSpace<"clang::LangAS::opencl_local">;
def GenericAS    : AddressSpace<"clang::LangAS::opencl_generic">;
// def PrivateAS    : AddressSpace<"clang::LangAS::sycl_private">;
// def GlobalAS     : AddressSpace<"clang::LangAS::sycl_global">;
// def ConstantAS   : AddressSpace<"clang::LangAS::sycl_constant">;
// def LocalAS      : AddressSpace<"clang::LangAS::sycl_local">;
// def GenericAS    : AddressSpace<"clang::LangAS::sycl_generic">;
// def DefaultAS    : AddressSpace<"">;
// def PrivateAS    : AddressSpace<"__private">;
// def GlobalAS     : AddressSpace<"__global">;
// def ConstantAS   : AddressSpace<"__constant">;
// def LocalAS      : AddressSpace<"__local">;
// def GenericAS    : AddressSpace<"__generic">;

// OpenCL language extension.
class AbstractExtension<string _Ext> {
  // One or more OpenCL extensions, space separated.  Each extension must be
  // a valid extension name for the opencl extension pragma.
  string ExtName = _Ext;
}

// Extension associated to a builtin function.
class FunctionExtension<string _Ext> : AbstractExtension<_Ext>;

// FunctionExtension definitions.
def FuncExtNone                          : FunctionExtension<"">;
def FuncExtKhrSubgroups                  : FunctionExtension<"cl_khr_subgroups">;
def FuncExtKhrGlobalInt32BaseAtomics     : FunctionExtension<"cl_khr_global_int32_base_atomics">;
def FuncExtKhrGlobalInt32ExtendedAtomics : FunctionExtension<"cl_khr_global_int32_extended_atomics">;
def FuncExtKhrLocalInt32BaseAtomics      : FunctionExtension<"cl_khr_local_int32_base_atomics">;
def FuncExtKhrLocalInt32ExtendedAtomics  : FunctionExtension<"cl_khr_local_int32_extended_atomics">;
def FuncExtKhrInt64BaseAtomics           : FunctionExtension<"cl_khr_int64_base_atomics">;
def FuncExtKhrInt64ExtendedAtomics       : FunctionExtension<"cl_khr_int64_extended_atomics">;
def FuncExtKhrMipmapImage                : FunctionExtension<"cl_khr_mipmap_image">;
def FuncExtKhrMipmapImageWrites          : FunctionExtension<"cl_khr_mipmap_image_writes">;
def FuncExtKhrGlMsaaSharing              : FunctionExtension<"cl_khr_gl_msaa_sharing">;

// Multiple extensions
def FuncExtKhrMipmapWritesAndWrite3d     : FunctionExtension<"cl_khr_mipmap_image_writes cl_khr_3d_image_writes">;

// Qualified Type.  These map to ASTContext::QualType.
class QualType<string _Name, bit _IsAbstract=0, bit _IsSigned=0> {
  // Name of the field or function in a clang::ASTContext
  // E.g. Name="IntTy" for the int type, and "getIntPtrType()" for an intptr_t
  string Name = _Name;
  // Some QualTypes in this file represent an abstract type for which there is
  // no corresponding AST QualType, e.g. a GenType or an `image2d_t` type
  // without access qualifiers.
  bit IsAbstract = _IsAbstract;
  bit IsSigned = _IsSigned;
}

// List of integers.
class IntList<string _Name, list<int> _List> {
  string Name = _Name;
  list<int> List = _List;
}

//===----------------------------------------------------------------------===//
//                      OpenCL C classes for types
//===----------------------------------------------------------------------===//
// OpenCL C basic data types (int, float, image2d_t, ...).
// Its child classes can represent concrete types (e.g. VectorType) or
// abstract types (e.g. GenType).
class Type<string _Name, QualType _QTName> {
  // Name of the Type.
  string Name = _Name;
  // QualType associated with this type.
  QualType QTName = _QTName;
  // Size of the vector (if applicable).
  int VecWidth = 1;
  // Size of the element in bits.
  int ElementSize = 1;
  // Is a integer.
  bit IsInteger = 0;
  // Is a signed integer.
  bit IsSigned = 1;
  // Is a float.
  bit IsFloat = 0;
  // Is a pointer.
  bit IsPointer = 0;
  // "const" qualifier.
  bit IsConst = 0;
  // "volatile" qualifier.
  bit IsVolatile = 0;
  // Access qualifier. Must be one of ("RO", "WO", "RW").
  string AccessQualifier = "";
  // Address space.
  string AddrSpace = DefaultAS.Name;
}

class FundamentalType<string _Name, QualType _QTName, int _Size> : Type<_Name, _QTName> {
  // Inherited fields
  let ElementSize = _Size;
}

// Integer Type.
class IntType<string _Name, QualType _QTName, int _Size> : FundamentalType<_Name, _QTName, _Size> {
  // Inherited fields
  let IsInteger = 1;
  let IsSigned = 1;
}

// Unsigned integer Type.
class UIntType<string _Name, QualType _QTName, int _Size> : FundamentalType<_Name, _QTName, _Size> {
  // Inherited fields
  let IsInteger = 1;
  let IsSigned = 0;
}

// Floating Type.
class FPType<string _Name, QualType _QTName, int _Size> : FundamentalType<_Name, _QTName, _Size> {
  // Inherited fields
  let IsFloat = 1;
}

class CompoundType<Type _Ty> : Type<_Ty.Name, _Ty.QTName> {
  // Inherited fields
  let VecWidth = _Ty.VecWidth;
  let ElementSize = _Ty.ElementSize;
  let IsInteger = _Ty.IsInteger;
  let IsSigned = _Ty.IsSigned;
  let IsFloat = _Ty.IsFloat;
  let IsPointer = _Ty.IsPointer;
  let IsConst = _Ty.IsConst;
  let IsVolatile = _Ty.IsVolatile;
  let AccessQualifier = _Ty.AccessQualifier;
  let AddrSpace = _Ty.AddrSpace;

  Type ElementType = _Ty;
}

// OpenCL vector types (e.g. int2, int3, int16, float8, ...).
class VectorType<Type _Ty, int _VecWidth> : Type<_Ty.Name, _Ty.QTName> {
  let VecWidth = _VecWidth;
  let AccessQualifier = "";
  // Inherited fields
  let ElementSize = _Ty.ElementSize;
  let IsInteger = _Ty.IsInteger;
  let IsSigned = _Ty.IsSigned;
  let IsFloat = _Ty.IsFloat;
  let IsPointer = _Ty.IsPointer;
  let IsConst = _Ty.IsConst;
  let IsVolatile = _Ty.IsVolatile;
  let AccessQualifier = _Ty.AccessQualifier;
  let AddrSpace = _Ty.AddrSpace;
}

// OpenCL pointer types (e.g. int*, float*, ...).
class PointerType<Type _Ty, AddressSpace _AS = DefaultAS> :
    CompoundType<_Ty> {
  // Inherited fields
  let IsPointer = 1;
  let AddrSpace = _AS.Name;
}

// OpenCL const types (e.g. const int).
class ConstType<Type _Ty> : CompoundType<_Ty> {
  // Inherited fields
  let IsConst = 1;
}

// OpenCL volatile types (e.g. volatile int).
class VolatileType<Type _Ty> : CompoundType<_Ty> {
  // Inherited fields
  let IsVolatile = 1;
}

// OpenCL image types (e.g. image2d).
class ImageType<Type _Ty, string _AccessQualifier> :
    Type<_Ty.Name, QualType<_Ty.QTName.Name#_AccessQualifier#"Ty", 0>> {
  let VecWidth = 0;
  let AccessQualifier = _AccessQualifier;
  // Inherited fields
  let ElementSize = _Ty.ElementSize;
  let IsInteger = _Ty.IsInteger;
  let IsSigned = _Ty.IsSigned;
  let IsFloat = _Ty.IsFloat;
  let IsPointer = _Ty.IsPointer;
  let IsConst = _Ty.IsConst;
  let IsVolatile = _Ty.IsVolatile;
  let AddrSpace = _Ty.AddrSpace;
}

// List of Types.
class TypeList<list<Type> _Type> {
  list<Type> List = _Type;
}

// A GenericType is an abstract type that defines a set of types as a
// combination of Types and vector sizes.
//
// For example, if TypeList = <int, float> and VectorList = <1, 2, 4>, then it
// represents <int, int2, int4, float, float2, float4>.
//
// Some rules apply when using multiple GenericType arguments in a declaration:
//   1. The number of vector sizes must be equal or 1 for all gentypes in a
//      declaration.
//   2. The number of Types must be equal or 1 for all gentypes in a
//      declaration.
//   3. Generic types are combined by iterating over all generic types at once.
//      For example, for the following GenericTypes
//        GenT1 = GenericType<half, [1, 2]> and
//        GenT2 = GenericType<float, int, [1, 2]>
//      A declaration f(GenT1, GenT2) results in the combinations
//        f(half, float), f(half2, float2), f(half, int), f(half2, int2) .
//   4. "sgentype" from the OpenCL specification is supported by specifying
//      a single vector size.
//      For example, for the following GenericTypes
//        GenT = GenericType<half, int, [1, 2]> and
//        SGenT = GenericType<half, int, [1]>
//      A declaration f(GenT, SGenT) results in the combinations
//        f(half, half), f(half2, half), f(int, int), f(int2, int) .
class GenericType<string _Ty, TypeList _TypeList, IntList _VectorList> :
    Type<_Ty, QualType<"null", 1>> {
  // Possible element types of the generic type.
  TypeList TypeList = _TypeList;
  // Possible vector sizes of the types in the TypeList.
  IntList VectorList = _VectorList;
  // The VecWidth field is ignored for GenericTypes. Use VectorList instead.
  let VecWidth = 0;
}

// Builtin function attributes.
def Attr {
  list<bit> None = [0, 0, 0];
  list<bit> Pure = [1, 0, 0];
  list<bit> Const = [0, 1, 0];
  list<bit> Convergent = [0, 0, 1];
}

//===----------------------------------------------------------------------===//
//                      OpenCL C class for builtin functions
//===----------------------------------------------------------------------===//
class Builtin<string _Name, list<Type> _Signature, list<bit> _Attributes = Attr.None> {
  // Name of the builtin function
  string Name = _Name;
  // List of types used by the function. The first one is the return type and
  // the following are the arguments. The list must have at least one element
  // (the return type).
  list<Type> Signature = _Signature;
  // Function attribute __attribute__((pure))
  bit IsPure = _Attributes[0];
  // Function attribute __attribute__((const))
  bit IsConst = _Attributes[1];
  // Function attribute __attribute__((convergent))
  bit IsConv = _Attributes[2];
  // Is function a variadic one
  bit IsVariadic = 0;
  // OpenCL extensions to which the function belongs.
  FunctionExtension Extension = FuncExtNone;
  // Version of OpenCL from which the function is available (e.g.: CL10).
  // MinVersion is inclusive.
  Version MinVersion = CL10;
  // Version of OpenCL from which the function is not supported anymore.
  // MaxVersion is exclusive.
  // CLAll makes the function available for all versions.
  Version MaxVersion = CLAll;
}
class SPVBuiltin<string _Name, list<Type> _Signature, list<bit> _Attributes = Attr.None> :
Builtin<"__spirv_" # _Name, _Signature, _Attributes> {} 

class OCLSPVBuiltin<string _Name, list<Type> _Signature, list<bit> _Attributes = Attr.None> :
SPVBuiltin<"ocl_" # _Name, _Signature, _Attributes> {} 
//===----------------------------------------------------------------------===//
//                 Definitions of OpenCL C types
//===----------------------------------------------------------------------===//

// OpenCL v1.0/1.2/2.0 s6.1.1: Built-in Scalar Data Types.
def Bool      : IntType<"bool",   QualType<"BoolTy">, 8>;
def TrueChar      : IntType<"char",      QualType<"CharTy", 0, 1>, 8>;
//def Char      : IntType<"char",      QualType<"CharTy", 0, 1>, 8>;
def Char      : IntType<"schar",      QualType<"SignedCharTy", 0, 1>, 8>;
def SChar     : IntType<"schar",     QualType<"SignedCharTy", 0, 1>, 8>;
def UChar     : UIntType<"uchar",     QualType<"UnsignedCharTy">, 8>;
def Short     : IntType<"short",     QualType<"ShortTy", 0, 1>, 16>;
def UShort    : UIntType<"ushort",    QualType<"UnsignedShortTy">, 16>;
def Int       : IntType<"int",       QualType<"IntTy", 0, 1>, 32>;
def UInt      : UIntType<"uint",      QualType<"UnsignedIntTy">, 32>;
def Long      : IntType<"long",      QualType<"LongTy", 0, 1>, 64>;
def ULong     : UIntType<"ulong",     QualType<"UnsignedLongTy">, 64>;
def Float     : FPType<"float",     QualType<"FloatTy">, 32>;
def Double    : FPType<"double",    QualType<"DoubleTy">, 64>;
//def Half      : FPType<"half",      QualType<"HalfTy">, 16>;
def Half      : FPType<"half",      QualType<"Float16Ty">, 16>;
def Void      : Type<"void",      QualType<"VoidTy">>;
// FIXME: ensure this is portable...
def Size      : Type<"size_t",    QualType<"getSizeType()">>;

// OpenCL v1.0/1.2/2.0 s6.1.2: Built-in Vector Data Types.
// Built-in vector data types are created by TableGen's OpenCLBuiltinEmitter.

// OpenCL v1.0/1.2/2.0 s6.1.3: Other Built-in Data Types.
// The image definitions are "abstract".  They should not be used without
// specifying an access qualifier (RO/WO/RW).
def Image1d               : Type<"image1d_t", QualType<"OCLImage1d", 1>>;
def Image2d               : Type<"image2d_t", QualType<"OCLImage2d", 1>>;
def Image3d               : Type<"image3d_t", QualType<"OCLImage3d", 1>>;
def Image1dArray          : Type<"image1d_array_t", QualType<"OCLImage1dArray", 1>>;
def Image1dBuffer         : Type<"image1d_buffer_t", QualType<"OCLImage1dBuffer", 1>>;
def Image2dArray          : Type<"image2d_array_t", QualType<"OCLImage2dArray", 1>>;
def Image2dDepth          : Type<"image2d_depth_t", QualType<"OCLImage2dDepth", 1>>;
def Image2dArrayDepth     : Type<"image2d_array_depth_t", QualType<"OCLImage2dArrayDepth", 1>>;
def Image2dMsaa           : Type<"image2d_msaa_t", QualType<"OCLImage2dMSAA", 1>>;
def Image2dArrayMsaa      : Type<"image2d_array_msaa_t", QualType<"OCLImage2dArrayMSAA", 1>>;
def Image2dMsaaDepth      : Type<"image2d_msaa_depth_t", QualType<"OCLImage2dMSAADepth", 1>>;
def Image2dArrayMsaaDepth : Type<"image2d_array_msaa_depth_t", QualType<"OCLImage2dArrayMSAADepth", 1>>;

def Sampler               : Type<"sampler_t", QualType<"OCLSamplerTy">>;
def Event                 : Type<"event_t", QualType<"OCLEventTy">>;

//===----------------------------------------------------------------------===//
//                 Definitions of OpenCL gentype variants
//===----------------------------------------------------------------------===//
// The OpenCL specification often uses "gentype" in builtin function
// declarations to indicate that a builtin function is available with various
// argument and return types.  The types represented by "gentype" vary between
// different parts of the specification.  The following definitions capture
// the different type lists for gentypes in different parts of the
// specification.

// Vector width lists.
def VecAndScalar: IntList<"VecAndScalar", [1, 2, 3, 4, 8, 16]>;
def VecNoScalar : IntList<"VecNoScalar", [2, 3, 4, 8, 16]>;
def Vec1        : IntList<"Vec1", [1]>;
def Vec2        : IntList<"Vec2", [2]>;
def Vec4        : IntList<"Vec4", [4]>;
def Vec8        : IntList<"Vec8", [8]>;
def Vec16       : IntList<"Vec16", [16]>;
def Vec1234     : IntList<"Vec1234", [1, 2, 3, 4]>;

// Type lists.
def TLAll           : TypeList<[Char,  UChar, Short,  UShort, Int,  UInt, Long,  ULong, Float, Double, Half]>;
def TLAllUnsigned   : TypeList<[UChar, UChar, UShort, UShort, UInt, UInt, ULong, ULong, UInt,  ULong,  UShort]>;
def TLFloat         : TypeList<[Float, Double, Half]>;
// Fixme: handle properly char (signed or unsigned depending on host)
def TLSignedInts    : TypeList<[Char, Short, Int, Long]>;
def TLUnsignedInts  : TypeList<[UChar, UShort, UInt, ULong]>;

// Signed to Unsigned conversion
// Fixme: handle properly char (signed or unsigned depending on host)
def TLSToUSignedInts    : TypeList<[Char, Short, Int, Long]>;
def TLSToUUnsignedInts  : TypeList<[UChar, UShort, UInt, ULong]>;

def TLIntLongFloats : TypeList<[Int, UInt, Long, ULong, Float, Double, Half]>;

// All unsigned integer types twice, to facilitate unsigned return types for e.g.
// uchar abs(char) and
// uchar abs(uchar).
def TLAllUIntsTwice : TypeList<[UChar, UChar, UChar, UShort, UShort, UInt, UInt, ULong, ULong]>;

def TLAllInts       : TypeList<[Char, UChar, Short, UShort, Int, UInt, Long, ULong]>;

// GenType definitions for multiple base types (e.g. all floating point types,
// or all integer types).
// All types
def AGenType1              : GenericType<"AGenType1", TLAll, Vec1>;
def AGenTypeN              : GenericType<"AGenTypeN", TLAll, VecAndScalar>;
def AGenTypeNNoScalar      : GenericType<"AGenTypeNNoScalar", TLAll, VecNoScalar>;
// All integer
def AIGenType1             : GenericType<"AIGenType1", TLAllInts, Vec1>;
def AIGenTypeN             : GenericType<"AIGenTypeN", TLAllInts, VecAndScalar>;
def AUIGenTypeN             : GenericType<"AUIGenTypeN", TLUnsignedInts, VecAndScalar>;
def ASIGenTypeN             : GenericType<"ASIGenTypeN", TLSignedInts, VecAndScalar>;
def AIGenTypeNNoScalar     : GenericType<"AIGenTypeNNoScalar", TLAllInts, VecNoScalar>;
// All integer to unsigned
def AI2UGenTypeN           : GenericType<"AI2UGenTypeN", TLAllUIntsTwice, VecAndScalar>;
// Signed integer
def SGenTypeN              : GenericType<"SGenTypeN", TLSignedInts, VecAndScalar>;
// Unsigned integer
def UGenTypeN              : GenericType<"UGenTypeN", TLUnsignedInts, VecAndScalar>;
// Float
def FGenTypeN              : GenericType<"FGenTypeN", TLFloat, VecAndScalar>;
// (u)int, (u)long, and all floats
def IntLongFloatGenType1   : GenericType<"IntLongFloatGenType1", TLIntLongFloats, Vec1>;

// GenType definitions for every single base type (e.g. fp32 only).
// Names are like: GenTypeFloatVecAndScalar.
foreach Type = [Bool, Char, UChar, Short, UShort,
                Int, UInt, Long, ULong,
                Float, Double, Half] in {
  foreach VecSizes = [VecAndScalar, VecNoScalar] in {
    def "GenType" # Type # VecSizes :
              GenericType<"GenType" # Type # VecSizes,
                          TypeList<[Type]>, VecSizes>;
  }
}

// GenType definitions for vec1234.
foreach Type = [Float, Double, Half] in {
  def "GenType" # Type # Vec1234 :
              GenericType<"GenType" # Type # Vec1234,
                          TypeList<[Type]>, Vec1234>;
}


// extinst.opencl.std.100.grammar.json

// 2.1. Math extended instructions

// 1 argument builtins

foreach name = ["acos"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["acosh"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["acospi"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["asin"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["asinh"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["asinpi"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["atan"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["atan2"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach name = ["atanh"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["atanpi"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["atan2pi"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach name = ["cbrt"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["ceil"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["copysign"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach name = ["cos"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["cosh"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["cospi"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["erfc"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["erf"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["exp"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["exp2"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["exp10"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["expm1"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["fabs"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["fdim"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach name = ["floor"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["fma"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach name = ["fmax"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach name = ["fmin"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach name = ["fmod"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach AS = [GlobalAS, LocalAS, PrivateAS, GenericAS] in {
  foreach name = ["fract"] in {
    def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, PointerType<FGenTypeN, AS>]>;
  }

  foreach name = ["frexp"] in {
    foreach Type = [GenTypeFloatVecAndScalar, GenTypeDoubleVecAndScalar, GenTypeHalfVecAndScalar] in {
      def : OCLSPVBuiltin<name, [Type, Type, PointerType<GenTypeIntVecAndScalar, AS>]>;
    }
  }
}

foreach name = ["hypot"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach name = ["ilogb"] in {
  def : OCLSPVBuiltin<name, [GenTypeIntVecAndScalar, GenTypeFloatVecAndScalar], Attr.Const>;
  def : OCLSPVBuiltin<name, [GenTypeIntVecAndScalar, GenTypeDoubleVecAndScalar], Attr.Const>;
  def : OCLSPVBuiltin<name, [GenTypeIntVecAndScalar, GenTypeHalfVecAndScalar], Attr.Const>;
}

foreach name = ["ldexp"] in {
  foreach Type = [GenTypeFloatVecAndScalar, GenTypeDoubleVecAndScalar, GenTypeHalfVecAndScalar] in {
    def : OCLSPVBuiltin<name, [Type, Type, GenTypeIntVecAndScalar]>;
    def : OCLSPVBuiltin<name, [Type, Type, GenTypeUIntVecAndScalar]>;
  }
}

foreach name = ["lgamma"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach AS = [GlobalAS, LocalAS, PrivateAS, GenericAS] in {
  foreach Type = [GenTypeFloatVecAndScalar, GenTypeDoubleVecAndScalar, GenTypeHalfVecAndScalar] in {
    foreach name = ["lgamma_r"] in {
      def : OCLSPVBuiltin<name, [Type, Type, PointerType<GenTypeIntVecAndScalar, AS>]>;
    }
  }
}

foreach name = ["log"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["log2"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["log10"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["log1p"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["logb"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["mad"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach name = ["maxmag"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach name = ["minmag"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach AS = [GlobalAS, LocalAS, PrivateAS, GenericAS] in {
  foreach name = ["modf"] in {
    def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, PointerType<FGenTypeN, AS>]>;
  }
}

foreach name = ["nan"] in {
  def : OCLSPVBuiltin<name, [GenTypeHalfVecAndScalar, GenTypeShortVecAndScalar]>;
  def : OCLSPVBuiltin<name, [GenTypeHalfVecAndScalar, GenTypeUShortVecAndScalar]>;
  def : OCLSPVBuiltin<name, [GenTypeFloatVecAndScalar, GenTypeIntVecAndScalar]>;
  def : OCLSPVBuiltin<name, [GenTypeFloatVecAndScalar, GenTypeUIntVecAndScalar]>;
  def : OCLSPVBuiltin<name, [GenTypeDoubleVecAndScalar, GenTypeLongVecAndScalar]>;
  def : OCLSPVBuiltin<name, [GenTypeDoubleVecAndScalar, GenTypeULongVecAndScalar]>;
}

foreach name = ["nextafter"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach name = ["pow"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach name = ["pown"] in {
  def : OCLSPVBuiltin<name, [GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar, GenTypeIntVecAndScalar], Attr.Const>;
  def : OCLSPVBuiltin<name, [GenTypeDoubleVecAndScalar, GenTypeDoubleVecAndScalar, GenTypeIntVecAndScalar], Attr.Const>;
  def : OCLSPVBuiltin<name, [GenTypeHalfVecAndScalar, GenTypeHalfVecAndScalar, GenTypeIntVecAndScalar], Attr.Const>;
}

foreach name = ["powr"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach name = ["remainder"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach AS = [GlobalAS, LocalAS, PrivateAS, GenericAS] in {
  foreach name = ["remquo"] in {
    foreach Type = [GenTypeFloatVecAndScalar, GenTypeDoubleVecAndScalar, GenTypeHalfVecAndScalar] in {
      def : OCLSPVBuiltin<name, [Type, Type, Type, PointerType<GenTypeIntVecAndScalar, AS>]>;
    }
  }
}

foreach name = ["rint"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["rootn"] in {
  def : OCLSPVBuiltin<name, [GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar, GenTypeIntVecAndScalar], Attr.Const>;
  def : OCLSPVBuiltin<name, [GenTypeDoubleVecAndScalar, GenTypeDoubleVecAndScalar, GenTypeIntVecAndScalar], Attr.Const>;
  def : OCLSPVBuiltin<name, [GenTypeHalfVecAndScalar, GenTypeHalfVecAndScalar, GenTypeIntVecAndScalar], Attr.Const>;
}

foreach name = ["round"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["rsqrt"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["sin"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach AS = [GlobalAS, LocalAS, PrivateAS, GenericAS] in {
  foreach name = ["sincos"] in {
    def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, PointerType<FGenTypeN, AS>]>;
  }
}

foreach name = ["sinh"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["sinpi"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["sqrt"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["tan"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["tanh"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["tanpi"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["tgamma"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["trunc"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["half_cos"] in {
  def : OCLSPVBuiltin<name, [GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar]>;
}

foreach name = ["half_divide"] in {
  def : OCLSPVBuiltin<name, [GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar]>;
}

foreach name = ["half_exp"] in {
  def : OCLSPVBuiltin<name, [GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar]>;
}

foreach name = ["half_exp2"] in {
  def : OCLSPVBuiltin<name, [GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar]>;
}

foreach name = ["half_exp10"] in {
  def : OCLSPVBuiltin<name, [GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar]>;
}

foreach name = ["half_log"] in {
  def : OCLSPVBuiltin<name, [GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar]>;
}

foreach name = ["half_log2"] in {
  def : OCLSPVBuiltin<name, [GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar]>;
}

foreach name = ["half_log10"] in {
  def : OCLSPVBuiltin<name, [GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar]>;
}

foreach name = ["half_powr"] in {
  def : OCLSPVBuiltin<name, [GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar]>;
}

foreach name = ["half_recip"] in {
  def : OCLSPVBuiltin<name, [GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar]>;
}

foreach name = ["half_rsqrt"] in {
  def : OCLSPVBuiltin<name, [GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar]>;
}

foreach name = ["half_sin"] in {
  def : OCLSPVBuiltin<name, [GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar]>;
}

foreach name = ["half_sqrt"] in {
  def : OCLSPVBuiltin<name, [GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar]>;
}

foreach name = ["half_tan"] in {
  def : OCLSPVBuiltin<name, [GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar]>;
}

foreach name = ["native_cos"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["native_divide"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach name = ["native_exp"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["native_exp2"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["native_exp10"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["native_log"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["native_log2"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["native_log10"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["native_powr"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach name = ["native_recip"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["native_rsqrt"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["native_sin"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["native_sqrt"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["native_tan"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

// 2.2. Integer instructions

foreach name = ["s_abs"] in {
  def : OCLSPVBuiltin<name, [AUIGenTypeN, ASIGenTypeN]>;
}

foreach name = ["s_abs_diff"] in {
  def : OCLSPVBuiltin<name, [AUIGenTypeN, ASIGenTypeN, ASIGenTypeN]>;
}

foreach name = ["s_add_sat"] in {
  def : OCLSPVBuiltin<name, [ASIGenTypeN, ASIGenTypeN, ASIGenTypeN]>;
}

foreach name = ["u_add_sat"] in {
  def : OCLSPVBuiltin<name, [AUIGenTypeN, AUIGenTypeN, AUIGenTypeN]>;
}

foreach name = ["s_hadd"] in {
  def : OCLSPVBuiltin<name, [ASIGenTypeN, ASIGenTypeN, ASIGenTypeN]>;
}

foreach name = ["u_hadd"] in {
  def : OCLSPVBuiltin<name, [AUIGenTypeN, AUIGenTypeN, AUIGenTypeN]>;
}

foreach name = ["s_rhadd"] in {
  def : OCLSPVBuiltin<name, [ASIGenTypeN, ASIGenTypeN, ASIGenTypeN]>;
}

foreach name = ["u_rhadd"] in {
  def : OCLSPVBuiltin<name, [AUIGenTypeN, AUIGenTypeN, AUIGenTypeN]>;
}

foreach name = ["s_clamp"] in {
  def : OCLSPVBuiltin<name, [ASIGenTypeN, ASIGenTypeN, ASIGenTypeN, ASIGenTypeN]>;
}

foreach name = ["u_clamp"] in {
  def : OCLSPVBuiltin<name, [AUIGenTypeN, AUIGenTypeN, AUIGenTypeN, AUIGenTypeN]>;
}

foreach name = ["clz"] in {
  def : OCLSPVBuiltin<name, [AIGenTypeN, AIGenTypeN]>;
}

foreach name = ["ctz"] in {
  def : OCLSPVBuiltin<name, [AIGenTypeN, AIGenTypeN]>;
}

foreach name = ["s_mad_hi"] in {
  def : OCLSPVBuiltin<name, [ASIGenTypeN, ASIGenTypeN, ASIGenTypeN, ASIGenTypeN]>;
}

foreach name = ["u_mad_sat"] in {
  def : OCLSPVBuiltin<name, [AUIGenTypeN, AUIGenTypeN, AUIGenTypeN, AUIGenTypeN]>;
}

foreach name = ["s_mad_sat"] in {
  def : OCLSPVBuiltin<name, [ASIGenTypeN, ASIGenTypeN, ASIGenTypeN, ASIGenTypeN]>;
}

foreach name = ["s_max"] in {
  def : OCLSPVBuiltin<name, [ASIGenTypeN, ASIGenTypeN, ASIGenTypeN]>;
}

foreach name = ["u_max"] in {
  def : OCLSPVBuiltin<name, [AUIGenTypeN, AUIGenTypeN, AUIGenTypeN]>;
}

foreach name = ["s_min"] in {
  def : OCLSPVBuiltin<name, [ASIGenTypeN, ASIGenTypeN, ASIGenTypeN]>;
}

foreach name = ["u_min"] in {
  def : OCLSPVBuiltin<name, [AUIGenTypeN, AUIGenTypeN, AUIGenTypeN]>;
}

foreach name = ["s_mul_hi"] in {
  def : OCLSPVBuiltin<name, [ASIGenTypeN, ASIGenTypeN, ASIGenTypeN]>;
}

foreach name = ["rotate"] in {
  def : OCLSPVBuiltin<name, [AIGenTypeN, AIGenTypeN, AIGenTypeN]>;
}

foreach name = ["s_sub_sat"] in {
  def : OCLSPVBuiltin<name, [ASIGenTypeN, ASIGenTypeN, ASIGenTypeN]>;
}

foreach name = ["u_sub_sat"] in {
  def : OCLSPVBuiltin<name, [AUIGenTypeN, AUIGenTypeN, AUIGenTypeN]>;
}

foreach name = ["u_upsample"] in {
  def : OCLSPVBuiltin<name, [GenTypeUShortVecAndScalar, GenTypeUCharVecAndScalar, GenTypeUCharVecAndScalar], Attr.Const>;
  def : OCLSPVBuiltin<name, [GenTypeUIntVecAndScalar, GenTypeUShortVecAndScalar, GenTypeUShortVecAndScalar], Attr.Const>;
  def : OCLSPVBuiltin<name, [GenTypeULongVecAndScalar, GenTypeUIntVecAndScalar, GenTypeUIntVecAndScalar], Attr.Const>;
}

foreach name = ["s_upsample"] in {
  def : OCLSPVBuiltin<name, [GenTypeShortVecAndScalar, GenTypeCharVecAndScalar, GenTypeUCharVecAndScalar], Attr.Const>;
  def : OCLSPVBuiltin<name, [GenTypeIntVecAndScalar, GenTypeShortVecAndScalar, GenTypeUShortVecAndScalar], Attr.Const>;
  def : OCLSPVBuiltin<name, [GenTypeLongVecAndScalar, GenTypeIntVecAndScalar, GenTypeUIntVecAndScalar], Attr.Const>;
}

foreach name = ["popcount"] in {
  def : OCLSPVBuiltin<name, [AIGenTypeN, AIGenTypeN]>;
}

foreach name = ["s_mad24"] in {
  def : OCLSPVBuiltin<name, [GenTypeIntVecAndScalar, GenTypeIntVecAndScalar, GenTypeIntVecAndScalar, GenTypeIntVecAndScalar]>;
}

foreach name = ["u_mad24"] in {
  def : OCLSPVBuiltin<name, [GenTypeUIntVecAndScalar, GenTypeUIntVecAndScalar, GenTypeUIntVecAndScalar, GenTypeUIntVecAndScalar]>;
}

foreach name = ["s_mul24"] in {
  def : OCLSPVBuiltin<name, [GenTypeIntVecAndScalar, GenTypeIntVecAndScalar, GenTypeIntVecAndScalar]>;
}

foreach name = ["u_mul24"] in {
  def : OCLSPVBuiltin<name, [GenTypeUIntVecAndScalar, GenTypeUIntVecAndScalar, GenTypeUIntVecAndScalar]>;
}

foreach name = ["u_abs"] in {
  def : OCLSPVBuiltin<name, [AUIGenTypeN, AUIGenTypeN]>;
}

foreach name = ["u_abs_diff"] in {
  def : OCLSPVBuiltin<name, [AUIGenTypeN, AUIGenTypeN, AUIGenTypeN]>;
}

foreach name = ["u_mul_hi"] in {
  def : OCLSPVBuiltin<name, [AUIGenTypeN, AUIGenTypeN, AUIGenTypeN]>;
}

foreach name = ["u_mad_hi"] in {
  def : OCLSPVBuiltin<name, [AUIGenTypeN, AUIGenTypeN, AUIGenTypeN, AUIGenTypeN]>;
}

// 2.3. Common instructions

foreach name = ["fclamp"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach name = ["degrees"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["fmax_common"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach name = ["fmin_common"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach name = ["mix"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach name = ["radians"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

foreach name = ["step"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach name = ["smoothstep"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN, FGenTypeN, FGenTypeN]>;
}

foreach name = ["sign"] in {
  def : OCLSPVBuiltin<name, [FGenTypeN, FGenTypeN]>;
}

// 2.4. Geometric instructions

foreach name = ["cross"] in {
  foreach VSize = [3, 4] in {
    def : OCLSPVBuiltin<name, [VectorType<Float, VSize>, VectorType<Float, VSize>, VectorType<Float, VSize>], Attr.Const>;
    def : OCLSPVBuiltin<name, [VectorType<Double, VSize>, VectorType<Double, VSize>, VectorType<Double, VSize>], Attr.Const>;
    def : OCLSPVBuiltin<name, [VectorType<Half, VSize>, VectorType<Half, VSize>, VectorType<Half, VSize>], Attr.Const>;
  }
}

foreach name = ["distance"] in {
  def : OCLSPVBuiltin<name, [Float, GenTypeFloatVec1234, GenTypeFloatVec1234], Attr.Const>;
  def : OCLSPVBuiltin<name, [Double, GenTypeDoubleVec1234, GenTypeDoubleVec1234], Attr.Const>;
  def : OCLSPVBuiltin<name, [Half, GenTypeHalfVec1234, GenTypeHalfVec1234], Attr.Const>;
}

foreach name = ["length"] in {
  def : OCLSPVBuiltin<name, [Float, GenTypeFloatVec1234], Attr.Const>;
  def : OCLSPVBuiltin<name, [Double, GenTypeDoubleVec1234], Attr.Const>;
  def : OCLSPVBuiltin<name, [Half, GenTypeHalfVec1234], Attr.Const>;
}

foreach name = ["normalize"] in {
  def : OCLSPVBuiltin<name, [GenTypeFloatVec1234, GenTypeFloatVec1234], Attr.Const>;
  def : OCLSPVBuiltin<name, [GenTypeDoubleVec1234, GenTypeDoubleVec1234], Attr.Const>;
  def : OCLSPVBuiltin<name, [GenTypeHalfVec1234, GenTypeHalfVec1234], Attr.Const>;
}

foreach name = ["fast_distance"] in {
  def : OCLSPVBuiltin<name, [Float, GenTypeFloatVec1234, GenTypeFloatVec1234], Attr.Const>;
}

foreach name = ["fast_length"] in {
  def : OCLSPVBuiltin<name, [Float, GenTypeFloatVec1234], Attr.Const>;
}

foreach name = ["fast_normalize"] in {
  def : OCLSPVBuiltin<name, [GenTypeFloatVec1234, GenTypeFloatVec1234], Attr.Const>;
}

// 2.5. Relational instructions

foreach name = ["bitselect"] in {
  def : OCLSPVBuiltin<name, [AGenTypeN, AGenTypeN, AGenTypeN, AGenTypeN], Attr.Const>;
}

foreach name = ["select"] in {
  def : OCLSPVBuiltin<name, [SGenTypeN, SGenTypeN, SGenTypeN, SGenTypeN], Attr.Const>;
  def : OCLSPVBuiltin<name, [SGenTypeN, SGenTypeN, SGenTypeN, UGenTypeN], Attr.Const>;
  def : OCLSPVBuiltin<name, [UGenTypeN, UGenTypeN, UGenTypeN, UGenTypeN], Attr.Const>;
  def : OCLSPVBuiltin<name, [UGenTypeN, UGenTypeN, UGenTypeN, SGenTypeN], Attr.Const>;
  def : OCLSPVBuiltin<name, [GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar, GenTypeUIntVecAndScalar], Attr.Const>;
  def : OCLSPVBuiltin<name, [GenTypeDoubleVecAndScalar, GenTypeDoubleVecAndScalar, GenTypeDoubleVecAndScalar, GenTypeULongVecAndScalar], Attr.Const>;
  def : OCLSPVBuiltin<name, [GenTypeHalfVecAndScalar, GenTypeHalfVecAndScalar, GenTypeHalfVecAndScalar, GenTypeUShortVecAndScalar], Attr.Const>;
  def : OCLSPVBuiltin<name, [GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar, GenTypeIntVecAndScalar], Attr.Const>;
  def : OCLSPVBuiltin<name, [GenTypeDoubleVecAndScalar, GenTypeDoubleVecAndScalar, GenTypeDoubleVecAndScalar, GenTypeLongVecAndScalar], Attr.Const>;
  def : OCLSPVBuiltin<name, [GenTypeHalfVecAndScalar, GenTypeHalfVecAndScalar, GenTypeHalfVecAndScalar, GenTypeShortVecAndScalar], Attr.Const>;
}

// 2.6. Vector Data Load and Store instructions

foreach VSize = [2, 3, 4, 8, 16] in {
  foreach AS = [GlobalAS, LocalAS, PrivateAS, ConstantAS, GenericAS] in {
    foreach Ty = TLAll.List in {
      foreach name = ["vloadn"] in {
        def : OCLSPVBuiltin<name # "_R" # Ty.Name # VSize, [VectorType<Ty, VSize>, Size, PointerType<ConstType<Ty>, AS>]>;
      }
    }
    foreach name = ["vloada_halfn", "vload_halfn"] in {
      def : OCLSPVBuiltin<name, [VectorType<Float, VSize>, Size, PointerType<ConstType<Half>, AS>]>;
    }
  }
  foreach AS = [GlobalAS, LocalAS, PrivateAS, GenericAS] in {
    foreach Ty = TLAll.List in {
      foreach name = ["vstoren"] in {
        def : OCLSPVBuiltin<name, [Void, VectorType<Ty, VSize>, Size, PointerType<ConstType<Ty>, AS>]>;
      }
    }
    foreach rnd = ["", "_rte", "_rtz", "_rtp", "_rtn"] in {
      foreach name = ["vstore_halfn" # rnd, "vstorea_halfn" # rnd] in {
        def : OCLSPVBuiltin<name, [Void, VectorType<Float, VSize>, Size, PointerType<Half, AS>]>;
        def : OCLSPVBuiltin<name, [Void, VectorType<Double, VSize>, Size, PointerType<Half, AS>]>;
      }
    }
  }
}

foreach AS = [GlobalAS, LocalAS, PrivateAS, ConstantAS, GenericAS] in {
  foreach name = ["vload_half"] in {
    def : OCLSPVBuiltin<name, [Float, Size, PointerType<ConstType<Half>, AS>]>;
  }
}

foreach AS = [GlobalAS, LocalAS, PrivateAS, GenericAS] in {
  foreach rnd = ["", "_rte", "_rtz", "_rtp", "_rtn"] in {
    foreach name = ["vstore_half" # rnd] in {
      def : OCLSPVBuiltin<name, [Void, Float, Size, PointerType<Half, AS>]>;
      def : OCLSPVBuiltin<name, [Void, Double, Size, PointerType<Half, AS>]>;
    }
  }
}

// 2.7. Miscellaneous Vector instructions

foreach VSize1 = [Vec2, Vec4, Vec8, Vec16] in {
  foreach VSize2 = [Vec2, Vec4, Vec8, Vec16] in {
    def : OCLSPVBuiltin<"shuffle", [GenericType<"TLAll" # VSize1.Name, TLAll, VSize1>,
                              GenericType<"TLAll" # VSize2.Name, TLAll, VSize2>,
                              GenericType<"TLAllUnsigned" # VSize1.Name, TLAllUnsigned, VSize1>],
                  Attr.Const>;
  }
}
foreach VSize1 = [Vec2, Vec4, Vec8, Vec16] in {
  foreach VSize2 = [Vec2, Vec4, Vec8, Vec16] in {
    def : OCLSPVBuiltin<"shuffle2", [GenericType<"TLAll" # VSize1.Name, TLAll, VSize1>,
                               GenericType<"TLAll" # VSize2.Name, TLAll, VSize2>,
                               GenericType<"TLAll" # VSize2.Name, TLAll, VSize2>,
                               GenericType<"TLAllUnsigned" # VSize1.Name, TLAllUnsigned, VSize1>],
                  Attr.Const>;
  }
}

// 2.8. Misc instructions

let IsVariadic = 1 in {
  foreach name = ["printf"] in {
    def : OCLSPVBuiltin<name, [Int, PointerType<ConstType<TrueChar>, ConstantAS>]>;
  }
}

foreach name = ["prefetch"] in {
  def : OCLSPVBuiltin<name, [Void, PointerType<ConstType<AGenTypeN>, GlobalAS>, Size]>;
}


// Core builtins

// 3.32.8. Memory Instructions

// foreach name = ["ImageTexelPointer"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

foreach name = ["GenericPtrMemSemantics"] in {
  def : SPVBuiltin<name, [Int, PointerType<ConstType<Int>, GenericAS>]>;
}

// 3.32.10. Image Instructions

// foreach name = ["SampledImage"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }
// foreach name = ["ImageSampleExplicitLod"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }
// foreach name = ["ImageFetch"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }
// foreach name = ["ImageRead"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }
// foreach name = ["ImageWrite"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }
// foreach name = ["Image"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }
// foreach name = ["ImageQueryFormat"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }
// foreach name = ["ImageQueryOrder"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }
// foreach name = ["ImageQuerySizeLod"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }
// foreach name = ["ImageQuerySize"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }
// foreach name = ["ImageQueryLevels"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }
// foreach name = ["ImageQuerySamples"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// 3.32.11. Conversion Instructions

foreach IType = [UChar, UShort, UInt, ULong] in {
  foreach FType = [Float, Double, Half] in {
    def : SPVBuiltin<"ConvertFToU_R" # IType.Name, [IType, FType], Attr.Const>;
    def : SPVBuiltin<"ConvertUToF_R" # FType.Name, [FType, IType], Attr.Const>;
    foreach v = [2, 3, 4, 8, 16] in {
      def : SPVBuiltin<"ConvertFToU_R" # IType.Name # v,
                       [VectorType<IType, v>, VectorType<FType, v>],
                       Attr.Const>;
      def : SPVBuiltin<"ConvertUToF_R" # FType.Name # v,
                       [VectorType<FType, v>, VectorType<IType, v>],
                       Attr.Const>;
    }
  }
}

foreach IType = [Char, Short, Int, Long] in {
  foreach FType = [Float, Double, Half] in {
    def : SPVBuiltin<"ConvertFToS_R" # IType.Name, [IType, FType], Attr.Const>;
    def : SPVBuiltin<"ConvertSToF_R" # FType.Name, [FType, IType], Attr.Const>;
    foreach v = [2, 3, 4, 8, 16] in {
      def : SPVBuiltin<"ConvertFToS_R" # IType.Name # v,
                       [VectorType<IType, v>, VectorType<FType, v>],
                       Attr.Const>;
      def : SPVBuiltin<"ConvertSToF_R" # FType.Name # v,
                       [VectorType<FType, v>, VectorType<IType, v>],
                       Attr.Const>;
    }
  }
}

foreach InType = TLAll.List in {
  foreach OutType = TLUnsignedInts.List in {
    if !ne(OutType.ElementSize, InType.ElementSize) then {
      def : SPVBuiltin<"UConvert_R" # OutType.Name, [OutType, InType], Attr.Const>;
      foreach v = [2, 3, 4, 8, 16] in {
        def : SPVBuiltin<"UConvert_R" # OutType.Name # v,
                         [VectorType<OutType, v>, VectorType<InType, v>],
                         Attr.Const>;
      }
    }
  }
  foreach OutType = TLSignedInts.List in {
    if !ne(OutType.ElementSize, InType.ElementSize) then {
      def : SPVBuiltin<"SConvert_R" # OutType.Name, [OutType, InType], Attr.Const>;
      foreach v = [2, 3, 4, 8, 16] in {
        def : SPVBuiltin<"SConvert_R" # OutType.Name # v,
                         [VectorType<OutType, v>, VectorType<InType, v>],
                         Attr.Const>;
      }
    }
  }
}

foreach InType = TLFloat.List in {
  foreach OutType = TLFloat.List in {
    if !ne(OutType.ElementSize, InType.ElementSize) then {
      def : SPVBuiltin<"FConvert_R" # OutType.Name, [OutType, InType], Attr.Const>;
      foreach v = [2, 3, 4, 8, 16] in {
        def : SPVBuiltin<"FConvert_R" # OutType.Name # v,
                         [VectorType<OutType, v>, VectorType<InType, v>],
                         Attr.Const>;
      }
    }
  }
}

foreach InType = TLSignedInts.List in {
  foreach OutType = TLUnsignedInts.List in {
    def : SPVBuiltin<"SatConvertSToU_R" # OutType.Name, [OutType, InType], Attr.Const>;
    foreach v = [2, 3, 4, 8, 16] in {
      def : SPVBuiltin<"SatConvertSToU_R" # OutType.Name # v,
                       [VectorType<OutType, v>, VectorType<InType, v>],
                       Attr.Const>;
    }
  }
}

foreach InType = TLUnsignedInts.List in {
  foreach OutType = TLSignedInts.List in {
    def : SPVBuiltin<"SatConvertUToS_R" # OutType.Name, [OutType, InType], Attr.Const>;
    foreach v = [2, 3, 4, 8, 16] in {
      def : SPVBuiltin<"SatConvertUToS_R" # OutType.Name # v,
                       [VectorType<OutType, v>, VectorType<InType, v>],
                       Attr.Const>;
    }
  }
}

foreach AS = [GlobalAS, LocalAS, PrivateAS] in {
  def : SPVBuiltin<"GenericCastToPtrExplicit", [PointerType<Char, AS>, PointerType<Char, GenericAS>]>;
}

foreach Type = TLFloat.List in {
  foreach v = [2, 3, 4, 8, 16] in {
    def : SPVBuiltin<"VectorTimesScalar", [VectorType<Type, v>, VectorType<Type, v>, Type]>;
  }
}

foreach name = ["Dot"] in {
  def : SPVBuiltin<name, [Float, GenTypeFloatVecNoScalar, GenTypeFloatVecNoScalar], Attr.Const>;
  def : SPVBuiltin<name, [Double, GenTypeDoubleVecNoScalar, GenTypeDoubleVecNoScalar], Attr.Const>;
  def : SPVBuiltin<name, [Half, GenTypeHalfVecNoScalar, GenTypeHalfVecNoScalar], Attr.Const>;
}

// foreach name = ["IAddCarry"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["ISubBorrow"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["UMulExtended"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SMulExtended"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

foreach name = ["Any", "All"] in {
  def : SPVBuiltin<name, [Bool, GenTypeBoolVecAndScalar], Attr.Const>;
}

foreach name = ["IsNan", "IsInf", "IsFinite", "IsNormal", "SignBitSet"] in {
  def : SPVBuiltin<name, [GenTypeBoolVecAndScalar, GenTypeFloatVecAndScalar], Attr.Const>;
  def : SPVBuiltin<name, [GenTypeBoolVecAndScalar, GenTypeDoubleVecAndScalar], Attr.Const>;
  def : SPVBuiltin<name, [GenTypeBoolVecAndScalar, GenTypeHalfVecAndScalar], Attr.Const>;
}

foreach name = ["LessOrGreater", "Ordered", "Unordered", "FOrdEqual", "FUnordEqual", "FOrdNotEqual", "FUnordNotEqual", "FOrdLessThan", "FUnordLessThan", "FOrdGreaterThan", "FUnordGreaterThan", "FOrdLessThanEqual", "FUnordLessThanEqual", "FOrdGreaterThanEqual", "FUnordGreaterThanEqual"] in {
  def : SPVBuiltin<name, [GenTypeBoolVecAndScalar, GenTypeFloatVecAndScalar, GenTypeFloatVecAndScalar], Attr.Const>;
  def : SPVBuiltin<name, [GenTypeBoolVecAndScalar, GenTypeDoubleVecAndScalar, GenTypeDoubleVecAndScalar], Attr.Const>;
  def : SPVBuiltin<name, [GenTypeBoolVecAndScalar, GenTypeHalfVecAndScalar, GenTypeHalfVecAndScalar], Attr.Const>;
}

foreach name = ["BitCount"] in {
  def : SPVBuiltin<name, [AIGenTypeN, AIGenTypeN], Attr.Const>;
}

// 3.32.20. Barrier Instructions

foreach name = ["ControlBarrier"] in {
  // FIXME: Add enum flags instead of UInt
  def : SPVBuiltin<name, [Void, UInt, UInt, UInt]>;
}

foreach name = ["MemoryBarrier"] in {
  // FIXME: Add enum flags instead of UInt
  def : SPVBuiltin<name, [Void, UInt, UInt]>;
}

// 3.32.18. Atomic Instructions

// OpenCL validation rules:
// The Pointer operand must be a pointer to
// the Function, Workgroup, or CrossWorkGroup Storage Classes.
// Note that an Atomic Instruction on a pointer to the Function Storage Class is valid,
// but does not have defined behavior.
foreach AS = [GlobalAS, LocalAS, PrivateAS] in {
  foreach Type = [Int, UInt, Long, ULong] in {
    foreach name = ["AtomicLoad", "AtomicIIncrement", "AtomicIDecrement"] in {
      def : SPVBuiltin<name, [Type, PointerType<ConstType<VolatileType<Type>>, AS>, UInt, UInt]>;
      def : SPVBuiltin<name, [Type, PointerType<ConstType<Type>, AS>, UInt, UInt]>;
    }

    foreach name = ["AtomicStore"] in {
      def : SPVBuiltin<name, [Void, PointerType<VolatileType<Type>, AS>, UInt, UInt, Type]>;
      def : SPVBuiltin<name, [Void, PointerType<Type, AS>, UInt, UInt, Type]>;
    }

    foreach name = ["AtomicExchange", "AtomicIAdd", "AtomicISub",
                    "AtomicAnd", "AtomicOr", "AtomicXor"] in {
      def : SPVBuiltin<name, [Type, PointerType<VolatileType<Type>, AS>, UInt, UInt, Type]>;
      def : SPVBuiltin<name, [Type, PointerType<Type, AS>, UInt, UInt, Type]>;
    }

    foreach name = ["AtomicCompareExchange"] in {
      def : SPVBuiltin<name, [Type, PointerType<VolatileType<Type>, AS>, UInt, UInt, UInt, Type, Type]>;
      def : SPVBuiltin<name, [Type, PointerType<Type, AS>, UInt, UInt, UInt, Type, Type]>;
    }
  }

  foreach Type = [Int, Long] in {
    foreach name = ["AtomicSMin", "AtomicSMax"] in {
      def : SPVBuiltin<name, [Type, PointerType<VolatileType<Type>, AS>, UInt, UInt, Type]>;
      def : SPVBuiltin<name, [Type, PointerType<Type, AS>, UInt, UInt, Type]>;
    }
  }

  foreach Type = [UInt, ULong] in {
    foreach name = ["AtomicUMin", "AtomicUMax"] in {
      def : SPVBuiltin<name, [Type, PointerType<VolatileType<Type>, AS>, UInt, UInt, Type]>;
      def : SPVBuiltin<name, [Type, PointerType<Type, AS>, UInt, UInt, Type]>;
    }
  }

  foreach Type = [Int, UInt] in {
    foreach name = ["AtomicFlagTestAndSet"] in {
      def : SPVBuiltin<name, [Type, PointerType<ConstType<VolatileType<Type>>, AS>, UInt, UInt]>;
      def : SPVBuiltin<name, [Type, PointerType<ConstType<Type>, AS>, UInt, UInt]>;
    }

    foreach name = ["AtomicFlagClear"] in {
      def : SPVBuiltin<name, [Void, PointerType<ConstType<VolatileType<Type>>, AS>, UInt, UInt]>;
      def : SPVBuiltin<name, [Void, PointerType<ConstType<Type>, AS>, UInt, UInt]>;
    }
  }
}

// 3.32.21. Group and Subgroup Instructions

foreach name = ["GroupAsyncCopy"] in {
  // FIXME: Add enum flags instead of UInt
  def : SPVBuiltin<name, [Event, UInt, PointerType<AGenTypeN, LocalAS>, PointerType<ConstType<AGenTypeN>, GlobalAS>, Size, Size, Event], Attr.Convergent>;
  def : SPVBuiltin<name, [Event, UInt, PointerType<AGenTypeN, GlobalAS>, PointerType<ConstType<AGenTypeN>, LocalAS>, Size, Size, Event], Attr.Convergent>;
}

foreach name = ["GroupWaitEvents"] in {
  def : SPVBuiltin<name, [Void, UInt, Int, PointerType<Event, PrivateAS>], Attr.Convergent>;
  def : SPVBuiltin<name, [Void, UInt, Int, PointerType<Event, GenericAS>], Attr.Convergent>;
}

foreach name = ["GroupAll", "GroupAny"] in {
  def : SPVBuiltin<name, [Char, UInt, Char], Attr.Convergent>;
}

foreach name = ["GroupBroadcast"] in {
  foreach IDType = TLAllInts.List in {
    def : SPVBuiltin<name, [AGenType1, UInt, AGenType1, IDType], Attr.Convergent>;
    def : SPVBuiltin<name, [AGenType1, UInt, AGenType1, VectorType<IDType, 2>], Attr.Convergent>;
    def : SPVBuiltin<name, [AGenType1, UInt, AGenType1, VectorType<IDType, 3>], Attr.Convergent>;
    def : SPVBuiltin<name, [Bool, UInt, Bool, IDType], Attr.Convergent>;
    def : SPVBuiltin<name, [Bool, UInt, Bool, VectorType<IDType, 2>], Attr.Convergent>;
    def : SPVBuiltin<name, [Bool, UInt, Bool, VectorType<IDType, 3>], Attr.Convergent>;
  }
}

foreach name = ["GroupIAdd"] in {
  def : SPVBuiltin<name, [AIGenTypeN, UInt, UInt, AIGenTypeN], Attr.Convergent>;
}

foreach name = ["GroupFAdd", "GroupFMin", "GroupFMax"] in {
  def : SPVBuiltin<name, [FGenTypeN, UInt, UInt, FGenTypeN], Attr.Convergent>;
}

foreach name = ["GroupUMin", "GroupUMax"] in {
  def : SPVBuiltin<name, [AUIGenTypeN, UInt, UInt, AUIGenTypeN], Attr.Convergent>;
}

foreach name = ["GroupSMin", "GroupSMax"] in {
  def : SPVBuiltin<name, [ASIGenTypeN, UInt, UInt, ASIGenTypeN], Attr.Convergent>;
}

// 3.32.23. Pipe Instructions

// foreach name = ["ReadPipe"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["WritePipe"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["ReservedReadPipe"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["ReservedWritePipe"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["ReserveReadPipePackets"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["ReserveWritePipePackets"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["CommitReadPipe"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["CommitWritePipe"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["IsValidReserveId"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["GetNumPipePackets"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["GetMaxPipePackets"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["GroupReserveReadPipePackets"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["GroupReserveWritePipePackets"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["GroupCommitReadPipe"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["GroupCommitWritePipe"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// 3.32.22. Device-Side Enqueue Instructions

// foreach name = ["EnqueueMarker"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["EnqueueKernel"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY, TY, TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["GetKernelNDrangeSubGroupCount"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["GetKernelNDrangeMaxSubGroupSize"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["GetKernelWorkGroupSize"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["GetKernelPreferredWorkGroupSizeMultiple"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["RetainEvent"] in {
//   def : SPVBuiltin<name, [TY]>;
// }

// foreach name = ["ReleaseEvent"] in {
//   def : SPVBuiltin<name, [TY]>;
// }

// foreach name = ["CreateUserEvent"] in {
//   def : SPVBuiltin<name, [TY, TY]>;
// }

// foreach name = ["IsValidEvent"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SetUserEventStatus"] in {
//   def : SPVBuiltin<name, [TY, TY]>;
// }

// foreach name = ["CaptureEventProfilingInfo"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["GetDefaultQueue"] in {
//   def : SPVBuiltin<name, [TY, TY]>;
// }

// foreach name = ["BuildNDRange"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }


// foreach name = ["ConstantPipeStorage"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["CreatePipeFromPipeStorage"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["GetKernelLocalSizeForSubgroupCount"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["GetKernelMaxNumSubgroups"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["NamedBarrierInitialize"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["MemoryNamedBarrier"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupBallotKHR"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupFirstInvocationKHR"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAllKHR"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAnyKHR"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAllEqualKHR"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupReadInvocationKHR"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["GroupIAddNonUniformAMD"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["GroupFAddNonUniformAMD"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["GroupFMinNonUniformAMD"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["GroupUMinNonUniformAMD"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["GroupSMinNonUniformAMD"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["GroupFMaxNonUniformAMD"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["GroupUMaxNonUniformAMD"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["GroupSMaxNonUniformAMD"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["FragmentMaskFetchAMD"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["FragmentFetchAMD"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["ReadClockKHR"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["ImageSampleFootprintNV"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["GroupNonUniformPartitionNV"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["WritePackedPrimitiveIndices4x8NV"] in {
//   def : SPVBuiltin<name, [TY, TY]>;
// }

// foreach name = ["ReportIntersectionNV"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["IgnoreIntersectionNV"] in {
//   def : SPVBuiltin<name, []>;
// }

// foreach name = ["TerminateRayNV"] in {
//   def : SPVBuiltin<name, []>;
// }

// foreach name = ["TraceNV"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["TypeAccelerationStructureNV"] in {
//   def : SPVBuiltin<name, [TY]>;
// }

// foreach name = ["ExecuteCallableNV"] in {
//   def : SPVBuiltin<name, [TY, TY]>;
// }

// foreach name = ["TypeCooperativeMatrixNV"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["CooperativeMatrixLoadNV"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["CooperativeMatrixStoreNV"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["CooperativeMatrixMulAddNV"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["CooperativeMatrixLengthNV"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["BeginInvocationInterlockEXT"] in {
//   def : SPVBuiltin<name, []>;
// }

// foreach name = ["EndInvocationInterlockEXT"] in {
//   def : SPVBuiltin<name, []>;
// }

// foreach name = ["DemoteToHelperInvocationEXT"] in {
//   def : SPVBuiltin<name, []>;
// }

// foreach name = ["IsHelperInvocationEXT"] in {
//   def : SPVBuiltin<name, [TY, TY]>;
// }

// foreach name = ["SubgroupShuffleINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupShuffleDownINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupShuffleUpINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupShuffleXorINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupBlockReadINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupBlockWriteINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY]>;
// }

// foreach name = ["SubgroupImageBlockReadINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupImageBlockWriteINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupImageMediaBlockReadINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupImageMediaBlockWriteINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["UCountLeadingZerosINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["UCountTrailingZerosINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["AbsISubINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["AbsUSubINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["IAddSatINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["UAddSatINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["IAverageINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["UAverageINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["IAverageRoundedINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["UAverageRoundedINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["ISubSatINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["USubSatINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["IMul32x16INTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["UMul32x16INTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["VmeImageINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["TypeVmeImageINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY]>;
// }

// foreach name = ["TypeAvcImePayloadINTEL"] in {
//   def : SPVBuiltin<name, [TY]>;
// }

// foreach name = ["TypeAvcRefPayloadINTEL"] in {
//   def : SPVBuiltin<name, [TY]>;
// }

// foreach name = ["TypeAvcSicPayloadINTEL"] in {
//   def : SPVBuiltin<name, [TY]>;
// }

// foreach name = ["TypeAvcMcePayloadINTEL"] in {
//   def : SPVBuiltin<name, [TY]>;
// }

// foreach name = ["TypeAvcMceResultINTEL"] in {
//   def : SPVBuiltin<name, [TY]>;
// }

// foreach name = ["TypeAvcImeResultINTEL"] in {
//   def : SPVBuiltin<name, [TY]>;
// }

// foreach name = ["TypeAvcImeResultSingleReferenceStreamoutINTEL"] in {
//   def : SPVBuiltin<name, [TY]>;
// }

// foreach name = ["TypeAvcImeResultDualReferenceStreamoutINTEL"] in {
//   def : SPVBuiltin<name, [TY]>;
// }

// foreach name = ["TypeAvcImeSingleReferenceStreaminINTEL"] in {
//   def : SPVBuiltin<name, [TY]>;
// }

// foreach name = ["TypeAvcImeDualReferenceStreaminINTEL"] in {
//   def : SPVBuiltin<name, [TY]>;
// }

// foreach name = ["TypeAvcRefResultINTEL"] in {
//   def : SPVBuiltin<name, [TY]>;
// }

// foreach name = ["TypeAvcSicResultINTEL"] in {
//   def : SPVBuiltin<name, [TY]>;
// }

// foreach name = ["SubgroupAvcMceGetDefaultInterBaseMultiReferencePenaltyINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceSetInterBaseMultiReferencePenaltyINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceGetDefaultInterShapePenaltyINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceSetInterShapePenaltyINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceGetDefaultInterDirectionPenaltyINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceSetInterDirectionPenaltyINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceGetDefaultIntraLumaShapePenaltyINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceGetDefaultInterMotionVectorCostTableINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceGetDefaultHighPenaltyCostTableINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceGetDefaultMediumPenaltyCostTableINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceGetDefaultLowPenaltyCostTableINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceSetMotionVectorCostFunctionINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceGetDefaultIntraLumaModePenaltyINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceGetDefaultNonDcLumaIntraPenaltyINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceGetDefaultIntraChromaModeBasePenaltyINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceSetAcOnlyHaarINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceSetSourceInterlacedFieldPolarityINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceSetSingleReferenceInterlacedFieldPolarityINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceSetDualReferenceInterlacedFieldPolaritiesINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceConvertToImePayloadINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceConvertToImeResultINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceConvertToRefPayloadINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceConvertToRefResultINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceConvertToSicPayloadINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceConvertToSicResultINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceGetMotionVectorsINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceGetInterDistortionsINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceGetBestInterDistortionsINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceGetInterMajorShapeINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceGetInterMinorShapeINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceGetInterDirectionsINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceGetInterMotionVectorCountINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceGetInterReferenceIdsINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcMceGetInterReferenceInterlacedFieldPolaritiesINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeInitializeINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeSetSingleReferenceINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeSetDualReferenceINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeRefWindowSizeINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeAdjustRefOffsetINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeConvertToMcePayloadINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeSetMaxMotionVectorCountINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeSetUnidirectionalMixDisableINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeSetEarlySearchTerminationThresholdINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeSetWeightedSadINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeEvaluateWithSingleReferenceINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeEvaluateWithDualReferenceINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeEvaluateWithSingleReferenceStreaminINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeEvaluateWithDualReferenceStreaminINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeEvaluateWithSingleReferenceStreamoutINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeEvaluateWithDualReferenceStreamoutINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeEvaluateWithSingleReferenceStreaminoutINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeEvaluateWithDualReferenceStreaminoutINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeConvertToMceResultINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeGetSingleReferenceStreaminINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeGetDualReferenceStreaminINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeStripSingleReferenceStreamoutINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeStripDualReferenceStreamoutINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeGetStreamoutSingleReferenceMajorShapeMotionVectorsINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeGetStreamoutSingleReferenceMajorShapeDistortionsINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeGetStreamoutSingleReferenceMajorShapeReferenceIdsINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeGetStreamoutDualReferenceMajorShapeMotionVectorsINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeGetStreamoutDualReferenceMajorShapeDistortionsINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeGetStreamoutDualReferenceMajorShapeReferenceIdsINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeGetBorderReachedINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeGetTruncatedSearchIndicationINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeGetUnidirectionalEarlySearchTerminationINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeGetWeightingPatternMinimumMotionVectorINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcImeGetWeightingPatternMinimumDistortionINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcFmeInitializeINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcBmeInitializeINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcRefConvertToMcePayloadINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcRefSetBidirectionalMixDisableINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcRefSetBilinearFilterEnableINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcRefEvaluateWithSingleReferenceINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcRefEvaluateWithDualReferenceINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcRefEvaluateWithMultiReferenceINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcRefEvaluateWithMultiReferenceInterlacedINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcRefConvertToMceResultINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicInitializeINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicConfigureSkcINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicConfigureIpeLumaINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicConfigureIpeLumaChromaINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY, TY, TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicGetMotionVectorMaskINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicConvertToMcePayloadINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicSetIntraLumaShapePenaltyINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicSetIntraLumaModeCostFunctionINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicSetIntraChromaModeCostFunctionINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicSetBilinearFilterEnableINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicSetSkcForwardTransformEnableINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicSetBlockBasedRawSkipSadINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicEvaluateIpeINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicEvaluateWithSingleReferenceINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicEvaluateWithDualReferenceINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicEvaluateWithMultiReferenceINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicEvaluateWithMultiReferenceInterlacedINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY, TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicConvertToMceResultINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicGetIpeLumaShapeINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicGetBestIpeLumaDistortionINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicGetBestIpeChromaDistortionINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicGetPackedIpeLumaModesINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicGetIpeChromaModeINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicGetPackedSkcLumaCountThresholdINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicGetPackedSkcLumaSumThresholdINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// foreach name = ["SubgroupAvcSicGetInterRawSadsINTEL"] in {
//   def : SPVBuiltin<name, [TY, TY, TY]>;
// }

// FIXME
def : Builtin<"get_work_dim", [UInt], Attr.Const>;
foreach name = ["get_global_size", "get_global_id", "get_local_size",
                "get_local_id", "get_num_groups", "get_group_id",
                "get_global_offset"] in {
  def : Builtin<name, [Size, UInt], Attr.Const>;
}

let MinVersion = CL20 in {
  def : Builtin<"get_enqueued_local_size", [Size, UInt]>;
  foreach name = ["get_global_linear_id", "get_local_linear_id"] in {
    def : Builtin<name, [Size]>;
  }
}
