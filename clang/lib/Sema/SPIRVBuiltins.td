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
// FIXME: this should really be clang::LangAS::opencl_*
// There is an implicit switch with -fsycl-is-device to
// make opencl_* attributes fallback to clang::LangAS::sycl_*
def DefaultAS    : AddressSpace<"clang::LangAS::Default">;
def PrivateAS    : AddressSpace<"clang::LangAS::sycl_private">;
def GlobalAS     : AddressSpace<"clang::LangAS::sycl_global">;
def ConstantAS   : AddressSpace<"clang::LangAS::sycl_constant">;
def LocalAS      : AddressSpace<"clang::LangAS::sycl_local">;
def GenericAS    : AddressSpace<"clang::LangAS::sycl_generic">;

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
def Char      : IntType<"char",      QualType<"CharTy", 0, 1>, 8>;
def UChar     : UIntType<"uchar",     QualType<"UnsignedCharTy">, 8>;
def Short     : IntType<"short",     QualType<"ShortTy", 0, 1>, 16>;
def UShort    : UIntType<"ushort",    QualType<"UnsignedShortTy">, 16>;
def Int       : IntType<"int",       QualType<"IntTy", 0, 1>, 32>;
def UInt      : UIntType<"uint",      QualType<"UnsignedIntTy">, 32>;
def Long      : IntType<"long",      QualType<"LongTy", 0, 1>, 64>;
def ULong     : UIntType<"ulong",     QualType<"UnsignedLongTy">, 64>;
def Float     : FPType<"float",     QualType<"FloatTy">, 32>;
def Double    : FPType<"double",    QualType<"DoubleTy">, 64>;
def Half      : FPType<"half",      QualType<"HalfTy">, 16>;
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
def TLSignedInts    : TypeList<[Char, Short, Int, Long]>;
def TLUnsignedInts  : TypeList<[UChar, UShort, UInt, ULong]>;

def TLIntLongFloats : TypeList<[Int, UInt, Long, ULong, Float, Double, Half]>;

// All unsigned integer types twice, to facilitate unsigned return types for e.g.
// uchar abs(char) and
// uchar abs(uchar).
def TLAllUIntsTwice : TypeList<[UChar, UChar, UShort, UShort, UInt, UInt, ULong, ULong]>;
def TLAllSToUIntsTwice : TypeList<[UChar, Char, UShort, Short, UInt, Int, ULong, Long]>;

def TLAllUInts       : TypeList<[UChar, UShort, UInt, ULong]>;
def TLAllSInts       : TypeList<[Char, Short, Int, Long]>;
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
def AUIGenTypeN             : GenericType<"AUIGenTypeN", TLAllUInts, VecAndScalar>;
def ASIGenTypeN             : GenericType<"ASIGenTypeN", TLAllSInts, VecAndScalar>;
def AIGenTypeNNoScalar     : GenericType<"AIGenTypeNNoScalar", TLAllInts, VecNoScalar>;
// All integer to unsigned
def AI2UGenTypeN           : GenericType<"AI2UGenTypeN", TLAllUIntsTwice, VecAndScalar>;
// All signed integer to unsigned
def AS2UGenTypeN           : GenericType<"AS2UGenTypeN", TLAllSToUIntsTwice, VecAndScalar>;
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
foreach Type = [Char, UChar, Short, UShort,
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

foreach name = ["GroupAsyncCopy"] in {
// FIXME: Add enum flags instead of UInt
  def : SPVBuiltin<name, [Event, UInt, PointerType<AGenTypeN, LocalAS>, PointerType<ConstType<AGenTypeN>, GlobalAS>, Size, Size, Event], Attr.Convergent>;
  def : SPVBuiltin<name, [Event, UInt, PointerType<AGenTypeN, GlobalAS>, PointerType<ConstType<AGenTypeN>, LocalAS>, Size, Size, Event], Attr.Convergent>;
}
