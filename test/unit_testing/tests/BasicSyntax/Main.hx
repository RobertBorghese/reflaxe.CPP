package;

import haxe.PosInfos;

class Main {
	var testField = 123;

	public function new() {
		assert(testField == 123);
	}

	static var returnCode = 0;
	static function assert(b: Bool, infos: Null<PosInfos> = null) {
		if(!b) {
			haxe.Log.trace("Assert failed", infos);
			returnCode = 1;
		}
	}

	@:topLevel
	@:dce(Off)
	public static function main(): Int {
		// arithmetic
		assert(true);
		assert(!false);
		assert(1 + 1 == 2);
		assert(1 - 1 == 0);
		assert(2 * 2 == 4);
		assert(10 / 2 == 5);

		// class
		final obj = new Main();
		assert(obj == obj);
		assert(obj.testField == 123);

		// strings
		var str = "Hello";
		str = "World";
		str = "Hello, " + str;
		str += "!";
		assert(str == "Hello, World!");

		// if/else
		if(str != "Goodbye World!") {
			var num = 3;
			assert(num > 1);
			assert(num >= 3 && num >= 2);
			assert(num == 3);
			assert(num <= 3 && num <= 6);
			assert(num < 4);
		} else {
			assert(false);
		}

		// bit-wise op
		var num = 3;
		assert((num & 1) == 1);
		assert((num & 4) == 0);
		assert((num | 8) == 11);
		assert((num | 3) == 3);

		assert((1 + 1) == 1 + 1);

		// anonymous structures
		final dict = {
			hey: "Hey",
			thing: obj,
			number: 3
		};

		assert(dict.hey == "Hey");
		assert(dict.number == 3);

		// Any
		var anyTest: Any = 123;
		assert(cast(anyTest, Int) == 123);
		assert(Std.string(anyTest) == "<Any(int)>");

		// Array
		final arr = [1, 2, 3];
		assert(arr[1] == 2);
		assert(arr.length == 3);

		// C++ reserved names
		final bool = true;
		assert(!!bool);

		// Unop
		var mutNum = 1000;
		mutNum++;
		mutNum++;
		assert(mutNum++ == 1002);
		assert(--mutNum == 1002);
		assert(--mutNum == 1001);
		assert(mutNum == 1001);

		// lambda
		final myFunc = function() {
			mutNum++;
		}
		myFunc();
		myFunc();
		assert(mutNum == 1003);

		// everything is expression
		final blockVal = {
			final a = 2;
			a * a;
		}
		assert(blockVal == 4);

		// if/else
		if(blockVal == 4) {
			assert(true);
		} else {
			assert(false);
		}

		// while
		var i = 0;
		while(i++ < 1000) {
			if(i == 800) {
				assert((i / 80) == 10);
			}
		}

		var j = 0;
		while(j < {
			assert(true);
			6;
		}) {
			assert(true);
			j++;
		}

		// value from assignment
		var anotherNum = 0;
		var anotherNum2 = anotherNum = 3;
		assert(anotherNum == anotherNum2);

		anotherNum2 = anotherNum += 10;
		assert(anotherNum == anotherNum2);

		return returnCode;
	}
}