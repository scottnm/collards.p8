-- test.p8: test cart

function _init()
    g_frame = 0
    run_tests()
end

function _update()
    g_frame += 1
    if g_frame >= 60 then
        extcmd("shutdown")
    end
end

function _draw()
    cls(0)
    print("Frame: "..g_frame)
end

-- math tests

-- here's an object with methods we want to test
local math={
  gt=function(a,b) return a>b end,
  lt=function(a,b) return a<b end,
  mul=function(a,b) return a*b end,
  div=function(a,b) return a/b end
}

function run_tests()
    test('math functions', function(desc,it)
        desc('math.gt()', function()
            local gt = math.gt
            it('should return type boolean', function()
                return 'boolean' == type(gt(1,0))
            end)
            it('should give same result as > operator', function()
                return gt(1,0)
            end)
        end)

        desc('math.lt()', function()
            local lt = math.lt
                it('should return type boolean',function()
                return 'boolean' == type(lt(1,0))
            end)
                it('should give same result as < operator',function()
                return lt(1, 0) == false
            end)
        end)

        desc('math.mul()', function()
            local mul = math.mul
            it('should return type number', function()
                local a = rnd(time())
                local b = rnd(time())
                return 'number' == type(mul(a,b))
            end)
            it('should give same result as * operator', function()
                local x=rnd(time())
                return x*1 == mul(x,1),
                       x*2 == mul(x,2),
                       x*3 == mul(x,3)
            end)
        end)

        desc('math.div()', function()
            local div = math.div
            it('should return type number', function()
                local a = rnd(time())
                local b = rnd(time())
                return 'number' == type(div(a,b))
            end)
            it('should give same result as / operator', function()
                local x=1+rnd(time())
                return x/1 == div(x,1),
                       x/2 == div(x,2),
                       x/3 == div(x,3)
            end)
        end)
    end)
end
