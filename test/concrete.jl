@testset "import" begin
    sys = pyimport("sys")
    os = pyimport("os")
    @test pyeq(Bool, sys.__name__, "sys")
    @test pyeq(Bool, os.__name__, "os")
    sysos = pyimport("sys", "os")
    @test sysos isa Tuple{Py, Py}
    @test pyis(sysos[1], sys)
    @test pyis(sysos[2], os)
    ver = pyimport("sys" => "version")
    @test pyis(ver, sys.version)
    path = pyimport("sys" => "path")
    @test pyis(path, sys.path)
    verpath = pyimport("sys" => ("version", "path"))
    @test verpath isa Tuple{Py, Py}
    @test pyis(verpath[1], ver)
    @test pyis(verpath[2], path)
end

@testset "consts" begin
    @test pybuiltins.None isa Py
    @test pystr(String, pybuiltins.None) == "None"
end

@testset "str" begin
    @test pyisinstance(pystr("foo"), pybuiltins.str)
    @test pyeq(Bool, pystr(pystr("foo")), pystr("foo"))
    @test pyeq(Bool, pystr(SubString("foobarbaz", 4:6)), pystr("bar"))
    @test pyeq(Bool, pystr('x'), pystr("x"))
    @test pystr(String, pybuiltins.None) === "None"
    @test pystr(String, pyint(123)) === "123"
    @test pystr(String, pystr("foo")) === "foo"
end

@testset "bytes" begin
    @test pyisinstance(pybytes(UInt8[1,2,3]), pybuiltins.bytes)
    @test pyeq(Bool, pybytes(pylist([1,2,3])), pybytes(UInt8[1,2,3]))
    @test pyeq(Bool, pybytes(b"foo"), pystr("foo").encode("ascii"))
    @test pyeq(Bool, pybytes(codeunits(SubString("foobarbaz", 4:6))), pystr("bar").encode("ascii"))
    @test pybytes(Vector, pylist([1,2,3])) == UInt8[1,2,3]
    @test pybytes(Vector{UInt8}, pylist([1,2,3])) == UInt8[1,2,3]
    @test pybytes(Base.CodeUnits, pystr("foo").encode("ascii")) == b"foo"
    @test pybytes(Base.CodeUnits{UInt8,String}, pystr("bar").encode("ascii")) == b"bar"
end

@testset "tuple" begin
    z = pytuple()
    @test pyisinstance(z, pybuiltins.tuple)
    @test pylen(z) == 0
    x = pytuple((1,2,3))
    @test pyisinstance(x, pybuiltins.tuple)
    @test pylen(x) == 3
    @test pyeq(Bool, pygetitem(x, 0), 1)
    @test pyeq(Bool, pygetitem(x, 1), 2)
    @test pyeq(Bool, pygetitem(x, 2), 3)
    @test pyeq(Bool, pytuple([1,2,3]), x)
    @test pyeq(Bool, pytuple(i+1 for i in 0:10 if i<3), x)
    @test pyeq(Bool, pytuple(pytuple((1,2,3))), x)
    @test pyeq(Bool, pytuple(pylist([1,2,3])), x)
end

@testset "list" begin
    z = pylist()
    @test pyisinstance(z, pybuiltins.list)
    @test pylen(z) == 0
    x = pylist((1,2,3))
    @test pyisinstance(x, pybuiltins.list)
    @test pylen(x) == 3
    @test pyeq(Bool, pygetitem(x, 0), 1)
    @test pyeq(Bool, pygetitem(x, 1), 2)
    @test pyeq(Bool, pygetitem(x, 2), 3)
    @test pyeq(Bool, pylist([1,2,3]), x)
    @test pyeq(Bool, pylist(i+1 for i in 0:10 if i<3), x)
    @test pyeq(Bool, pylist(pylist((1,2,3))), x)
    @test pyeq(Bool, pylist(pytuple([1,2,3])), x)
    @test pyeq(Bool, pycollist([1,2,3]), pylist([1,2,3]))
    @test pyeq(Bool, pycollist([1 2; 3 4]), pylist((pylist([1,3]), pylist([2,4]))))
    @test pyeq(Bool, pyrowlist([1,2,3]), pylist([1,2,3]))
    @test pyeq(Bool, pyrowlist([1 2; 3 4]), pylist((pylist([1,2]), pylist([3,4]))))
end

@testset "dict" begin
    z = pydict()
    @test pyisinstance(z, pybuiltins.dict)
    @test pylen(z) == 0
    x = pydict(foo=1, bar=2)
    @test pyisinstance(x, pybuiltins.dict)
    @test pylen(x) == 2
    @test pyeq(Bool, pygetitem(x, "foo"), 1)
    @test pyeq(Bool, pygetitem(x, "bar"), 2)
    @test pyeq(Bool, pydict(["foo"=>1, "bar"=>2]), x)
    @test pyeq(Bool, pydict([("foo"=>1), ("bar"=>2)]), x)
    @test pyeq(Bool, pydict(Dict("foo"=>1, "bar"=>2)), x)
    @test pyeq(Bool, pydict((foo=1, bar=2)), x)
    @test pyeq(Bool, pydict(x), x)
end

@testset "bool" begin
    @test pyis(pybool(), pybuiltins.False)
    @test pyis(pybool(false), pybuiltins.False)
    @test pyis(pybool(true), pybuiltins.True)
    @test pyis(pybool(0.0), pybuiltins.False)
    @test pyis(pybool(-1.2), pybuiltins.True)
    @test pyis(pybool(pybuiltins.None), pybuiltins.False)
    @test pyis(pybool(pylist()), pybuiltins.False)
    @test pyis(pybool(pylist([1,2,3])), pybuiltins.True)
end

@testset "int" begin
    @test pyisinstance(pyint(), pybuiltins.int)
    @test pystr(String, pyint()) == "0"
    x = 123
    y = pyint(x)
    @test pyisinstance(y, pybuiltins.int)
    @test pystr(String, y) == string(x)
    x = BigInt(123) << 200
    y = pyint(x)
    @test pyisinstance(y, pybuiltins.int)
    @test pystr(String, y) == string(x)
    x = UInt(123)
    y = pyint(x)
    @test pyisinstance(y, pybuiltins.int)
    @test pystr(String, y) == string(x)
    x = UInt128(123) << 100
    y = pyint(x)
    @test pyisinstance(y, pybuiltins.int)
    @test pystr(String, y) == string(x)
    @test pyeq(Bool, pyint(pyint(123)), pyint(123))
    @test pyeq(Bool, pyint(pyfloat(12.3)), pyint(12))
end

@testset "float" begin
    y = pyfloat()
    @test pyisinstance(y, pybuiltins.float)
    @test pyeq(Bool, y, pyint(0))
    x = 123
    y = pyfloat(x)
    @test pyisinstance(y, pybuiltins.float)
    @test pyeq(Bool, y, pyint(x))
    x = 0.25
    y = pyfloat(x)
    @test pyisinstance(y, pybuiltins.float)
    @test pyeq(Bool, y, pytruediv(1, 4))
    x = 1//4
    y = pyfloat(x)
    @test pyisinstance(y, pybuiltins.float)
    @test pyeq(Bool, y, pyfloat(float(x)))
    @test pyeq(Bool, pyfloat(pyfloat(12.3)), pyfloat(12.3))
    @test pyeq(Bool, pyfloat(pyint(123)), pyfloat(123))
end

@testset "complex" begin
    y = pycomplex()
    @test pyisinstance(y, pybuiltins.complex)
    @test pyeq(Bool, y, pyint(0))
    x = 12.3
    y = pycomplex(x)
    @test pyisinstance(y, pybuiltins.complex)
    @test pyeq(Bool, y, pyfloat(x))
    xr, xi = 12, 34
    y = pycomplex(xr, xi)
    @test pyisinstance(y, pybuiltins.complex)
    @test pyeq(Bool, y.real, pyfloat(xr))
    @test pyeq(Bool, y.imag, pyfloat(xi))
    x = Complex(12, 34)
    y = pycomplex(x)
    @test pyisinstance(y, pybuiltins.complex)
    @test pyeq(Bool, y.real, pyfloat(real(x)))
    @test pyeq(Bool, y.imag, pyfloat(imag(x)))
    @test pyeq(Bool, pycomplex(y), y)
    @test pyeq(Bool, pycomplex(pyint(12), pyint(34)), y)
end

@testset "set" begin
    y = pyset()
    yf = pyfrozenset()
    @test pyisinstance(y, pybuiltins.set)
    @test pylen(y) == 0
    @test pyisinstance(yf, pybuiltins.frozenset)
    @test pylen(yf) == 0
    @test pyeq(Bool, y, yf)
    x = [1,2,3,2,1]
    y = pyset(x)
    yf = pyfrozenset(x)
    @test pyisinstance(y, pybuiltins.set)
    @test pylen(y) == 3
    @test pycontains(y, 1)
    @test pycontains(y, 2)
    @test pycontains(y, 3)
    @test pyeq(Bool, pyset(y), y)
    @test pyisinstance(yf, pybuiltins.frozenset)
    @test pylen(yf) == 3
    @test pycontains(yf, 1)
    @test pycontains(yf, 2)
    @test pycontains(yf, 3)
    @test pyeq(Bool, pyfrozenset(y), y)
    @test pyeq(Bool, y, yf)
end

@testset "slice" begin
    x = pyslice(12)
    @test pyisinstance(x, pybuiltins.slice)
    @test pyeq(Bool, x.start, pybuiltins.None)
    @test pyeq(Bool, x.stop, 12)
    @test pyeq(Bool, x.step, pybuiltins.None)
    x = pyslice(12, 34)
    @test pyisinstance(x, pybuiltins.slice)
    @test pyeq(Bool, x.start, 12)
    @test pyeq(Bool, x.stop, 34)
    @test pyeq(Bool, x.step, pybuiltins.None)
    x = pyslice(12, 34, 56)
    @test pyisinstance(x, pybuiltins.slice)
    @test pyeq(Bool, x.start, 12)
    @test pyeq(Bool, x.stop, 34)
    @test pyeq(Bool, x.step, 56)
end

@testset "range" begin
    x = pyrange(123)
    @test pyisinstance(x, pybuiltins.range)
    @test pyeq(Bool, x.start, 0)
    @test pyeq(Bool, x.stop, 123)
    @test pyeq(Bool, x.step, 1)
    x = pyrange(12, 123)
    @test pyisinstance(x, pybuiltins.range)
    @test pyeq(Bool, x.start, 12)
    @test pyeq(Bool, x.stop, 123)
    @test pyeq(Bool, x.step, 1)
    x = pyrange(12, 123, 3)
    @test pyisinstance(x, pybuiltins.range)
    @test pyeq(Bool, x.start, 12)
    @test pyeq(Bool, x.stop, 123)
    @test pyeq(Bool, x.step, 3)
end

@testset "none" begin
end

@testset "type" begin
    x = pytype(pyint())
    @test pyisinstance(x, pybuiltins.type)
    @test pyis(x, pybuiltins.int)
    x = pytype(pybuiltins.type)
    @test pyisinstance(x, pybuiltins.type)
    @test pyis(x, pybuiltins.type)
    x = pytype("Foo", (), (foo=1, bar=2))
    @test pyisinstance(x, pybuiltins.type)
    @test pyeq(Bool, x.__name__, "Foo")
    @test pyeq(Bool, x.foo, 1)
    @test pyeq(Bool, x.bar, 2)
    x = pyclass("Bar", (), foo=3, bar=4)
    @test pyisinstance(x, pybuiltins.type)
    @test pyeq(Bool, x.__name__, "Bar")
    @test pyeq(Bool, x.foo, 3)
    @test pyeq(Bool, x.bar, 4)
end

@testset "fraction" begin
    # TODO
end

@testset "method" begin
    # TODO
end

@testset "datetime" begin
    # TODO
end

@testset "code" begin
    # TODO
end
