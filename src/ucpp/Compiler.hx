package ucpp;

#if macro

import sys.FileSystem;

/**
	A macro-only class used for advanced compiler configurations
	for the Haxe to Unbound C++ library. The functions of this
	class should be called using --macro.

	For example, additional C++ files can be included in the
	output.
**/
class Compiler {
	static var extraCppDirectories: Array<{ path: String, recursive: Bool }> = [];
	static var extraHeaderFiles: Array<String> = [];
	static var extraSourceFiles: Array<String> = [];

	/**
		Adds a directory to be scanned for C++ source files that
		will be copied to the output folders.

		`.h` and `.hpp` files will be copied to the "include" output
		folder. `.cpp`, `.c`, and `.cc` files will be copied to the
		"src" output folder. All other files will be ignored.
	**/
	public static function addCppDirectory(dirPath: String, recursive: Bool = true) {
		extraCppDirectories.push({ path: dirPath, recursive: recursive });
	}

	/**
		Adds a local file to be copied to the "include" output folder.
	**/
	public static function addHeader(filePath: String) {
		addFile(extraHeaderFiles, filePath);
	}

	/**
		Adds a local file to be copied to the "src" output folder.
	**/
	public static function addCppFile(filePath: String) {
		addFile(extraSourceFiles, filePath);
	}

	static function addFile(files: Array<String>, file: String) {
		final filePath = findFile(file);
		if(filePath != null) {
			files.push(filePath);
		} else {
			throw "Could not find file: `" + file + "`.";
		}
	}

	static function findFile(path: String, pos: Null<haxe.PosInfos> = null): Null<String> {
		return FileSystem.exists(path) ? path : null;
	}

	/**
		Returns an array of file paths for every file that has been
		registered to be copied to the output folders.

		Upon calling this function, all the directories provided to
		`addCppDirectory` will be scanned. The discovered C++
		files will be merged with the list of files provided to
		`addHeader` and `addCppFile` to generate the list returned
		by this function.

		The structures within the array store two fields:
			`path` The path to the file.
			`includeFolder` If `true`, coped to "include"; if `false`, "src".
	**/
	public static function findAllExtraFiles(): Array<{ path: String, includeFolder: Bool }> {
		// Used to parse directories for C++ source files.
		function getFiles(dir: String, recursive: Bool): Array<{ path: String, includeFolder: Bool }> {
			final result = [];
			for(file in sys.FileSystem.readDirectory(dir)) {
				final filePath = haxe.io.Path.join([dir, file]);
				if(recursive && sys.FileSystem.isDirectory(file)) {
					for(f in getFiles(filePath, true)) {
						result.push(f);
					}
				} else {
					final path = new haxe.io.Path(file);
					if(path.ext == "h" || path.ext == "hpp") {
						result.push({ path: filePath, includeFolder: true });
					} else if(path.ext == "c" || path.ext == "cpp" || path.ext == "cc") {
						result.push({ path: filePath, includeFolder: false });
					}
				}
			}
			return result;
		}

		// Collect all the files
		final result = [];

		for(f in extraHeaderFiles) {
			result.push({ path: f, includeFolder: true });
		}

		for(f in extraSourceFiles) {
			result.push({ path: f, includeFolder: true });
		}

		for(dir in extraCppDirectories) {
			for(f in getFiles(dir.path, dir.recursive)) {
				result.push(f);
			}
		}

		return result;
	}
}

#end
