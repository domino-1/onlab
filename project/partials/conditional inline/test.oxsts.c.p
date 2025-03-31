tran main { 
	inline NAME1()
	inline NAME1()
	inline NAME2()
	REST
}
tran NAME1() { 
	REST
	inline NAME3()
	REST
}
tran NAME2() { 
	REST 
}
tran NAME3() { 
	inline NAME4()
	REST
}
tran NAME4() {
	REST
	REST
}