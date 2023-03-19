#include "Main.h"

#include <cmath>
#include <cstdlib>
#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "_TypeUtils.h"
#include "Std.h"

BaseClass::BaseClass() {
	
}
ChildClass::ChildClass() {
	BaseClass();
}
AnotherClass::AnotherClass() {
	
}

std::string AnotherClass::toString() {
	return "another class as string";
}
ClassWInt::ClassWInt() {
	this->number = 123;
}
int Main::returnCode = 0;

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/Std/Main.hx", 29, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed" << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::assertFloat(double a, double b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(abs(a - b) >= 0.001) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/Std/Main.hx", 36, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed" << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::main() {
	std::shared_ptr<BaseClass> base = std::make_shared<BaseClass>();
	std::shared_ptr<ChildClass> child = std::make_shared<ChildClass>();
	std::shared_ptr<AnotherClass> another = std::make_shared<AnotherClass>();
	
	Main::assert(StdImpl::isOfType<std::shared_ptr<ChildClass>, haxe::_class<ChildClass>>(child, haxe::_class<ChildClass>()), haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 47, "main"));
	Main::assert(StdImpl::isOfType<std::shared_ptr<ChildClass>, haxe::_class<BaseClass>>(child, haxe::_class<BaseClass>()), haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 48, "main"));
	Main::assert(!StdImpl::isOfType<std::shared_ptr<ChildClass>, haxe::_class<AnotherClass>>(child, haxe::_class<AnotherClass>()), haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 49, "main"));
	Main::assert(!StdImpl::isOfType<std::shared_ptr<AnotherClass>, haxe::_class<ChildClass>>(another, haxe::_class<ChildClass>()), haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 51, "main"));
	Main::assert(!StdImpl::isOfType<std::shared_ptr<AnotherClass>, haxe::_class<BaseClass>>(another, haxe::_class<BaseClass>()), haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 52, "main"));
	Main::assert(StdImpl::isOfType<std::shared_ptr<AnotherClass>, haxe::_class<AnotherClass>>(another, haxe::_class<AnotherClass>()), haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 53, "main"));
	
	std::optional<int> a = std::nullopt;
	
	Main::assert(Std::string<std::optional<int>>(a) == "null", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 57, "main"));
	a = 123;
	Main::assert(Std::string<std::optional<int>>(a) == "123", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 60, "main"));
	Main::assert(Std::string<haxe::_class<Main>>(haxe::_class<Main>()) == "Class<Main>", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 62, "main"));
	Main::assert(Std::string<haxe::_class<Std>>(haxe::_class<Std>()) == "Class<Std>", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 63, "main"));
	Main::assert(Std::string<std::shared_ptr<AnotherClass>>(another) == "another class as string", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 65, "main"));
	Main::assert(Std::string<std::shared_ptr<AnotherClass>>(another) == another->toString(), haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 66, "main"));
	
	AnotherClass anotherVal = AnotherClass();
	
	Main::assert(Std::string<AnotherClass>(anotherVal) == anotherVal.toString(), haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 69, "main"));
	Main::assert(Std::string<std::shared_ptr<BaseClass>>(base) == "<unknown(size:1)>", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 71, "main"));
	
	BaseClass baseVal = BaseClass();
	
	Main::assert(Std::string<BaseClass>(baseVal) == "<unknown(size:1)>", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 74, "main"));
	
	ClassWInt numVal = ClassWInt();
	
	Main::assert(Std::string<ClassWInt>(numVal) == "<unknown(size:" + std::to_string(sizeof(numVal)) + ")>", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 77, "main"));
	Main::assert(4 == 4, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 80, "main"));
	Main::assert(0 == 0, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 81, "main"));
	Main::assert(0 == 0, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 82, "main"));
	Main::assert(1 == 1, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 83, "main"));
	Main::assert(Std::parseInt("0") == 0, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 86, "main"));
	Main::assert(Std::parseInt("123") == 123, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 87, "main"));
	Main::assert(!Std::parseInt("number!").has_value(), haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 88, "main"));
	Main::assert(Std::parseInt("1").has_value(), haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 89, "main"));
	Main::assertFloat(Std::parseFloat("1.1"), 1.1, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 92, "main"));
	Main::assertFloat(Std::parseFloat("2.0"), 2.0, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 93, "main"));
	Main::assertFloat(Std::parseFloat("0.5"), 0.5, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 94, "main"));
	Main::assertFloat(Std::parseFloat("0.0001"), 0.0001, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 95, "main"));
	Main::assert(std::isnan(Std::parseFloat("another number!")), haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 96, "main"));
	Main::assert(!std::isnan(Std::parseFloat("0")), haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 97, "main"));
	
	int _g = 0;
	
	while(_g < 1000) {
		int i = _g++;
		int tempNumber;
		if(10 <= 1) {
			tempNumber = 0;
		} else {
			tempNumber = floor((((float)rand()) / RAND_MAX) * 10);
		};
		int v = tempNumber;
		Main::assert(v >= 0 && v < 10, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Std/Main.hx", 103, "main"));
	};
	
	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
