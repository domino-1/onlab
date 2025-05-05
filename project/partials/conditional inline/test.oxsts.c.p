tran main { 
	inline NAME1()
	inline NAME1()
	inline NAME2()
	a := 1 
}
tran NAME1() { 
	b := 2
	inline NAME3()
	c := 3
}
tran NAME2() { 
	havoc(c)
}
tran NAME3() { 
	inline NAME4()
	assume(true)
}
tran NAME4() {
	d := true
	e := false
}