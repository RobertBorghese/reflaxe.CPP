// =======================================================
// * GCFCompiler
//
// The main compiler. Most of its behavior is split
// between "sub-compilers" in the `subcompilers` package.
// =======================================================

package gcfcompiler;

#if (macro || gcf_runtime)

import haxe.macro.Expr;
import haxe.macro.Type;

import reflaxe.BaseCompiler;

using reflaxe.helpers.ClassTypeHelper;
using reflaxe.helpers.ModuleTypeHelper;
using reflaxe.helpers.NameMetaHelper;
using reflaxe.helpers.TypeHelper;

import gcfcompiler.subcompilers.GCFSubCompiler;
import gcfcompiler.subcompilers.GCFCompiler_Classes;
import gcfcompiler.subcompilers.GCFCompiler_Enums;
import gcfcompiler.subcompilers.GCFCompiler_Anon;
import gcfcompiler.subcompilers.GCFCompiler_Exprs;
import gcfcompiler.subcompilers.GCFCompiler_Includes;
import gcfcompiler.subcompilers.GCFCompiler_Types;

class GCFCompiler extends reflaxe.BaseCompiler {
	// ----------------------------
	// The extension for the generated header files.
	static final HeaderExt: String = ".h";

	// ----------------------------
	// The extension for the generated source files.
	static final SourceExt: String = ".cpp";

	// ----------------------------
	// The C++ classes used for nullability and memory management.
	static final OptionalClassCpp: String = "std::optional";
	static final SharedPtrClassCpp: String = "std::shared_ptr";
	static final UniquePtrClassCpp: String = "std::unique_ptr";

	// ----------------------------
	// The include params used upon requiring the above C++ classes.
	static final OptionalInclude: Dynamic = ["optional", true];
	static final SharedPtrInclude: Dynamic = ["memory", true];
	static final UniquePtrInclude: Dynamic = ["memory", true];

	// ----------------------------
	// The name of the header file generated for the anonymous structs.
	static final AnonStructHeaderFile: String = "_AnonStructs";
	static final OptionalInfoHeaderFile: String = "_OptionalInfo";

	// ----------------------------
	// Required for adding semicolons at the end of each line.
	override function formatExpressionLine(expr: String): String {
		return expr + ";";
	}

	// ============================
	// * Sub-Compilers
	// ============================
	var CComp: GCFCompiler_Classes;
	var EComp: GCFCompiler_Enums;
	var AComp: GCFCompiler_Anon;
	var IComp: GCFCompiler_Includes;
	var TComp: GCFCompiler_Types;
	var XComp: GCFCompiler_Exprs;

	public function new() {
		super();
		CComp = new GCFCompiler_Classes(this);
		EComp = new GCFCompiler_Enums(this);
		AComp = new GCFCompiler_Anon(this);
		IComp = new GCFCompiler_Includes(this);
		TComp = new GCFCompiler_Types(this);
		XComp = new GCFCompiler_Exprs(this);

		function setup(c: GCFSubCompiler) c.setSubCompilers(CComp, EComp, AComp, IComp, TComp, XComp);
		setup(CComp);
		setup(EComp);
		setup(AComp);
		setup(IComp);
		setup(TComp);
		setup(XComp);
	}

	// ----------------------------
	// Called after all module types have
	// been passed to this compiler class.
	public override function onCompileEnd() {
		generateAnonStructHeader();
	}

	// ----------------------------
	public function onTypeEncountered(t: Type, addToHeader: Bool) {
		IComp.addIncludeFromType(t, addToHeader);
	}

	public function onModuleTypeEncountered(mt: ModuleType, addToHeader: Bool) {
		IComp.addIncludeFromModuleType(mt, addToHeader);
		addModuleTypeForCompilation(mt);
	}

	// ----------------------------
	function generateAnonStructHeader() {
		IComp.resetAndInitIncludes(true);
		IComp.addInclude(OptionalInclude[0], true, OptionalInclude[1]);
		final anonContent = AComp.makeAllUnnamedDecls();
		if(IComp.anonHeaderRequired || anonContent.length > 0) {
			final optionalInfoHeaderName = OptionalInfoHeaderFile + HeaderExt;

			// Generate haxe::optional_info header.
			{
				var content = "#pragma once\n\n";
				content += "#include " + IComp.wrapInclude(OptionalInclude[0], OptionalInclude[1]) + "\n\n";
				content += AComp.optionalInfoContent() + "\n\n";
				setExtraFile("include/" + optionalInfoHeaderName, content);
			}

			// Generate anonymous structures header.
			{
				var content = "#pragma once\n\n";
				content += "#include \"" + optionalInfoHeaderName + "\"\n\n";
				content += IComp.compileHeaderIncludes() + "\n\n";
				content += "namespace haxe {\n\n";
				content += anonContent;
				content += "\n}";
				setExtraFile("include/" + AnonStructHeaderFile + HeaderExt, content);
			}
		}
	}

	// ----------------------------
	// Checks if this type is the same as the
	// ModuleType that's currently being compiled.
	function isSameAsCurrentModule(t: Type): Bool {
		// If Null<T>, unwrap and check "T"
		switch(t) {
			case TAbstract(absRef, params): {
				switch(absRef.get().name) {
					case "Null" if(params.length == 1): {
						return isSameAsCurrentModule(params[0]);
					}
					case _:
				}
			}
			case _:
		}

		return getCurrentModule().equals(t.toModuleType());
	}

	// ----------------------------
	// Get the file name that would be generated
	// by default for the provided Haxe type.
	function getFileNameFromType(t: Type): Null<String> {
		final mt = t.toModuleType();
		if(mt == null) return null;
		return getFileNameFromModuleData(mt.getCommonData());
	}

	function getFileNameFromModuleData(md: CommonModuleTypeData): String {
		return md.moduleId();
	}

	// ----------------------------
	// Compile the start of all namespaces
	// for the provided module data.
	function compileNamespaceStart(md: CommonModuleTypeData): String {
		var result = "";
		for(p in md.pack) {
			result += "namespace " + p + " {\n";
		}
		if(md.pack.length > 0) result += "\n";
		return result;
	}

	// ----------------------------
	// Compile all namespace closing brackets.
	function compileNamespaceEnd(md: CommonModuleTypeData): String {
		var result = "";
		for(p in md.pack) {
			result += "\n}";
		}
		return result;
	}

	// ----------------------------
	// Compile standard function-argument syntax
	// for C++ from a TVar and TypedExpr.
	function compileFunctionArgument(arg: { v: TVar, value: Null<TypedExpr> }, pos: Position, noDefaultValue: Bool = false) {
		var result = TComp.compileType(arg.v.t, pos) + " " + compileVarName(arg.v.name);
		if(!noDefaultValue && arg.value != null) {
			result += " = " + compileExpression(arg.value);
		}
		return result;
	}

	// ----------------------------
	// Stores the super class's name so we can use
	// it when calling "super" functions.
	var superTypeName: String = "";

	// ----------------------------
	// Compiles a class into C++.
	public function compileClassImpl(classType: ClassType, varFields: ClassFieldVars, funcFields: ClassFieldFuncs): Null<String> {
		return CComp.compileClass(classType, varFields, funcFields);
	}

	// ----------------------------
	// Compiles an enum into C++.
	public function compileEnumImpl(enumType: EnumType, options: EnumOptions): Null<String> {
		return EComp.compileEnum(enumType, options);
	}

	// ----------------------------
	// Compiles an typedef into C++.
	public override function compileTypedef(defType: DefType): Null<String> {
		// Get filename for this typedef
		final filename = getFileNameFromModuleData(defType);
		final headerFilename = filename + HeaderExt;

		// Init includes
		IComp.resetAndInitIncludes(true, [headerFilename]);

		// Ignore "static" member structures
		switch(defType.type) {
			case TAnonymous(anonRef): {
				switch(anonRef.get().status) {
					case AClassStatics(_) | AEnumStatics(_) | AAbstractStatics(_): {
						return null;
					}
					case _:
				}
			}
			case _:
		}

		// Get typedef alias name
		final typedefName = defType.getNameOrNative();

		// Compile content
		var content = "";
		content += compileNamespaceStart(defType);
		switch(defType.type) {
			case TAnonymous(anonRef): {
				content += AComp.compileNamedAnonTypeDefinition(defType, anonRef);
			}
			case _: {
				content += "typedef " + TComp.compileType(defType.type, defType.pos) + " " + typedefName + ";";
			}
		}
		content += compileNamespaceEnd(defType);

		final headerFilePath = "include/" + headerFilename;

		// pragma once
		setExtraFileIfEmpty(headerFilePath, "#pragma once");

		// Compile headers
		IComp.appendIncludesToExtraFileWithoutRepeats(headerFilePath, IComp.compileHeaderIncludes(), 1);

		// Output typedef
		appendToExtraFile(headerFilePath, content + "\n", 2);

		return null;
	}

	public override function compileAbstract(ab: AbstractType): Null<String> {
		return null;
	}

	public function compileExpressionImpl(expr: TypedExpr): Null<String> {
		return XComp.compileExpressionToCpp(expr);
	}
}

#end
